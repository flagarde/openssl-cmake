cmake_minimum_required(VERSION 3.15...3.20.2)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GetCMakeMM)
cmmm(VERSION "2.0" REPOSITORY "flagarde/CMakeMM" PROVIDER "gitlab" VERBOSITY VERBOSE)

cmmm_modules_list(REPOSITORY "flagarde/CMakeCM" PROVIDER "gitlab")

project(openssl-cmake VERSION "2.1" LANGUAGES C CXX DESCRIPTION "CMake to compile OpenSSL" HOMEPAGE_URL "https://github.com/flagarde/openssl-cmake")

include(CPM)
cpm()

if(NOT DEFINED OPENSSL_VERSION)
  set(OPENSSL_VERSION "1.1.1k")  
endif()

if(NOT DEFINED OPENSSL_URL)
  set(OPENSSL_URL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz")
endif()

if(NOT DEFINED OPENSSL_URL_HASH)
  set(OPENSSL_URL_HASH "SHA256=892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5")
endif()

if(NOT DEFINED WITH_APPS)
  option( WITH_APPS "Build applications" ON)
endif()

if(NOT DEFINED WITH_DOCS)
  option( WITH_DOCS  "Install docs" ON)
endif()

if(NOT DEFINED WITH_TESTS)
  option( WITH_TESTS  "Build tests" ON)
endif()

include(PreventInSourceBuilds)
prevent_in_source_builds()

CPMAddPackage(NAME OpenSSL
              VERSION "${OPENSSL_VERSION}"
              URL "${OPENSSL_URL}"
              URL_HASH "${OPENSSL_URL_HASH}"
              DOWNLOAD_ONLY TRUE
              FETCHCONTENT_UPDATES_DISCONNECTED "${IS_OFFLINE}")

if(OpenSSL_ADDED)
  file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/patchs/" DESTINATION "${OpenSSL_SOURCE_DIR}/")
  add_subdirectory("${OpenSSL_SOURCE_DIR}" "${OpenSSL_BINARY_DIR}")
endif()

if(WITH_TESTS)
  include(CTest)
  add_subdirectory(tests)
endif()
