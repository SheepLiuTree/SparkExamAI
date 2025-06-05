cmake_minimum_required(VERSION 3.14)

project(SparkExamAI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# MSVC编译器特定选项
if(MSVC)
    add_compile_options(/Zc:__cplusplus)
    # 设置Qt MSVC版本的路径
    set(CMAKE_PREFIX_PATH "C:/Qt/6.7.3/msvc2019_64")
    # 增加多字节字符集支持和UTF-8支持
    add_compile_options(/utf-8)
    # 添加QT多字节字符集支持定义
    add_definitions(-DUNICODE -D_UNICODE)
endif()

# 添加OpenCV
set(OpenCV_DIR "C:/OpenCV4.5.2/x64/vc16/lib")
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
message(STATUS "Using OpenCV from: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "OpenCV include path: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "OpenCV libraries: ${OpenCV_LIBS}")

# 添加SeetaFace2
set(SEETA_FACE_PATH "C:/SeetaFace2")
include_directories(${SEETA_FACE_PATH}/include)
link_directories(${SEETA_FACE_PATH}/lib)

# 查找SeetaFace2库文件 - 使用MSVC正确的库名称
find_library(SEETA_FACEDETECTOR SeetaFaceDetector ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACELANDMARKER SeetaFaceLandmarker ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACERECOGNIZER SeetaFaceRecognizer ${SEETA_FACE_PATH}/lib)
find_library(SEETA_FACETRACKER SeetaFaceTracker ${SEETA_FACE_PATH}/lib)
find_library(SEETA_NET SeetaNet ${SEETA_FACE_PATH}/lib)

message(STATUS "SeetaFaceDetector: ${SEETA_FACEDETECTOR}")
message(STATUS "SeetaFaceLandmarker: ${SEETA_FACELANDMARKER}")
message(STATUS "SeetaFaceRecognizer: ${SEETA_FACERECOGNIZER}")
message(STATUS "SeetaFaceTracker: ${SEETA_FACETRACKER}")
message(STATUS "SeetaNet: ${SEETA_NET}")

# 查找Qt模块
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Sql Multimedia MultimediaWidgets SerialPort)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Sql Multimedia MultimediaWidgets SerialPort)

# 可选的Qt模块
find_package(Qt6 COMPONENTS WebEngineQuick)
find_package(Qt6 COMPONENTS VirtualKeyboard)

# 设置定义，以便在代码中检查模块是否可用
if(Qt6WebEngineQuick_FOUND)
    add_definitions(-DHAS_WEBENGINE)
endif()

if(Qt6VirtualKeyboard_FOUND)
    add_definitions(-DHAS_VIRTUALKEYBOARD)
endif()

set(PROJECT_SOURCES
        main.cpp
        qml.qrc
        app_icon.rc
        FileManager.cpp
        FileManager.h
        DatabaseManager.cpp
        DatabaseManager.h
        FaceRecognizer.cpp
        FaceRecognizer.h
        LogManager.h
        LogManager.cpp
        SerialPortManager.cpp
        SerialPortManager.h
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(SparkExamAI
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(SparkExamAI SHARED
            ${PROJECT_SOURCES}
        )
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
  Qt${QT_VERSION_MAJOR}::SerialPort
  # 显式列出OpenCV库，先列出imgproc库
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_imgproc452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_core452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_highgui452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_imgcodecs452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_videoio452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_calib3d452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_features2d452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_flann452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_dnn452.lib
  C:/OpenCV4.5.2/x64/vc16/lib/opencv_objdetect452.lib
)

# 可选的Qt模块链接
if(Qt6WebEngineQuick_FOUND)
  target_link_libraries(SparkExamAI PRIVATE Qt6::WebEngineQuick)
endif()

if(Qt6VirtualKeyboard_FOUND)
  target_link_libraries(SparkExamAI PRIVATE Qt6::VirtualKeyboard)
endif()

# 添加QXlsx库
add_subdirectory(QXlsx)  #添加
target_link_libraries(SparkExamAI PRIVATE QXlsx::QXlsx)

# 直接使用 SeetaXXX.lib 文件进行链接 (MSVC版本)
target_link_libraries(SparkExamAI PRIVATE
  ${SEETA_FACE_PATH}/lib/SeetaFaceDetector.lib
  ${SEETA_FACE_PATH}/lib/SeetaFaceLandmarker.lib
  ${SEETA_FACE_PATH}/lib/SeetaFaceRecognizer.lib
  ${SEETA_FACE_PATH}/lib/SeetaFaceTracker.lib
  ${SEETA_FACE_PATH}/lib/SeetaNet.lib
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
  file(GLOB SEETA_DLLS "${SEETA_FACE_PATH}/bin/Seeta*.dll")
  message(STATUS "SeetaFace2 DLLs: ${SEETA_DLLS}")
  
  add_custom_command(TARGET SparkExamAI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:SparkExamAI>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${SEETA_DLLS}
      $<TARGET_FILE_DIR:SparkExamAI>
  )
  
  # 复制 OpenCV DLL
  file(GLOB OPENCV_DLLS "C:/OpenCV4.5.2/x64/vc16/bin/opencv_*.dll")
  message(STATUS "OpenCV DLLs: ${OPENCV_DLLS}")
  
  add_custom_command(TARGET SparkExamAI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${OPENCV_DLLS}
      $<TARGET_FILE_DIR:SparkExamAI>
  )
  
  # 确保模型文件夹存在并复制所有模型文件 - 使用多种方式以确保模型文件被正确复制
  message(STATUS "==== 复制模型文件到目标目录 ====")
  
  # 检查源模型目录是否存在
  if(EXISTS "${CMAKE_SOURCE_DIR}/model")
    message(STATUS "源模型目录存在: ${CMAKE_SOURCE_DIR}/model")
    
    # 列出模型文件
    file(GLOB MODEL_FILES "${CMAKE_SOURCE_DIR}/model/*.dat")
    message(STATUS "模型文件列表: ${MODEL_FILES}")
    
    # 1. 复制到应用程序目录的model子目录
    add_custom_command(TARGET SparkExamAI POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:SparkExamAI>/model
      COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/model
        $<TARGET_FILE_DIR:SparkExamAI>/model
      COMMENT "复制模型文件到目标的model子目录"
    )
    
    # 2. 也直接复制到应用程序目录（为保险起见）
    add_custom_command(TARGET SparkExamAI POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${MODEL_FILES}
        $<TARGET_FILE_DIR:SparkExamAI>
      COMMENT "复制模型文件到目标根目录"
    )
    
    # 记录日志
    message(STATUS "模型文件源目录: ${CMAKE_SOURCE_DIR}/model")
    message(STATUS "模型文件目标目录1: $<TARGET_FILE_DIR:SparkExamAI>/model")
    message(STATUS "模型文件目标目录2: $<TARGET_FILE_DIR:SparkExamAI>")
  else()
    message(WARNING "源模型目录不存在: ${CMAKE_SOURCE_DIR}/model")
  endif()
  
  # 添加安装指令，确保模型文件被正确安装
  install(DIRECTORY ${CMAKE_SOURCE_DIR}/model/ 
          DESTINATION bin/model
          FILES_MATCHING PATTERN "*.dat")
  
  # 也直接复制到bin目录
  install(DIRECTORY ${CMAKE_SOURCE_DIR}/model/ 
          DESTINATION bin
          FILES_MATCHING PATTERN "*.dat")
          
  message(STATUS "==== 模型文件复制设置完成 ====")
endif()

include(GNUInstallDirs)
install(TARGETS SparkExamAI
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(SparkExamAI)
    qt_finalize_executable(SparkExamAI)
endif() 