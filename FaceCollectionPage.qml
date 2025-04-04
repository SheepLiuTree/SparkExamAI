import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtMultimedia 5.15
import QtQuick.Dialogs 1.3

Rectangle {
    color: "transparent" 

    // 创建一个ListModel来存储采集的人脸数据
    ListModel {
        id: faceCollectionModel
    }

    // 组件加载完成后，从数据库加载数据
    Component.onCompleted: {
        // 加载面部数据列表
        loadFaceDataFromDatabase()
        
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
            stackView.pop()
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
            
            // 获取当前摄像头设置并应用
            var savedCameraId = dbManager.getSetting("camera_device", "")
            if (savedCameraId !== "") {
                camera.deviceId = savedCameraId
                console.log("使用设置的摄像头ID:", savedCameraId)
            } else {
                camera.deviceId = QtMultimedia.defaultCamera.deviceId
                console.log("使用默认摄像头")
            }
            
            camera.start()
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

                Camera {
                    id: camera
                    
                    viewfinder.resolution: Qt.size(640, 360)
                    
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
                                    var result = dbManager.deleteFaceData(workId);
                                    
                                    if (result) {
                                        // 从模型中删除数据
                                        faceCollectionModel.remove(index);
                                        messageText.text = "数据已成功删除！";
                                    } else {
                                        messageText.text = "删除数据失败！";
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
    }
}
