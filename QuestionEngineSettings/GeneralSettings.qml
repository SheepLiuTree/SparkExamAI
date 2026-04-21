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
    property string aiAgentAddress: ""
    property string aiAgent2Address: ""
    property string aiAgent3Address: ""
    property string aiAgent4Address: ""
    property string platformTitle: ""
    property string dailyCourseText: ""
    property string specialTrainingText: ""
    property string tuanweiButtonText: ""
    property string tuanweiButton2Text: ""
    property string tuanweiButton3Text: ""
    property string tuanweiButton4Text: ""
    property bool demoMode: false
    
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

        // 载入AI智能体2地址设置
        var savedAgent2Address = dbManager.getSetting("ai_agent2_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        aiAgent2Address = savedAgent2Address
        agent2AddressField.text = savedAgent2Address
        console.log("从数据库载入AI智能体2地址: " + (savedAgent2Address ? savedAgent2Address : "未设置"))

        // 载入AI智能体3地址设置
        var savedAgent3Address = dbManager.getSetting("ai_agent3_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        aiAgent3Address = savedAgent3Address
        agent3AddressField.text = savedAgent3Address
        console.log("从数据库载入AI智能体3地址: " + (savedAgent3Address ? savedAgent3Address : "未设置"))

        // 载入AI智能体4地址设置
        var savedAgent4Address = dbManager.getSetting("ai_agent4_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        aiAgent4Address = savedAgent4Address
        agent4AddressField.text = savedAgent4Address
        console.log("从数据库载入AI智能体4地址: " + (savedAgent4Address ? savedAgent4Address : "未设置"))

        // 载入平台标题设置
        var savedPlatformTitle = dbManager.getSetting("platform_title", "智能体平台")
        platformTitle = savedPlatformTitle
        platformTitleField.text = savedPlatformTitle
        console.log("从数据库载入平台标题: " + (savedPlatformTitle ? savedPlatformTitle : "未设置，使用默认值"))

        // 载入按钮文本设置
        var savedDailyCourseText = dbManager.getSetting("daily_course_text", "日课")
        dailyCourseText = savedDailyCourseText
        dailyCourseField.text = savedDailyCourseText
        console.log("从数据库载入日课按钮文本: " + (savedDailyCourseText ? savedDailyCourseText : "未设置，使用默认值"))

        var savedSpecialTrainingText = dbManager.getSetting("special_training_text", "特训")
        specialTrainingText = savedSpecialTrainingText
        specialTrainingField.text = savedSpecialTrainingText
        console.log("从数据库载入特训按钮文本: " + (savedSpecialTrainingText ? savedSpecialTrainingText : "未设置，使用默认值"))

        var savedTuanweiButtonText = dbManager.getSetting("tuanwei_button_text", "智能体")
        tuanweiButtonText = savedTuanweiButtonText
        tuanweiButtonField.text = savedTuanweiButtonText
        console.log("从数据库载入团委按钮文本: " + (savedTuanweiButtonText ? savedTuanweiButtonText : "未设置，使用默认值"))

        // 载入团委按钮2文本设置
        var savedTuanweiButton2Text = dbManager.getSetting("tuanwei_button2_text", "智能体2")
        tuanweiButton2Text = savedTuanweiButton2Text
        tuanweiButton2Field.text = savedTuanweiButton2Text
        console.log("从数据库载入团委按钮2文本: " + (savedTuanweiButton2Text ? savedTuanweiButton2Text : "未设置，使用默认值"))

        // 载入团委按钮3文本设置
        var savedTuanweiButton3Text = dbManager.getSetting("tuanwei_button3_text", "智能体3")
        tuanweiButton3Text = savedTuanweiButton3Text
        tuanweiButton3Field.text = savedTuanweiButton3Text
        console.log("从数据库载入团委按钮3文本: " + (savedTuanweiButton3Text ? savedTuanweiButton3Text : "未设置，使用默认值"))

        // 载入团委按钮4文本设置
        var savedTuanweiButton4Text = dbManager.getSetting("tuanwei_button4_text", "智能体4")
        tuanweiButton4Text = savedTuanweiButton4Text
        tuanweiButton4Field.text = savedTuanweiButton4Text
        console.log("从数据库载入团委按钮4文本: " + (savedTuanweiButton4Text ? savedTuanweiButton4Text : "未设置，使用默认值"))

        var savedDemoMode = dbManager.getSetting("demo_mode", "0")
        demoMode = (savedDemoMode === "1")
        demoModeSwitch.checked = demoMode
        console.log("从数据库载入演示模式: " + (demoMode ? "开启" : "关闭"))
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
                    height: 980  // 增加高度以容纳新增的设置项
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
                        
                        // 演示模式设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 50
                            spacing: 10
                            
                            Text {
                                text: "演示模式:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 50
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
                                    spacing: 10
                                    
                                    Switch {
                                        id: demoModeSwitch
                                        checked: demoMode
                                        font.family: "阿里妈妈数黑体"
                                        
                                        indicator: Rectangle {
                                            implicitWidth: 50
                                            implicitHeight: 28
                                            x: demoModeSwitch.leftPadding
                                            y: parent.height / 2 - height / 2
                                            radius: height / 2
                                            color: demoModeSwitch.checked ? "#4CAF50" : "#cccccc"
                                            
                                            Rectangle {
                                                x: demoModeSwitch.checked ? parent.width - width - 2 : 2
                                                width: 24
                                                height: 24
                                                radius: 12
                                                color: "white"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        
                                        onCheckedChanged: {
                                            demoMode = checked
                                        }
                                    }
                                    
                                    Text {
                                        text: demoMode ? "已开启" : "已关闭"
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        color: demoMode ? "#4CAF50" : "#cccccc"
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
                                    placeholderText: "请输入AI智能体地址"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgentAddress = text
                                    }
                                }
                            }
                        }
                        
                        // AI智能体2地址设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体2地址:"
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
                                    id: agent2AddressField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: aiAgent2Address
                                    placeholderText: "请输入AI智能体2地址"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgent2Address = text
                                    }
                                }
                            }
                        }
                        
                        // AI智能体3地址设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体3地址:"
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
                                    id: agent3AddressField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: aiAgent3Address
                                    placeholderText: "请输入AI智能体3地址"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgent3Address = text
                                    }
                                }
                            }
                        }
                        
                        // AI智能体4地址设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体4地址:"
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
                                    id: agent4AddressField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: aiAgent4Address
                                    placeholderText: "请输入AI智能体4地址"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        aiAgent4Address = text
                                    }
                                }
                            }
                        }
                        
                        Text {
                                text: "注意：以下内容设置后需重启软件生效！！！"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 15
                                color: "red"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                        // 平台标题设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "平台标题:"
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
                                    id: platformTitleField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: platformTitle
                                    placeholderText: "请输入平台标题"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        platformTitle = text
                                    }
                                }
                            }
                        }
                        
                        // 日课按钮文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "日课按钮:"
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
                                    id: dailyCourseField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: dailyCourseText
                                    placeholderText: "请输入日课按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        dailyCourseText = text
                                    }
                                }
                            }
                        }

                        // 特训按钮文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "特训按钮:"
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
                                    id: specialTrainingField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: specialTrainingText
                                    placeholderText: "请输入特训按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        specialTrainingText = text
                                    }
                                }
                            }
                        }

                        // 团委按钮文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体按钮:"
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
                                    id: tuanweiButtonField
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: tuanweiButtonText
                                    placeholderText: "请输入团委按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        tuanweiButtonText = text
                                    }
                                }
                            }
                        }

                        // 团委按钮2文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体2按钮:"
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
                                    id: tuanweiButton2Field
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: tuanweiButton2Text
                                    placeholderText: "请输入智能体2按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        tuanweiButton2Text = text
                                    }
                                }
                            }
                        }

                        // 团委按钮3文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体3按钮:"
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
                                    id: tuanweiButton3Field
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: tuanweiButton3Text
                                    placeholderText: "请输入智能体3按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        tuanweiButton3Text = text
                                    }
                                }
                            }
                        }

                        // 团委按钮4文本设置
                        RowLayout {
                            Layout.fillWidth: true
                            height: 40
                            spacing: 10
                            
                            Text {
                                text: "智能体4按钮:"
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
                                    id: tuanweiButton4Field
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    text: tuanweiButton4Text
                                    placeholderText: "请输入智能体4按钮文本"
                                    placeholderTextColor: "#cccccc"
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: {
                                        tuanweiButton4Text = text
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
        
        // 保存首页排序设置 - 再次确保设置正确保存
        var sortSuccess = dbManager.setSetting("home_sort_option", homeSortOption.toString())
        console.log("首页排序设置已保存: " + (homeSortOption === 1 ? "本月个人能力排序(1)" : "本月刷题数排序(0)") + 
                   " (home_sort_option=" + homeSortOption.toString() + ")")
        
        // 保存AI智能体地址
        var agentAddressSuccess = dbManager.setSetting("ai_agent_address", agentAddressField.text)
        console.log("AI智能体地址已保存: " + agentAddressField.text)
        
        // 保存AI智能体2地址
        var agent2AddressSuccess = dbManager.setSetting("ai_agent2_address", agent2AddressField.text)
        console.log("AI智能体2地址已保存: " + agent2AddressField.text)
        
        // 保存AI智能体3地址
        var agent3AddressSuccess = dbManager.setSetting("ai_agent3_address", agent3AddressField.text)
        console.log("AI智能体3地址已保存: " + agent3AddressField.text)
        
        // 保存AI智能体4地址
        var agent4AddressSuccess = dbManager.setSetting("ai_agent4_address", agent4AddressField.text)
        console.log("AI智能体4地址已保存: " + agent4AddressField.text)
        
        // 保存平台标题
        var platformTitleSuccess = dbManager.setSetting("platform_title", platformTitleField.text)
        console.log("平台标题已保存: " + platformTitleField.text)
        
        // 保存按钮文本设置
        var dailyCourseSuccess = dbManager.setSetting("daily_course_text", dailyCourseField.text)
        console.log("日课按钮文本已保存: " + dailyCourseField.text)
        
        var specialTrainingSuccess = dbManager.setSetting("special_training_text", specialTrainingField.text)
        console.log("特训按钮文本已保存: " + specialTrainingField.text)
        
        var tuanweiButtonSuccess = dbManager.setSetting("tuanwei_button_text", tuanweiButtonField.text)
        console.log("团委按钮文本已保存: " + tuanweiButtonField.text)
        
        var tuanweiButton2Success = dbManager.setSetting("tuanwei_button2_text", tuanweiButton2Field.text)
        console.log("智能体2按钮文本已保存: " + tuanweiButton2Field.text)
        
        var tuanweiButton3Success = dbManager.setSetting("tuanwei_button3_text", tuanweiButton3Field.text)
        console.log("智能体3按钮文本已保存: " + tuanweiButton3Field.text)
        
        var tuanweiButton4Success = dbManager.setSetting("tuanwei_button4_text", tuanweiButton4Field.text)
        console.log("智能体4按钮文本已保存: " + tuanweiButton4Field.text)
        
        var demoModeSuccess = dbManager.setSetting("demo_mode", demoMode ? "1" : "0")
        console.log("演示模式已保存: " + (demoMode ? "开启" : "关闭"))
        
        // 使用延迟调用确保数据库操作完成后再更新UI
        Qt.callLater(function() {
            // 再次从数据库读取设置确保保存成功
            var savedOption = dbManager.getSetting("home_sort_option", "1")
            console.log("验证首页排序设置: [" + savedOption + "] " +
                      " (" + (savedOption.trim() === "1" ? "本月个人能力排序" : "本月刷题数排序") + ")")
            
            // 更新首页用户列表
            sortOptionUpdated()
        })
        
        // 显示结果消息
        if (passwordSuccess && cameraSuccess && sortSuccess && agentAddressSuccess && agent2AddressSuccess &&
            agent3AddressSuccess && agent4AddressSuccess && platformTitleSuccess &&
            dailyCourseSuccess && specialTrainingSuccess && tuanweiButtonSuccess &&
            tuanweiButton2Success && tuanweiButton3Success && tuanweiButton4Success && demoModeSuccess) {
            statusMessage = "所有设置已保存成功"
            isSuccess = true
        } else {
            let failedSettings = [];
            if (!passwordSuccess) failedSettings.push("密码");
            if (!cameraSuccess) failedSettings.push("摄像头");
            if (!sortSuccess) failedSettings.push("首页排序");
            if (!agentAddressSuccess) failedSettings.push("智能体地址");
            if (!agent2AddressSuccess) failedSettings.push("智能体2地址");
            if (!agent3AddressSuccess) failedSettings.push("智能体3地址");
            if (!agent4AddressSuccess) failedSettings.push("智能体4地址");
            if (!platformTitleSuccess) failedSettings.push("平台标题");
            if (!dailyCourseSuccess) failedSettings.push("日课按钮");
            if (!specialTrainingSuccess) failedSettings.push("特训按钮");
            if (!tuanweiButtonSuccess) failedSettings.push("团委按钮");
            if (!tuanweiButton2Success) failedSettings.push("智能体2按钮");
            if (!tuanweiButton3Success) failedSettings.push("智能体3按钮");
            if (!tuanweiButton4Success) failedSettings.push("智能体4按钮");
            if (!demoModeSuccess) failedSettings.push("演示模式");
            
            statusMessage = "保存失败的设置: " + failedSettings.join(", ") + "，请重试"
            isSuccess = false
        }
    }
} 
