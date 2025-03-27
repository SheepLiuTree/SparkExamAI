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
        loadFaceDataFromDatabase();
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
                    // 设置摄像头为摄像头2
                    deviceId: {
                        // 获取可用摄像头列表
                        var cameras = QtMultimedia.availableCameras
                        // 如果有多个摄像头，选择第二个（索引为1）
                        if (cameras.length > 1) {
                            return cameras[2].deviceId
                        } else {
                            // 如果只有一个摄像头，使用默认摄像头
                            return QtMultimedia.defaultCamera.deviceId
                        }
                    }
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
                    focus: visible
                    autoOrientation: true
                }

                Image {
                    id: capturedImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
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
                            });
                            capturedImage.visible = true
                            videoOutput.visible = false
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

                        // 如果所有信息都已填写，则保存数据
                        captureCanvas.getContext("2d").drawImage(capturedImage, 0, 0, capturedImage.width, capturedImage.height);
                        capturedImage.source = captureCanvas.toDataURL("image/jpeg");
                        
                        // 保存Canvas图像到文件
                        var faceImagePath = fileManager.getApplicationDir() + "/faceimages/" + nameInput.text + ".jpg";
                        captureCanvas.save(faceImagePath);
                        
                        // 复制头像图片
                        var avatarImagePath = fileManager.getApplicationDir() + "/avatarimages/" + nameInput.text + ".jpg";
                        fileManager.copyFile(avatarPathInput.filePath, "avatarimages/" + nameInput.text + ".jpg");
                        
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
                        width: parent.width * 0.2
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
                        width: parent.width * 0.2
                        height: parent.height
                        text: "工号"
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
                            width: parent.width * 0.2
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
                            width: parent.width * 0.2
                            height: parent.height
                            text: workId
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
}
