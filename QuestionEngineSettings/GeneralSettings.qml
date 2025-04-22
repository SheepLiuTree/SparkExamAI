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
    property bool showPassword: false
    property int homeSortOption: 1
    
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
        
        // 载入首页排序设置
        var savedSortOption = parseInt(dbManager.getSetting("home_sort_option", "1"))
        homeSortOption = savedSortOption
        sortOptionGroup.checkedButton = savedSortOption === 1 ? sortOption1 : sortOption2
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
                    height: 320
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
                        
                        // 首页排序设置
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "首页排序设置:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredHeight: 30
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: "#22ffffff"
                                radius: 5
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 5
                                    
                                    ButtonGroup {
                                        id: sortOptionGroup
                                        onCheckedButtonChanged: {
                                            if (checkedButton === sortOption1) {
                                                homeSortOption = 1
                                            } else if (checkedButton === sortOption2) {
                                                homeSortOption = 0
                                            }
                                        }
                                    }
                                    
                                    RadioButton {
                                        id: sortOption1
                                        text: "本月个人能力排序"
                                        checked: homeSortOption === 1
                                        ButtonGroup.group: sortOptionGroup
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        padding: 0
                                        
                                        indicator: Rectangle {
                                            implicitWidth: 16
                                            implicitHeight: 16
                                            x: sortOption1.leftPadding
                                            y: parent.height / 2 - height / 2
                                            radius: width / 2
                                            border.color: "white"
                                            border.width: 1
                                            color: "transparent"
                                            
                                            Rectangle {
                                                width: 8
                                                height: 8
                                                anchors.centerIn: parent
                                                radius: width / 2
                                                color: "white"
                                                visible: sortOption1.checked
                                            }
                                        }
                                        
                                        contentItem: Text {
                                            text: sortOption1.text
                                            font: sortOption1.font
                                            color: "white"
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: sortOption1.indicator.width + 8
                                        }
                                    }
                                    
                                    RadioButton {
                                        id: sortOption2
                                        text: "本月刷题数排序"
                                        checked: homeSortOption === 0
                                        ButtonGroup.group: sortOptionGroup
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        padding: 0
                                        
                                        indicator: Rectangle {
                                            implicitWidth: 16
                                            implicitHeight: 16
                                            x: sortOption2.leftPadding
                                            y: parent.height / 2 - height / 2
                                            radius: width / 2
                                            border.color: "white"
                                            border.width: 1
                                            color: "transparent"
                                            
                                            Rectangle {
                                                width: 8
                                                height: 8
                                                anchors.centerIn: parent
                                                radius: width / 2
                                                color: "white"
                                                visible: sortOption2.checked
                                            }
                                        }
                                        
                                        contentItem: Text {
                                            text: sortOption2.text
                                            font: sortOption2.font
                                            color: "white"
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: sortOption2.indicator.width + 8
                                        }
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
        
        // 保存首页排序设置
        var sortSuccess = dbManager.setSetting("home_sort_option", homeSortOption.toString())
        console.log("首页排序设置已更新: " + (homeSortOption === 1 ? "本月个人能力排序" : "本月刷题数排序"))
        
        // 显示结果消息
        if (passwordSuccess && cameraSuccess && sortSuccess) {
            statusMessage = "所有设置已保存成功"
            isSuccess = true
        } else {
            let failedSettings = [];
            if (!passwordSuccess) failedSettings.push("密码");
            if (!cameraSuccess) failedSettings.push("摄像头");
            if (!sortSuccess) failedSettings.push("首页排序");
            
            statusMessage = "保存失败的设置: " + failedSettings.join(", ") + "，请重试"
            isSuccess = false
        }
    }
} 
