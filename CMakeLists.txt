cmake_minimum_required(VERSION 3.14)

project(SparkExamAI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加OpenCV
set(OpenCV_DIR "C:/OpenCV4.5.2/x64/mingw/lib")
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# 添加SeetaFace2
set(SEETA_FACE_PATH "C:/SeetaFace2")
include_directories(${SEETA_FACE_PATH}/include)
link_directories(${SEETA_FACE_PATH}/lib)

# 查找SeetaFace2库文件 - 使用正确的库名称
find_library(SEETA_FACEDETECTOR libSeetaFaceDetector ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACELANDMARKER libSeetaFaceLandmarker ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACERECOGNIZER libSeetaFaceRecognizer ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACETRACKER libSeetaFaceTracker ${SEETA_FACE_PATH}/lib)
find_library(SEETA_NET libSeetaNet ${SEETA_FACE_PATH}/lib)

message(STATUS "SeetaFaceDetector: ${SEETA_FACEDETECTOR}")
message(STATUS "SeetaFaceLandmarker: ${SEETA_FACELANDMARKER}")
message(STATUS "SeetaFaceRecognizer: ${SEETA_FACERECOGNIZER}")
message(STATUS "SeetaFaceTracker: ${SEETA_FACETRACKER}")
message(STATUS "SeetaNet: ${SEETA_NET}")

# 查找Qt模块
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Sql Multimedia MultimediaWidgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Sql Multimedia MultimediaWidgets)

set(PROJECT_SOURCES
        main.cpp
        qml.qrc
        FileManager.cpp
        FileManager.h
        DatabaseManager.cpp
        DatabaseManager.h
        FaceRecognizer.cpp
        FaceRecognizer.h
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(SparkExamAI
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET SparkExamAI APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(SparkExamAI SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(SparkExamAI
          ${PROJECT_SOURCES}
        )
    endif()
endif()

# 使用Qt库和OpenCV库
target_link_libraries(SparkExamAI
  PRIVATE Qt${QT_VERSION_MAJOR}::Core 
  Qt${QT_VERSION_MAJOR}::Quick 
  Qt${QT_VERSION_MAJOR}::Sql
  Qt${QT_VERSION_MAJOR}::Multimedia
  Qt${QT_VERSION_MAJOR}::MultimediaWidgets
  ${OpenCV_LIBS}
)

# 添加QXlsx库
add_subdirectory(QXlsx)  #添加
target_link_libraries(SparkExamAI PRIVATE QXlsx::QXlsx)

# 直接使用 libSeetaXXX.dll.a 文件进行链接
target_link_libraries(SparkExamAI PRIVATE
  ${SEETA_FACE_PATH}/lib/libSeetaFaceDetector.dll.a
  ${SEETA_FACE_PATH}/lib/libSeetaFaceLandmarker.dll.a
  ${SEETA_FACE_PATH}/lib/libSeetaFaceRecognizer.dll.a
  ${SEETA_FACE_PATH}/lib/libSeetaFaceTracker.dll.a
  ${SEETA_FACE_PATH}/lib/libSeetaNet.dll.a
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SparkExamAI)
endif()
set_target_properties(SparkExamAI PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 复制运行时依赖库
if(WIN32)
  # 确保目标目录存在
  file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
  
  # 复制 SeetaFace2 DLL
  file(GLOB SEETA_DLLS "${SEETA_FACE_PATH}/bin/libSeeta*.dll")
  message(STATUS "SeetaFace2 DLLs: ${SEETA_DLLS}")
  
  add_custom_command(TARGET SparkExamAI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:SparkExamAI>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${SEETA_DLLS}
      $<TARGET_FILE_DIR:SparkExamAI>
  )
  
  # 复制 OpenCV DLL
  file(GLOB OPENCV_DLLS "C:/OpenCV4.5.2/x64/mingw/bin/libopencv_*.dll")
  message(STATUS "OpenCV DLLs: ${OPENCV_DLLS}")
  
  add_custom_command(TARGET SparkExamAI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${OPENCV_DLLS}
      $<TARGET_FILE_DIR:SparkExamAI>
  )
endif()

include(GNUInstallDirs)
install(TARGETS SparkExamAI
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(SparkExamAI)
    qt_finalize_executable(SparkExamAI)
endif()
