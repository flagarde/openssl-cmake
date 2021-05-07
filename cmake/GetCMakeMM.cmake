include_guard(GLOBAL)

function(cmmm)
  cmake_parse_arguments(CMMM "NO_COLOR" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;REPOSITORY;PROVIDER" "" "${ARGN}")

  if(NOT DEFINED CMMM_VERSION)
    set(CMMM_TAG "main")
  elseif(CMMM_VERSION STREQUAL "main")
    set(CMMM_TAG "${CMMM_VERSION}")
  else()
    set(CMMM_TAG "v${CMMM_VERSION}")
  endif()

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_BINARY_DIR}")
  endif()
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT "5")
  endif()

  if(NOT DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT "10")
  endif()

  string(ASCII 27 Esc)

  if(NOT DEFINED CMMM_REPOSITORY)
    set(CMMM_REPOSITORY "flagarde/CMakeMM")
  endif()

  if(NOT DEFINED CMMM_PROVIDER OR CMMM_PROVIDER STREQUAL "github")
    set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_REPOSITORY}")
  elseif("${CMMM_PROVIDER}" STREQUAL "gitlab")
    set(CMMM_URL "https://gitlab.com/${CMMM_REPOSITORY}/-/raw")
  elseif("${CMMM_PROVIDER}" STREQUAL "gitee")
    set(CMMM_URL "https://gitee.com/${CMMM_REPOSITORY}/raw")
  else()
    if(CMMM_NO_COLOR OR WIN32)
      message("## [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fallback to \"github\" ##")
    else()
      message("${Esc}[1;33m## [CMakeMM] Provider \"${CMMM_PROVIDER}\" unknown. Fallback to \"github\" ##${Esc}[m")
    endif()
    set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_REPOSITORY}")
  endif()

  if(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")

    if(CMMM_NO_COLOR OR WIN32)
      message("-- [CMakeMM] Downloading CMakeMM (${CMMM_TAG}) from ${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake --")
    else()
      message("${Esc}[1;35m-- [CMakeMM] Downloading CMakeMM (${CMMM_TAG}) from ${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake --${Esc}[m")
    endif()

    file(DOWNLOAD "${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" INACTIVITY_TIMEOUT "${CMMM_INACTIVITY_TIMEOUT}" LOG LOG_ STATUS CMAKECM_STATUS TIMEOUT "${CMMM_TIMEOUT}")
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      if(CMMM_NO_COLOR OR WIN32)
        message(FATAL_ERROR "[CMakeMM] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE}")
      else()
        message(FATAL_ERROR "${Esc}[1;31m [CMakeMM] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE}${Esc}[m")
      endif()
    endif()

  endif()

  include("${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")

  set(ARGN "URL;${CMMM_URL};DESTINATION;${CMMM_DESTINATION};INACTIVITY_TIMEOUT;${CMMM_INACTIVITY_TIMEOUT};TIMEOUT;${CMMM_TIMEOUT};TAG;${CMMM_TAG};${ARGN}")
  list(REMOVE_DUPLICATES ARGN)

  cmmm_entry("${ARGN}")

endfunction()
