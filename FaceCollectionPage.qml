import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtMultimedia 5.15
import QtQuick.Dialogs 1.3

Rectangle {
    color: "transparent" 
    objectName: "FaceCollectionPage"

    // 添加信号，用于通知主窗口用户列表已更新
    signal userListUpdated()

    // 创建一个ListModel来存储采集的人脸数据
    ListModel {
        id: faceCollectionModel
    }

    // 定义顶级摄像头组件
    Camera {
        id: camera
        viewfinder.resolution: Qt.size(640, 360)
        deviceId: ""  // 初始为空，在初始化函数中设置正确的值
            
        imageCapture {
            onImageCaptured: {
                console.log("Image captured with id: " + requestId)
                capturedImage.source = preview
            }
            onImageSaved: {
                console.log("Image saved as: " + path)
                fileManager.moveFile(path, "faceimages/" + nameInput.text + ".jpg")
            }
        }
        
        onCameraStateChanged: {
            console.log("摄像头状态变化:", cameraState)
            if (cameraState === Camera.ActiveState) {
                cameraReady = true
                console.log("摄像头已激活，使用的设备ID:", deviceId)
            } else {
                cameraReady = false
            }
        }
        
        onErrorChanged: {
            if (error !== Camera.NoError) {
                console.log("摄像头错误:", error, errorString)
            }
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
        if (camera.cameraState === Camera.ActiveState) {
            console.log("摄像头已在活动状态，先停止")
            camera.stop()
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
        var cameras = QtMultimedia.availableCameras
        console.log("可用摄像头数量:", cameras.length)
        for (var i = 0; i < cameras.length; i++) {
            console.log("摄像头 #" + i + ": " + cameras[i].deviceId + " - " + cameras[i].displayName)
        }
        
        // 设置摄像头ID
        if (savedCameraId === "auto") {
            // 自动模式，使用默认摄像头
            if (cameras.length > 0) {
                camera.deviceId = QtMultimedia.defaultCamera.deviceId
                console.log("使用默认摄像头:", camera.deviceId)
            } else {
                console.log("没有可用摄像头!")
                return
            }
        } else if (savedCameraId !== "") {
            // 使用指定的摄像头ID
            var foundDevice = false
            // 先检查指定的ID是否在可用列表中
            for (var i = 0; i < cameras.length; i++) {
                if (cameras[i].deviceId === savedCameraId) {
                    foundDevice = true
                    break
                }
            }
            
            if (foundDevice) {
                camera.deviceId = savedCameraId
                console.log("使用指定摄像头:", savedCameraId)
            } else {
                console.log("指定的摄像头不可用，使用默认摄像头")
                if (cameras.length > 0) {
                    camera.deviceId = QtMultimedia.defaultCamera.deviceId
                    console.log("退回到默认摄像头:", camera.deviceId)
                } else {
                    console.log("没有可用摄像头!")
                    return
                }
            }
        } else {
            // 空设置，使用默认摄像头
            if (cameras.length > 0) {
                camera.deviceId = QtMultimedia.defaultCamera.deviceId
                console.log("使用默认摄像头:", camera.deviceId)
            } else {
                console.log("没有可用摄像头!")
                return
            }
        }
        
        // 记录当前使用的摄像头ID
        console.log("最终设置的摄像头ID:", camera.deviceId)
        
        // 启动摄像头
        console.log("启动摄像头...")
        camera.start()
        
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
            console.log("监视摄像头状态:", camera.cameraState, "就绪:", cameraReady, "次数:", checkCount)
            
            if (cameraReady) {
                console.log("摄像头就绪，停止监视")
                cameraMonitorTimer.stop()
                checkCount = 0
            } else if (checkCount >= 5) {
                console.log("摄像头未就绪，重试初始化")
                camera.stop()
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
        
        // 将数据添加到模型中
        for (var i = 0; i < faceList.length; i++) {
            var face = faceList[i];
            faceCollectionModel.append({
                "name": face.name,
                "gender": face.gender,
                "workId": face.workId,
                "faceImage": face.faceImage,
                "avatarPath": face.avatarPath,
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

    Popup {
        id: cameraPopup
        width: 900
        height: 500
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape

        onOpened: {
            capturedImage.visible = false
            videoOutput.visible = true
            capturedImage.source = ""
            
            nameInput.text = ""
            workIdInput.text = ""
            maleRadio.checked = true
            normalRadio.checked = true
            avatarPathInput.text = ""
            avatarPathInput.filePath = ""
            
            console.log("相机弹窗打开 - 摄像头状态:", camera.cameraState, "就绪:", cameraReady)
            
            // 始终重新初始化摄像头，确保使用正确的设备
            console.log("重新初始化摄像头以确保使用正确的设备")
            
            // 如果摄像头在活动状态，先停止
            if (camera.cameraState === Camera.ActiveState) {
                camera.stop()
                // 短暂延迟后重新初始化
                Qt.callLater(function() {
                    initCamera()
                })
            } else {
                // 直接初始化
                initCamera()
            }
        }
        
        onClosed: {
            console.log("相机弹窗关闭 - 不停止摄像头，保持运行状态")
        }

        background: Rectangle {
            color: "#333333"
            border.color: "#666666"
            border.width: 2
            radius: 10
        }

        contentItem: Item {
            anchors.fill: parent

            Rectangle {
                id: cameraViewfinder
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                width: parent.width * 0.5 - 30
                height: parent.height - 100
                color: "black"

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
                    
                    // 计算实际视频内容区域
                    property rect contentRect: {
                        if (sourceRect.width <= 0 || sourceRect.height <= 0) {
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
                
                // 顶部指导文字
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: guideText.width + 20
                    height: guideText.height + 10
                    color: "#AA000000"
                    radius: 5
                    
                    Text {
                        id: guideText
                        anchors.centerIn: parent
                        text: "请将脸部对准绿色框内"
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
                    
                    // 椭圆形引导框 - 旋转90度垂直放置
                    Rectangle {
                        id: clearArea
                        color: "transparent"
                        border.width: 2  // 增加边框宽度，提高清晰度
                        border.color: "#4AFF4A"  // 更亮的绿色，提高对比度
                        anchors.centerIn: parent
                        // 交换宽高以旋转90度
                        width: videoOutput.contentRect.height
                        height: videoOutput.contentRect.width * 0.5
                        radius: Math.min(width, height) / 2
                        
                        // 添加旋转变换
                        transform: Rotation {
                            angle: 90
                            origin.x: clearArea.width / 2
                            origin.y: clearArea.height / 2
                        }
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
                width: parent.width * 0.5 - 30
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

                            TextInput {
                                id: nameInput
                                anchors.fill: parent
                                anchors.margins: 5
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
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

                            TextInput {
                                id: workIdInput
                                anchors.fill: parent
                                anchors.margins: 5
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
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
                folder: shortcuts.pictures
                nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.bmp)"]
                selectMultiple: false

                onAccepted: {
                    console.log("选择的文件: " + fileDialog.fileUrl)
                    var filePath = fileDialog.fileUrl.toString().replace("file:///", "")
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
                                source: faceImage ? "file:///" + faceImage : ""
                                fillMode: Image.PreserveAspectFit
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
                                source: avatarPath ? "file:///" + avatarPath : ""
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    }
                }
            }
        }
    }

    // 添加一个消息弹窗组件
    Popup {
        id: messagePopup
        width: 400
        height: 200
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#333333"
            border.color: "#666666"
            border.width: 2
            radius: 10
        }

        contentItem: Item {
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

    // 添加管理员密码验证弹窗
    Popup {
        id: adminPasswordPopup
        width: 400
        height: 250
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property var onPasswordVerified: null

        background: Rectangle {
            color: "#333333"
            border.color: "#666666"
            border.width: 2
            radius: 10
        }

        contentItem: Item {
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
                    anchors.margins: 5
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                    placeholderText: "请输入管理员密码"
                    placeholderTextColor: "#cccccc"
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
        
        onOpened: {
            adminPasswordField.text = ""
            passwordErrorText.visible = false
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

    // 确认对话框
    Popup {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#1e293b"
            radius: 10
            border.color: "#334155"
            border.width: 2
        }
        
        contentItem: Item {
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
                                camera.stop()
                                // 设置deviceId为空，彻底释放资源
                                camera.deviceId = ""
                            }
                            
                            // 停止所有定时器
                            if (firstInitTimer.running)
                                firstInitTimer.stop()
                            if (cameraMonitorTimer && cameraMonitorTimer.running)
                                cameraMonitorTimer.stop()
                            
                            if (messagePopup.visible) {
                                messagePopup.close()
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
            camera.stop()
            
            // 设置deviceId为空，彻底释放资源
            camera.deviceId = ""
        }
    }
}
