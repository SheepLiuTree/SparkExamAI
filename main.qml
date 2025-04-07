import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Window {
    width: 640
    height: 480
    visible: true
    visibility: Window.Maximized
    title: qsTr("Hello World")

    Image {
        id: background
        anchors.fill: parent
        source: "qrc:/images/background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        id: headline_background
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/images/headline.png"
        Text {
            id: headline_text
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: "星火智能评测系统"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 48
            color: "white"
        }
        Text {
            id: date_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            text: Qt.formatDateTime(new Date(), "yyyy年MM月dd日")
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"
        }
        Text {
            id: time_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            text: Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + getWeekDay()
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"

            function getWeekDay() {
                var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
                var day = new Date().getDay();
                return weekDays[day];
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    time_text.text = Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + time_text.getWeekDay();
                    date_text.text = Qt.formatDateTime(new Date(), "yyyy年MM月dd日");
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.top: headline_background.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        initialItem: mainPage
        clip: true
    }

    // 主页面
    Rectangle {
        id: mainPage
        color: "transparent"
        visible: false

        Image {
            id: function_menu_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: function_menu_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "功能菜单"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            Column {
                anchors.centerIn: parent
                spacing: 25

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火日课"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火日课 clicked")
                        faceRecognitionPopup.targetPage = "DailyCourseContent.qml"
                        faceRecognitionPopup.titleText = "星火日课"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火特训"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火特训 clicked")
                        faceRecognitionPopup.targetPage = "SpecialTrainingPage.qml"
                        faceRecognitionPopup.titleText = "星火特训"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "面容采集"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        stackView.push("FaceCollectionPage.qml")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "题集速录"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("题集速录 clicked")
                        faceRecognitionPopup.targetPage = "QuestionCollectionPage.qml"
                        faceRecognitionPopup.titleText = "题集速录"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "题策引擎"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("题策引擎 clicked")
                        faceRecognitionPopup.targetPage = "QuestionEnginePage.qml"
                        faceRecognitionPopup.titleText = "题策引擎"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火智能体"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火智能体 clicked")
                    }
                }
            }
        }

        Image {
            id: personal_page_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: personal_page_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "个人主页"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            Flickable {
                id: personal_page_flickable
                anchors.top: personal_page_text.bottom
                anchors.topMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                clip: true
                
                // 滚动属性
                contentWidth: personal_page_column.width
                contentHeight: personal_page_column.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                
                // 启用滚动条
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    interactive: true
                }

                Column {
                    id: personal_page_column
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: 200

                    Repeater {
                        model: ["杨柳", "王林浩", "邵海波", "董楠", "包君钰","薄小钰","陈兆琮","陈子豪","崔文博","丁子轩","董楠","冯子豪","高子豪","郭子豪","韩子豪","何子豪","胡子豪","贾子豪","康子豪","李子豪","刘子豪","马子豪","孟子豪","宁子豪","裴子豪","秦子豪","任子豪","邵子豪","孙子豪","唐子豪","王子豪","徐子豪","杨子豪","于子豪","张子豪","赵子豪","郑子豪","周子豪","朱子豪"]

                        Button {
                            width: 200
                            height: 70
                            background: Image {
                                source: "qrc:/images/personal_button_bg.png"
                                fillMode: Image.Stretch
                            }
                            contentItem: Text {
                                text: modelData
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 30
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -8
                            }
                            onClicked: {
                                console.log(modelData + " clicked")
                            }
                        }
                    }
                }
            }
        }
    }

    // 人脸识别摄像头弹窗
    Popup {
        id: faceRecognitionPopup
        width: 800
        height: 600
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        property string capturedImagePath: ""
        property bool isRecognizing: false
        property int recognitionTimerId: 0
        property bool isFaceDetected: false
        property rect detectedFaceRect: Qt.rect(0, 0, 0, 0)
        property int trackingUpdateInterval: 300 // 人脸跟踪更新间隔(毫秒)
        property string targetPage: ""
        property string titleText: ""
        
        onOpened: {
            // 清空之前的状态
            capturedImage.visible = false
            videoOutput.visible = true
            capturedImagePath = ""
            statusText.text = "正在准备摄像头..."
            isRecognizing = false
            isFaceDetected = false
            detectedFaceRect = Qt.rect(0, 0, 0, 0)
            
            // 确保临时目录存在
            var appDir = fileManager.getApplicationDir()
            var tempDir = appDir + "/temp"
            
            if (!fileManager.directoryExists(tempDir)) {
                fileManager.createDirectory(tempDir)
                console.log("创建临时目录: " + tempDir)
            }
            
            // 获取当前摄像头设置并应用
            var savedCameraId = dbManager.getSetting("camera_device", "")
            if (savedCameraId !== "") {
                camera.deviceId = savedCameraId
                console.log("使用设置的摄像头ID:", savedCameraId)
            } else {
                camera.deviceId = QtMultimedia.defaultCamera.deviceId
                console.log("使用默认摄像头")
            }
            
            // 启动摄像头
            camera.start()
            console.log("启动摄像头，状态:", camera.cameraState)
            
            // 检查可用的摄像头
            var cameras = QtMultimedia.availableCameras
            console.log("可用摄像头数量:", cameras.length)
            for (var i = 0; i < cameras.length; i++) {
                console.log("摄像头 #" + i + ": " + cameras[i].deviceId + " - " + cameras[i].displayName)
            }
            console.log("当前使用摄像头ID:", camera.deviceId)
            
            // 启动人脸跟踪
            faceTrackingTimer.start()
            console.log("人脸跟踪定时器已启动")
            
            // 延迟2秒后开始人脸识别
            recognitionTimerId = recognitionTimer.restart()
        }
        
        onClosed: {
            // 停止摄像头和识别
            if (camera.cameraState === Camera.ActiveState) {
                camera.stop()
            }
            isRecognizing = false
            recognitionTimer.stop()
            faceTrackingTimer.stop()
        }
        
        // 用于延迟启动识别的定时器
        Timer {
            id: recognitionTimer
            interval: 2000
            onTriggered: {
                faceRecognitionPopup.startRecognition()
            }
            
            function restart() {
                stop()
                start()
                return setTimeout(function() {}, interval)
            }
        }
        
        // 周期性人脸识别的定时器
        Timer {
            id: periodicRecognitionTimer
            interval: 1500  // 每1.5秒尝试识别一次
            repeat: true
            running: faceRecognitionPopup.isRecognizing
            onTriggered: {
                faceRecognitionPopup.captureAndRecognize()
            }
        }
        
        // 人脸跟踪定时器
        Timer {
            id: faceTrackingTimer
            interval: faceRecognitionPopup.trackingUpdateInterval
            repeat: true
            running: false
            onTriggered: {
                faceRecognitionPopup.trackFace()
            }
        }
        
        // 开始人脸识别
        function startRecognition() {
            statusText.text = "正在进行人脸识别..."
            isRecognizing = true
            captureAndRecognize()
        }
        
        // 捕获图像并进行识别
        function captureAndRecognize() {
            if (!isRecognizing) return
            
            var tempPath = fileManager.getApplicationDir() + "/temp/face_recognition_temp.jpg"
            camera.imageCapture.captureToLocation(tempPath)
            capturedImagePath = tempPath
            
            // 图片保存完成后由onImageSaved事件触发识别
        }
        
        // 进行人脸跟踪
        function trackFace() {
            var tempPath = fileManager.getApplicationDir() + "/temp/face_tracking_temp.jpg"
            camera.imageCapture.captureToLocation(tempPath)
            
            // 清理之前可能存在的所有连接
            try {
                camera.imageCapture.imageSaved.disconnect(trackFaceImageSavedHandler)
            } catch (e) {
                // 可能没有连接，忽略错误
            }
            
            // 在图片保存完成后检测人脸位置
            camera.imageCapture.imageSaved.connect(trackFaceImageSavedHandler)
        }
        
        // 人脸跟踪图像保存后的处理函数
        function trackFaceImageSavedHandler(id, path) {
            console.log("Face tracking image saved: " + path)
            
            // 检查是否是跟踪用的临时图像
            var tempPath = fileManager.getApplicationDir() + "/temp/face_tracking_temp.jpg"
            if (path !== tempPath) {
                console.log("Not a tracking image, ignoring")
                return
            }
            
            // 使用FaceRecognizer检测人脸位置
            var faceInfo = faceRecognizer.detectFacePosition(path)
            console.log("Face detection result: " + JSON.stringify(faceInfo))
            
            if (faceInfo.faceDetected) {
                console.log("Face detected at: x=" + faceInfo.x + ", y=" + faceInfo.y + 
                           ", width=" + faceInfo.width + ", height=" + faceInfo.height)
                
                isFaceDetected = true
                
                // 获取视频输出区域的实际尺寸
                var actualVideoRect = videoOutput.contentRect
                console.log("Video area: x=" + actualVideoRect.x + ", y=" + actualVideoRect.y + 
                           ", width=" + actualVideoRect.width + ", height=" + actualVideoRect.height)
                
                // 将人脸坐标从图像坐标系转换到视频区域坐标系
                var normalizedRect = Qt.rect(
                    // 镜像显示时，需要翻转X坐标
                    actualVideoRect.x + (1.0 - (faceInfo.x + faceInfo.width) / faceInfo.imageWidth) * actualVideoRect.width,
                    actualVideoRect.y + (faceInfo.y / faceInfo.imageHeight) * actualVideoRect.height,
                    (faceInfo.width / faceInfo.imageWidth) * actualVideoRect.width,
                    (faceInfo.height / faceInfo.imageHeight) * actualVideoRect.height
                )
                console.log("Normalized face rect: x=" + normalizedRect.x + ", y=" + normalizedRect.y + 
                           ", width=" + normalizedRect.width + ", height=" + normalizedRect.height)
                
                // 更新人脸框位置
                detectedFaceRect = normalizedRect
                
                // 显示跟踪状态
                if (!isRecognizing) {
                    statusText.text = "检测到人脸，对准框中央以进行识别"
                }
                
                // 更新人脸框颜色为绿色（成功检测到人脸）
                faceFrame.border.color = "green"
            } else {
                console.log("No face detected in tracking image")
                isFaceDetected = false
                
                // 重置人脸框到中央
                detectedFaceRect = Qt.rect(0, 0, 0, 0)
                
                // 显示未检测到人脸
                if (!isRecognizing) {
                    statusText.text = "未检测到人脸，请正对摄像头"
                }
                
                // 更新人脸框颜色为红色（未检测到人脸）
                faceFrame.border.color = "red"
            }
            
            // 不需要断开连接，因为我们使用的是命名函数
        }

        Rectangle {
            anchors.fill: parent
            color: "#EEEEEE"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    text: faceRecognitionPopup.titleText || "人脸识别"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 24
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    id: statusText
                    text: "正在准备摄像头..."
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // 摄像头预览区域
                Rectangle {
                    width: 640
                    height: 360
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Camera {
                        id: camera
                        
                        viewfinder.resolution: Qt.size(640, 360)
                        
                        imageCapture {
                            onImageSaved: {
                                console.log("Image saved to: " + path)
                                
                                // 只有识别用的图片才触发人脸识别
                                if (path === faceRecognitionPopup.capturedImagePath && faceRecognitionPopup.isRecognizing) {
                                    faceRecognitionPopup.recognizeFaceInAllUsers(path)
                                }
                            }
                        }
                    }
                    
                    VideoOutput {
                        id: videoOutput
                        source: camera
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectFit
                        focus: visible
                        visible: true
                        
                        // 添加水平镜像变换
                        transform: Scale {
                            xScale: -1
                            origin.x: videoOutput.width / 2
                        }
                        
                        property rect contentRect: {
                            if (camera.viewfinder.resolution.width <= 0 || camera.viewfinder.resolution.height <= 0) {
                                return Qt.rect(0, 0, width, height)
                            }
                            
                            var srcRatio = sourceRect.width / sourceRect.height
                            var destRatio = width / height
                            
                            var resultWidth, resultHeight, resultX, resultY
                            
                            if (srcRatio > destRatio) {
                                // 视频比例更宽，上下留黑边
                                resultWidth = width
                                resultHeight = width / srcRatio
                                resultX = 0
                                resultY = (height - resultHeight) / 2
                            } else {
                                // 视频比例更窄，左右留黑边
                                resultHeight = height
                                resultWidth = height * srcRatio
                                resultX = (width - resultWidth) / 2
                                resultY = 0
                            }
                            
                            return Qt.rect(resultX, resultY, resultWidth, resultHeight)
                        }
                    }
                    
                    Image {
                        id: capturedImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        visible: false
                        
                        // 添加水平镜像变换，与视频输出保持一致
                        transform: Scale {
                            xScale: -1
                            origin.x: capturedImage.width / 2
                        }
                    }
                    
                    // 人脸框辅助线 - 根据检测到的位置动态调整
                    Rectangle {
                        id: faceFrame
                        color: "transparent"
                        border.width: 2
                        border.color: "red"
                        visible: faceRecognitionPopup.isFaceDetected
                        
                        // 如果检测到人脸，使用检测到的位置和大小
                        x: faceRecognitionPopup.detectedFaceRect.x
                        y: faceRecognitionPopup.detectedFaceRect.y
                        width: faceRecognitionPopup.detectedFaceRect.width
                        height: faceRecognitionPopup.detectedFaceRect.height
                        
                        // 平滑过渡效果
                        Behavior on x { NumberAnimation { duration: 200 } }
                        Behavior on y { NumberAnimation { duration: 200 } }
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on height { NumberAnimation { duration: 200 } }
                    }
                }
                
                ProgressBar {
                    id: recognitionProgress
                    width: 640
                    height: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    indeterminate: true
                    visible: faceRecognitionPopup.isRecognizing
                }
                
                Button {
                    width: 150
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        color: "#F44336"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "取消"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        faceRecognitionPopup.close()
                    }
                }
            }
        }
        
        // 自动识别所有用户中的人脸
        function recognizeFaceInAllUsers(imagePath) {
            // 获取所有用户数据
            var allUsers = dbManager.getAllFaceData()
            
            if (allUsers.length === 0) {
                statusText.text = "数据库中没有用户数据"
                return
            }
            
            // 先使用FaceRecognizer检测图像中是否有人脸
            var faceDetected = faceRecognizer.detectFace(imagePath)
            if (!faceDetected) {
                statusText.text = "未检测到人脸，请正对摄像头"
                return
            }
            
            statusText.text = "正在比对人脸..."
            
            // 遍历所有用户，与当前拍摄的照片比对
            var maxSimilarity = 0
            var bestMatchUser = null
            
            for (var i = 0; i < allUsers.length; i++) {
                var user = allUsers[i]
                
                // 跳过没有面部图像的用户
                if (!user.faceImage || user.faceImage === "") continue
                
                // 比较人脸相似度
                var similarity = faceRecognizer.compareFaces(user.faceImage, imagePath)
                console.log("用户: " + user.name + ", 相似度: " + similarity)
                
                // 更新最佳匹配
                if (similarity > maxSimilarity) {
                    maxSimilarity = similarity
                    bestMatchUser = user
                }
            }
            
            // 使用固定阈值0.65（65%）
            var threshold = 0.65
            
            // 如果最佳匹配的相似度超过阈值，则识别成功
            if (maxSimilarity >= threshold && bestMatchUser) {
                // 设置用户信息对话框数据并显示
                userInfoDialog.userData = bestMatchUser
                userInfoDialog.similarityValue = Math.round(maxSimilarity * 100)
                userInfoDialog.capturedImagePath = imagePath
                userInfoDialog.useCapturedImageAsAvatar = true
                userInfoDialog.targetPage = faceRecognitionPopup.targetPage
                userInfoDialog.titleText = faceRecognitionPopup.titleText
                isRecognizing = false
                
                // 获取用户头像路径
                var userAvatarPath = dbManager.getUserAvatarPath(bestMatchUser.workId)
                if (userAvatarPath && userAvatarPath !== "") {
                    userInfoDialog.userData.avatarPath = userAvatarPath
                    console.log("获取到用户头像路径:", userAvatarPath)
                } else {
                    // 如果没有头像，使用采集的面部图像作为头像
                    userInfoDialog.userData.avatarPath = imagePath
                    console.log("用户没有头像，使用采集的面部图像:", imagePath)
                }
                
                statusText.text = "识别成功: " + bestMatchUser.name + " (相似度: " + Math.round(maxSimilarity * 100) + "%)"
                console.log("Face recognition successful: " + bestMatchUser.name + " with similarity: " + maxSimilarity)
                
                // 关闭人脸识别对话框
                faceRecognitionPopup.close()
                
                // 显示用户信息确认对话框
                userInfoDialog.open()
            } else {
                // 如果找到了最佳匹配但相似度不够
                if (bestMatchUser) {
                    statusText.text = "人脸相似度不足: " + Math.round(maxSimilarity * 100) + "%, 需要65%以上"
                    console.log("Face similarity too low: " + maxSimilarity + " (threshold: " + threshold + ")")
                } else {
                    statusText.text = "未找到匹配的人脸，请重试或先进行面容采集"
                    console.log("No matching face found.")
                }
            }
        }
    }
    
    // 用户信息确认对话框
    Dialog {
        id: userInfoDialog
        width: 400
        height: 520
        anchors.centerIn: parent
        modal: true
        title: "用户信息确认"
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property var userData: ({})
        property int similarityValue: 0
        property string capturedImagePath: ""
        property bool useCapturedImageAsAvatar: false
        property string targetPage: ""
        property string titleText: ""
        
        // 添加打开事件，用于调试头像显示
        onOpened: {
            console.log("用户信息对话框已打开")
            console.log("用户数据:", JSON.stringify(userData))
            console.log("头像路径:", userData.avatarPath)
            console.log("采集的图像路径:", capturedImagePath)
            
            var imageToShow = ""
            
            // 优先使用用户资料中的头像
            if (userData.avatarPath && userData.avatarPath !== "") {
                imageToShow = userData.avatarPath
                console.log("使用用户头像:", imageToShow)
            } 
            // 如果允许且存在采集的图像，则使用采集的图像
            else if (useCapturedImageAsAvatar && capturedImagePath && capturedImagePath !== "") {
                imageToShow = capturedImagePath
                console.log("使用采集的图像作为头像:", imageToShow)
            }
            
            // 确保头像路径是完整的
            if (imageToShow !== "") {
                if (!imageToShow.startsWith("file:///")) {
                    // 尝试修复头像路径
                    var fixedPath = "file:///" + imageToShow.replace(/\\/g, "/")
                    console.log("修正后的头像路径:", fixedPath)
                    userAvatar.source = fixedPath
                } else {
                    userAvatar.source = imageToShow
                }
            } else {
                console.log("无可用头像，显示默认头像")
            }
        }
        
        contentItem: Rectangle {
            anchors.fill: parent
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Image {
                    id: userAvatar
                    width: 150
                    height: 150
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: ""
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            console.log("头像加载成功:", source)
                        } else if (status === Image.Error) {
                            console.log("头像加载失败:", source)
                        }
                    }
                    
                    // 如果没有头像，显示默认图标
                    Rectangle {
                        anchors.fill: parent
                        color: "#DDDDDD"
                        visible: userAvatar.status !== Image.Ready
                        
                        Text {
                            anchors.centerIn: parent
                            text: userInfoDialog.userData.name ? userInfoDialog.userData.name.charAt(0) : "?"
                            font.pixelSize: 80
                            font.family: "阿里妈妈数黑体"
                            color: "#666666"
                        }
                    }
                }
                
                // 显示头像路径（调试用）
                Text {
                    text: "头像路径: " + (userInfoDialog.userData.avatarPath || "无")
                    font.pixelSize: 10
                    color: "#999999"
                    visible: false // 调试时设为true，发布时设为false
                    width: parent.width
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideMiddle
                    maximumLineCount: 2
                }
                
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#E3F2FD"
                    radius: 5
                    
                    Text {
                        anchors.centerIn: parent
                        text: "人脸相似度: " + userInfoDialog.similarityValue + "%"
                        font.pixelSize: 18
                        font.family: "阿里妈妈数黑体"
                        color: userInfoDialog.similarityValue >= 90 ? "#4CAF50" : "#FF9800"
                        font.bold: true
                    }
                }
                
                Text {
                    text: "姓名: " + (userInfoDialog.userData.name || "")
                    font.pixelSize: 18
                    font.family: "阿里妈妈数黑体"
                }
                
                Text {
                    text: "性别: " + (userInfoDialog.userData.gender || "")
                    font.pixelSize: 18
                    font.family: "阿里妈妈数黑体"
                }
                
                Text {
                    text: "工号: " + (userInfoDialog.userData.workId || "")
                    font.pixelSize: 18
                    font.family: "阿里妈妈数黑体"
                }
                
                Text {
                    text: "是否管理员: " + (userInfoDialog.userData.isAdmin ? "是" : "否")
                    font.pixelSize: 18
                    font.family: "阿里妈妈数黑体"
                }
                
                Text {
                    text: "请确认以上信息是否正确"
                    font.pixelSize: 16
                    font.family: "阿里妈妈数黑体"
                    font.italic: true
                    color: "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    
                    Button {
                        width: 120
                        height: 40
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 5
                        }
                        contentItem: Text {
                            text: "确认并进入"
                            color: "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            userInfoDialog.close()
                            
                            // 检查是否是题策引擎或题集速录且用户不是管理员
                            if ((userInfoDialog.titleText === "题策引擎" || userInfoDialog.titleText === "题集速录") && !userInfoDialog.userData.isAdmin) {
                                console.log("非管理员用户尝试访问" + userInfoDialog.titleText)
                                // 显示管理员权限提示弹窗
                                adminRequiredPopup.titleText = userInfoDialog.titleText
                                adminRequiredPopup.open()
                            } else {
                                console.log("用户已确认信息，正在跳转到" + userInfoDialog.titleText + "页面...")
                                // 确认后跳转到对应页面
                                stackView.push(userInfoDialog.targetPage)
                            }
                        }
                    }
                    
                    Button {
                        width: 120
                        height: 40
                        background: Rectangle {
                            color: "#F44336"
                            radius: 5
                        }
                        contentItem: Text {
                            text: "信息有误"
                            color: "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            userInfoDialog.close()
                            // 返回人脸识别界面
                            faceRecognitionPopup.open()
                        }
                    }
                }
            }
        }
    }

    // 管理员权限提示弹窗
    Popup {
        id: adminRequiredPopup
        width: 450
        height: 300
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property string titleText: "题策引擎" // 默认为题策引擎，可根据当前操作设置
        
        background: Rectangle {
            color: "#FFFFFF"
            radius: 10
            border.color: "#E0E0E0"
            border.width: 1
        }
        
        contentItem: Item {
            anchors.fill: parent
            
            // 顶部色带
            Rectangle {
                id: headerBand
                width: parent.width
                height: 8
                color: "#F44336"
                anchors.top: parent.top
                radius: 10
            }
            
            // 图标
            Image {
                id: lockIcon
                source: "qrc:/images/face_icon.png"
                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40
                fillMode: Image.PreserveAspectFit
            }
            
            // 红色锁图标
            Text {
                anchors.right: lockIcon.right
                anchors.bottom: lockIcon.bottom
                text: "🔒"
                font.pixelSize: 24
                color: "#F44336"
            }
            
            // 标题
            Text {
                id: titleText
                text: "需要管理员权限"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: lockIcon.bottom
                anchors.topMargin: 20
                font.pixelSize: 24
                font.family: "阿里妈妈数黑体"
                font.bold: true
                color: "#333333"
            }
            
            // 说明文本
            Text {
                id: descriptionText
                text: adminRequiredPopup.titleText + "仅对管理员开放，请联系系统管理员获取相应权限。"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: titleText.bottom
                anchors.topMargin: 15
                width: parent.width - 60
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 16
                font.family: "阿里妈妈数黑体"
                color: "#666666"
                lineHeight: 1.3
            }
            
            // 按钮
            Button {
                id: closeButton
                text: "返回"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                width: 180
                height: 45
                
                background: Rectangle {
                    color: closeButton.pressed ? "#E0E0E0" : "#F5F5F5"
                    radius: 22.5
                    border.color: "#DDDDDD"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: closeButton.text
                    font.pixelSize: 16
                    font.family: "阿里妈妈数黑体"
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    adminRequiredPopup.close()
                }
            }
        }
    }
}
