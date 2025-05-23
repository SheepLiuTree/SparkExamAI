import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtMultimedia
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import QtCore

Rectangle {
    color: "transparent" 
    objectName: "FaceCollectionPage"

    // 添加信号，用于通知主窗口用户列表已更新
    signal userListUpdated()

    // 创建一个ListModel来存储采集的人脸数据
    ListModel {
        id: faceCollectionModel
    }

    // 添加MediaDevices对象用于访问摄像头列表
    MediaDevices {
        id: mediaDevices
    }

    // 定义顶级摄像头组件
    Camera {
        id: camera
        active: false // 初始不激活，在初始化函数中设置
        
        onActiveChanged: {
            console.log("摄像头激活状态变化:", active)
            if (active) {
                cameraReady = true
                console.log("摄像头已激活，使用的设备:", cameraDevice ? cameraDevice.id : "未知")
            } else {
                cameraReady = false
            }
        }
        
        onErrorOccurred: function(error, errorString) {
            console.log("摄像头错误:", error, errorString)
        }
    }
    
    // 添加CaptureSession组件用于连接摄像头和图像捕获
    CaptureSession {
        id: captureSession
        camera: camera
        videoOutput: videoOutput
        imageCapture: imageCapture
    }
    
    // 独立的图像捕获组件
    ImageCapture {
        id: imageCapture
        
        onImageCaptured: function(id, preview) {
            console.log("Image captured with id: " + id)
            capturedImage.source = preview
        }
        onImageSaved: function(id, path) {
            console.log("Image saved as: " + path)
            fileManager.moveFile(path, "faceimages/" + nameInput.text + ".jpg")
        }
    }
    
    // 摄像头就绪状态
    property bool cameraReady: false
    
    // 初始化尝试次数
    property int initAttempts: 0
    property int maxInitAttempts: 5

    // 组件加载完成后，从数据库加载数据
    Component.onCompleted: {
        // 加载面部数据列表
        loadFaceDataFromDatabase()
        console.log("FaceCollectionPage完成加载，将在1秒后初始化摄像头")
        
        // 第一次尝试初始化摄像头
        firstInitTimer.start()
    }
    
    // 首次初始化定时器
    Timer {
        id: firstInitTimer
        interval: 1000  // 1秒延迟
        running: false
        repeat: false
        onTriggered: {
            initCamera()
        }
    }
    
    // 初始化摄像头
    function initCamera() {
        console.log("开始初始化摄像头, 尝试次数:", initAttempts + 1)
        
        // 超过最大尝试次数
        if (initAttempts >= maxInitAttempts) {
            console.log("达到最大尝试次数，初始化失败")
            return
        }
        
        initAttempts++
        
        // 先释放已存在的资源
        if (camera.active) {
            console.log("摄像头已在活动状态，先停止")
            camera.active = false
            // 短暂延迟后再重新启动
            Qt.callLater(function() {
                startCamera()
            })
        } else {
            startCamera()
        }
    }
    
    // 启动摄像头
    function startCamera() {
        // 获取摄像头设置
        var savedCameraId = dbManager.getSetting("camera_device", "auto")
        console.log("获取摄像头设置:", savedCameraId)
        
        // 检查可用摄像头
        var cameras = mediaDevices.videoInputs
        console.log("可用摄像头数量:", cameras.length)
        for (var i = 0; i < cameras.length; i++) {
            console.log("摄像头 #" + i + ": " + cameras[i].id + " - " + cameras[i].description)
        }
        
        // 设置摄像头ID
        if (savedCameraId === "auto") {
            // 自动模式，使用默认摄像头
            if (cameras.length > 0) {
                camera.cameraDevice = cameras[0]
                console.log("使用默认摄像头:", camera.cameraDevice.id)
            } else {
                console.log("没有可用摄像头!")
                return
            }
        } else if (savedCameraId !== "") {
            // 使用指定的摄像头ID
            var foundDevice = false
            var selectedCamera = null
            // 先检查指定的ID是否在可用列表中
            for (var i = 0; i < cameras.length; i++) {
                if (cameras[i].id === savedCameraId) {
                    selectedCamera = cameras[i]
                    foundDevice = true
                    break
                }
            }
            
            if (foundDevice) {
                camera.cameraDevice = selectedCamera
                console.log("使用指定摄像头:", selectedCamera.id)
            } else {
                console.log("指定的摄像头不可用，使用默认摄像头")
                if (cameras.length > 0) {
                    camera.cameraDevice = cameras[0]
                    console.log("退回到默认摄像头:", camera.cameraDevice.id)
                } else {
                    console.log("没有可用摄像头!")
                    return
                }
            }
        } else {
            // 空设置，使用默认摄像头
            if (cameras.length > 0) {
                camera.cameraDevice = cameras[0]
                console.log("使用默认摄像头:", camera.cameraDevice.id)
            } else {
                console.log("没有可用摄像头!")
                return
            }
        }
        
        // 设置合适的分辨率
        if (camera.cameraDevice) {
            var closestFormat = null
            var targetRes = Qt.size(640, 360)
            var minDiff = Number.MAX_VALUE
            
            for (var i = 0; i < camera.cameraDevice.videoFormats.length; i++) {
                var format = camera.cameraDevice.videoFormats[i]
                var res = format.resolution
                var diff = Math.abs(res.width - targetRes.width) + Math.abs(res.height - targetRes.height)
                
                if (diff < minDiff) {
                    minDiff = diff
                    closestFormat = format
                }
            }
            
            if (closestFormat) {
                camera.cameraFormat = closestFormat
                console.log("设置摄像头分辨率:", camera.cameraFormat.resolution.width, "x", camera.cameraFormat.resolution.height)
            }
        }
        
        // 记录当前使用的摄像头ID
        console.log("最终设置的摄像头:", camera.cameraDevice ? camera.cameraDevice.id : "未设置")
        
        // 启动摄像头
        console.log("启动摄像头...")
        camera.active = true
        
        // 确保VideoOutput变换设置正确
        Qt.callLater(function() {
            // 重置VideoOutput的变换，确保只有水平镜像，没有垂直翻转
            if (videoOutput) {
                console.log("设置VideoOutput正确的变换")
                videoOutput.rotation = 0
                
                // 创建新的变换对象
                var newTransform = []
                newTransform.push(Qt.createQmlObject(
                    'import QtQuick 2.15; Scale { xScale: -1; yScale: 1; origin.x: videoOutput.width / 2 }',
                    videoOutput, 
                    "dynamicStartTransform"
                ));
                videoOutput.transform = newTransform
            }
        })
        
        // 启动监视定时器
        cameraMonitorTimer.start()
    }
    
    // 摄像头监视定时器
    Timer {
        id: cameraMonitorTimer
        interval: 1000  // 1秒检查一次
        running: false
        repeat: true
        property int checkCount: 0
        
        onTriggered: {
            checkCount++
            console.log("监视摄像头状态:", camera.active, "就绪:", cameraReady, "次数:", checkCount)
            
            if (cameraReady) {
                console.log("摄像头就绪，停止监视")
                cameraMonitorTimer.stop()
                checkCount = 0
            } else if (checkCount >= 5) {
                console.log("摄像头未就绪，重试初始化")
                camera.active = false
                cameraMonitorTimer.stop()
                checkCount = 0
                
                // 短暂延迟后重试
                Qt.callLater(function() {
                    initCamera()
                })
            }
        }
    }

    // 从数据库加载人脸数据的函数
    function loadFaceDataFromDatabase() {
        // 清空现有模型
        faceCollectionModel.clear();
        
        // 从数据库获取所有人脸数据
        var faceList = dbManager.getAllFaceData();
        console.log("从数据库获取到 " + faceList.length + " 条人脸数据");
        
        // 将数据添加到模型中
        for (var i = 0; i < faceList.length; i++) {
            var face = faceList[i];
            
            // 处理头像和人脸图像路径
            var processedFaceImage = face.faceImage;
            var processedAvatarPath = face.avatarPath;
            
            console.log("原始人脸图像路径: " + processedFaceImage);
            console.log("原始头像路径: " + processedAvatarPath);
            
            faceCollectionModel.append({
                "name": face.name,
                "gender": face.gender,
                "workId": face.workId,
                "faceImage": processedFaceImage,
                "avatarPath": processedAvatarPath,
                "isAdmin": face.isAdmin
            });
        }
    }

    Button {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: 100
        height: 40
        background: Image {
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }
        contentItem: Text {
            text: "返回"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 18
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: {
            console.log("返回按钮被点击")
            // 显示确认对话框
            confirmDialog.open()
        }
    }
    Button {
        id: captureButton
        anchors.top: backButton.top
        anchors.right: parent.right
        anchors.rightMargin: 20
        width: 120
        height: 40
        background: Image {
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }
        contentItem: Text {
            text: "采集"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 18
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: {
            cameraPopup.open()
        }
    }

    // 添加Canvas元素用于截取图像
    Canvas {
        id: captureCanvas
        width: videoOutput.width
        height: videoOutput.height
        visible: false
    }

    // 半透明遮罩层作为模态背景
    Rectangle {
        id: modalOverlay
        anchors.fill: parent
        color: "#80000000"  // 半透明黑色
        visible: cameraPopup.visible
        z: 99  // 确保在弹窗下面，但在其他元素上面
        
        // 点击遮罩层不关闭弹窗
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 不做任何操作
            }
        }
    }

    // 使用Rectangle实现弹窗效果，替代Popup组件
    Rectangle {
        id: cameraPopup
        width: 1100
        height: 500
        anchors.centerIn: parent
        visible: false  // 默认不可见
        z: 100  // 确保显示在最上层

        // 定义打开和关闭函数
        function open() {
            visible = true
            // 执行原Popup的onOpened逻辑
            capturedImage.visible = false
            videoOutput.visible = true
            capturedImage.source = ""
            
            nameInput.text = ""
            workIdInput.text = ""
            maleRadio.checked = true
            normalRadio.checked = true
            avatarPathInput.text = ""
            avatarPathInput.filePath = ""
            
            console.log("相机弹窗打开 - 摄像头状态:", camera.active, "就绪:", cameraReady)
            
            // 始终重新初始化摄像头，确保使用正确的设备
            console.log("重新初始化摄像头以确保使用正确的设备")
            
            // 如果摄像头在活动状态，先停止
            if (camera.active) {
                camera.active = false
                // 短暂延迟后重新初始化
                Qt.callLater(function() {
                    initCamera()
                })
            } else {
                // 直接初始化
                initCamera()
            }
        }
        
        function close() {
            visible = false
            // 执行原Popup的onClosed逻辑
            console.log("相机弹窗关闭 - 不停止摄像头，保持运行状态")
        }

        // 键盘处理，模拟Popup的CloseOnEscape功能
        Keys.onEscapePressed: {
            cameraPopup.close()
        }

        color: "#333333"
        border.color: "#666666"
        border.width: 2
        radius: 10

        // 内容部分
        Item {
            anchors.fill: parent

            Rectangle {
                id: cameraViewfinder
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                width: parent.width * 0.55 - 30
                height: parent.height - 100
                color: "black"

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                    visible: true
                    
                    // 添加水平镜像变换
                    transform: [
                        Scale {
                            id: videoTransform
                            xScale: -1
                            yScale: 1  // 明确设置yScale为1确保不会垂直翻转
                            origin.x: videoOutput.width / 2
                        }
                    ]
                    
                    // 计算实际视频内容区域
                    property rect contentRect: Qt.rect(0, 0, width, height)
                }

                Image {
                    id: capturedImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
                    rotation: 0 // 显式设置为0度，防止旋转
                    
                    // 添加水平镜像变换，与视频输出保持一致
                    transform: [
                        Scale {
                            xScale: -1
                            yScale: 1  // 明确设置yScale为1确保不会垂直翻转
                            origin.x: capturedImage.width / 2
                        }
                    ]
                }
                
                // 顶部指导文字
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: guideText.width + 20
                    height: guideText.height + 10
                    color: "#AA000000"
                    radius: 5
                    
                    Text {
                        id: guideText
                        anchors.centerIn: parent
                        text: "请将脸部对准识别框内"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 15  // 增大字体
                        color: "white"
                        style: Text.Outline  // 添加轮廓
                        styleColor: "black"  // 轮廓颜色
                    }
                }
                // 人脸引导遮罩 - 仅在视频输出可见时显示
                Item {
                    id: faceGuide
                    anchors.fill: parent
                    visible: videoOutput.visible && !capturedImage.visible                
                    
                    // 椭圆形引导框 - 保持正方形尺寸
                    Image {
                        id: clearArea
                        source: "qrc:/images/FaceTracking.png"
                        anchors.centerIn: parent
                        // 设置为相同的宽高，确保是正方形
                        property real size: Math.min(videoOutput.contentRect.width * 0.8, videoOutput.contentRect.height * 0.8)
                        width: size
                        height: size
                    }
                    
                    // 添加鼻子位置的十字标记 - 增加宽度提高可见性
                    Rectangle {
                        id: noseCrossHorizontal
                        anchors.centerIn: parent
                        width: 20
                        height: 2
                        color: "#AAffff00"  // 使用黄色以增加可见度
                    }
                    
                    Rectangle {
                        id: noseCrossVertical
                        anchors.centerIn: parent
                        width: 2
                        height: 20
                        color: "#AAffff00"  // 使用黄色以增加可见度
                    }
                                        
                }
            }

            // 个人信息表单
            Rectangle {
                id: infoForm
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 20
                width: parent.width * 0.45 - 30
                height: parent.height - 100
                color: "#44ffffff"
                radius: 10

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "个人信息"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 22
                        color: "white"
                    }

                    // 姓名
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 10

                        Text {
                            width: 80
                            height: parent.height
                            text: "姓名："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            width: parent.width - 90
                            height: parent.height
                            color: "#22ffffff"
                            radius: 5

                            TextField {
                                id: nameInput
                                anchors.fill: parent
                                anchors.margins: 5
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                background: Rectangle {
                                    color: "transparent"
                                }
                                inputMethodHints: Qt.ImhNone
                                
                                // 强制使用虚拟键盘
                                onFocusChanged: {
                                    if (focus) {
                                        console.log("姓名输入框获得焦点")
                                        forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    // 性别
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 10

                        Text {
                            width: 80
                            height: parent.height
                            text: "性别："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Row {
                            width: parent.width - 90
                            height: parent.height
                            spacing: 20

                            RadioButton {
                                id: maleRadio
                                text: "男"
                                checked: true
                                contentItem: Text {
                                    text: maleRadio.text
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: maleRadio.indicator.width + 4
                                }
                            }

                            RadioButton {
                                id: femaleRadio
                                text: "女"
                                contentItem: Text {
                                    text: femaleRadio.text
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: femaleRadio.indicator.width + 4
                                }
                            }
                        }
                    }

                    // 工号
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 10

                        Text {
                            width: 80
                            height: parent.height
                            text: "工号："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            width: parent.width - 90
                            height: parent.height
                            color: "#22ffffff"
                            radius: 5

                            TextField {
                                id: workIdInput
                                anchors.fill: parent
                                anchors.margins: 5
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                background: Rectangle {
                                    color: "transparent"
                                }
                                inputMethodHints: Qt.ImhDigitsOnly
                                
                                // 强制使用虚拟键盘
                                onFocusChanged: {
                                    if (focus) {
                                        console.log("工号输入框获得焦点")
                                        forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    // 权限
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 10

                        Text {
                            width: 80
                            height: parent.height
                            text: "权限："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Row {
                            width: parent.width - 90
                            height: parent.height
                            spacing: 2

                            RadioButton {
                                id: normalRadio
                                text: "普通"
                                checked: true
                                contentItem: Text {
                                    text: normalRadio.text
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: normalRadio.indicator.width + 4
                                }
                            }
                            
                            RadioButton {
                                id: adminRadio
                                text: "管理员"
                                contentItem: Text {
                                    text: adminRadio.text
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: adminRadio.indicator.width + 4
                                }
                            }
                        }
                    }

                    // 个人头像路径
                    Row {
                        width: parent.width
                        height: 40
                        spacing: 10

                        Text {
                            width: 120
                            height: parent.height
                            text: "个人头像路径："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            width: parent.width - 200
                            height: parent.height
                            color: "#22ffffff"
                            radius: 5

                            Text {
                                id: avatarPathInput
                                anchors.fill: parent
                                anchors.margins: 5
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideMiddle
                                clip: true
                                property string filePath: ""
                            }
                        }

                        Button {
                            width: 60
                            height: parent.height
                            background: Image {
                                source: "qrc:/images/button_bg.png"
                                fillMode: Image.Stretch
                            }
                            contentItem: Text {
                                text: "浏览"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 14
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                fileDialog.open()
                            }
                        }
                    }
                }
            }

            // 文件选择对话框
            FileDialog {
                id: fileDialog
                title: "选择个人头像"
                currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.bmp)"]
                fileMode: FileDialog.OpenFile

                onAccepted: {
                    console.log("选择的文件: " + selectedFile)
                    var filePath = selectedFile.toString().replace("file:///", "")
                    avatarPathInput.text = filePath
                    avatarPathInput.filePath = filePath
                }

                onRejected: {
                    console.log("取消选择文件")
                }
            }

            Row {
                anchors.top: cameraViewfinder.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 40

                Button {
                    width: 120
                    height: 40
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: capturedImage.visible ? "重拍" : "拍照"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (capturedImage.visible) {
                            // 重拍逻辑
                            capturedImage.visible = false
                            videoOutput.visible = true
                        } else {
                            // 拍照逻辑                           
                            videoOutput.grabToImage(function(result) {
                                capturedImage.source = result.url; // 仅预览
                                capturedImage.visible = true
                                videoOutput.visible = false
                            });
                        }
                    }
                }

                Button {
                    width: 120
                    height: 40
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "取消"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        cameraPopup.close()
                    }
                }

                Button {
                    width: 120
                    height: 40
                    visible: capturedImage.visible
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "保存"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // 验证信息是否完整
                        if (nameInput.text === "") {
                            messageText.text = "请输入姓名"
                            messagePopup.open()
                            return
                        }

                        if (workIdInput.text === "") {
                            messageText.text = "请输入工号"
                            messagePopup.open()
                            return
                        }

                        if (avatarPathInput.filePath === "") {
                            messageText.text = "请选择个人头像路径"
                            messagePopup.open()
                            return
                        }

                        // 检查工号是否已存在
                        if (dbManager.userExists(workIdInput.text)) {
                            messageText.text = "该工号已存在，请使用其他工号"
                            messagePopup.open()
                            return
                        }

                        // 检查是否是管理员账户，如果是则需要密码验证
                        if (adminRadio.checked) {
                            adminPasswordPopup.onPasswordVerified = function() {
                                // 密码验证成功后保存数据
                                saveFaceData()
                            }
                            adminPasswordPopup.open()
                        } else {
                            // 非管理员账户直接保存
                            saveFaceData()
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: tableContainer
        anchors.top: backButton.bottom
        anchors.topMargin: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: parent.height - backButton.height - 60
        color: "#33ffffff"
        radius: 10

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2

            // Header row
            Rectangle {
                width: parent.width
                height: 50
                color: "#66ffffff"
                radius: 5

                Row {
                    anchors.fill: parent

                    Text {
                        width: parent.width * 0.1
                        height: parent.height
                        text: "编辑"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width * 0.15
                        height: parent.height
                        text: "姓名"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width * 0.1
                        height: parent.height
                        text: "性别"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width * 0.15
                        height: parent.height
                        text: "工号"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        width: parent.width * 0.1
                        height: parent.height
                        text: "权限"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        text: "采集图像"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width * 0.2
                        height: parent.height
                        text: "个人头像"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Table content will be a ListView
            ListView {
                width: parent.width
                height: parent.height - 50
                clip: true
                model: faceCollectionModel

                delegate: Rectangle {
                    width: parent.width
                    height: 60
                    color: index % 2 ? "#22ffffff" : "#11ffffff"

                    Row {
                        anchors.fill: parent

                        Rectangle {
                            width: parent.width * 0.1
                            height: parent.height
                            color: "transparent"

                            Button {
                                anchors.centerIn: parent
                                width: 100
                                height: 40
                                background: Image {
                                    source: "qrc:/images/button_bg.png"
                                    fillMode: Image.Stretch
                                }
                                contentItem: Text {
                                    text: "删除"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    // 从数据库中删除数据
                                    var workId = faceCollectionModel.get(index).workId;
                                    console.log("尝试删除用户: " + workId);
                                    var result = dbManager.deleteFaceData(workId);
                                    
                                    if (result) {
                                        // 从模型中删除数据
                                        faceCollectionModel.remove(index);
                                        messageText.text = "数据已成功删除！";
                                        
                                        // 通知主窗口用户列表已更新
                                        console.log("删除成功，发出用户列表更新信号");
                                        userListUpdated();
                                    } else {
                                        messageText.text = "删除数据失败！";
                                        console.log("删除失败");
                                    }
                                    messagePopup.open();
                                }
                            }
                        }
                        Text {
                            width: parent.width * 0.15
                            height: parent.height
                            text: name
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: parent.width * 0.1
                            height: parent.height
                            text: gender
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: parent.width * 0.15
                            height: parent.height
                            text: workId
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Rectangle {
                            width: parent.width * 0.1
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: isAdmin ? "管理员" : "普通"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        Rectangle {
                            width: parent.width * 0.2
                            height: parent.height
                            color: "transparent"

                            Image {
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                source: faceImage ? processImagePath(faceImage) : ""
                                fillMode: Image.PreserveAspectFit
                                
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("人脸图像加载失败: " + source)
                                    } else if (status === Image.Ready) {
                                        console.log("人脸图像加载成功: " + source)
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width * 0.2
                            height: parent.height
                            color: "transparent"

                            Image {
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                source: avatarPath ? processImagePath(avatarPath) : ""
                                fillMode: Image.PreserveAspectFit
                                
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("头像图像加载失败: " + source)
                                    } else if (status === Image.Ready) {
                                        console.log("头像图像加载成功: " + source)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 消息弹窗前的半透明遮罩层
    Rectangle {
        id: messageModalOverlay
        anchors.fill: parent
        color: "#80000000"  // 半透明黑色
        visible: messagePopup.visible
        z: 105  // 确保在弹窗下面，但在其他元素上面
        
        // 点击遮罩层不关闭弹窗
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 不做任何操作
            }
        }
    }

    // 消息弹窗组件，使用Rectangle实现替代Popup
    Rectangle {
        id: messagePopup
        width: 400
        height: 200
        anchors.centerIn: parent
        visible: false  // 默认不可见
        z: 106  // 确保显示在最上层

        // 定义打开和关闭函数
        function open() {
            visible = true
        }
        
        function close() {
            visible = false
        }

        // 键盘处理，模拟Popup的CloseOnEscape功能
        Keys.onEscapePressed: {
            messagePopup.close()
        }

        color: "#333333"
        border.color: "#666666"
        border.width: 2
        radius: 10

        // 内容部分
        Item {
            anchors.fill: parent

            Text {
                id: messageText
                anchors.centerIn: parent
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                width: 120
                height: 40
                background: Image {
                    source: "qrc:/images/button_bg.png"
                    fillMode: Image.Stretch
                }
                contentItem: Text {
                    text: "确定"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    messagePopup.close()
                }
            }
        }
    }

    // 为管理员密码验证弹窗添加的半透明遮罩层
    Rectangle {
        id: adminModalOverlay
        anchors.fill: parent
        color: "#80000000"  // 半透明黑色
        visible: adminPasswordPopup.visible
        z: 101  // 确保在弹窗下面，但在其他元素上面
        
        // 点击遮罩层不关闭弹窗
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 不做任何操作
            }
        }
    }

    // 使用Rectangle实现管理员密码验证弹窗，替代Popup组件
    Rectangle {
        id: adminPasswordPopup
        width: 400
        height: 250
        anchors.centerIn: parent
        visible: false  // 默认不可见
        z: 102  // 确保显示在最上层
        
        property var onPasswordVerified: null

        // 定义打开和关闭函数
        function open() {
            visible = true
            // 执行原Popup的onOpened逻辑
            adminPasswordField.text = ""
            passwordErrorText.visible = false
        }
        
        function close() {
            visible = false
        }

        // 键盘处理，模拟Popup的CloseOnEscape功能
        Keys.onEscapePressed: {
            adminPasswordPopup.close()
        }

        color: "#333333"
        border.color: "#666666"
        border.width: 2
        radius: 10

        // 内容部分
        Item {
            anchors.fill: parent

            Text {
                id: adminPasswordTitle
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "管理员身份验证"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 22
                color: "white"
            }
            
            Text {
                anchors.top: adminPasswordTitle.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "请输入管理员密码："
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "white"
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 80
                height: 40
                color: "#44ffffff"
                radius: 5

                TextField {
                    id: adminPasswordField
                    anchors.fill: parent
                    anchors.margins: 1
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                    echoMode: TextInput.Password
                    
                    background: Rectangle {
                        color: "transparent"
                    }
                    
                    onAccepted: {
                        adminPasswordPopup.verifyAdminPassword()
                    }
                }
            }
            
            Text {
                id: passwordErrorText
                anchors.top: parent.verticalCenter
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#ff6666"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 14
                visible: false
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                spacing: 30

                Button {
                    width: 120
                    height: 40
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "取消"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        adminPasswordPopup.close()
                    }
                }

                Button {
                    width: 120
                    height: 40
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "确定"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        adminPasswordPopup.verifyAdminPassword()
                    }
                }
            }
        }
        
        function verifyAdminPassword() {
            // 从数据库获取管理员密码
            var adminPassword = dbManager.getSetting("admin_password", "123456")
            
            if (adminPasswordField.text === adminPassword) {
                // 密码验证成功，关闭弹窗并执行回调
                adminPasswordPopup.close()
                if (adminPasswordPopup.onPasswordVerified) {
                    adminPasswordPopup.onPasswordVerified()
                }
            } else {
                // 密码验证失败，显示错误信息
                passwordErrorText.text = "密码错误，请重新输入"
                passwordErrorText.visible = true
            }
        }
    }

    // 添加保存人脸数据的函数
    function saveFaceData() {
        // 如果所有信息都已填写，则保存数据
        captureCanvas.width = capturedImage.paintedWidth
        captureCanvas.height = capturedImage.paintedHeight
        captureCanvas.getContext("2d").drawImage(capturedImage, 0, 0, captureCanvas.width, captureCanvas.height);
        capturedImage.source = captureCanvas.toDataURL("image/jpeg");
        
        // 确保目录存在
        var appDir = fileManager.getApplicationDir();
        var facesDir = appDir + "/faceimages";
        var avatarsDir = appDir + "/avatarimages";
        
        if (!fileManager.directoryExists(facesDir)) {
            fileManager.createDirectory(facesDir);
        }
        
        if (!fileManager.directoryExists(avatarsDir)) {
            fileManager.createDirectory(avatarsDir);
        }
        
        // 保存Canvas图像到文件
        var faceImagePath = facesDir + "/" + nameInput.text + "_" + workIdInput.text + ".jpg";
        captureCanvas.save(faceImagePath);
        
        // 复制头像图片
        var avatarImagePath = avatarsDir + "/" + nameInput.text + "_" + workIdInput.text + ".jpg";
        fileManager.copyFile(avatarPathInput.filePath, avatarImagePath);
        
        // 保存到数据库
        var isAdmin = adminRadio.checked;
        var result = dbManager.addFaceData(
            nameInput.text,
            maleRadio.checked ? "男" : "女",
            workIdInput.text,
            faceImagePath,
            avatarImagePath,
            isAdmin
        );
        
        if (!result) {
            messageText.text = "保存到数据库失败！";
            messagePopup.open();
            return;
        }
        
        console.log("保存人脸和个人信息");
        console.log("姓名: " + nameInput.text);
        console.log("性别: " + (maleRadio.checked ? "男" : "女"));
        console.log("工号: " + workIdInput.text);
        console.log("权限: " + (adminRadio.checked ? "管理员" : "普通"));
        console.log("头像路径: " + avatarImagePath);
        console.log("人脸图像已保存至: " + faceImagePath);

        // 重新从数据库加载数据到模型
        loadFaceDataFromDatabase();

        // 显示成功消息
        messageText.text = "人脸数据采集成功！";
        messagePopup.open();
        
        cameraPopup.close();

        // 通知主窗口用户列表已更新
        console.log("发出用户列表更新信号");
        userListUpdated();
    }

    // 确认对话框前的半透明遮罩层
    Rectangle {
        id: confirmModalOverlay
        anchors.fill: parent
        color: "#80000000"  // 半透明黑色
        visible: confirmDialog.visible
        z: 103  // 确保在弹窗下面，但在其他元素上面
        
        // 点击遮罩层不关闭弹窗
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 不做任何操作
            }
        }
    }

    // 确认对话框，使用Rectangle实现替代Popup
    Rectangle {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        visible: false  // 默认不可见
        z: 104  // 确保显示在最上层
        
        // 定义打开和关闭函数
        function open() {
            visible = true
        }
        
        function close() {
            visible = false
        }

        // 键盘处理，模拟Popup的CloseOnEscape功能
        Keys.onEscapePressed: {
            confirmDialog.close()
        }
        
        color: "#1e293b"
        radius: 10
        border.color: "#334155"
        border.width: 2
        
        Item {
            anchors.fill: parent
            
            Rectangle {
                id: headerRect
                width: parent.width
                height: 50
                color: "#334155"
                radius: 8
                anchors.top: parent.top
                
                Text {
                    text: "返回确认"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            
            Text {
                width: parent.width - 40
                anchors.centerIn: parent
                text: "确定要退出面容采集吗？"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "#f0f9ff"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            Rectangle {
                width: parent.width
                height: 70
                color: "transparent"
                anchors.bottom: parent.bottom
                
                Row {
                    anchors.centerIn: parent
                    spacing: 30
                    
                    // 取消按钮
                    Button {
                        width: 120
                        height: 40
                        background: Rectangle {
                            radius: 6
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#64748b" }
                                GradientStop { position: 1.0; color: "#475569" }
                            }
                        }
                        contentItem: Text {
                            text: "取消"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            confirmDialog.close()
                        }
                    }
                    
                    // 确认按钮
                    Button {
                        width: 120
                        height: 40
                        background: Rectangle {
                            radius: 6
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#0891b2" }
                                GradientStop { position: 1.0; color: "#0e7490" }
                            }
                        }
                        contentItem: Text {
                            text: "确认"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            // 确保在返回前清理所有状态
                            if (camera) {
                                console.log("关闭摄像头...")
                                camera.active = false
                                // 不再将null赋值给cameraDevice，避免Qt 6中的错误
                                // camera.cameraDevice = null
                            }
                            
                            // 停止所有定时器
                            if (firstInitTimer.running)
                                firstInitTimer.stop()
                            if (cameraMonitorTimer && cameraMonitorTimer.running)
                                cameraMonitorTimer.stop()
                            
                            if (messagePopup.visible) {
                                messagePopup.close()
                            }
                            
                            // 获取主页引用
                            var mainPage = stackView.get(0)
                            
                            // 确保返回时显示中间列，隐藏个人数据页面
                            if (mainPage) {
                                console.log("确保返回时显示中间列，隐藏个人数据页面");
                                if (mainPage.middle_column) {
                                    mainPage.middle_column.visible = true;
                                }
                                if (mainPage.user_practice_data) {
                                    mainPage.user_practice_data.visible = false;
                                }
                            }
                            
                            console.log("返回上一页面")
                            stackView.pop()
                            confirmDialog.close()
                        }
                    }
                }
            }
        }
    }

    // 页面销毁时关闭摄像头
    Component.onDestruction: {
        console.log("FaceCollectionPage即将销毁 - 停止所有定时器和摄像头")
        
        // 停止所有定时器
        if (firstInitTimer.running)
            firstInitTimer.stop()
            
        if (cameraMonitorTimer && cameraMonitorTimer.running)
            cameraMonitorTimer.stop()
        
        // 彻底停止摄像头
        if (camera) {
            console.log("正在停止摄像头...")
            camera.active = false
            
            // 不再将null赋值给cameraDevice，避免Qt 6中的错误
            // camera.cameraDevice = null
        }
        
        // 重置所有变换，确保不会影响其他页面
        if (videoOutput) {
            console.log("完全重置VideoOutput所有属性")
            videoOutput.rotation = 0
            
            // 创建新的简单变换作为最终状态
            var newTransform = []
            newTransform.push(Qt.createQmlObject(
                'import QtQuick 2.15; Scale { xScale: -1; yScale: 1; origin.x: videoOutput.width / 2 }',
                videoOutput, 
                "dynamicFinalTransform"
            ));
            videoOutput.transform = newTransform
        }
    }

    // 组件可见性变化时
    onVisibleChanged: {
        if (visible) {
            console.log("FaceCollectionPage变为可见，确保摄像头设置正确")
            // 确保VideoOutput变换设置正确
            Qt.callLater(function() {
                // 重置VideoOutput的变换，确保只有水平镜像，没有垂直翻转
                if (videoOutput) {
                    console.log("重置VideoOutput所有变换和属性")
                    videoOutput.rotation = 0
                    
                    // 重新创建和设置变换
                    var newTransform = []
                    newTransform.push(Qt.createQmlObject(
                        'import QtQuick 2.15; Scale { xScale: -1; yScale: 1; origin.x: videoOutput.width / 2 }',
                        videoOutput, 
                        "dynamicVisibleTransform"
                    ));
                    videoOutput.transform = newTransform
                }
            })
        }
    }

    // 定义水平镜像变换，用于重置
    Scale {
        id: scaleTransform
        xScale: -1
        origin.x: 0
    }

    // 全局路径处理函数
    function processImagePath(path) {
        if (!path || path.toString().trim() === "") {
            return ""; 
        }
        
        var fixedPath = path.toString().trim();
        console.log("处理图像路径: " + fixedPath);
        
        // 该路径已经是QUrl格式，直接返回
        if (fixedPath.startsWith("file:///")) {
            return fixedPath;
        }
        
        // 替换反斜杠为正斜杠
        fixedPath = fixedPath.replace(/\\/g, "/");
        
        // 确保有file:///前缀
        if (!fixedPath.startsWith("file:///")) {
            fixedPath = "file:///" + fixedPath;
        }
        
        console.log("处理后的路径: " + fixedPath);
        return fixedPath;
    }
}
