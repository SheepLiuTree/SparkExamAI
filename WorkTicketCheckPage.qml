import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtWebEngine 1.8

Rectangle {
    id: workTicketCheckPage
    color: "transparent"
    // 是否已登录状态
    property bool isLoggedIn: false

    // 设置全局样式
    Component.onCompleted: {
        Material.theme = Material.Dark
        Material.accent = Material.Blue
    }

    // 自定义提示对话框组件
    Component {
        id: messageDialog
        Dialog {
            id: dialog
            modal: true
            anchors.centerIn: parent
            width: 300
            height: 180
            background: Rectangle {
                color: "#FFFFFF"
                radius: 10
            }

            // 声明message属性
            property string message: ""
            // 声明确认信号
            signal confirmed()

            // 标题栏
            Rectangle {
                id: titleBar
                width: parent.width
                height: 40
                color: "red"
                radius: 10

                Text {
                    anchors.centerIn: parent
                    text: "提示"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "white"
                }
            }

            // 内容区域
            Column {
                width: parent.width
                anchors.top: titleBar.bottom
                anchors.topMargin: 20
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dialog.message
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#666666"
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    Rectangle {
                        width: 100
                        height: 36
                        radius: 18
                        color: "#808080"

                        Text {
                            anchors.centerIn: parent
                            text: "取消"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: dialog.close()
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 36
                        radius: 18
                        color: "#2196F3"

                        Text {
                            anchors.centerIn: parent
                            text: "确定"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dialog.confirmed()
                                dialog.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // 显示提示对话框的函数
    function showMessage(title, message) {
        var dialog = messageDialog.createObject(workTicketCheckPage, {
            "message": message
        })
        dialog.open()
    }

    // 登录弹窗
    Rectangle {
        id: loginDialog
        width: 400
        height: 300
        radius: 10
        color: "#FFFFFF"
        visible: false
        anchors.centerIn: parent

        // 是否显示新增账户表单
        property bool showAddAccount: false

        // 半透明背景遮罩
        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            visible: loginDialog.visible
            z: -1
        }

        // 标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height: 50
            color: "#2196F3"
            radius: 10

            Text {
                anchors.centerIn: parent
                text: loginDialog.showAddAccount ? "新增账户" : "用户登录"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                color: "white"
            }

            // 关闭按钮
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: closeMouseArea.containsMouse ? "#FF5252" : "transparent"
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: 24
                    color: "white"
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        loginDialog.visible = false
                        loginDialog.showAddAccount = false
                    }
                }
            }
        }

        // 登录表单
        Column {
            anchors.top: titleBar.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: 20
            width: parent.width * 0.8
            visible: !loginDialog.showAddAccount

            // 新增账户按钮
            Rectangle {
                width: parent.width
                height: 40
                color: "#808080"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "+ 新增账户"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        loginDialog.showAddAccount = true
                    }
                }
            }

            // 账户列表
            Rectangle {
                width: parent.width
                height: parent.height - titleBar.height - 15  // 减去标题栏高度和上下边距
                color: "#F5F5F5"
                radius: 5

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 5
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: ListModel { id: accountModel }

                            Rectangle {
                                width: parent.width
                                height: 40
                                radius: 5
                                color: mouseArea.containsMouse ? "#E3F2FD" : "#FFFFFF"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    Text {
                                        id: usernameText
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.username
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 14
                                        color: "#333333"
                                        elide: Text.ElideRight
                                    }
                                }

                                // 右键菜单
                                Menu {
                                    id: contextMenu
                                    MenuItem {
                                        text: "删除账户"
                                        onTriggered: {
                                            // 显示确认对话框
                                            var dialog = messageDialog.createObject(workTicketCheckPage, {
                                                "message": "确定要删除账户 " + model.username + " 吗？"
                                            })
                                            
                                            // 连接对话框的确认按钮点击事件
                                            dialog.confirmed.connect(function() {
                                                // 删除账户
                                                if (dbManager.deleteAccount(model.workId)) {
                                                    // 从列表中移除
                                                    accountModel.remove(index)
                                                    showMessage("提示", "账户删除成功")
                                                } else {
                                                    showMessage("错误", "账户删除失败")
                                                }
                                            })
                                            
                                            dialog.open()
                                        }
                                    }
                                }

                                // 将登录点击区域限制在用户名区域
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.LeftButton) {
                                            // 处理账户选择逻辑        
                                            // 更新按钮文本为"登录中..."
                                            loginButtonText.text = "登录中..."
                                            loginButton.enabled = false                                    
                                            loginDialog.visible = false
                                            
                                            // 在网页中填写工号和密码
                                            webView.runJavaScript(
                                                "document.getElementById('p_username').value = '" + model.workId + "';" +
                                                "document.getElementById('p_password').value = '" + model.password + "';" +
                                                "document.querySelector('button#login.log-btn[type=\"submit\"]').click();"
                                            )
                                            // 创建定时器监测登录状态
                                            var checkLoginTimer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', loginButton, "checkLoginTimer");
                                            checkLoginTimer.interval = 1000; // 每秒检查一次
                                            checkLoginTimer.repeat = true;
                                            checkLoginTimer.triggered.connect(function() {
                                                webView.runJavaScript(
                                                    "document.documentElement.outerHTML",
                                                    function(result) {
                                                        if (result.indexOf("施工调度管理二期系统【正式环境】") !== -1) {
                                                            // 登录成功
                                                            isLoggedIn = true;
                                                            checkLoginTimer.stop();
                                                            checkLoginTimer.destroy();
                                                            loginButtonText.text = "登录成功-"+ model.username;
                                                            loginButton.enabled = true;
                                                        }
                                                    }
                                                );
                                            });
                                            checkLoginTimer.start();
                                        } else if (mouse.button === Qt.RightButton) {
                                            // 显示右键菜单
                                            contextMenu.popup()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 组件加载时从数据库加载账户列表
                Component.onCompleted: {
                    var accounts = dbManager.getAllAccounts()
                    accountModel.clear()
                    for (var i = 0; i < accounts.length; i++) {
                        accountModel.append({
                            "username": accounts[i].username,
                            "workId": accounts[i].workId,  // 确保添加workId
                            "password": accounts[i].password  // 添加password字段
                        })
                    }
                }
            }
        }

        // 新增账户表单
        Column {
            anchors.top: titleBar.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            width: parent.width * 0.8
            visible: loginDialog.showAddAccount

            // 用户名输入行
            Row {
                width: parent.width
                height: 40
                spacing: 20

                Text {
                    width: 80
                    height: parent.height
                    text: "用户名："
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: parent.width - 100
                    height: parent.height
                    radius: 5
                    color: "#F5F5F5"

                    TextInput {
                        id: newUsernameInput
                        anchors.fill: parent
                        anchors.margins: 10
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }
            }

            // 工号输入行
            Row {
                width: parent.width
                height: 40
                spacing: 20

                Text {
                    width: 80
                    height: parent.height
                    text: "工号："
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: parent.width - 100
                    height: parent.height
                    radius: 5
                    color: "#F5F5F5"

                    TextInput {
                        id: workIdInput
                        anchors.fill: parent
                        anchors.margins: 10
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }
            }

            // 密码输入行
            Row {
                width: parent.width
                height: 40
                spacing: 20

                Text {
                    width: 80
                    height: parent.height
                    text: "密码："
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: parent.width - 100
                    height: parent.height
                    radius: 5
                    color: "#F5F5F5"

                    TextInput {
                        id: newPasswordInput
                        anchors.fill: parent
                        anchors.margins: 10
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }
            }

            // 按钮行
            Row {
                width: parent.width
                height: 40
                spacing: 20

// 返回登录按钮
                Rectangle {
                    width: (parent.width - 20) / 2
                    height: parent.height
                    color: "#808080"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "返回登录"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            loginDialog.showAddAccount = false
                        }
                    }
                }

                // 保存按钮
                Rectangle {
                    width: (parent.width - 20) / 2
                    height: parent.height
                    radius: 5
                    color: saveButtonMouseArea.pressed ? "#1976D2" : "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: "保存"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                    }

                    MouseArea {
                        id: saveButtonMouseArea
                        anchors.fill: parent
                        onClicked: {
                            // 检查表单是否为空
                            if (!newUsernameInput.text) {
                                showMessage("错误", "用户名不能为空")
                                return
                            }
                            if (!workIdInput.text) {
                                showMessage("错误", "工号不能为空")
                                return
                            }
                            if (!newPasswordInput.text) {
                                showMessage("错误", "密码不能为空")
                                return
                            }

                            // 调用数据库管理器保存账户信息
                            var success = dbManager.addAccount(
                                newUsernameInput.text,
                                workIdInput.text,
                                newPasswordInput.text
                            );
                            
                            if (success) {
                                // 保存成功，添加到账户列表
                                accountModel.append({
                                    "username": newUsernameInput.text,
                                    "workId": workIdInput.text
                                })
                                
                                // 清空表单并返回登录界面
                                newUsernameInput.text = ""
                                workIdInput.text = ""
                                newPasswordInput.text = ""
                                loginDialog.showAddAccount = false
                                
                                // 显示成功提示
                                showMessage("提示", "账户添加成功")
                            } else {
                                // 保存失败，显示错误信息
                                showMessage("错误", "保存失败，工号可能已存在")
                            }
                        }
                    }
                }            
            }
        }
    }

    // 返回按钮
    Rectangle {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: 100
        height: 40
        color: "transparent"
        radius: 5

        Image {
            anchors.fill: parent
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }

        Text {
            anchors.centerIn: parent
            text: "返回"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 18
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 返回上一页
                if (stackView) stackView.pop()
            }
        }
    }

    // 页面标题
    Text {
        id: pageTitle
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: "工作票核对"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 36
        color: "white"
        font.bold: true
    }

    // 添加网页加载组件
    Rectangle {
        id: webViewContainer
        anchors.left: pageTitle.right
        anchors.leftMargin: 20
        anchors.verticalCenter: pageTitle.verticalCenter
        width: 300
        height: 250
        color: "#33ffffff"
        radius: 5

        WebEngineView {
            id: webView
            anchors.fill: parent
            url: "http://172.16.200.120/qdsg2/login.jsp"
        }
    }

    // 定时器用于定期检查页面内容
    Timer {
        id: checkTimer
        interval: 1000  // 每秒检查一次
        repeat: true
        running: true
        onTriggered: {
            if (webView.loading) return
            webView.runJavaScript("document.body.innerHTML", function(result) {
                if (result && result.includes("请输入用户名")) {
                    // 启用登录按钮
                    loginButton.enabled = true
                    loginButton.opacity = 1.0
                    // 停止定时器
                    checkTimer.stop()
                } else {
                    // 禁用登录按钮
                    loginButton.enabled = false
                    loginButton.opacity = 0.7
                }
            })
        }
    }

    // 菜单区域
    Rectangle {
        id: menuBar
        anchors.top: pageTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.9
        height: 60
        color: "#33ffffff"
        radius: 20

        // 左侧按钮组
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30
            
            Rectangle {
                width: 160
                height: 40
                radius: 15
                color: !workTicketCheckPage.isLoggedIn ? "#CCCCCC" : (mouseArea1.pressed ? "#4a90e2" : "#2196F3")
                opacity: !workTicketCheckPage.isLoggedIn ? 0.7 : 1.0

                Text {
                    anchors.centerIn: parent
                    text: "第一种工作票获取"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                }

                MouseArea {
                    id: mouseArea1
                    anchors.fill: parent
                    enabled: workTicketCheckPage.isLoggedIn
                    onClicked: { /* TODO: 第一种工作票获取逻辑 */ }
                }
            }

            Rectangle {
                width: 160
                height: 40
                radius: 15
                color: !workTicketCheckPage.isLoggedIn ? "#CCCCCC" : (mouseArea2.pressed ? "#4a90e2" : "#2196F3")
                opacity: !workTicketCheckPage.isLoggedIn ? 0.7 : 1.0

                Text {
                    anchors.centerIn: parent
                    text: "第二种工作票获取"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                }

                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    enabled: workTicketCheckPage.isLoggedIn
                    onClicked: { /* TODO: 第二种工作票获取逻辑 */ }
                }
            }
        }

        // 中间登录按钮
        Rectangle {
            id: loginButton
            width: 180
            height: 40
            radius: 15
            color: loginMouseArea.pressed ? "#4a90e2" : "#2196F3"
            anchors.centerIn: parent
            enabled: false  // 初始状态禁用
            opacity: 0.7    // 初始状态半透明

            Text {
                id: loginButtonText
                anchors.centerIn: parent
                text: workTicketCheckPage.isLoggedIn ? "已登录" : "登录"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
            }

            MouseArea {
                id: loginMouseArea
                anchors.fill: parent
                onClicked: { 
                    if (!workTicketCheckPage.isLoggedIn) {
                        loginDialog.visible = true
                    }
                }
            }
        }

        // 右侧按钮组
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30
            
            Rectangle {
                width: 140
                height: 40
                radius: 15
                color: mouseArea3.pressed ? "#4a90e2" : "#2196F3"

                Text {
                    anchors.centerIn: parent
                    text: "变电所配置"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                }

                MouseArea {
                    id: mouseArea3
                    anchors.fill: parent
                    onClicked: { /* TODO: 变电所配置逻辑 */ }
                }
            }

            Rectangle {
                width: 140
                height: 40
                radius: 15
                color: mouseArea4.pressed ? "#4a90e2" : "#2196F3"

                Text {
                    anchors.centerIn: parent
                    text: "工作票模板管理"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                }

                MouseArea {
                    id: mouseArea4
                    anchors.fill: parent
                    onClicked: { /* TODO: 工作票模板管理逻辑 */ }
                }
            }
        }
    }
} 