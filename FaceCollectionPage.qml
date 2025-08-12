import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
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

    // 组件加载完成后，从数据库加载数据
    Component.onCompleted: {
        loadFaceDataFromDatabase()
        console.log("FaceCollectionPage完成加载")
    }

    // 从数据库加载人脸数据的函数
    function loadFaceDataFromDatabase() {
        faceCollectionModel.clear()
        var faceList = dbManager.getAllFaceData()
        console.log("从数据库获取到 " + faceList.length + " 条人脸数据")
        
        for (var i = 0; i < faceList.length; i++) {
            var face = faceList[i]
            faceCollectionModel.append({
                "name": face.name,
                "gender": face.gender,
                "workId": face.workId,
                "faceImage": face.faceImage,
                "avatarPath": face.avatarPath,
                "isAdmin": face.isAdmin
            })
        }
    }

    // 删除用户数据的函数
    function deleteUserData(workId, name) {
        console.log("删除用户函数被调用，工号:", workId, "姓名:", name)
        // 确认删除
        confirmDeleteText.text = "确定要删除用户 " + name + " (" + workId + ") 吗？"
        confirmDeleteDialog.workIdToDelete = workId
        console.log("准备打开确认删除对话框")
        confirmDeleteDialog.open()
        console.log("确认删除对话框应该已打开")
    }

    // 执行删除操作
    function performDelete(workId) {
        console.log("开始执行删除操作，工号:", workId)
        
        // 从数据库删除用户
        var result = dbManager.deleteFaceData(workId)
        console.log("数据库删除操作结果:", result)
        
        if (!result) {
            console.log("删除用户失败，显示错误消息")
            messageText.text = "删除用户失败！"
            messagePopup.open()
            return
        }
        
        console.log("删除用户成功")
        
        // 重新从数据库加载数据到模型
        loadFaceDataFromDatabase()
        
        // 显示成功消息
        messageText.text = "用户删除成功！"
        messagePopup.open()
        
        // 通知用户列表已更新
        userListUpdated()
    }

    // 保存用户数据的函数（去掉面容采集）
    function saveUserData() {
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

        if (passwordInput.text === "") {
            messageText.text = "请输入密码"
            messagePopup.open()
            return
        }

        if (passwordInput.text !== confirmPasswordInput.text) {
            messageText.text = "两次输入的密码不一致"
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

        // 确保目录存在
        var appDir = fileManager.getApplicationDir()
        var avatarsDir = appDir + "/avatarimages"
        
        if (!fileManager.directoryExists(avatarsDir)) {
            fileManager.createDirectory(avatarsDir)
        }
        
        // 检查源文件是否存在
        var sourcePath = avatarPathInput.text.trim()
        if (!sourcePath || sourcePath === "") {
            messageText.text = "请选择有效的头像文件"
            messagePopup.open()
            return
        }
        
        // 检查文件是否存在
        if (!fileManager.fileExists(sourcePath)) {
            messageText.text = "头像文件不存在，请重新选择"
            console.log("文件不存在:", sourcePath)
            messagePopup.open()
            return
        }
        
        // 复制头像图片
        var avatarImagePath = avatarsDir + "/" + nameInput.text + "_" + workIdInput.text + ".jpg"
        
        console.log("源文件路径:", sourcePath)
        console.log("目标文件路径:", avatarImagePath)
        console.log("目录存在:", fileManager.directoryExists(avatarsDir))
        console.log("源文件存在:", fileManager.fileExists(sourcePath))
        
        var copyResult = fileManager.copyFile(sourcePath, avatarImagePath)
        if (!copyResult) {
            messageText.text = "头像文件复制失败！请检查文件路径和权限"
            console.log("复制失败，请检查：")
            console.log("1. 源文件路径:", sourcePath)
            console.log("2. 源文件是否存在:", fileManager.fileExists(sourcePath))
            console.log("3. 目标目录:", avatarsDir)
            console.log("4. 目录是否存在:", fileManager.directoryExists(avatarsDir))
            messagePopup.open()
            return
        }
        
        console.log("头像文件复制成功:", avatarImagePath)
        
        // 保存到数据库（不再保存人脸图像）
        var isAdmin = adminRadio.checked
        var gender = maleRadio.checked ? "男" : "女"
        console.log("调用addUserData参数：")
        console.log("  name:", nameInput.text)
        console.log("  gender:", gender)
        console.log("  workId:", workIdInput.text)
        console.log("  avatarPath:", avatarImagePath)
        console.log("  isAdmin:", isAdmin)
        console.log("  password:", passwordInput.text)
        
        var result = dbManager.addUserData(
            nameInput.text,
            gender,
            workIdInput.text,
            avatarImagePath,
            isAdmin,
            passwordInput.text
        )
        
        if (!result) {
            messageText.text = "保存到数据库失败！"
            messagePopup.open()
            return
        }
        
        console.log("保存用户信息成功")
        
        // 重新从数据库加载数据到模型
        loadFaceDataFromDatabase()

        // 显示成功消息
        messageText.text = "人员信息采集成功！"
        messagePopup.open()
        
        collectionPopup.close()
        userListUpdated()
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
        onClicked: stackView.pop()
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
            text: "人员采集"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 18
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: collectionPopup.open()
    }

    // 人员采集弹窗
    Popup {
        id: collectionPopup
        width: 500
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: parent

        background: Rectangle {
            color: "#f5f5f5"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 10
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "人员信息采集"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "#333"
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: nameInput
                placeholderText: "请输入姓名"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                width: parent.width
            }

            TextField {
                id: workIdInput
                placeholderText: "请输入工号"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                width: parent.width
            }

            Row {
                spacing: 20
                width: parent.width

                RadioButton {
                    id: maleRadio
                    text: "男"
                    checked: true
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                }

                RadioButton {
                    id: femaleRadio
                    text: "女"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                }
            }

            TextField {
                id: passwordInput
                placeholderText: "请输入密码"
                echoMode: TextInput.Password
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                width: parent.width
            }

            TextField {
                id: confirmPasswordInput
                placeholderText: "请确认密码"
                echoMode: TextInput.Password
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                width: parent.width
            }

            Row {
                spacing: 10
                width: parent.width

                TextField {
                    id: avatarPathInput
                    placeholderText: "请选择头像路径"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    width: parent.width - 80
                }

                Button {
                    text: "浏览"
                    width: 70
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: fileDialog.open()
                }
            }

            Row {
                spacing: 20
                width: parent.width

                RadioButton {
                    id: normalRadio
                    text: "普通用户"
                    checked: true
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                }

                RadioButton {
                    id: adminRadio
                    text: "管理员"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                }
            }

            Row {
                spacing: 20
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "取消"
                    width: 100
                    height: 35
                    onClicked: collectionPopup.close()
                }

                Button {
                    text: "保存"
                    width: 100
                    height: 35
                    onClicked: saveUserData()
                }
            }
        }
    }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择头像图片"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif)"]
        folder: shortcuts.home
        selectExisting: true
        selectMultiple: false
        onAccepted: {
            if (fileDialog.fileUrls.length > 0) {
                var fileUrl = fileDialog.fileUrls[0]
                var filePath = fileUrl.toString()
                
                // 处理Windows路径
                if (filePath.startsWith("file:///")) {
                    filePath = filePath.substring(8)  // 移除 "file:///"
                } else if (filePath.startsWith("file://")) {
                    filePath = filePath.substring(5)  // 移除 "file://"
                }
                
                // 处理Windows路径中的正斜杠
                if (Qt.platform.os === "windows") {
                    filePath = filePath.replace(/\//g, "\\")
                }
                
                console.log("选择的文件URL:", fileUrl)
                console.log("转换后的本地路径:", filePath)
                avatarPathInput.text = filePath
            }
        }
        onRejected: {
            console.log("文件选择已取消")
        }
    }

    // 消息弹窗
    Popup {
        id: messagePopup
        width: 300
        height: 150
        modal: true
        anchors.centerIn: parent

        background: Rectangle {
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 10
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: messageText
                text: ""
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "#333"
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "确定"
                width: 80
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: messagePopup.close()
            }
        }
    }

    // 确认删除对话框
    Popup {
        id: confirmDeleteDialog
        width: 300
        height: 150
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        z: 1000
        anchors.centerIn: parent
        
        // 自定义属性，存储要删除的工号
        property string workIdToDelete: ""

        background: Rectangle {
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 10
        }
        
        // 弹窗打开时的调试信息
        onOpened: {
            console.log("确认删除对话框已打开，要删除的工号:", workIdToDelete)
        }
        
        // 弹窗关闭时的调试信息
        onClosed: {
            console.log("确认删除对话框已关闭")
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: confirmDeleteText
                text: ""
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "#333"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width - 40
            }

            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "是"
                    width: 80
                    height: 30
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#ff6b6b"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "是"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("点击了'是'按钮，准备删除用户")
                        performDelete(confirmDeleteDialog.workIdToDelete)
                        confirmDeleteDialog.close()
                    }
                }

                Button {
                    text: "否"
                    width: 80
                    height: 30
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "否"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "#333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("点击了'否'按钮，取消删除操作")
                        confirmDeleteDialog.close()
                    }
                }
            }
        }
    }

    // 用户列表视图
    ListView {
        id: userListView
        anchors.top: backButton.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        clip: true
        spacing: 10
        model: faceCollectionModel

        delegate: Rectangle {
            width: parent.width
            height: 80
            color: "transparent"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 5

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Image {
                    width: 60
                    height: 60
                    source: avatarPath
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }

                Column {
                    spacing: 5
                    width: parent.width - 140

                    Text {
                        text: name + " (" + workId + ")"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "#333"
                    }

                    Text {
                        text: gender
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "#666"
                    }

                    Text {
                        text: isAdmin ? "管理员" : "普通用户"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: isAdmin ? "#ff6b6b" : "#4ecdc4"
                    }
                }

                Button {
                    width: 60
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: "#ff6b6b"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "删除"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: deleteUserData(workId, name)
                }
            }
        }
    }
}
