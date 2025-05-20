import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtMultimedia 5.15 as QtMultimedia

Rectangle {
    id: generalSettingsPage
    color: "transparent"
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    property string adminPassword: ""
    property bool showPassword: false
    property int homeSortOption: 1
    property string aiAgentAddress: ""
    property bool enableVirtualKeyboard: true
    property bool virtualKeyboardChanged: false
    property bool previousVirtualKeyboardState: true // 保存之前的虚拟键盘状态
    
    // 定义信号
    signal sortOptionUpdated()
    
    // 连接到信号以更新首页用户列表
    onSortOptionUpdated: {
        // 调用主窗口提供的全局函数更新用户列表排序
        var success = Qt.callLater(function() {
            if (typeof window.updateUserListSorting === "function") {
                window.updateUserListSorting()
                console.log("已通知主窗口更新用户列表排序")
            } else {
                console.log("未找到主窗口更新用户列表排序的函数")
            }
        })
    }
    
    Component.onCompleted: {
        // 载入管理员密码设置
        var savedPassword = dbManager.getSetting("admin_password", "")
        adminPassword = savedPassword !== "" ? savedPassword : ""
        passwordField.text = adminPassword
        
        // 载入虚拟键盘设置
        var savedVirtualKeyboard = dbManager.getSetting("enable_virtual_keyboard", "true")
        enableVirtualKeyboard = savedVirtualKeyboard.toLowerCase() === "true"
        previousVirtualKeyboardState = enableVirtualKeyboard
        
        // 载入摄像头设备设置
        var savedCameraId = dbManager.getSetting("camera_device", "auto")
        if (savedCameraId === "auto") {
            // 自动模式选择第一个特殊选项
            cameraComboBox.currentIndex = 0
        } else if (savedCameraId !== "") {
            var cameras = QtMultimedia.videoInputs();
            for (var i = 0; i < cameras.length; i++) {
                if (cameras[i].id === savedCameraId) {
                    cameraComboBox.currentIndex = i + 1  // +1是因为第一项是"自动"
                    break
                }
            }
        }
        
        // 载入首页排序设置
        var savedSortOption = dbManager.getSetting("home_sort_option", "1").toString().trim()
        console.log("从数据库获取的排序设置原始值: [" + savedSortOption + "]");
        
        // 确保有效的排序选项值 - 只有当值明确为"0"时才使用刷题数排序，其他情况使用能力排序
        var useAbilitySort = (savedSortOption !== "0");
        homeSortOption = useAbilitySort ? 1 : 0;
        
        console.log("最终应用的排序设置: " + (useAbilitySort ? "个人能力排序(1)" : "刷题数排序(0)"));
        
        // 设置对应的单选按钮选中状态 - 通过属性绑定，避免触发事件
        if (useAbilitySort) {
            sortOption1.checked = true;
            sortOption2.checked = false;
        } else {
            sortOption1.checked = false;
            sortOption2.checked = true;
        }
        
        // 载入AI智能体地址设置
        var savedAgentAddress = dbManager.getSetting("ai_agent_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        aiAgentAddress = savedAgentAddress
        agentAddressField.text = savedAgentAddress
        console.log("从数据库载入AI智能体地址: " + (savedAgentAddress ? savedAgentAddress : "未设置，使用默认值"))
    }
    
    // 虚拟键盘重启对话框
    Dialog {
        id: restartDialog
        title: "重启提示"
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        width: 400
        height: 200
        
        background: Rectangle {
            color: "#333333"
            border.color: "#666666"
            border.width: 1
            radius: 5
        }
        
        header: Rectangle {
            color: "#2c70b7"
            height: 40
            width: parent.width
            radius: 5
            
            Text {
                text: restartDialog.title
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "更改虚拟键盘设置后需重启软件生效"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width - 40
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 60
            width: parent.width
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Button {
                    text: "确定"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: "#2c70b7"
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: "确定重启"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        // 保存虚拟键盘设置到数据库
                        var virtualKeyboardSuccess = dbManager.setSetting("enable_virtual_keyboard", enableVirtualKeyboard.toString())
                        console.log("保存虚拟键盘设置: " + enableVirtualKeyboard)
                        
                        if (virtualKeyboardSuccess) {
                            // 更新先前状态
                            previousVirtualKeyboardState = enableVirtualKeyboard
                        }
                        
                        restartDialog.close()
                        // 退出应用程序以便重启
                        Qt.quit()
                    }
                }
                
                Button {
                    text: "取消"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: "#666666"
                        radius: 4
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
                        console.log("取消虚拟键盘设置更改，恢复为: " + previousVirtualKeyboardState)
                        // 恢复为先前状态
                        enableVirtualKeyboard = previousVirtualKeyboardState
                        // 更新开关状态，注意这不会触发onCheckedChanged
                        virtualKeyboardSwitch.checked = previousVirtualKeyboardState
                        virtualKeyboardChanged = false
                        restartDialog.close()
                    }
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
                    height: 380  // 增加高度以容纳新增的设置项
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
                                        // 占位符
                                        Item {                                            
                                            Layout.preferredWidth: 30
                                            Layout.fillHeight: true                                            
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
                                        var cameras = QtMultimedia.videoInputs();
                                        for (var i = 0; i < cameras.length; i++) {
                                            model.push(cameras[i].description);
                                        }
                                        return model;
                                    }
                                }
                            }
                        }
                        
                        // 虚拟键盘设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "启用虚拟键盘:"
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
                                
                                Switch {
                                    id: virtualKeyboardSwitch
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    checked: enableVirtualKeyboard
                                    
                                    onCheckedChanged: {
                                        if (enableVirtualKeyboard !== checked) {
                                            enableVirtualKeyboard = checked
                                            virtualKeyboardChanged = true
                                        }
                                    }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 48
                                        implicitHeight: 24
                                        x: virtualKeyboardSwitch.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: 12
                                        color: virtualKeyboardSwitch.checked ? "#2c70b7" : "#666666"
                                        border.color: virtualKeyboardSwitch.checked ? "#2c70b7" : "#999999"
                                        
                                        Rectangle {
                                            x: virtualKeyboardSwitch.checked ? parent.width - width : 0
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            border.color: "#999999"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.margins: 2
                                        }
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
                                        property bool initialized: false
                                        
                                        Component.onCompleted: {
                                            // 初始化完成后设置标志
                                            initialized = true
                                        }
                                        
                                        onCheckedButtonChanged: {
                                            // 只有初始化完成后才处理变更，避免在加载时错误地覆盖设置
                                            if (!initialized) {
                                                console.log("ButtonGroup初始化中，忽略选择变更")
                                                return
                                            }
                                            
                                            if (checkedButton === sortOption1) {
                                                homeSortOption = 1
                                            } else if (checkedButton === sortOption2) {
                                                homeSortOption = 0
                                            }
                                            
                                            // 立即保存排序设置到数据库
                                            var sortSuccess = dbManager.setSetting("home_sort_option", homeSortOption.toString())
                                            console.log("立即保存首页排序设置: " + (homeSortOption === 1 ? "本月个人能力排序" : "本月刷题数排序") + 
                                                       " (home_sort_option=" + homeSortOption.toString() + ")")
                                            
                                            // 发送排序选项变更信号
                                            generalSettingsPage.sortOptionUpdated()
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
                        
                        // AI智能体地址设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体地址:"
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
                                
                                TextField {
                                    id: agentAddressField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: aiAgentAddress
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgentAddress = text
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
                if (cameraIndex >= 0 && cameraIndex < QtMultimedia.videoInputs().length) {
                    var selectedCamera = QtMultimedia.videoInputs()[cameraIndex]
                    cameraSuccess = dbManager.setSetting("camera_device", selectedCamera.id)
                    console.log("摄像头设置已更新: ID=" + selectedCamera.id + ", 名称=" + selectedCamera.description)
                }
            }
        }
        
        // 保存首页排序设置
        var sortSuccess = dbManager.setSetting("home_sort_option", homeSortOption.toString())
        console.log("首页排序设置已保存: " + (homeSortOption === 1 ? "本月个人能力排序(1)" : "本月刷题数排序(0)") + 
                   " (home_sort_option=" + homeSortOption.toString() + ")")
        
        // 保存AI智能体地址
        var agentAddressSuccess = dbManager.setSetting("ai_agent_address", agentAddressField.text)
        console.log("AI智能体地址已保存: " + agentAddressField.text)
        
        // 使用延迟调用确保数据库操作完成后再更新UI
        Qt.callLater(function() {
            // 再次从数据库读取设置确保保存成功
            var savedOption = dbManager.getSetting("home_sort_option", "1")
            console.log("验证首页排序设置: [" + savedOption + "] " + 
                      " (" + (savedOption.trim() === "1" ? "本月个人能力排序" : "本月刷题数排序") + ")")
            
            // 更新首页用户列表
            sortOptionUpdated()
        })
        
        // 默认考虑虚拟键盘设置是成功的
        var virtualKeyboardSuccess = true
        
        // 判断是否虚拟键盘设置发生了变化
        if (virtualKeyboardChanged) {
            console.log("检测到虚拟键盘设置变更，弹出确认对话框")
            // 显示重启确认对话框，不立即保存设置
            restartDialog.open()
            // 保持virtualKeyboardChanged为true，以便在确认后使用
        } else {
            // 如果没有变化，直接保存虚拟键盘设置
            virtualKeyboardSuccess = dbManager.setSetting("enable_virtual_keyboard", enableVirtualKeyboard.toString())
            console.log("虚拟键盘设置没有变化，直接保存: " + enableVirtualKeyboard)
        }
        
        // 显示结果消息，但不包括虚拟键盘设置（如果它已更改）
        if (passwordSuccess && cameraSuccess && sortSuccess && agentAddressSuccess && 
            (virtualKeyboardSuccess || virtualKeyboardChanged)) {
            
            // 如果虚拟键盘设置已更改，则只显示其他设置已保存
            if (virtualKeyboardChanged) {
                statusMessage = "其他设置已保存成功，等待确认虚拟键盘设置变更"
            } else {
                statusMessage = "所有设置已保存成功"
            }
            isSuccess = true
        } else {
            let failedSettings = [];
            if (!passwordSuccess) failedSettings.push("密码");
            if (!cameraSuccess) failedSettings.push("摄像头");
            if (!sortSuccess) failedSettings.push("首页排序");
            if (!agentAddressSuccess) failedSettings.push("智能体地址");
            if (!virtualKeyboardSuccess && !virtualKeyboardChanged) failedSettings.push("虚拟键盘");
            
            statusMessage = "保存失败的设置: " + failedSettings.join(", ") + "，请重试"
            isSuccess = false
        }
    }
} 
