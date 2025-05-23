import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 6.0

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
    
    // 新增：智能体用户名和密码设置
    property string aiAgentUsername: ""
    property string aiAgentPassword: ""
    property bool showAgentPassword: false
    
    // 摄像头相关属性
    property var availableCameras: []
    property bool camerasLoaded: false
    property int cameraRetryCount: 0
    property int maxCameraRetries: 5
    
    // 定义信号
    signal sortOptionUpdated()
    
    // 添加MediaDevices对象用于访问摄像头列表
    MediaDevices {
        id: mediaDevices
    }
    
    // 连接到信号以更新首页用户列表
    onSortOptionUpdated: {
        // 发送排序选项变更信号，不依赖window对象
        console.log("已发送首页排序设置变更信号")
    }
    
    Component.onCompleted: {
        // 首先验证数据库中的摄像头设置
        console.log("=== 页面加载时验证数据库设置 ===")
        var initialCameraSetting = dbManager.getSetting("camera_device", "auto")
        console.log("数据库中当前摄像头设置: [" + initialCameraSetting + "], 类型: " + typeof initialCameraSetting)
        
        // 载入管理员密码设置
        var savedPassword = dbManager.getSetting("admin_password", "")
        adminPassword = savedPassword !== "" ? savedPassword : ""
        passwordField.text = adminPassword
        
        // 载入虚拟键盘设置
        var savedVirtualKeyboard = dbManager.getSetting("enable_virtual_keyboard", "true")
        enableVirtualKeyboard = savedVirtualKeyboard.toLowerCase() === "true"
        previousVirtualKeyboardState = enableVirtualKeyboard
        
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
        
        // 载入AI智能体用户名和密码设置
        var savedAgentUsername = dbManager.getSetting("ai_agent_username", "")
        aiAgentUsername = savedAgentUsername
        agentUsernameField.text = savedAgentUsername
        console.log("从数据库载入AI智能体用户名: " + (savedAgentUsername ? "已设置" : "未设置"))
        
        var savedAgentPassword = dbManager.getSetting("ai_agent_password", "")
        aiAgentPassword = savedAgentPassword
        agentPasswordField.text = savedAgentPassword
        console.log("从数据库载入AI智能体密码: " + (savedAgentPassword ? "已设置" : "未设置"))
        
        // 初始化摄像头
        initializeCameras()
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
                    height: 560  // 增加高度以容纳新增的智能体用户名和密码设置项
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
                                    
                                    // 初始模型
                                    model: ["自动检测（推荐）", "正在加载..."]
                                    currentIndex: 0
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
                        
                        // AI智能体用户名设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体用户名:"
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
                                    id: agentUsernameField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: aiAgentUsername
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgentUsername = text
                                    }
                                }
                            }
                        }
                        
                        // AI智能体密码设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体密码:"
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
                                        id: agentPasswordField
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        color: "white"
                                        text: aiAgentPassword
                                        echoMode: showAgentPassword ? TextInput.Normal : TextInput.Password
                                        
                                        background: Rectangle {
                                            color: "transparent"
                                        }
                                        
                                        onTextChanged: {
                                            aiAgentPassword = text
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
                                            text: showAgentPassword ? "👁️" : "👁️‍🗨️"
                                            font.pixelSize: 16
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            showAgentPassword = !showAgentPassword
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
        console.log("=== 开始保存摄像头设置 ===")
        console.log("当前ComboBox索引: " + cameraComboBox.currentIndex)
        console.log("当前显示文本: " + cameraComboBox.currentText)
        
        try {
            var cameraId = getCurrentCameraId()
            console.log("要保存的摄像头ID: " + cameraId)
            
            cameraSuccess = dbManager.setSetting("camera_device", cameraId)
            console.log("摄像头设置保存结果: " + cameraSuccess)
            
            if (cameraSuccess) {
                if (cameraId === "auto") {
                    console.log("已保存自动检测模式")
                } else {
                    // 查找设备名称用于日志
                    var deviceName = "未知设备"
                    var deviceIndex = cameraComboBox.currentIndex - 1
                    if (deviceIndex >= 0 && deviceIndex < availableCameras.length) {
                        deviceName = availableCameras[deviceIndex].description
                    }
                    console.log("已保存特定摄像头: ID=" + cameraId + ", 名称=" + deviceName)
                }
            }
        } catch (e) {
            console.log("保存摄像头设置时出错: " + e.toString() + "，使用自动模式")
            cameraSuccess = dbManager.setSetting("camera_device", "auto")
            console.log("错误处理后保存结果: " + cameraSuccess)
        }
        
        console.log("=== 摄像头设置保存完成 ===")
        
        // 保存首页排序设置
        var sortSuccess = dbManager.setSetting("home_sort_option", homeSortOption.toString())
        console.log("首页排序设置已保存: " + (homeSortOption === 1 ? "本月个人能力排序(1)" : "本月刷题数排序(0)") + 
                   " (home_sort_option=" + homeSortOption.toString() + ")")
        
        // 保存AI智能体地址
        var agentAddressSuccess = dbManager.setSetting("ai_agent_address", agentAddressField.text)
        console.log("AI智能体地址已保存: " + agentAddressField.text)
        
        // 保存AI智能体用户名
        var agentUsernameSuccess = dbManager.setSetting("ai_agent_username", agentUsernameField.text)
        console.log("AI智能体用户名已保存: " + (agentUsernameField.text ? "已设置" : "未设置"))
        
        // 保存AI智能体密码
        var agentPasswordSuccess = dbManager.setSetting("ai_agent_password", agentPasswordField.text)
        console.log("AI智能体密码已保存: " + (agentPasswordField.text ? "已设置" : "未设置"))
        
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
        if (passwordSuccess && cameraSuccess && sortSuccess && agentAddressSuccess && agentUsernameSuccess && agentPasswordSuccess && 
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
            if (!agentUsernameSuccess) failedSettings.push("智能体用户名");
            if (!agentPasswordSuccess) failedSettings.push("智能体密码");
            if (!virtualKeyboardSuccess && !virtualKeyboardChanged) failedSettings.push("虚拟键盘");
            
            statusMessage = "保存失败的设置: " + failedSettings.join(", ") + "，请重试"
            isSuccess = false
        }
    }
    
    // 摄像头重试定时器
    Timer {
        id: cameraRetryTimer
        interval: 1000
        repeat: false
        onTriggered: {
            console.log("重试定时器触发，第 " + (cameraRetryCount + 1) + " 次尝试")
            tryLoadCameras()
        }
    }
    
    // 页面级别的摄像头初始化
    function initializeCameras() {
        console.log("=== 页面级别初始化摄像头 ===")
        cameraRetryCount = 0
        camerasLoaded = false
        tryLoadCameras()
    }
    
    // 尝试加载摄像头
    function tryLoadCameras() {
        cameraRetryCount++
        console.log("尝试加载摄像头列表，第 " + cameraRetryCount + " 次")
        
        try {
            // 检查MediaDevices是否存在
            if (typeof mediaDevices === 'undefined' || !mediaDevices) {
                console.log("MediaDevices对象不存在或未定义")
                handleCameraLoadFailure()
                return
            }
            
            // 尝试获取摄像头列表
            var cameras
            try {
                cameras = mediaDevices.videoInputs
            } catch (e) {
                console.log("获取videoInputs时出错: " + e.toString())
                handleCameraLoadFailure()
                return
            }
            
            if (!cameras) {
                console.log("摄像头列表为null")
                handleCameraLoadFailure()
                return
            }
            
            if (cameras.length === undefined) {
                console.log("摄像头列表长度未定义")
                handleCameraLoadFailure()
                return
            }
            
            console.log("成功获取摄像头列表，共 " + cameras.length + " 个设备")
            
            // 构建摄像头数组
            availableCameras = []
            for (var i = 0; i < cameras.length; i++) {
                var camera = cameras[i]
                if (camera && camera.id && camera.description) {
                    // 确保ID和描述都是字符串
                    var cameraId = String(camera.id)
                    var cameraDesc = String(camera.description)
                    
                    availableCameras.push({
                        id: cameraId,
                        description: cameraDesc
                    })
                    console.log("摄像头 " + i + ": ID=[" + cameraId + "], 名称=[" + cameraDesc + "]")
                } else {
                    console.log("摄像头 " + i + " 数据不完整，跳过")
                }
            }
            
            camerasLoaded = true
            console.log("摄像头数据加载完成，有效摄像头: " + availableCameras.length + " 个")
            setupCameraComboBox()
            
        } catch (e) {
            console.log("加载摄像头时发生异常: " + e.toString())
            handleCameraLoadFailure()
        }
    }
    
    // 处理摄像头加载失败
    function handleCameraLoadFailure() {
        if (cameraRetryCount < maxCameraRetries) {
            console.log("摄像头加载失败，" + (1000) + "ms 后重试...")
            cameraRetryTimer.start()
        } else {
            console.log("摄像头加载重试次数达到上限，使用默认设置")
            availableCameras = []
            camerasLoaded = true
            setupCameraComboBox()
        }
    }
    
    // 设置摄像头ComboBox
    function setupCameraComboBox() {
        console.log("=== 设置摄像头ComboBox ===")
        console.log("可用摄像头数量: " + availableCameras.length)
        
        // 构建显示列表
        var displayList = ["自动检测（推荐）"]
        for (var i = 0; i < availableCameras.length; i++) {
            displayList.push(availableCameras[i].description)
            console.log("添加到列表: " + availableCameras[i].description)
        }
        
        // 设置模型
        console.log("设置ComboBox模型，共 " + displayList.length + " 项")
        cameraComboBox.model = displayList
        
        // 延迟应用设置，确保模型更新完成
        Qt.callLater(function() {
            console.log("模型设置完成，延迟应用摄像头设置")
            applyCameraSetting()
        })
    }
    
    // 应用摄像头设置
    function applyCameraSetting() {
        console.log("=== 应用摄像头设置 ===")
        
        // 从数据库读取设置
        var savedCameraId = String(dbManager.getSetting("camera_device", "auto"))
        console.log("数据库中的摄像头设置: [" + savedCameraId + "]")
        console.log("设置字符串长度: " + savedCameraId.length)
        console.log("当前ComboBox模型长度: " + cameraComboBox.model.length)
        console.log("可用摄像头数组长度: " + availableCameras.length)
        
        var targetIndex = 0  // 默认自动检测
        
        if (savedCameraId === "auto" || savedCameraId === "") {
            console.log("设置为自动检测模式，目标索引: 0")
            targetIndex = 0
        } else {
            console.log("查找匹配的摄像头设备...")
            console.log("要匹配的ID: [" + savedCameraId + "]")
            var found = false
            for (var i = 0; i < availableCameras.length; i++) {
                var currentId = String(availableCameras[i].id)
                console.log("比较摄像头 " + i + ":")
                console.log("  数据库ID: [" + savedCameraId + "] (长度: " + savedCameraId.length + ")")
                console.log("  摄像头ID: [" + currentId + "] (长度: " + currentId.length + ")")
                console.log("  直接比较: " + (currentId === savedCameraId))
                
                if (currentId === savedCameraId) {
                    targetIndex = i + 1  // +1因为第一项是自动检测
                    found = true
                    console.log("*** 找到匹配摄像头！***")
                    console.log("  摄像头索引: " + i)
                    console.log("  ComboBox目标索引: " + targetIndex)
                    console.log("  摄像头名称: " + availableCameras[i].description)
                    break
                } else {
                    console.log("  不匹配，继续查找...")
                }
            }
            
            if (!found) {
                console.log("*** 未找到匹配的摄像头 ***")
                console.log("搜索的ID: [" + savedCameraId + "]")
                console.log("使用自动检测，目标索引: 0")
                targetIndex = 0
            }
        }
        
        console.log("准备设置ComboBox索引: " + targetIndex)
        console.log("ComboBox设置前索引: " + cameraComboBox.currentIndex)
        
        // 设置选中项
        cameraComboBox.currentIndex = targetIndex
        console.log("ComboBox设置后索引: " + cameraComboBox.currentIndex)
        
        // 验证设置结果
        Qt.callLater(function() {
            console.log("=== 设置结果验证 ===")
            console.log("ComboBox最终索引: " + cameraComboBox.currentIndex)
            console.log("ComboBox最终文本: " + cameraComboBox.currentText)
            console.log("对应的设备ID: " + getCurrentCameraId())
            
            // 再次验证是否匹配
            var finalCameraId = getCurrentCameraId()
            if (finalCameraId === savedCameraId || (savedCameraId === "" && finalCameraId === "auto")) {
                console.log("✓ 摄像头设置匹配成功")
            } else {
                console.log("✗ 摄像头设置不匹配！期望: [" + savedCameraId + "], 实际: [" + finalCameraId + "]")
                
                // 如果不匹配，强制重新设置
                console.log("尝试强制重新设置...")
                for (var i = 0; i < availableCameras.length; i++) {
                    if (String(availableCameras[i].id) === savedCameraId) {
                        var forceIndex = i + 1
                        console.log("强制设置索引为: " + forceIndex)
                        cameraComboBox.currentIndex = forceIndex
                        break
                    }
                }
            }
            console.log("=== 摄像头初始化完全完成 ===")
        })
    }
    
    // 获取当前选中的摄像头ID
    function getCurrentCameraId() {
        var index = cameraComboBox.currentIndex
        if (index === 0) {
            return "auto"
        } else if (index > 0 && index <= availableCameras.length) {
            return availableCameras[index - 1].id
        } else {
            return "auto"
        }
    }
} 
