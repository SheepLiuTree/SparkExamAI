import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15

Rectangle {
    id: generalSettingsPage
    color: "transparent"
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    property string adminPassword: ""
    
    Component.onCompleted: {
        // 载入和应用已保存的设置
        var savedPassword = dbManager.getSetting("admin_password", "123456")
        adminPassword = savedPassword
        passwordField.text = savedPassword
        console.log("从数据库载入管理员密码: " + (savedPassword ? "已设置" : "未设置，使用默认值"))

        // 载入已保存的摄像头设置
        var savedCameraId = dbManager.getSetting("camera_device", "auto")
        if (savedCameraId === "auto") {
            // 自动模式选择第一个特殊选项
            cameraComboBox.currentIndex = 0
        } else if (savedCameraId !== "") {
            var cameras = QtMultimedia.availableCameras
            for (var i = 0; i < cameras.length; i++) {
                if (cameras[i].deviceId === savedCameraId) {
                    cameraComboBox.currentIndex = i + 1  // +1是因为第一项是"自动"
                    break
                }
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: settingsColumn.height
            clip: true
            
            ColumnLayout {
                id: settingsColumn
                width: parent.width
                spacing: 25
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 220
                    color: "#44ffffff"
                    radius: 10
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        Text {
                            text: "通用设置"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }
                        
                        // 管理员密码设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "管理员密码:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#22ffffff"
                                radius: 5
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 5
                                    
                                    TextField {
                                        id: passwordField
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        color: "white"
                                        text: adminPassword
                                        placeholderText: "请输入管理员密码"
                                        placeholderTextColor: "#cccccc"
                                        echoMode: showPassword ? TextInput.Normal : TextInput.Password
                                        
                                        background: Rectangle {
                                            color: "transparent"
                                        }
                                        
                                        onTextChanged: {
                                            adminPassword = text
                                        }
                                    }
                                    
                                    // 密码显示/隐藏按钮
                                    Button {
                                        Layout.preferredWidth: 30
                                        Layout.fillHeight: true
                                        background: Rectangle {
                                            color: "transparent"
                                        }
                                        contentItem: Text {
                                            text: showPassword ? "👁️" : "👁️‍🗨️"
                                            font.pixelSize: 16
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            showPassword = !showPassword
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 密码显示/隐藏状态
                        property bool showPassword: false
                        
                        // 摄像头设备设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "摄像头设备:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#22ffffff"
                                radius: 5
                                
                                ComboBox {
                                    id: cameraComboBox
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    contentItem: Text {
                                        text: parent.displayText
                                        color: "white"
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    model: {
                                        var model = ["自动检测（推荐）"];
                                        for (var i = 0; i < QtMultimedia.availableCameras.length; i++) {
                                            model.push(QtMultimedia.availableCameras[i].displayName);
                                        }
                                        return model;
                                    }
                                }
                            }
                        }
                        
                        // 保存按钮
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            
                            Button {
                                anchors.right: parent.right
                                width: 120
                                height: 40
                                background: Rectangle {
                                    color: "#2c70b7"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: "保存设置"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 18
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    saveAllSettings()
                                }
                            }
                        }
                    }
                }
                
                // 状态信息显示
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: isSuccess ? "#3366cc33" : "#33cc3333"
                    radius: 4
                    visible: statusMessage !== ""
                    
                    Text {
                        anchors.centerIn: parent
                        text: statusMessage
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                    }
                    
                    // 3秒后自动隐藏消息
                    Timer {
                        running: statusMessage !== ""
                        interval: 3000
                        onTriggered: {
                            statusMessage = ""
                        }
                    }
                }
                
                // 占位空间
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
    
    // 保存所有设置
    function saveAllSettings() {
        // 保存管理员密码
        var passwordSuccess = dbManager.setSetting("admin_password", passwordField.text)
        
        // 保存摄像头设置
        var cameraSuccess = false
        if (cameraComboBox.currentIndex >= 0) {
            if (cameraComboBox.currentIndex === 0) {
                // 保存自动模式
                cameraSuccess = dbManager.setSetting("camera_device", "auto")
                console.log("摄像头设置已更新为自动模式")
            } else {
                // 保存特定摄像头
                var cameraIndex = cameraComboBox.currentIndex - 1; // 减1是因为第一项是"自动"
                if (cameraIndex >= 0 && cameraIndex < QtMultimedia.availableCameras.length) {
                    var selectedCamera = QtMultimedia.availableCameras[cameraIndex]
                    cameraSuccess = dbManager.setSetting("camera_device", selectedCamera.deviceId)
                    console.log("摄像头设置已更新: ID=" + selectedCamera.deviceId + ", 名称=" + selectedCamera.displayName)
                }
            }
        }
        
        // 显示结果消息
        if (passwordSuccess && cameraSuccess) {
            statusMessage = "所有设置已保存成功"
            isSuccess = true
        } else if (passwordSuccess) {
            statusMessage = "密码已保存，但摄像头设置失败"
            isSuccess = false
        } else if (cameraSuccess) {
            statusMessage = "摄像头已保存，但密码设置失败"
            isSuccess = false
        } else {
            statusMessage = "保存设置失败，请重试"
            isSuccess = false
        }
    }
} 
