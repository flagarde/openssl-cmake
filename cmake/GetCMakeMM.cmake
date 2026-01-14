#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2025 flagarde
#
# SPDX-License-Identifier: MIT
#

#[=======================================================================[.rst:
cmmm
----

Download and configure CMakeMM

.. code-block:: cmake

  cmmm([NO_CHANGELOG] [NO_COLOR] [SHOW_PROGRESS] [VERSION <version>] [DESTINATION <path>] [INACTIVITY_TIMEOUT <seconds>] [TIMEOUT <seconds>] [TLS_VERIFY <ON|OFF>] [TLS_CAINFO <file>] [RETRIES <number/INFINITY>])

Options
^^^^^^^

The options are:

``NO_CHANGELOG``
  **Optional** Disable changelog printing.

``NO_COLOR``
  **Optional** Disable the color on terminal.

``SHOW_PROGRESS``
  **Optional** Print progress information as status messages until the operation is complete.

``VERSION <version>``
  **Optional** Version of CMakeMM to download (use one of the versions in https://github.com/cmake-tools/cmmm/releases or 'latest' for the last version. Only for testing !).

``DESTINATION <path>``
  **Optional** Path destination to install CMakeMM.

``INACTIVITY_TIMEOUT <seconds>``
  **Optional** Terminate the operation after a period of inactivity.

``TIMEOUT <seconds>``
  **Optional** Terminate the operation after a given total time has elapsed.

``TLS_VERIFY <ON|OFF>``
  **Optional** Specify whether to verify the server certificate for ``https://`` URLs.
  The default is to *not* verify. If this option is not specified, the value of the `CMAKE_TLS_VERIFY <https://cmake.org/cmake/help/latest/variable/CMAKE_TLS_VERIFY.html>`_ variable will be used instead.

``TLS_CAINFO <file>``
  **Optional** Specify a custom Certificate Authority file for ``https://`` URLs.
  If this option is not specified, the value of the `CMAKE_TLS_CAINFO <https://cmake.org/cmake/help/latest/variable/CMAKE_TLS_CAINFO.html>`_ variable will be used instead.

``RETRIES <number/INFINITY>``
  **Optional** Specify the number of retries if download fails.

#]=======================================================================]

# cmake-format: off
if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

set(GETCMMM_FILE_VERSION "1.0.0")

if((NOT "${GETCMMM_FILE_VERSION}" VERSION_GREATER "${CURRENT_GETCMMM_FILE_VERSION}") AND COMMAND cmmm)
  return()
endif()

set(CURRENT_GETCMMM_FILE_VERSION "${GETCMMM_FILE_VERSION}" CACHE INTERNAL "GetCMakeMM version.")
unset(GETCMMM_FILE_VERSION)

# Setup and download CMakeMM
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()

  cmake_parse_arguments(CMMM "NO_COLOR;SHOW_PROGRESS" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO;RETRIES" "" "${ARGN}")

  if(CMAKE_VERSION VERSION_GREATER 3.23.9)
    cmake_host_system_information(RESULT ARG_DEFAULT_VALUE QUERY WINDOWS_REGISTRY "HKCU/Console" VALUE "VirtualTerminalLevel")
  endif()
  if(WIN32 AND NOT ARG_DEFAULT_VALUE)
    set(CMMM_NO_COLOR TRUE)
  else()
    set(CMMM_NO_COLOR FALSE)
  endif()
  if(DEFINED ENV{CLICOLOR_FORCE} AND NOT "$ENV{CLICOLOR_FORCE}" STREQUAL "0")
    set(CMMM_NO_COLOR FALSE)
  elseif(DEFINED ENV{CLICOLOR} AND "$ENV{CLICOLOR}" STREQUAL "0")
    set(CMMM_NO_COLOR TRUE)
  elseif(DEFINED ENV{CI} AND NOT CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  elseif("$ENV{TERM_PROGRAM}" STREQUAL "vscode" AND NOT CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  elseif(DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot} OR DEFINED ENV{VSCODE_CLI} OR CMMM_NO_COLOR)
    set(CMMM_NO_COLOR TRUE)
  endif()

  if(NOT CMMM_NO_COLOR)
    set(CMMM_DEFAULT_COLORS "default=0;35:fatal_error=1;31:error=0;31:warn=0;33:info=0;32")
    if(DEFINED ENV{CMMM_COLORS})
      string(REPLACE ";" "." CMMM_COLORS "$ENV{CMMM_COLORS}")
      string(REPLACE ":" ";" CMMM_COLORS "${CMMM_COLORS}")
      string(REPLACE "=" ";" CMMM_COLORS "${CMMM_COLORS}")
    elseif(DEFINED CMMM_COLORS)
      string(REPLACE ";" "." CMMM_COLORS "${CMMM_COLORS}")
      string(REPLACE ":" ";" CMMM_COLORS "${CMMM_COLORS}")
      string(REPLACE "=" ";" CMMM_COLORS "${CMMM_COLORS}")
    endif()
    string(REPLACE ";" "." CMMM_DEFAULT_COLORS "${CMMM_DEFAULT_COLORS}")
    string(REPLACE ":" ";" CMMM_DEFAULT_COLORS "${CMMM_DEFAULT_COLORS}")
    string(REPLACE "=" ";" CMMM_DEFAULT_COLORS "${CMMM_DEFAULT_COLORS}")

    set(COLOR_TYPES "default;fatal_error;error;warn;info")
    cmake_parse_arguments(GIVEN "" "${COLOR_TYPES}" "" "${CMMM_COLORS}")
    cmake_parse_arguments(DEFAULT "" "${COLOR_TYPES}" "" "${CMMM_DEFAULT_COLORS}")
    foreach(COLOR_TYPE IN LISTS COLOR_TYPES)
      string(TOUPPER "CMMM_${COLOR_TYPE}_COLOR" CMMM_TYPE_COLOR)
      if(DEFINED GIVEN_${COLOR_TYPE})
        string(REPLACE "." ";" GIVEN_${COLOR_TYPE} "${GIVEN_${COLOR_TYPE}}")
        set(${CMMM_TYPE_COLOR} "[${GIVEN_${COLOR_TYPE}}m")
      else()
        string(REPLACE "." ";" DEFAULT_${COLOR_TYPE} "${DEFAULT_${COLOR_TYPE}}")
        set(${CMMM_TYPE_COLOR} "[${DEFAULT_${COLOR_TYPE}}m")
      endif()
    endforeach()
    string(ASCII 27 CMMM_ESC)
    set(CMMM_RESET_COLOR "[0m")
  endif()

  if(NOT DEFINED CMMM_VERSION OR CMMM_VERSION STREQUAL "latest")
    set(CMMM_URL "https://cmake-tools.github.io/cmmm")
    set(CMMM_TAG "latest")
  else()
    set(CMMM_URL "https://github.com/cmake-tools/cmmm/releases/download")
    set(CMMM_TAG "v${CMMM_VERSION}")
  endif()

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/cmmm")
  endif()
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION}")

  set(ARGN "${ARGN};TAG;${CMMM_TAG};DESTINATION;${CMMM_DESTINATION}")

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock" RELEASE)
    endif()
  endfunction()

  set(CMMM_COMMAND "")
  set(ARGUMENTS "")
  list(APPEND ARGUMENTS INACTIVITY_TIMEOUT TIMEOUT TLS_VERIFY TLS_CAINFO)
  foreach(ARG IN LISTS ARGUMENTS)
    if(DEFINED CMMM_${ARG})
      if(NOT "${CMMM_COMMAND}" STREQUAL "")
        set(CMMM_COMMAND "${CMMM_COMMAND};${ARG};${CMMM_${ARG}}")
      else()
        set(CMMM_COMMAND "${ARG};${CMMM_${ARG}}")
      endif()
    endif()
  endforeach()

  if(CMMM_SHOW_PROGRESS)
    set(CMMM_COMMAND "${CMMM_COMMAND};SHOW_PROGRESS")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock")
  endif()

  if(NOT DEFINED CMMM_RETRIES)
    set(CMMM_RETRIES "0")
  endif()
  set(ARGN "${ARGN};RETRIES;${CMMM_RETRIES}")

  if(EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
    file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
  endif()

  set(CMMM_EMPTY_FILE_SHA256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  set(CMMM_RETRIES_DONE "0")
  if(NOT "${CMMM_FETCHED_VERSION}" STREQUAL "${CMMM_VERSION}")
    while(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" OR "${CMakeMMSHA256}" STREQUAL "${CMMM_EMPTY_FILE_SHA256}")

      if(${CMMM_RETRIES_DONE} STREQUAL "0")
        message(STATUS "${CMMM_ESC}${CMMM_DEFAULT_COLOR}[cmmm] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake${CMMM_ESC}${CMMM_RESET_COLOR}")
      else()
        message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[cmmm] Retry downloading CMakeMM.cmake (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_ESC}${CMMM_RESET_COLOR}")
      endif()

      file(DOWNLOAD "${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" ${CMMM_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS)
      list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
      list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
      if(NOT "${CMAKECM_CODE}" STREQUAL "0")
        message(STATUS "${CMMM_ESC}${CMMM_ERROR_COLOR}[cmmm] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${CMMM_ESC}${CMMM_RESET_COLOR}")
      else()
        file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
        if(${CMakeMMSHA256} STREQUAL "${CMMM_EMPTY_FILE_SHA256}")
          file(REMOVE "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
          message(STATUS "${CMMM_ESC}${CMMM_ERROR_COLOR}[cmmm] Error downloading CMakeMM.cmake : Empty file.${CMMM_ESC}${CMMM_RESET_COLOR}")
        else()
          break()
        endif()
      endif()
      if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
        unlock()
        message(STATUS "${CMMM_ESC}${CMMM_FATAL_ERROR_COLOR}[cmmm] Error downloading CMakeMM.cmake.${CMMM_ESC}${CMMM_RESET_COLOR}")
        message(FATAL_ERROR "Error downloading CMakeMM.cmake.")
      endif()
      math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
    endwhile()

    include("${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
  else()
    configure_file("${cmmm_SOURCE_DIR}/cmake/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-v${CMMM_FETCHED_VERSION}.cmake" COPYONLY)
    include("${CMMM_DESTINATION}/CMakeMM-v${CMMM_FETCHED_VERSION}.cmake")
  endif()
  cmmm_entry(${ARGN})
  unlock()

endfunction()
# cmake-format: on
