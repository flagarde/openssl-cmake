# Redistribution and use of this file is allowed according to the terms of the
# MIT license.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
cmake_minimum_required(VERSION 3.15...3.19.7)

project(OpenSSL VERSION "1.0.0" LANGUAGES CXX DESCRIPTION "CMake to compile OpenSSL" HOMEPAGE_URL "https://github.com/flagarde/openssl-cmake")

if(OPENSSL_VER)
  string(REPLACE "." "_" OPENSSL_TAG ${OPENSSL_VER})
else()
   set(OPENSSL_TAG "1_1_1j" CACHE STRING "Version the OpenSSL to download")
endif()
set(OPENSSL_URL "https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_TAG}.zip" CACHE STRING "URL of the OpenSSL depot")

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed")
endif()

message(STATUS "${CMAKE_INSTALL_PREFIX}")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/openssl-${OPENSSL_TAG}" CACHE PATH "Default Install Prefix" FORCE)
  message(STATUS "Install Prefix set to : ${CMAKE_INSTALL_PREFIX}")
endif()

option( WITH_APPS "Build applications" ON )
option( WITH_DOCS  "Install docs" ON )

set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

include(ExternalProject)
# ----- OpenSSL package -----
ExternalProject_Add(OpenSSL
                    URL ${OPENSSL_URL}
                    PREFIX ${CMAKE_BINARY_DIR}
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
                    LOG_DOWNLOAD ON
                    CMAKE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DWITH_APPS=${WITH_APPS} -DWITH_DOCS=${WITH_DOCS}
                    PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory "${PROJECT_SOURCE_DIR}/patch" "${CMAKE_BINARY_DIR}/src/OpenSSL"
                   )

add_executable(Dumb ./Dumb.cpp)
add_dependencies(Dumb OpenSSL)
install(TARGETS Dumb DESTINATION ${CMAKE_BINARY_DIR})
