import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: userPermissionsSettingsPage
    color: "transparent"
    
    property var userRoles: [
        { id: 1, name: "管理员", permissions: ["viewAllData", "editData", "manageUsers", "changeSettings", "exportData", "manageQuestions"] },
        { id: 2, name: "教师", permissions: ["viewAssignedData", "editAssignedData", "manageAssignedUsers", "viewSettings", "exportAssignedData"] },
        { id: 3, name: "学生", permissions: ["viewOwnData", "practiceQuestions"] }
    ]
    
    property var permissions: [
        { id: "viewAllData", name: "查看所有数据", description: "可以查看系统中的所有数据信息" },
        { id: "editData", name: "编辑数据", description: "可以编辑系统中的所有数据" },
        { id: "manageUsers", name: "管理用户", description: "可以创建、修改和删除用户账户" },
        { id: "changeSettings", name: "修改系统设置", description: "可以修改系统的各项设置" },
        { id: "exportData", name: "导出数据", description: "可以导出系统中的各类数据" },
        { id: "manageQuestions", name: "管理题库", description: "可以管理题库中的题目" },
        { id: "viewAssignedData", name: "查看指定数据", description: "可以查看被分配的数据" },
        { id: "editAssignedData", name: "编辑指定数据", description: "可以编辑被分配的数据" },
        { id: "manageAssignedUsers", name: "管理指定用户", description: "可以管理被分配的用户" },
        { id: "viewSettings", name: "查看设置", description: "可以查看系统设置，但不能修改" },
        { id: "exportAssignedData", name: "导出指定数据", description: "可以导出被分配的数据" },
        { id: "viewOwnData", name: "查看个人数据", description: "可以查看个人的数据信息" },
        { id: "practiceQuestions", name: "练习题目", description: "可以练习系统中的题目" }
    ]
    
    property var users: [
        { id: 1, name: "张三", avatar: "qrc:/images/avatar1.png", role: "管理员", lastLogin: "2023-06-30 15:30" },
        { id: 2, name: "李四", avatar: "qrc:/images/avatar2.png", role: "教师", lastLogin: "2023-06-30 09:15" },
        { id: 3, name: "王五", avatar: "qrc:/images/avatar3.png", role: "教师", lastLogin: "2023-06-29 14:20" },
        { id: 4, name: "赵六", avatar: "qrc:/images/avatar4.png", role: "学生", lastLogin: "2023-06-30 10:45" },
        { id: 5, name: "钱七", avatar: "qrc:/images/avatar5.png", role: "学生", lastLogin: "2023-06-28 16:05" }
    ]
    
    property int selectedRoleIndex: 0
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "用户权限设置"
            font.pixelSize: 20
            font.bold: true
            color: "#333333"
            Layout.bottomMargin: 10
        }
        
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle {
                color: "#f5f5f5"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 4
            }
            
            TabButton {
                text: "角色权限"
                width: implicitWidth
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: parent.checked ? "#2c70b7" : "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                    border.color: parent.checked ? "#2c70b7" : "transparent"
                    border.width: parent.checked ? 1 : 0
                    radius: 4
                }
            }
            
            TabButton {
                text: "用户管理"
                width: implicitWidth
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: parent.checked ? "#2c70b7" : "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                    border.color: parent.checked ? "#2c70b7" : "transparent"
                    border.width: parent.checked ? 1 : 0
                    radius: 4
                }
            }
        }
        
        StackLayout {
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // 角色权限页面
            Item {
                RowLayout {
                    anchors.fill: parent
                    spacing: 20
                    
                    // 左侧角色列表
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                text: "角色列表"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                                Layout.fillWidth: true
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#e0e0e0"
                            }
                            
                            ListView {
                                id: roleListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: userRoles
                                currentIndex: selectedRoleIndex
                                
                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 50
                                    color: index === ListView.view.currentIndex ? "#f0f7ff" : "transparent"
                                    border.color: index === ListView.view.currentIndex ? "#2c70b7" : "transparent"
                                    border.width: 1
                                    radius: 4
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedRoleIndex = index
                                            roleListView.currentIndex = index
                                        }
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10
                                        
                                        Rectangle {
                                            width: 6
                                            height: 30
                                            color: index === ListView.view.currentIndex ? "#2c70b7" : "transparent"
                                            radius: 3
                                        }
                                        
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 14
                                            color: index === ListView.view.currentIndex ? "#2c70b7" : "#333333"
                                            font.bold: index === ListView.view.currentIndex
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                            
                            Button {
                                text: "添加角色"
                                Layout.fillWidth: true
                                implicitHeight: 36
                                
                                background: Rectangle {
                                    color: "#f5f5f5"
                                    border.color: "#d0d0d0"
                                    border.width: 1
                                    radius: 4
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#444444"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                    
                    // 右侧权限设置
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            
                            Text {
                                text: userRoles[selectedRoleIndex].name + " 权限设置"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "选择该角色拥有的权限"
                                font.pixelSize: 14
                                color: "#666666"
                                Layout.fillWidth: true
                                Layout.bottomMargin: 10
                            }
                            
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 15
                                    
                                    Repeater {
                                        model: permissions
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 60
                                            color: "#f9f9f9"
                                            radius: 4
                                            
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 15
                                                
                                                CheckBox {
                                                    checked: userRoles[selectedRoleIndex].permissions.indexOf(modelData.id) !== -1
                                                }
                                                
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2
                                                    
                                                    Text {
                                                        text: modelData.name
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                        color: "#333333"
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.description
                                                        font.pixelSize: 12
                                                        color: "#666666"
                                                        wrapMode: Text.Wrap
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 10
                                
                                Button {
                                    text: "全选"
                                    implicitWidth: 80
                                    implicitHeight: 36
                                    flat: true
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        color: "#2c70b7"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Button {
                                    text: "全不选"
                                    implicitWidth: 80
                                    implicitHeight: 36
                                    flat: true
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        color: "#2c70b7"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "保存设置"
                                    implicitWidth: 100
                                    implicitHeight: 40
                                    
                                    background: Rectangle {
                                        color: "#2c70b7"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 用户管理页面
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    
                    // 搜索和添加
                    RowLayout {
                        Layout.fillWidth: true
                        
                        TextField {
                            placeholderText: "搜索用户名"
                            Layout.preferredWidth: 250
                            
                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 40
                                color: "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                        }
                        
                        ComboBox {
                            model: ["所有角色", "管理员", "教师", "学生"]
                            implicitWidth: 150
                            implicitHeight: 40
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "添加用户"
                            implicitWidth: 100
                            implicitHeight: 40
                            
                            background: Rectangle {
                                color: "#2c70b7"
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                // 打开添加用户对话框
                                addUserDialog.open()
                            }
                        }
                    }
                    
                    // 用户表格
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 1
                            spacing: 0
                            
                            // 表头
                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                color: "#f5f5f5"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    
                                    Text {
                                        text: "用户"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#444444"
                                        Layout.preferredWidth: 200
                                    }
                                    
                                    Text {
                                        text: "角色"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#444444"
                                        Layout.preferredWidth: 100
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: "最后登录"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#444444"
                                        Layout.preferredWidth: 150
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: "操作"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#444444"
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                            
                            // 用户列表
                            ListView {
                                id: userListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: users
                                
                                delegate: Rectangle {
                                    width: userListView.width
                                    height: 70
                                    color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 15
                                        anchors.rightMargin: 15
                                        
                                        // 用户信息
                                        RowLayout {
                                            Layout.preferredWidth: 200
                                            spacing: 10
                                            
                                            Image {
                                                source: modelData.avatar
                                                sourceSize.width: 40
                                                sourceSize.height: 40
                                                Layout.preferredWidth: 40
                                                Layout.preferredHeight: 40
                                                
                                                Rectangle {
                                                    visible: status !== Image.Ready
                                                    anchors.fill: parent
                                                    color: "#e0e0e0"
                                                    radius: width / 2
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.name.substring(0, 1)
                                                        font.pixelSize: 20
                                                        color: "#666666"
                                                    }
                                                }
                                            }
                                            
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 14
                                                color: "#333333"
                                            }
                                        }
                                        
                                        // 角色
                                        Text {
                                            text: modelData.role
                                            font.pixelSize: 14
                                            color: "#333333"
                                            Layout.preferredWidth: 100
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 最后登录
                                        Text {
                                            text: modelData.lastLogin
                                            font.pixelSize: 14
                                            color: "#666666"
                                            Layout.preferredWidth: 150
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 操作按钮
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10
                                            
                                            Item { Layout.fillWidth: true }
                                            
                                            Button {
                                                text: "编辑"
                                                flat: true
                                                implicitWidth: 60
                                                implicitHeight: 30
                                                
                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: 14
                                                    color: "#2196f3"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                            
                                            Button {
                                                text: "重置密码"
                                                flat: true
                                                implicitWidth: 80
                                                implicitHeight: 30
                                                
                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: 14
                                                    color: "#ff9800"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                            
                                            Button {
                                                text: "删除"
                                                flat: true
                                                implicitWidth: 60
                                                implicitHeight: 30
                                                
                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: 14
                                                    color: "#f44336"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 添加用户对话框
    Dialog {
        id: addUserDialog
        title: "添加用户"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400
        height: 380
        modal: true
        
        contentItem: ColumnLayout {
            spacing: 15
            anchors.margins: 20
            
            Text {
                text: "请输入新用户信息"
                font.pixelSize: 14
                color: "#666666"
                Layout.fillWidth: true
            }
            
            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 15
                Layout.fillWidth: true
                
                Text {
                    text: "用户名:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextField {
                    id: usernameField
                    placeholderText: "请输入用户名"
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "初始密码:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextField {
                    id: passwordField
                    placeholderText: "请输入初始密码"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "确认密码:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextField {
                    id: confirmPasswordField
                    placeholderText: "请再次输入密码"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "用户角色:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                ComboBox {
                    id: roleComboBox
                    model: ["管理员", "教师", "学生"]
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "用户头像:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Rectangle {
                        width: 50
                        height: 50
                        color: "#f0f0f0"
                        radius: 25
                        
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 24
                            color: "#666666"
                        }
                    }
                    
                    Button {
                        text: "选择图片"
                        implicitWidth: 100
                        implicitHeight: 36
                        
                        background: Rectangle {
                            color: "#f5f5f5"
                            border.color: "#d0d0d0"
                            border.width: 1
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "#444444"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
        
        onAccepted: {
            // 处理添加用户逻辑
            console.log("添加用户: " + usernameField.text + ", 角色: " + roleComboBox.currentText)
        }
    }
} 