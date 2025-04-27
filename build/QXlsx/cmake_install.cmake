# Install script for directory: E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/SparkExamAI")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/QXlsxQt5.lib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/QXlsxQt5" TYPE FILE FILES
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxabstractooxmlfile.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxabstractsheet.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxabstractsheet_p.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxcellformula.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxcell.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxcelllocation.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxcellrange.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxcellreference.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxchart.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxchartsheet.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxconditionalformatting.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxdatavalidation.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxdatetype.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxdocument.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxformat.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxglobal.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxrichstring.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxworkbook.h"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/QXlsx/header/xlsxworksheet.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "devel" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5/QXlsxQt5Targets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5/QXlsxQt5Targets.cmake"
         "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/CMakeFiles/Export/9160ef171b5927dbe66bf41de9e1c9c5/QXlsxQt5Targets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5/QXlsxQt5Targets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5/QXlsxQt5Targets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5" TYPE FILE FILES "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/CMakeFiles/Export/9160ef171b5927dbe66bf41de9e1c9c5/QXlsxQt5Targets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5" TYPE FILE FILES "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/CMakeFiles/Export/9160ef171b5927dbe66bf41de9e1c9c5/QXlsxQt5Targets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/QXlsxQt5" TYPE FILE FILES
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/QXlsxQt5Config.cmake"
    "E:/SparkExamAI/SparkExamAI/SparkExamAI/build/QXlsx/QXlsxQt5ConfigVersion.cmake"
    )
endif()

