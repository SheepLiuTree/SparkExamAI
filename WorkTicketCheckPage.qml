import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

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
                        echoMode: TextInput.Password
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
                            if (newUsernameInput.text && workIdInput.text && newPasswordInput.text) {
                                // TODO: 实现保存新账户的逻辑
                                console.log("保存新账户:", newUsernameInput.text, workIdInput.text)
                                loginDialog.showAddAccount = false
                                newUsernameInput.text = ""
                                workIdInput.text = ""
                                newPasswordInput.text = ""
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

    // 菜单区域
    Rectangle {
        id: menuBar
        anchors.top: pageTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.9
        height: 80
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
            width: 120
            height: 40
            radius: 15
            color: loginMouseArea.pressed ? "#4a90e2" : "#2196F3"
            anchors.centerIn: parent

            Text {
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
                    } else {
                        workTicketCheckPage.isLoggedIn = false
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
                color: !workTicketCheckPage.isLoggedIn ? "#CCCCCC" : (mouseArea3.pressed ? "#4a90e2" : "#2196F3")
                opacity: !workTicketCheckPage.isLoggedIn ? 0.7 : 1.0

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
                    enabled: workTicketCheckPage.isLoggedIn
                    onClicked: { /* TODO: 变电所配置逻辑 */ }
                }
            }

            Rectangle {
                width: 140
                height: 40
                radius: 15
                color: !workTicketCheckPage.isLoggedIn ? "#CCCCCC" : (mouseArea4.pressed ? "#4a90e2" : "#2196F3")
                opacity: !workTicketCheckPage.isLoggedIn ? 0.7 : 1.0

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
                    enabled: workTicketCheckPage.isLoggedIn
                    onClicked: { /* TODO: 工作票模板管理逻辑 */ }
                }
            }
        }
    }
} 