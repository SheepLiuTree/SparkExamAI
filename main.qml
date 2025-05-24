import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtMultimedia
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs

Window {
    width: Screen.width
    height: Screen.height
    // width: 1440
    // height: 1024
    visible: true
    visibility: Window.FullScreen
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTr("星火智能评测系统")
    
    // 应用Material样式 - 确保全局应用
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    
    // 虚拟键盘设置属性
    property bool enableVirtualKeyboard: true

    
    
    // 附加属性确保样式应用到所有控件
    QtObject {
        id: appStyle
        property int style: QtQuick.Controls.ApplicationWindow.Material
    }

    // 提供一个全局函数用于更新用户数据
    function updateUserData(workId) {
        if (workId && mainPage && mainPage.user_practice_data) {
            console.log("全局函数：更新用户数据，工号: " + workId)
            // 先清空ID然后设置ID以确保触发变更
            mainPage.user_practice_data.currentUserId = ""
            mainPage.user_practice_data.currentUserId = workId
            mainPage.user_practice_data.loadUserPracticeData(workId)
            return true
        }
        return false
    }
    
    // 提供一个全局函数用于更新首页用户列表排序
    function updateUserListSorting() {
        if (mainPage && mainPage.personal_page_column) {
            console.log("全局函数：更新首页用户列表排序");
            
            // 使用延迟调用确保设置已保存到数据库
            Qt.callLater(function() {
                // 重新从数据库读取设置值
                var sortOption = dbManager.getSetting("home_sort_option", "1");
                console.log("从数据库读取排序设置: " + sortOption + 
                          " (" + (sortOption === "1" ? "本月个人能力排序" : "本月刷题数排序") + ")");
                
                // 重新加载用户列表
                mainPage.personal_page_column.loadUserListFromDatabase();
            });
            
            return true;
        }
        return false;
    }

    // 虚拟键盘组件
    VirtualKeyboard {
        id: virtualKeyboard
        visible: false
        
        // 当键盘关闭时处理信号
        onClosed: {
            visible = false
            // 确保输入法上下文被正确处理
            if (Qt.inputMethod) {
                Qt.inputMethod.hide()
            }
        }
    }
    
    // 虚拟键盘控制按钮
    Rectangle {
        id: keyboardButton
        width: 50
        height: 50
        radius: 25
        color: "#404040"
        opacity: 0.8
        z: 1000
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        visible: enableVirtualKeyboard  // 根据虚拟键盘设置控制显示
        
        Text {
            anchors.centerIn: parent
            text: "⌨"
            color: "white"
            font.pixelSize: 24
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                virtualKeyboard.visible = !virtualKeyboard.visible
            }
        }
    }
    
    // 全局焦点变化监听器
    Connections {
        target: Window
        function onActiveFocusItemChanged() {
            checkFocusedItem()
        }
    }
    
    // 检查当前焦点项并显示键盘
    function checkFocusedItem() {
        var focusItem = Window.activeFocusItem
        if (focusItem) {
            console.log("焦点变化: " + focusItem)
            
            // 检查是否是输入控件
            if (focusItem.hasOwnProperty("text") && 
                (focusItem.hasOwnProperty("cursorPosition") || 
                 focusItem.hasOwnProperty("inputMethodHints") || 
                 focusItem.hasOwnProperty("echoMode"))) {
                console.log("检测到输入控件获得焦点，显示虚拟键盘")
                virtualKeyboard.visible = true
            }
        }
    }
    
    // 应用程序激活状态监听
    Connections {
        target: Qt.application
        function onActiveChanged() {
            if (Qt.application.active) {
                checkFocusedItem()
            }
        }
    }

    Image {
        id: background
        anchors.fill: parent
        source: "qrc:/images/background.png"
        fillMode: Image.PreserveAspectCrop
    }
    // 显示窗口尺寸
    // Text {
    //     id: window_size_text
    //     anchors.top: parent.top
    //     anchors.right: parent.right
    //     anchors.margins: 10
    //     text: "窗口尺寸: " + parent.width + " x " + parent.height
    //     font.family: "阿里妈妈数黑体"
    //     font.pixelSize: 16
    //     color: "white"
    //     z: 100 // 确保显示在最上层
    // }

    Image {
        id: headline_background
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/images/headline.png"
        Text {
            id: headline_text
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: "星火智能评测系统"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 48
            color: "white"
            
            // 添加鼠标事件区域，用于处理双击事件
            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                    console.log("系统标题被双击，显示退出确认对话框")
                    exitDialog.open()
                }
            }
        }
        Text {
            id: date_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            text: Qt.formatDateTime(new Date(), "yyyy年MM月dd日")
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"
        }
        
        Text {
            id: time_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            text: Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + getWeekDay()
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"

            function getWeekDay() {
                var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
                var day = new Date().getDay();
                return weekDays[day];
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    time_text.text = Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + time_text.getWeekDay();
                    date_text.text = Qt.formatDateTime(new Date(), "yyyy年MM月dd日");
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.top: headline_background.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        initialItem: mainPage
        clip: true

        // 添加当前项改变的监听器
        onCurrentItemChanged: {
            // 检查是否返回到了主页（mainPage）
            if (currentItem && currentItem === mainPage) {
                console.log("已返回到首页，确保显示中间列")
                // 显示中间列，隐藏个人练习数据
                if (mainPage) {
                    mainPage.middle_column.visible = true
                    mainPage.user_practice_data.visible = false
                }
            }
        }
    }

    // 主页面
    Rectangle {
        id: mainPage
        color: "transparent"
        visible: false
        objectName: "mainPage"
        
        // 将个人主页用户列表列暴露为属性
        property alias personal_page_column: personal_page_column
        // 将中间列和用户数据页面暴露为属性
        property alias middle_column: middle_column
        property alias user_practice_data: user_practice_data

        // Component initialization
        Component.onCompleted: {
            // Default to showing the middle column on initial load
            middle_column.visible = true
            user_practice_data.visible = false
        }
        
        // 当主页面变为可见时重新加载用户列表（例如从其他页面返回时）
        onVisibleChanged: {
            if (visible && personal_page_column) {
                console.log("主页变为可见，刷新用户列表")
                // 使用延迟调用避免界面卡顿
                Qt.callLater(function() {
                    personal_page_column.loadUserListFromDatabase()
                })
            }
        }

        Image {
            id: function_menu_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: function_menu_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "功能菜单"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            Column {
                anchors.centerIn: parent
                spacing: 25

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "首  页"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("首页 clicked")
                        // 显示中间列，隐藏个人练习数据
                        middle_column.visible = true
                        user_practice_data.visible = false
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火日课"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火日课 clicked")
                        faceRecognitionPopup.targetPage = "DailyCourseContent.qml"
                        faceRecognitionPopup.titleText = "星火日课"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火特训"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火特训 clicked")
                        faceRecognitionPopup.targetPage = "SpecialTrainingPage.qml"
                        faceRecognitionPopup.titleText = "星火特训"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "面容采集"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // 检查当前页面是否已经是面容采集页面
                        if (stackView.currentItem && stackView.currentItem.objectName === "FaceCollectionPage") {
                            console.log("面容采集页面已经打开，不重复打开")
                            return
                        }
                        
                        // 确保在打开新页面前，先关闭可能存在的弹窗
                        if (faceRecognitionPopup.visible) {
                            faceRecognitionPopup.close()
                        }
                        
                        // 确保释放任何可能在使用的摄像头资源
                        if (camera && camera.active) {
                            console.log("面容采集前释放已使用的摄像头资源")
                            camera.active = false
                        }
                        
                        // 短暂延迟后再打开页面，确保资源释放完成
                        delayOpenFaceCollection.start()
                    }
                    
                    // 添加延迟定时器，确保摄像头资源得到释放
                    Timer {
                        id: delayOpenFaceCollection
                        interval: 500
                        running: false
                        repeat: false
                        onTriggered: {
                            console.log("延迟后打开面容采集页面")
                            stackView.push("FaceCollectionPage.qml")
                            
                            // 连接新页面的用户列表更新信号
                            if (stackView.currentItem && stackView.currentItem.userListUpdated) {
                                stackView.currentItem.userListUpdated.connect(function() {
                                    console.log("收到用户列表更新信号")
                                    personal_page_column.loadUserListFromDatabase()
                                })
                            }
                        }
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "策略引擎"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("策略引擎 clicked")
                        faceRecognitionPopup.targetPage = "QuestionEnginePage.qml"
                        faceRecognitionPopup.titleText = "策略引擎"
                        faceRecognitionPopup.open()
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火智能体"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火智能体 clicked")
                        try {
                            // 直接打开星火智能体页面，不需要人脸识别
                            stackView.push("SparkAIAgentPage.qml")
                        } catch (e) {
                            // 显示错误信息
                            console.error("打开星火智能体页面失败: " + e.message)
                            // 显示提示对话框
                            errorDialog.title = "功能不可用"
                            errorDialog.text = "星火智能体需要QtWebEngine支持。请确保已安装Qt WebEngine模块。"
                            errorDialog.open()
                        }
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "工作票核对"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("工作票核对 clicked")
                        stackView.push("WorkTicketCheckPage.qml")
                    }
                }
            }
        }

        // 中间列
        Rectangle {
            id: middle_column
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: function_menu_background.right
            anchors.right: personal_page_background.left
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            visible: true // Default to visible
            // 标题背景图
            Image {      
                id: monthly_ranking_bg_image
                source: "qrc:/images/title_bg.png"
                width: 350
                height: 200
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter   
                anchors.top: parent.top
                anchors.topMargin: -70
                // 智点速览文本
                Text {
                    text: "月度排行榜"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 26
                    color: "white"
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


            Rectangle {
                id: monthly_ranking
                anchors.top: monthly_ranking_bg_image.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: title_bg_image.top                
                anchors.topMargin: -30
                color: "transparent"
                
                //背景
                Image {                    
                    source: "qrc:/images/RankingList_bg.png"
                    width: parent.width / 4 *3
                    height: width / 3
                    fillMode: Image.Stretch
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -50
                }
                //第一名背景
                Image {                    
                    source: "qrc:/images/ranking_bg.png"
                    width: parent.width / 4
                    height: width / 3 * 2 
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 100
                    Image {                    
                        source: "qrc:/images/avatar_bg.png"
                        width: parent.width 
                        height: width
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: -width/2
                        //第一名头像
                        Rectangle {
                            id: firstPlaceAvatarContainer
                            anchors.centerIn: parent  // 改为居中对齐
                            width: parent.width * 0.6  // 再次减小尺寸为父容器的70%
                            height: width  // 保持宽高比
                            radius: width / 2
                            clip: true
                            color: "transparent"
                            
                            Image {
                                id: firstPlaceAvatar
                                anchors.fill: parent
                                source: ""  // 初始设为空
                                fillMode: Image.PreserveAspectCrop
                                cache: false // 禁用缓存，确保每次都重新加载图片
                                asynchronous: true // 异步加载图片
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: firstPlaceAvatar.width
                                        height: firstPlaceAvatar.height
                                        radius: Math.min(width, height) / 2
                                        visible: false
                                    }
                                }
                                
                                // 状态监控
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("第一名头像加载错误:", source)
                                        source = "" // 加载错误时不设置默认头像
                                    } else if (status === Image.Ready) {
                                        console.log("第一名头像加载成功")
                                    } else if (status === Image.Loading) {
                                        console.log("第一名头像正在加载...")
                                    }
                                }
                            }
                        }
                    }
                }
                //第二名背景
                        Image {
                    source: "qrc:/images/ranking_bg.png"
                    width: parent.width / 4
                    height: width / 3 * 2 
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: parent.width / 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 50
                    Image {                    
                        source: "qrc:/images/avatar_bg.png"
                        width: parent.width
                        height: width
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: -width/2
                        //第二名头像
                        Rectangle {
                            id: secondPlaceAvatarContainer
                            anchors.centerIn: parent  // 改为居中对齐
                            width: parent.width * 0.6  // 减小尺寸为父容器的70%
                            height: width  // 保持宽高比
                            radius: width / 2
                            clip: true
                            color: "transparent"
                            
                            Image {
                                id: secondPlaceAvatar
                                anchors.fill: parent
                                source: ""  // 初始设为空
                                fillMode: Image.PreserveAspectCrop
                                cache: false // 禁用缓存，确保每次都重新加载图片
                                asynchronous: true // 异步加载图片
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: secondPlaceAvatar.width
                                        height: secondPlaceAvatar.height
                                        radius: Math.min(width, height) / 2
                                        visible: false
                                    }
                                }
                                
                                // 状态监控
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("第二名头像加载错误:", source)
                                        source = "" // 加载错误时不设置默认头像
                                    } else if (status === Image.Ready) {
                                        console.log("第二名头像加载成功")
                                    } else if (status === Image.Loading) {
                                        console.log("第二名头像正在加载...")
                                    }
                                }
                            }
                        }
                    }
                }
                //第三名背景
                Image {                    
                    source: "qrc:/images/ranking_bg.png"
                    width: parent.width / 4
                    height: width / 3 * 2 
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -parent.width / 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 50
                    Image {                    
                        source: "qrc:/images/avatar_bg.png"
                        width: parent.width
                        height: width
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: -width/2
                        //第三名头像
                        Rectangle {
                            id: thirdPlaceAvatarContainer
                            anchors.centerIn: parent  // 改为居中对齐
                            width: parent.width * 0.6  // 减小尺寸为父容器的70%
                            height: width  // 保持宽高比
                            radius: width / 2
                            clip: true
                            color: "transparent"
                            
                            Image {
                                id: thirdPlaceAvatar
                                anchors.fill: parent
                                source: ""  // 初始设为空
                                fillMode: Image.PreserveAspectCrop
                                cache: false // 禁用缓存，确保每次都重新加载图片
                                asynchronous: true // 异步加载图片
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: thirdPlaceAvatar.width
                                        height: thirdPlaceAvatar.height
                                        radius: Math.min(width, height) / 2
                                        visible: false
                                    }
                                }
                                
                                // 状态监控
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("第三名头像加载错误:", source)
                                        source = "" // 加载错误时不设置默认头像
                                    } else if (status === Image.Ready) {
                                        console.log("第三名头像加载成功")
                                    } else if (status === Image.Loading) {
                                        console.log("第三名头像正在加载...")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // 标题背景图
            Image {
                id: title_bg_image
                source: "qrc:/images/title_bg.png"
                width: 350
                height: 200
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter   
                anchors.bottom: knowledge_point_bg_image.top
                anchors.bottomMargin: -50
                // 智点速览文本
                Text {
                    text: "智 点 速 览"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 26
                    color: "white"
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 知识点背景图
            Image {
                id: knowledge_point_bg_image
                source: "qrc:/images/KnowledgePoint_bg.png"
                // 设置宽度为窗口的三分之一
                width: parent.width / 8 * 5 
                height: parent.height / 3
                // fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -parent.height / 90

                // 智点标题
                Text {
                    id: knowledge_point_title
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "加载中..."
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 24
                    color: "white"
                }

                // 智点内容
                Text {
                    id: knowledge_point_content
                    anchors.top: knowledge_point_title.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: parent.width / 10
                    anchors.rightMargin: parent.width / 10
                    text: "正在加载智点内容..."
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 20
                            color: "white"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                // 智点切换定时器
                Timer {
                    id: knowledge_point_timer
                    interval: 7000  // 默认7秒
                    repeat: true
                    running: false  // 初始设置为不运行
                }

                // 使用Connections来处理定时器触发
                Connections {
                    target: knowledge_point_timer
                    function onTriggered() {
                        console.log("定时器触发，切换到下一个智点")
                        knowledge_point_bg_image.switchToNextKnowledgePoint()
                    }
                }

                // 组件加载完成后初始化
                Component.onCompleted: {
                    console.log("智点组件初始化")
                    // 从数据库加载切换间隔设置
                    var interval = dbManager.getSetting("knowledge_point_switch_interval", "7")
                    knowledge_point_timer.interval = parseInt(interval) * 1000
                    console.log("设置切换间隔为:", interval, "秒")
                    
                    // 加载第一个智点
                    loadKnowledgePoints()
                }

                // 加载智点列表
                function loadKnowledgePoints() {
                    console.log("开始加载智点列表")
                    var points = dbManager.getAllKnowledgePoints()
                    console.log("从数据库获取到", points.length, "个智点")
                    
                    if (points.length > 0) {
                        currentKnowledgePointIndex = 0
                        displayKnowledgePoint(points[currentKnowledgePointIndex])
                        // 启动定时器
                        knowledge_point_timer.start()
                    } else {
                        knowledge_point_title.text = "暂无智点"
                        knowledge_point_content.text = "请先在策略引擎中添加智点"
                    }
                }

                // 切换到下一个智点
                function switchToNextKnowledgePoint() {
                    console.log("切换到下一个智点")
                    var points = dbManager.getAllKnowledgePoints()
                    if (points.length > 0) {
                        currentKnowledgePointIndex = (currentKnowledgePointIndex + 1) % points.length
                        displayKnowledgePoint(points[currentKnowledgePointIndex])
                        console.log("显示智点:", points[currentKnowledgePointIndex].title)
                    }
                }

                // 显示智点
                function displayKnowledgePoint(point) {
                    knowledge_point_title.text = point.title
                    knowledge_point_content.text = point.content
                    console.log("更新显示智点 - 标题:", point.title)
                }

                // 当前显示的智点索引
                property int currentKnowledgePointIndex: 0

                // 确保组件可见时定时器运行，不可见时停止
                onVisibleChanged: {
                    if (visible) {
                        // 每次可见时重新获取最新的间隔设置
                        var interval = dbManager.getSetting("knowledge_point_switch_interval", "7")
                        knowledge_point_timer.interval = parseInt(interval) * 1000
                        console.log("更新定时器间隔为:", interval, "秒")
                        knowledge_point_timer.restart()
                    } else {
                        knowledge_point_timer.stop()
                    }
                }
            }            
        }

        // 用户练习数据显示区域 (添加新组件)
        Rectangle {
            id: user_practice_data
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: function_menu_background.right
            anchors.right: personal_page_background.left
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            visible: false // Default to hidden
            objectName: "user_practice_data"
            
            // 当用户ID改变时，从数据库加载该用户的练习数据
            property string currentUserId: ""
            
            onCurrentUserIdChanged: {
                if (currentUserId !== "") {
                    console.log("用户ID已更改: " + currentUserId)
                    // 从数据库获取当前用户信息
                    var userData = dbManager.getFaceDataByWorkId(currentUserId);
                    if (userData && !userData.isEmpty) {
                        // 更新用户姓名显示
                        user_name.text = userData.name || "未知用户";
                        console.log("已加载用户姓名: " + user_name.text);
                        
                        // 在这里可以加载用户的其他数据
                        loadUserPracticeData(currentUserId);
                    } else {
                        user_name.text = "未知用户";
                        console.log("无法获取用户信息");
                    }
                } else {
                    // 如果ID为空，清空用户名
                    user_name.text = "";
                    console.log("用户ID为空，已清空用户名显示");
                }
            }
            
            // 加载用户练习数据
            function loadUserPracticeData(userId) {
                // 这里加载用户的练习数据并更新UI
                console.log("加载用户练习数据，用户ID: " + userId);
                
                // 获取所有用户最大刷题量
                var maxMonthlyCount = dbManager.getMaxMonthlyQuestionCount();
                
                // 计算目标值为最大刷题量的1.2倍，如果没有数据则使用每日题目数乘以天数
                var targetCount = 0;
                if (maxMonthlyCount <= 0) {
                    // 如果没有刷题记录，使用每日题目数乘以天数作为目标
                    var dailyQuestionCount = parseInt(dbManager.getSetting("daily_question_count", "20"));
                    var currentDate = new Date();
                    var daysInMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0).getDate();
                    targetCount = dailyQuestionCount * daysInMonth;
                } else {
                    // 使用最大值的1.2倍
                    targetCount = Math.ceil(maxMonthlyCount * 1.2);
                }
                
                // 更新进度条目标值
                progress_bar.targetQuestions = targetCount;
                
                // 获取当月刷题数量
                var currentMonthQuestions = dbManager.getUserCurrentMonthQuestionCount(userId) || 0;
                monthly_stats_value.text = currentMonthQuestions.toString();
                
                // 直接设置进度条的当前值，让Behavior动画处理过渡
                progress_bar.currentValue = parseInt(monthly_stats_value.text);
                
                // 获取近一年的刷题数据（从当月向前推12个月）
                var yearlyData = dbManager.getUserRollingYearQuestionData(userId);
                if (yearlyData && yearlyData.length === 12) {
                    // 找出最大值来调整Y轴刻度
                    var maxQuestionCount = 0;
                    for (var i = 0; i < yearlyData.length; i++) {
                        if (yearlyData[i] > maxQuestionCount) {
                            maxQuestionCount = yearlyData[i];
                        }
                    }
                    
                    // 设置Y轴最大值为最大刷题数的1.2倍，确保柱状图有足够空间
                    // 如果最大值太小，则使用默认值100确保图表看起来美观
                    if (maxQuestionCount > 0) {
                        yearly_stats_rect.maxValue = Math.max(100, Math.ceil(maxQuestionCount * 1.2));
                    } else {
                        yearly_stats_rect.maxValue = 100;
                    }
                    
                    console.log("设置Y轴最大值为: " + yearly_stats_rect.maxValue);
                    
                    // 更新数据，这会触发monthlyDataChanged信号，启动动画
                    month_bars.monthlyData = yearlyData;
                    
                    // 启动柱状图动画
                    resetBarAnimation.stop();
                    resetBarAnimation.start();
                }
                
                // 加载五芒图数据
                radar_chart.loadUserPentagonData();
            }

            // 标题背景图
                Image {                    
                id: practice_title_bg_image
                source: "qrc:/images/title_bg2.png"
                width: 200
                height: 50
                fillMode: Image.Stretch
                anchors.horizontalCenter: parent.horizontalCenter   
                anchors.top: parent.top
                
                // 个人数据文本
                Text {
                    id: personalDataTitle
                    text: "学习智能分析"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 24
                    color: "white"
                    anchors.centerIn: parent
                }
            }

            Image {
                id: user_practice_data_bg_image
                source: "qrc:/images/arrows.png"
                width: 40
                height: 18
                fillMode: Image.Stretch
                anchors.verticalCenter: practice_title_bg_image.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -250
                anchors.top: parent.top
                // 逆时针旋转90度
                rotation: -90
            }
            
            // 用户姓名 - 将Text移到Image外部，避免随Image一起旋转
            Text {
                id: user_name
                text: ""
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
                anchors.left: user_practice_data_bg_image.left
                anchors.leftMargin: 60 // 调整到合适位置
                anchors.verticalCenter: practice_title_bg_image.verticalCenter
            }

            // 月刷题统计显示
            Rectangle {
                id: monthly_stats_rect
                anchors.top: practice_title_bg_image.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 50
                color: "#1e3a5f"
                radius: 5
                border.color: "#4A7CB1"
                border.width: 1
                
                Text {
                    id: monthly_stats_title
                    text: "本月刷题数："
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    id: monthly_stats_value
                    text: "0"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#5B9BD5"
                    anchors.left: monthly_stats_title.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                // 进度条背景
                Rectangle {
                    anchors.left: monthly_stats_value.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    color: "#2A5C91"
                    radius: 5
                    
                    // 进度条
                    Rectangle {
                        id: progress_bar
                        property int targetQuestions: 300 // 月目标题数
                        property int currentValue: 0 // 当前显示的值
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        // 使用currentValue进行动画过渡
                        width: Math.min(parent.width * (currentValue / progress_bar.targetQuestions), parent.width)
                        color: "#5B9BD5"
                        radius: 5
                        
                        // 动画效果
                        Behavior on width {
                            NumberAnimation {
                                duration: 1000 // 与柱状图保持一致的动画时长
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }

            // 年度刷题统计图表
            Rectangle {
                id: yearly_stats_rect
                anchors.top: monthly_stats_rect.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: parent.width * 0.1
                anchors.rightMargin: parent.width * 0.1
                height: parent.height * 0.3
                color: "#1e3a5f"
                opacity: 0.7
                radius: 10
                
                Text {
                    id: yearly_stats_title
                    text: "近一年刷题统计"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                }
                
                // 图表Y轴最大值
                property int maxValue: 200
                
                // 图表区域
                Rectangle {
                    id: chart_area
                    anchors.top: yearly_stats_title.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 40
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 40 // 增加底部空间以容纳月份标签
                    color: "transparent"
                    
                    // Y轴刻度线
                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        spacing: parent.height / 4
                        
                        Repeater {
                            model: 5
                            
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#555555"
                                opacity: 0.5
                                
                                Text {
                                    text: yearly_stats_rect.maxValue - (yearly_stats_rect.maxValue / 4 * index)
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 12
                                    color: "#BBDEFB"
                                    anchors.right: parent.left
                                    anchors.rightMargin: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                    
                    // 月份柱状图
                    Row {
                        id: month_bars
                        anchors.fill: parent
                        // 根据图表宽度和柱子数量自动计算间距，确保均匀分布
                        spacing: (parent.width - 12 * 30) / 11 // 使用更均衡的间距计算方式
                        layoutDirection: Qt.LeftToRight // 确保从左到右排列
                        
                        // 12个月的数据
                        property var monthlyData: [120, 200, 150, 80, 70, 110, 130, 200, 150, 80, 70, 110]
                        
                        // 监听数据变化，触发动画重绘
                        onMonthlyDataChanged: {
                            // 数据变化时重新触发柱状图动画
                            resetBarAnimation.start()
                        }
                        
                        // 重置柱状图高度以便重新触发动画
                        function resetBars() {
                            console.log("更新柱状图动画 - 直接过渡到新值");
                            for (var i = 0; i < barRepeater.count; i++) {
                                var barItem = barRepeater.itemAt(i)
                                if (barItem && barItem.children && barItem.children.length > 0) {
                                    var bar = barItem.children[0] // monthBar
                                    if (bar) {
                                        // 重新计算目标高度
                                        if (typeof bar.updateTargetHeight === 'function') {
                                            bar.updateTargetHeight();
                                        }
                                        
                                        // 直接使用动画过渡到目标高度，不先归零
                                        if (typeof bar.startAnimation === 'function') {
                                            // 使用不同的延迟创建波浪效果
                                            var delay = 150 + (i * 80); // 匹配startAnimation中的延迟设置
                                            bar.startAnimation(delay);
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 用于重置柱状图动画的定时器
                        Timer {
                            id: resetBarAnimation
                            interval: 100 // 增加延迟，确保数据已完全更新
                            repeat: false
                            onTriggered: month_bars.resetBars()
                        }
                        
                        Repeater {
                            id: barRepeater
                            model: 12
                            
                            Item {
                                width: 30 // 和柱状图宽度相同
                                height: parent.height // 占据整个高度空间
                                
                                Rectangle {
                                    id: monthBar
                                    width: 30 // 柱子宽度
                                    // 设置动画初始高度为0
                                    property int targetHeight: {
                                        var value = month_bars.monthlyData[index];
                                        // 如果值为0，不显示柱子
                                        return value > 0 ? (value / yearly_stats_rect.maxValue * parent.height) : 0;
                                    }
                                    height: targetHeight // 初始高度设置为目标高度
                                    anchors.bottom: parent.bottom // 从底部向上增长
                                    // 当前月使用不同颜色突出显示
                                    color: index === 11 ? "#78C1FF" : "#5B9BD5"
                                    visible: month_bars.monthlyData[index] > 0 // 只有值大于0时才显示
                                    
                                    // 添加更新目标高度的函数
                                    function updateTargetHeight() {
                                        var value = month_bars.monthlyData[index];
                                        targetHeight = value > 0 ? (value / yearly_stats_rect.maxValue * parent.height) : 0;
                                    }
                                    
                                    // 添加安全的动画启动函数
                                    function startAnimation(delay) {
                                        // 停止可能正在运行的计时器
                                        if (delayTimer.running) {
                                            delayTimer.stop();
                                        }
                                        
                                        // 更新目标高度
                                        updateTargetHeight();
                                        
                                        // 直接设置高度为目标高度，让Behavior动画处理过渡
                                        height = targetHeight;
                                        
                                        // 延迟显示标签
                                        delayTimer.interval = delay || 150 + (index * 80);
                                        delayTimer.start();
                                    }
                                    
                                    // 添加动画效果
                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 1000 // 动画时长增加到1000毫秒，使动画更流畅
                                            easing.type: Easing.OutQuad // 改用OutQuad缓动效果，使动画更自然
                                        }
                                    }
                                    
                                    // 用于延迟启动动画的计时器
                                    Timer {
                                        id: delayTimer
                                        interval: 100 + (index * 50)
                                        repeat: false
                                        onTriggered: {
                                            // 仅处理标签淡入效果
                                            if (month_bars.monthlyData[index] > 0 && labelFadeIn && !labelFadeIn.running) {
                                                labelFadeIn.start();
                                            }
                                        }
                                    }
                                    
                                    Component.onCompleted: {
                                        // 组件加载完成后只启动标签动画，高度已经设置好了
                                        if (delayTimer && !delayTimer.running) {
                                            delayTimer.start();
                                        }
                                    }
                                    
                                    // 添加数值标签
                                    Text {
                                        text: month_bars.monthlyData[index]
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 10
                                        color: "white"
                                        anchors.bottom: parent.top
                                        anchors.bottomMargin: 5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        visible: month_bars.monthlyData[index] > 0 // 只有值大于0时才显示数值
                                        opacity: 0 // 初始透明度为0
                                        
                                        // 添加淡入动画
                                        NumberAnimation on opacity {
                                            id: labelFadeIn
                                            to: 1
                                            duration: 800 // 延长淡入时间
                                            easing.type: Easing.OutCubic // 更平滑的淡入效果
                                            running: false
                                        }
                                    }
                                }
                                
                                // 月份标签 - 确保始终可见
                                Text {
                                    // 显示从现在起前12个月的月份标签
                                    text: {
                                        var d = new Date();
                                        // 从11个月前到当月 (index 0 = 11个月前, index 11 = 当月)
                                        d.setMonth(d.getMonth() - 11 + index);
                                        var month = d.getMonth() + 1;
                                        
                                        // 如果是当前月，显示"本月"
                                        if (index === 11) {
                                            return month + "月\n(本月)";
                                        } else {
                                            return month + "月";
                                        }
                                    }
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 10
                                    color: "#BBDEFB"
                                    anchors.top: parent.bottom // 改为anchors.bottom
                                    anchors.topMargin: 10 // 距离底部的距离
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    // 确保始终可见
                                    visible: true
                                }
                            }
                        }
                    }
                }
            }

            // 个人能力五边形图表
            Rectangle {
                id: ability_chart_rect
                anchors.top: yearly_stats_rect.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: parent.width * 0.1
                anchors.rightMargin: parent.width * 0.1
                anchors.bottomMargin: 20
                color: "#1e3a5f"
                opacity: 0.7
                radius: 10
                
                Text {
                    id: ability_chart_title
                    text: "个人能力五芒图"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Canvas {
                    id: radar_chart
                    anchors.fill: parent
                    
                    // 五个维度的标签
                    property var labels: ["基础认知", "原理理解", "操作应用", "诊断分析", "安全规范"]
                    
                    // 定义颜色
                    property color color1: "#5B9BD5"  // 蓝色
                    property color color2: "#70AD47"  // 绿色
                    property color color3: "#FFAA33"  // 黄色
                    
                    // 月份名称
                    property var currentMonthName: {
                        var d = new Date();
                        return (d.getMonth() + 1) + "月";
                    }
                    
                    property var lastMonthName: {
                        var d = new Date();
                        d.setMonth(d.getMonth() - 1);
                        return (d.getMonth() + 1) + "月";
                    }
                    
                    property var twoMonthsAgoName: {
                        var d = new Date();
                        d.setMonth(d.getMonth() - 2);
                        return (d.getMonth() + 1) + "月";
                    }
                    
                    // 存储标签位置和当前悬停的标签索引
                    property var labelPositions: [{x:0, y:0, width:0, height:0}, 
                                                 {x:0, y:0, width:0, height:0}, 
                                                 {x:0, y:0, width:0, height:0}, 
                                                 {x:0, y:0, width:0, height:0}, 
                                                 {x:0, y:0, width:0, height:0}]
                    
                    // 当前鼠标悬停的标签索引
                    property int hoverIndex: -1
                    
                    // 示例数据 - 五个维度的值（0-1范围）
                    property var data1: [0.8, 0.6, 0.9, 0.7, 0.5]  // 当月数据
                    property var data2: [0.6, 0.5, 0.7, 0.6, 0.4]  // 上月数据
                    property var data3: [0.4, 0.3, 0.5, 0.4, 0.2]  // 上上月数据
                    
                    // 真实数据 - 用于存储实际值
                    property var realData1: [0.8, 0.6, 0.9, 0.7, 0.5]  // 当月实际数据
                    property var realData2: [0.6, 0.5, 0.7, 0.6, 0.4]  // 上月实际数据
                    property var realData3: [0.4, 0.3, 0.5, 0.4, 0.2]  // 上上月实际数据
                    
                    // 动画系数 - 用于控制动画进度 (0.0-1.0)
                    property real animProgress: 0.0
                    
                    // 数据标签（显示具体百分比）
                    property var data1Labels: ["80%", "60%", "90%", "70%", "50%"]  // 当月数据标签
                    property var data2Labels: ["60%", "50%", "70%", "60%", "40%"]  // 上月数据标签
                    property var data3Labels: ["40%", "30%", "50%", "40%", "20%"]  // 上上月数据标签
                    
                    // 动画定时器
                    Timer {
                        id: radarAnimTimer
                        interval: 16  // 约60fps
                        repeat: true
                        running: false
                        onTriggered: {
                            if (radar_chart.animProgress < 1.0) {
                                radar_chart.animProgress += 0.04
                                if (radar_chart.animProgress > 1.0) {
                                    radar_chart.animProgress = 1.0
                                    radarAnimTimer.stop()
                                }
                                
                                // 根据动画进度更新显示数据
                                for (var i = 0; i < 5; i++) {
                                    radar_chart.data1[i] = radar_chart.realData1[i] * radar_chart.animProgress
                                    radar_chart.data2[i] = radar_chart.realData2[i] * radar_chart.animProgress
                                    radar_chart.data3[i] = radar_chart.realData3[i] * radar_chart.animProgress
                                }
                                
                                radar_chart.requestPaint()
                            }
                        }
                    }
                    
                    // 加载用户五芒图数据的函数
                    function loadUserPentagonData() {
                        if (user_practice_data.currentUserId && user_practice_data.currentUserId !== "") {
                            var pentagonData = dbManager.getUserPentagonData(user_practice_data.currentUserId);
                            
                            // 输出五芒图数据到控制台
                            console.log("===== 用户五芒图数据 =====");
                            console.log("用户ID: " + user_practice_data.currentUserId);
                            
                            // 输出原始数据结构
                            console.log("\n----- 原始数据结构 -----");
                            console.log("当月数据: " + JSON.stringify(pentagonData.currentMonth));
                            console.log("上月数据: " + JSON.stringify(pentagonData.lastMonth));
                            console.log("上上月数据: " + JSON.stringify(pentagonData.twoMonthsAgo));
                            
                            // 重置动画
                            radar_chart.animProgress = 0.0
                            
                            // 处理当月数据
                            console.log("\n----- 当月数据 -----");
                            if (pentagonData.currentMonth) {
                                var currentMonthData = [0, 0, 0, 0, 0];
                                var currentMonthLabels = ["0%", "0%", "0%", "0%", "0%"];
                                for (var i = 0; i < labels.length; i++) {
                                    var typeName = labels[i];
                                    var typeData = pentagonData.currentMonth[typeName];
                                    if (typeData && typeof typeData === 'object') {
                                        currentMonthData[i] = typeData.accuracy;
                                        // 计算百分比标签
                                        var percent = Math.round(typeData.accuracy * 100);
                                        currentMonthLabels[i] = percent + "%";
                                        
                                        // 输出到控制台
                                        console.log(typeName + ": 答题总数 = " + typeData.totalQuestions + 
                                                   ", 正确数量 = " + typeData.correctCount + 
                                                   ", 正确率 = " + percent + "%");
                                    } else {
                                        console.log(typeName + ": 无数据");
                                    }
                                }
                                // 保存实际数据到realData1，初始显示数据设为0
                                realData1 = currentMonthData.slice();
                                data1 = [0, 0, 0, 0, 0];
                                data1Labels = currentMonthLabels;
                            } else {
                                console.log("无当月数据");
                                realData1 = [0, 0, 0, 0, 0];
                                data1 = [0, 0, 0, 0, 0];
                            }
                            
                            // 处理上月数据
                            console.log("\n----- 上月数据 -----");
                            if (pentagonData.lastMonth) {
                                var lastMonthData = [0, 0, 0, 0, 0];
                                var lastMonthLabels = ["0%", "0%", "0%", "0%", "0%"];
                                for (var i = 0; i < labels.length; i++) {
                                    var typeName = labels[i];
                                    var typeData = pentagonData.lastMonth[typeName];
                                    if (typeData && typeof typeData === 'object') {
                                        lastMonthData[i] = typeData.accuracy;
                                        // 计算百分比标签
                                        var percent = Math.round(typeData.accuracy * 100);
                                        lastMonthLabels[i] = percent + "%";
                                        
                                        // 输出到控制台
                                        console.log(typeName + ": 答题总数 = " + typeData.totalQuestions + 
                                                   ", 正确数量 = " + typeData.correctCount + 
                                                   ", 正确率 = " + percent + "%");
                                    } else {
                                        console.log(typeName + ": 无数据");
                                    }
                                }
                                // 保存实际数据到realData2，初始显示数据设为0
                                realData2 = lastMonthData.slice();
                                data2 = [0, 0, 0, 0, 0];
                                data2Labels = lastMonthLabels;
                            } else {
                                console.log("无上月数据");
                                realData2 = [0, 0, 0, 0, 0];
                                data2 = [0, 0, 0, 0, 0];
                            }
                            
                            // 处理上上月数据
                            console.log("\n----- 上上月数据 -----");
                            if (pentagonData.twoMonthsAgo) {
                                var twoMonthsAgoData = [0, 0, 0, 0, 0];
                                var twoMonthsAgoLabels = ["0%", "0%", "0%", "0%", "0%"];
                                for (var i = 0; i < labels.length; i++) {
                                    var typeName = labels[i];
                                    var typeData = pentagonData.twoMonthsAgo[typeName];
                                    if (typeData && typeof typeData === 'object') {
                                        twoMonthsAgoData[i] = typeData.accuracy;
                                        // 计算百分比标签
                                        var percent = Math.round(typeData.accuracy * 100);
                                        twoMonthsAgoLabels[i] = percent + "%";
                                        
                                        // 输出到控制台
                                        console.log(typeName + ": 答题总数 = " + typeData.totalQuestions + 
                                                   ", 正确数量 = " + typeData.correctCount + 
                                                   ", 正确率 = " + percent + "%");
                                    } else {
                                        console.log(typeName + ": 无数据");
                                    }
                                }
                                // 保存实际数据到realData3，初始显示数据设为0
                                realData3 = twoMonthsAgoData.slice();
                                data3 = [0, 0, 0, 0, 0];
                                data3Labels = twoMonthsAgoLabels;
                            } else {
                                console.log("无上上月数据");
                                realData3 = [0, 0, 0, 0, 0];
                                data3 = [0, 0, 0, 0, 0];
                            }
                            
                            // 输出结束标识
                            console.log("\n===== 五芒图数据输出结束 =====");
                            
                            // 开始动画
                            radarAnimTimer.start();
                        } else {
                            console.log("用户ID为空，无法获取五芒图数据");
                        }
                    }
                    
                    Component.onCompleted: {
                        // 初始加载数据
                        loadUserPentagonData();
                    }
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        var centerX = width / 2;
                        var centerY = height / 2 + 15; // 向下移动15个像素
                        var size = Math.min(width, height) / 2 * 0.8;
                        
                        // 清空画布
                        ctx.clearRect(0, 0, width, height);
                        
                        // 绘制背景网格
                        drawPentagon(ctx, centerX, centerY, size, "#555555", 0.2, false);
                        drawPentagon(ctx, centerX, centerY, size * 0.8, "#555555", 0.2, false);
                        drawPentagon(ctx, centerX, centerY, size * 0.6, "#555555", 0.2, false);
                        drawPentagon(ctx, centerX, centerY, size * 0.4, "#555555", 0.2, false);
                        drawPentagon(ctx, centerX, centerY, size * 0.2, "#555555", 0.2, false);
                        
                        // 绘制数据多边形
                        drawDataPolygon(ctx, centerX, centerY, size, data3, color3, 0.6);
                        drawDataPolygon(ctx, centerX, centerY, size, data2, color2, 0.6);
                        drawDataPolygon(ctx, centerX, centerY, size, data1, color1, 0.8);
                        
                        // 绘制维度轴线
                        drawAxisLines(ctx, centerX, centerY, size, "#666666");
                        
                        // 绘制标签和数据点值
                        drawLabels(ctx, centerX, centerY, size);
                        
                        // 显示月份图例
                        drawLegend(ctx, centerX, centerY, size);
                    }
                    
                    // 绘制多边形函数
                    function drawPentagon(ctx, centerX, centerY, radius, color, alpha, fill) {
                        ctx.beginPath();
                        ctx.strokeStyle = color;
                        ctx.fillStyle = color;
                        ctx.globalAlpha = alpha;
                        
                        for (var i = 0; i < 5; i++) {
                            var angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
                            var x = centerX + radius * Math.cos(angle);
                            var y = centerY + radius * Math.sin(angle);
                            
                            if (i === 0) {
                                ctx.moveTo(x, y);
                            } else {
                                ctx.lineTo(x, y);
                            }
                        }
                        
                        ctx.closePath();
                        if (fill) {
                            ctx.fill();
                        } else {
                            ctx.stroke();
                        }
                        ctx.globalAlpha = 1.0;
                    }
                    
                    // 绘制数据多边形
                    function drawDataPolygon(ctx, centerX, centerY, radius, data, color, alpha) {
                        // 开始绘制
                        ctx.strokeStyle = color;
                        ctx.fillStyle = color;
                        ctx.globalAlpha = alpha;
                        ctx.lineWidth = 2;
                        
                        // 计算所有点的位置和信息
                        var points = [];
                        for (var i = 0; i < 5; i++) {
                            var angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
                            var value = Math.max(0, Math.min(1, data[i])); // 确保值在0-1范围内
                            
                            // 计算点的位置
                            points.push({
                                x: centerX + radius * value * Math.cos(angle),
                                y: centerY + radius * value * Math.sin(angle),
                                value: value,
                                angle: angle,
                                index: i
                            });
                        }
                        
                        // 先绘制所有为0的点
                        for (var i = 0; i < 5; i++) {
                            if (points[i].value < 0.01) {
                                ctx.beginPath();
                                ctx.arc(centerX, centerY, 3, 0, Math.PI * 2);
                                ctx.fill();
                            }
                        }
                        
                        // 检查是否所有点都是0
                        var allZero = true;
                        for (var i = 0; i < 5; i++) {
                            if (points[i].value > 0.01) {
                                allZero = false;
                                break;
                            }
                        }
                        
                        // 如果所有点都是0，不绘制多边形
                        if (allZero) {
                            return;
                        }
                        
                        // 为每相邻的两个点分别绘制，避免连成一个闭合路径
                        // 这样可以防止在有些点为0、有些不为0的情况下形成奇怪的图形
                        for (var i = 0; i < 5; i++) {
                            var current = points[i];
                            var next = points[(i + 1) % 5];
                            
                            // 只有当两个点都不为0时才连线
                            if (current.value > 0.01 && next.value > 0.01) {
                                ctx.beginPath();
                                ctx.moveTo(current.x, current.y);
                                ctx.lineTo(next.x, next.y);
                                ctx.stroke();
                            }
                        }
                        
                        // 计算有效区域，用于填充
                        var validPoints = points.filter(function(p) {
                            return p.value > 0.01;
                        });
                        
                        // 如果有2个以上有效点，才绘制填充区域
                        if (validPoints.length >= 3) {
                            // 按原始索引排序
                            validPoints.sort(function(a, b) {
                                return a.index - b.index;
                            });
                            
                            // 绘制填充区域
                            ctx.beginPath();
                            ctx.moveTo(validPoints[0].x, validPoints[0].y);
                            
                            for (var i = 1; i < validPoints.length; i++) {
                                ctx.lineTo(validPoints[i].x, validPoints[i].y);
                            }
                            
                            ctx.closePath();
                            ctx.globalAlpha = 0.3;
                            ctx.fill();
                            ctx.globalAlpha = alpha;
                        }
                        
                        // 绘制非0值点
                        for (var i = 0; i < 5; i++) {
                            if (points[i].value > 0.01) {
                                ctx.beginPath();
                                ctx.arc(points[i].x, points[i].y, 3, 0, Math.PI * 2);
                                ctx.fill();
                            }
                        }
                        
                        ctx.globalAlpha = 1.0;
                    }
                    
                    // 绘制轴线
                    function drawAxisLines(ctx, centerX, centerY, radius, color) {
                        ctx.strokeStyle = color;
                        ctx.lineWidth = 1;
                        
                        for (var i = 0; i < 5; i++) {
                            var angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
                            ctx.beginPath();
                            ctx.moveTo(centerX, centerY);
                            ctx.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
                            ctx.stroke();
                        }
                    }
                    
                    // 绘制标签和数据点值
                    function drawLabels(ctx, centerX, centerY, radius) {
                        ctx.fillStyle = "white";
                        ctx.font = "15px 阿里妈妈数黑体";
                        ctx.textAlign = "center";
                        ctx.textBaseline = "middle";
                        
                        // 重置标签位置数组
                        labelPositions = [];
                        
                        for (var i = 0; i < 5; i++) {
                            var angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
                            
                            // 标签位置调整 - 为每个位置单独设置半径和位置偏移
                            var labelRadius = radius * 1.1; // 默认外部偏移
                            var offsetX = 0;
                            var offsetY = 0;
                            
                            // 为每个方向单独调整
                            if (i === 0) { // 顶部
                                labelRadius = radius * 1.2;
                                offsetY = 20;
                            } else if (i === 1) { // 右上
                                labelRadius = radius * 1.2;
                                offsetX = 10;
                                offsetY = 5;
                            } else if (i === 2) { // 右下
                                labelRadius = radius * 1.2;
                                offsetX = 10;
                                offsetY = -10;
                            } else if (i === 3) { // 左下
                                labelRadius = radius * 1.2;
                                offsetX = -10;
                                offsetY = -10;
                            } else if (i === 4) { // 左上
                                labelRadius = radius * 1.2;
                                offsetX = -10;
                                offsetY = 5;
                            }
                            
                            var x = centerX + labelRadius * Math.cos(angle) + offsetX;
                            var y = centerY + labelRadius * Math.sin(angle) + offsetY;
                            
                            // 存储标签位置用于鼠标悬停检测 - 调整大小为更准确的匹配
                            var labelWidth = ctx.measureText(labels[i]).width + 20; // 添加一些边距
                            labelPositions.push({
                                x: x - labelWidth/2,
                                y: y - 15,
                                width: labelWidth,
                                height: 30
                            });
                            
                            // 绘制标签
                            ctx.fillStyle = (i === hoverIndex) ? "#FFFF00" : "white"; // 悬停时黄色
                            ctx.fillText(labels[i], x, y);
                            ctx.fillStyle = "white";
                            
                            // 当鼠标悬停时，绘制百分比信息
                            if (i === hoverIndex) {
                                // 绘制悬停提示框 - 调整位置以避免超出边界
                                var tooltipWidth = 150;
                                var tooltipHeight = 80;
                                
                                // 计算提示框位置，确保不会超出可视区域
                                var tooltipX = x;
                                var tooltipY = y - 50; // 默认在标签上方显示
                                
                                // 调整X轴位置，防止提示框超出左右边界
                                if (tooltipX - tooltipWidth/2 < 0) {
                                    tooltipX = tooltipWidth/2 + 10; // 左边界保持一定距离
                                } else if (tooltipX + tooltipWidth/2 > width) {
                                    tooltipX = width - tooltipWidth/2 - 10; // 右边界保持一定距离
                                }
                                
                                // 调整Y轴位置，防止提示框超出上下边界
                                if (tooltipY - tooltipHeight/2 < 0) {
                                    tooltipY = tooltipHeight/2 + 55; // 上边界保持一定距离
                                } else if (tooltipY + tooltipHeight/2 > height) {
                                    tooltipY = y - 20; // 如果下方空间不足，将提示框移到标签上方
                                }
                                
                                // 绘制背景
                                ctx.fillStyle = "rgba(0, 0, 0, 0.7)";
                                
                                // 绘制圆角矩形背景
                                var cornerRadius = 8; // 圆角半径
                                ctx.beginPath();
                                ctx.moveTo(tooltipX - tooltipWidth/2 + cornerRadius, tooltipY - tooltipHeight/2);
                                ctx.lineTo(tooltipX + tooltipWidth/2 - cornerRadius, tooltipY - tooltipHeight/2);
                                ctx.quadraticCurveTo(tooltipX + tooltipWidth/2, tooltipY - tooltipHeight/2, tooltipX + tooltipWidth/2, tooltipY - tooltipHeight/2 + cornerRadius);
                                ctx.lineTo(tooltipX + tooltipWidth/2, tooltipY + tooltipHeight/2 - cornerRadius);
                                ctx.quadraticCurveTo(tooltipX + tooltipWidth/2, tooltipY + tooltipHeight/2, tooltipX + tooltipWidth/2 - cornerRadius, tooltipY + tooltipHeight/2);
                                ctx.lineTo(tooltipX - tooltipWidth/2 + cornerRadius, tooltipY + tooltipHeight/2);
                                ctx.quadraticCurveTo(tooltipX - tooltipWidth/2, tooltipY + tooltipHeight/2, tooltipX - tooltipWidth/2, tooltipY + tooltipHeight/2 - cornerRadius);
                                ctx.lineTo(tooltipX - tooltipWidth/2, tooltipY - tooltipHeight/2 + cornerRadius);
                                ctx.quadraticCurveTo(tooltipX - tooltipWidth/2, tooltipY - tooltipHeight/2, tooltipX - tooltipWidth/2 + cornerRadius, tooltipY - tooltipHeight/2);
                                ctx.closePath();
                                ctx.fill();
                                
                                // 绘制文本
                                ctx.fillStyle = color1;
                                ctx.fillText(currentMonthName + ": " + data1Labels[i], tooltipX, tooltipY - 20);
                                
                                ctx.fillStyle = color2;
                                ctx.fillText(lastMonthName + ": " + data2Labels[i], tooltipX, tooltipY);
                                
                                ctx.fillStyle = color3;
                                ctx.fillText(twoMonthsAgoName + ": " + data3Labels[i], tooltipX, tooltipY + 20);
                                
                                ctx.fillStyle = "white";
                            }
                        }
                    }
                    
                    // 绘制图例函数
                    function drawLegend(ctx, centerX, centerY, size) {
                        // 图例放在底部，不使用ctx绘制而是使用QML组件
                        // 这是一个空函数，实际的图例显示由QML的Row组件实现
                        // 保留这个函数调用以保持代码一致性
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onPositionChanged: {
                            var foundIndex = -1;
                            
                            // 检查鼠标是否在任何标签上
                            for (var i = 0; i < radar_chart.labelPositions.length; i++) {
                                var pos = radar_chart.labelPositions[i];
                                if (mouseX >= pos.x && mouseX <= pos.x + pos.width &&
                                    mouseY >= pos.y && mouseY <= pos.y + pos.height) {
                                    foundIndex = i;
                                    break;
                                }
                            }
                            
                            if (radar_chart.hoverIndex !== foundIndex) {
                                radar_chart.hoverIndex = foundIndex;
                                radar_chart.requestPaint(); // 重绘画布
                            }
                        }
                        
                        onExited: {
                            radar_chart.hoverIndex = -1;
                            radar_chart.requestPaint(); // 重绘画布
                        }
                    }
                    
                    // 图例
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 30
                        
                        Row {
                            spacing: 5
                            Rectangle {
                                width: 15
                                height: 10
                                color: radar_chart.color1
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: radar_chart.currentMonthName
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 12
                                color: "white"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            Rectangle {
                                width: 15
                                height: 10
                                color: radar_chart.color2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: radar_chart.lastMonthName
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 12
                                color: "white"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            Rectangle {
                                width: 15
                                height: 10
                                color: radar_chart.color3
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: radar_chart.twoMonthsAgoName
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 12
                                color: "white"
                            }
                        }
                    }
                }
                
                // 当用户ID改变时，从数据库加载该用户的练习数据
            }
        }

        Image {
            id: personal_page_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: personal_page_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "个人主页"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            Flickable {
                id: personal_page_flickable
                anchors.top: personal_page_text.bottom
                anchors.topMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                clip: true
                
                // 滚动属性
                contentWidth: personal_page_column.width
                contentHeight: personal_page_column.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                
                // 启用滚动条
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    interactive: true
                }

                Column {
                    id: personal_page_column
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0
                    width: 200

                    // 组件加载完成后，从数据库加载数据
                    Component.onCompleted: {
                        loadUserListFromDatabase()
                    }

                    // 从数据库加载用户列表的函数
                    function loadUserListFromDatabase() {
                        console.log("开始加载用户列表...");
                        
                        // 获取当前排序选项
                        var sortOption = dbManager.getSetting("home_sort_option", "1");
                        console.log("当前排序选项: " + sortOption + 
                                   " (" + (sortOption === "1" ? "本月个人能力排序" : "本月刷题数排序") + ")");
                        
                        // 确保排序选项为有效值（如果为空或非法值则使用默认值'1'）
                        if (sortOption !== "0" && sortOption !== "1") {
                            console.log("检测到无效的排序选项: " + sortOption + "，使用默认值'1'（个人能力排序）");
                            sortOption = "1";
                            dbManager.setSetting("home_sort_option", sortOption);
                        }
                        
                        console.log("当前用户列表项数: " + userButtonModel.count);
                        
                        // 从数据库获取所有人脸数据（按照设置排序）
                        var userList = dbManager.getAllFaceDataSorted();
                        console.log("从数据库获取到 " + userList.length + " 个用户（已排序）");
                        
                        // 清空现有模型
                        userButtonModel.clear();
                        console.log("已清空用户列表模型");
                        
                        // 将数据添加到模型中
                        for (var j = 0; j < userList.length; j++) {
                            userButtonModel.append({
                                "name": userList[j].name,
                                "workId": userList[j].workId,
                                "avatarPath": userList[j].avatarPath
                            });
                            console.log("添加用户 #" + (j+1) + ": " + userList[j].name + " (工号: " + userList[j].workId + ")");
                        }
                        
                        console.log("用户列表更新完成，共加载 " + userList.length + " 个用户");
                        
                        // 更新排行榜头像
                        updateRankingAvatars();
                    }
                    
                    // 更新排行榜头像的函数
                    function updateRankingAvatars() {
                        console.log("更新排行榜头像");
                        
                        try {
                            // 调用辅助函数，设置默认头像
                            refreshRankingImages();
                            
                            // 输出诊断信息
                            if (userButtonModel.count > 0) {
                                console.log("第一名用户:", 
                                    userButtonModel.get(0).name,
                                    "工号:", userButtonModel.get(0).workId);
                            }
                        } catch (e) {
                            console.log("更新排行榜头像出错:", e);
                        }
                    }

                    // 创建一个ListModel来存储用户数据
                    ListModel {
                        id: userButtonModel
                    }
                    
                    // 刷新排行榜配置
                    function refreshRankingImages() {
                        console.log("刷新排行榜图像");
                        
                        // 修复路径格式的辅助函数
                        function fixPath(path) {
                            if (!path || path.toString().trim() === "") {
                                return ""; // 返回空字符串而不是默认头像
                            }
                            
                            var fixedPath = path.toString().trim();
                            
                            // 该路径已经是QUrl格式，直接返回
                            if (fixedPath.startsWith("file:///")) {
                                console.log("路径已经是URL格式，不需要修正:", fixedPath);
                                return fixedPath;
                            }
                            
                            // 替换反斜杠为正斜杠
                            fixedPath = fixedPath.replace(/\\/g, "/");
                            
                            // 确保有file:///前缀
                            if (!fixedPath.startsWith("file:///")) {
                                fixedPath = "file:///" + fixedPath;
                            }
                            
                            console.log("原始路径:", path, "修正后:", fixedPath);
                            return fixedPath;
                        }
                        
                        // 首先将所有头像设置为空
                        firstPlaceAvatar.source = "";
                        secondPlaceAvatar.source = "";
                        thirdPlaceAvatar.source = "";
                        
                        // 延迟一下再尝试加载真实头像
                        Qt.callLater(function() {
                            if (userButtonModel.count > 0) {
                                var path1 = userButtonModel.get(0).avatarPath;
                                if (path1 && path1 !== "") {
                                    firstPlaceAvatar.source = fixPath(path1);
                                }
                            }
                            
                            if (userButtonModel.count > 1) {
                                var path2 = userButtonModel.get(1).avatarPath;
                                if (path2 && path2 !== "") {
                                    secondPlaceAvatar.source = fixPath(path2);
                                }
                            }
                            
                            if (userButtonModel.count > 2) {
                                var path3 = userButtonModel.get(2).avatarPath;
                                if (path3 && path3 !== "") {
                                    thirdPlaceAvatar.source = fixPath(path3);
                                }
                            }
                        });
                    }

                    // 使用Repeater显示数据
                    Repeater {
                        id: userButtonRepeater
                        model: userButtonModel

                        Button {
                            width: 200
                            height: 60
                            
                            // 使用Qt 6兼容的样式定制方式

                                
                            background: Image {
                                    anchors.fill: parent
                                source: "qrc:/images/personal_button_bg.png"
                                fillMode: Image.Stretch
                            }
                                
                                contentItem: Text {
                                    text: model.name
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 30
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    anchors.verticalCenterOffset: -6
                                }
                            
                            Item {
                                // 奖牌图标容器
                                visible: index < 3  // 只对前三名显示
                                width: 30
                                height: 30
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -3
                                
                                Image {
                                    anchors.fill: parent
                                    source: {
                                        if (index === 0) return "qrc:/images/goldMedal.png"
                                        else if (index === 1) return "qrc:/images/silverMedal.png"
                                        else return "qrc:/images/bronzeMedal.png"
                                    }
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            
                            
                            onClicked: {
                                console.log(model.name + " clicked, workId: " + model.workId)
                                // 设置当前选中的用户ID
                                user_practice_data.currentUserId = model.workId
                                // 显示个人练习数据，隐藏中间列
                                middle_column.visible = false
                                user_practice_data.visible = true
                            }
                        }
                    }
                }
            }
        }
    }

    // 人脸识别摄像头弹窗
    Popup {
        id: faceRecognitionPopup
        width: 800
        height: 600
        anchors.centerIn: parent
        modal: true
        
        // 去除模糊效果以提高性能
        // Overlay.modal: Rectangle {
        //     color: "#80000000"
        // }
        
        closePolicy: Popup.CloseOnEscape
        
        property string capturedImagePath: ""
        property bool isRecognizing: false
        property int recognitionTimerId: 0
        property bool isFaceDetected: false
        property rect detectedFaceRect: Qt.rect(0, 0, 0, 0)
        property int trackingUpdateInterval: 200 // 人脸跟踪更新间隔(毫秒)，改为200ms提高响应速度
        property string targetPage: ""
        property string titleText: ""
        property var extraParams: ({}) // 添加额外参数属性，用于向目标页面传递参数
        
        // 添加MediaDevices对象用于访问摄像头列表
        MediaDevices {
            id: mediaDevices
        }
        
        // 弹窗打开后立即检查摄像头并开始人脸跟踪
        onOpened: {
            console.log("人脸识别弹窗已打开，检查摄像头...")
            
            isRecognizing = false
            isFaceDetected = false
            
            // 重置人脸矩形
            detectedFaceRect = Qt.rect(0, 0, 0, 0)
            
            // 初始化摄像头
            initCamera()
            
            // 激活摄像头
            camera.active = true
            
            // 在成功打开摄像头后启动人脸跟踪
            Qt.callLater(function() {
                startFaceTracking()
            })
            
            // 延迟2秒后开始识别
            recognitionTimer.restart()
        }
        
        // 初始化摄像头
        function initCamera() {
            // 先关闭之前可能在运行的摄像头
            if (camera.active) {
                camera.active = false
            }
            
            // 获取摄像头设置
            var savedCameraId = dbManager.getSetting("camera_device", "auto")
            console.log("人脸识别弹窗 - 重新设置摄像头，设置:", savedCameraId)
            
            // 检查可用摄像头
            var cameras = mediaDevices.videoInputs
            console.log("可用摄像头数量:", cameras.length)
            
            if (cameras.length === 0) {
                console.log("无法找到可用摄像头")
                statusText.text = "未检测到摄像头设备"
                return
            }
            
            if (savedCameraId === "auto") {
                // 自动模式，使用默认摄像头
                if (cameras.length > 0) {
                    camera.cameraDevice = cameras[0]
                    console.log("人脸识别弹窗 - 使用默认摄像头:", camera.cameraDevice.id)
                }
            } else if (savedCameraId !== "") {
                // 使用指定的摄像头ID
                var foundDevice = false
                var selectedCamera = null
                // 先检查指定的ID是否在可用列表中
                for (var i = 0; i < cameras.length; i++) {
                    if (cameras[i].id === savedCameraId) {
                        selectedCamera = cameras[i]
                        foundDevice = true
                        break
                    }
                }
                
                if (foundDevice) {
                    camera.cameraDevice = selectedCamera
                    console.log("人脸识别弹窗 - 使用指定摄像头:", camera.cameraDevice.id)
                } else if (cameras.length > 0) {
                    camera.cameraDevice = cameras[0]
                    console.log("人脸识别弹窗 - 指定摄像头不可用，使用默认摄像头:", camera.cameraDevice.id)
                }
            }
            
            // 设置合适的分辨率
            if (camera.cameraDevice) {
                var closestFormat = null
                var targetRes = Qt.size(640, 360)
                var minDiff = Number.MAX_VALUE
                
                for (var i = 0; i < camera.cameraDevice.videoFormats.length; i++) {
                    var format = camera.cameraDevice.videoFormats[i]
                    var res = format.resolution
                    var diff = Math.abs(res.width - targetRes.width) + Math.abs(res.height - targetRes.height)
                    
                    if (diff < minDiff) {
                        minDiff = diff
                        closestFormat = format
                    }
                }
                
                if (closestFormat) {
                    camera.cameraFormat = closestFormat
                    console.log("设置摄像头分辨率:", camera.cameraFormat.resolution.width, "x", camera.cameraFormat.resolution.height)
                }
            }
        }

        onClosed: {
            console.log("人脸识别弹窗已关闭，停止摄像头")
            
            // 停止摄像头
            camera.active = false
            
            // 停止定时器
            faceTrackingTimer.stop()
            recognitionTimer.stop()
            periodicRecognitionTimer.stop()
            
            // 停止人脸追踪框旋转
            faceRecognizer.stopRotation()
            
            // 清理变量
            isRecognizing = false
            isFaceDetected = false
            
            // 重置所有摄像头和视频输出属性
            if (videoOutput) {
                console.log("完全重置VideoOutput属性")
                videoOutput.rotation = 0
                
                // 重置变换
                var newTransform = []
                newTransform.push(Qt.createQmlObject(
                    'import QtQuick 2.15; Scale { xScale: -1; yScale: 1; origin.x: videoOutput.width / 2 }',
                    videoOutput, 
                    "dynamicCloseTransform"
                ));
                videoOutput.transform = newTransform
            }
            
            // 触发状态文本预设
            statusText.text = "正在准备摄像头..."
        }
        
        // 用于延迟启动识别的定时器
        Timer {
            id: recognitionTimer
            interval: 2000
            onTriggered: {
                faceRecognitionPopup.startRecognition()
            }
            
            function restart() {
                stop()
                start()
            }
        }
        
        // 周期性人脸识别的定时器
        Timer {
            id: periodicRecognitionTimer
            interval: 1000  // 减少为1秒尝试识别一次
            repeat: true
            running: faceRecognitionPopup.isRecognizing
            onTriggered: {
                faceRecognitionPopup.captureAndRecognize()
            }
        }
        
        // 人脸跟踪定时器
        Timer {
            id: faceTrackingTimer
            interval: 200  // 减少为200毫秒，提高跟踪速度
            repeat: true
            running: false
            onTriggered: {
                faceRecognitionPopup.trackFace()
            }
        }
        
        // 开始人脸识别
        function startRecognition() {
            statusText.text = "正在进行人脸识别..."
            isRecognizing = true
            captureAndRecognize()
        }
        
        // 捕获图像并进行识别
        function captureAndRecognize() {
            if (!isRecognizing) return
            
            var tempPath = fileManager.getApplicationDir() + "/temp/face_recognition_temp.jpg"
            imageCapture.captureToFile(tempPath)
            capturedImagePath = tempPath
            
            // 图片保存完成后由onImageSaved事件触发识别
        }
        
        // 进行人脸跟踪
        function trackFace() {
            var tempPath = fileManager.getApplicationDir() + "/temp/face_tracking_temp.jpg"
            imageCapture.captureToFile(tempPath)
            
            // 清理之前可能存在的所有连接
            try {
                imageCapture.imageSaved.disconnect(trackFaceImageSavedHandler)
            } catch (e) {
                // 可能没有连接，忽略错误
            }
            
            // 在图片保存完成后检测人脸位置
            imageCapture.imageSaved.connect(trackFaceImageSavedHandler)
        }
        
        // 人脸跟踪图像保存后的处理函数
        function trackFaceImageSavedHandler(id, path) {
            console.log("Face tracking image saved: " + path)
            
            // 检查是否是跟踪用的临时图像
            var tempPath = fileManager.getApplicationDir() + "/temp/face_tracking_temp.jpg"
            if (path !== tempPath) {
                console.log("Not a tracking image, ignoring")
                return
            }
            
            // 使用FaceRecognizer检测人脸位置
            var faceInfo = faceRecognizer.detectFacePosition(path)
            console.log("Face detection result: " + JSON.stringify(faceInfo))
            
            if (faceInfo.faceDetected) {
                console.log("Face detected at: x=" + faceInfo.x + ", y=" + faceInfo.y + 
                           ", width=" + faceInfo.width + ", height=" + faceInfo.height)
                
                isFaceDetected = true
                
                // 获取视频输出区域的实际尺寸
                var actualVideoRect = videoOutput.contentRect
                console.log("Video area: x=" + actualVideoRect.x + ", y=" + actualVideoRect.y + 
                           ", width=" + actualVideoRect.width + ", height=" + actualVideoRect.height)
                
                // 将人脸坐标从图像坐标系转换到视频区域坐标系
                var normalizedRect = Qt.rect(
                    // 镜像显示时，需要翻转X坐标
                    actualVideoRect.x + (1.0 - (faceInfo.x + faceInfo.width) / faceInfo.imageWidth) * actualVideoRect.width,
                    actualVideoRect.y + (faceInfo.y / faceInfo.imageHeight) * actualVideoRect.height,
                    (faceInfo.width / faceInfo.imageWidth) * actualVideoRect.width,
                    (faceInfo.height / faceInfo.imageHeight) * actualVideoRect.height
                )
                console.log("Normalized face rect: x=" + normalizedRect.x + ", y=" + normalizedRect.y + 
                           ", width=" + normalizedRect.width + ", height=" + normalizedRect.height)
                
                // 更新人脸框位置
                detectedFaceRect = normalizedRect
                
                // 显示跟踪状态
                if (!isRecognizing) {
                    statusText.text = "检测到人脸，对准框中央以进行识别"
                }
                
                // 更新人脸框颜色为绿色（成功检测到人脸）
                // faceFrame.border.color = "green"  // Image没有border属性
                faceFrame.opacity = 1.0  // 成功检测到人脸时使用完全不透明
            } else {
                console.log("No face detected in tracking image")
                isFaceDetected = false
                
                // 重置人脸框到中央
                detectedFaceRect = Qt.rect(0, 0, 0, 0)
                
                // 显示未检测到人脸
                if (!isRecognizing) {
                    statusText.text = "未检测到人脸，请正对摄像头"
                }
                
                // 更新人脸框颜色为红色（未检测到人脸）
                // faceFrame.border.color = "red"  // Image没有border属性
                faceFrame.opacity = 0.5  // 未检测到人脸时使用半透明
            }
        }
        
        // 在所有用户中进行人脸识别的函数
        function recognizeFaceInAllUsers(imagePath) {
            console.log("开始人脸识别，图像路径: " + imagePath)
            
            // 停止定时器，避免重复识别
            periodicRecognitionTimer.stop()
            
            // 首先检查是否检测到人脸
            var faceInfo = faceRecognizer.detectFacePosition(imagePath)
            if (!faceInfo.faceDetected) {
                console.log("未检测到人脸，无法识别")
                statusText.text = "未检测到人脸，请正对摄像头"
                // 重新启动定时器继续识别
                periodicRecognitionTimer.start()
                return
            }
            
            // 显示正在识别状态
            statusText.text = "正在识别人脸..."
            
            // 调用后端进行人脸识别
            var result = dbManager.recognizeFace(imagePath)
            console.log("人脸识别结果: " + JSON.stringify(result))
            
            if (result.recognized) {
                // 识别成功
                statusText.text = "欢迎你，" + result.name
                
                // 确保定时器已停止
                periodicRecognitionTimer.stop()
                faceTrackingTimer.stop()
                
                Qt.callLater(function() {
                    // 关闭弹窗
                    faceRecognitionPopup.close()
                    
                    // 判断目标页面并打开
                    if (faceRecognitionPopup.targetPage !== "") {
                        // 打开指定的页面
                        console.log("打开目标页面：" + faceRecognitionPopup.targetPage + 
                                   (Object.keys(faceRecognitionPopup.extraParams).length > 0 ? 
                                    "，附加参数：" + JSON.stringify(faceRecognitionPopup.extraParams) : ""))
                        
                        // 使用临时对象组合所有参数
                        var pageParams = { 
                            userData: { id: result.id, name: result.name, workId: result.workId }
                        }
                        
                        // 合并extraParams中的参数
                        if (Object.keys(faceRecognitionPopup.extraParams).length > 0) {
                            for (var key in faceRecognitionPopup.extraParams) {
                                pageParams[key] = faceRecognitionPopup.extraParams[key]
                            }
                        }
                        
                        // 打开页面并传递参数
                        stackView.push(faceRecognitionPopup.targetPage, pageParams)
                    }
                })
            } else {
                // 识别失败
                statusText.text = "人脸识别失败，请再试一次"
                console.log("人脸识别失败")
                // 重新启动定时器继续识别
                periodicRecognitionTimer.start()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#EEEEEE"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    text: faceRecognitionPopup.titleText || "人脸识别"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 24
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    id: statusText
                    text: "正在准备摄像头..."
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // 摄像头预览区域
                Rectangle {
                    width: 640
                    height: 360
                    color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // 使用常规Item包装摄像头模块
                    Item {
                        id: cameraItem
                        anchors.fill: parent
                        
                        // 摄像头捕获会话
                        CaptureSession {
                            id: captureSession
                            camera: camera
                            imageCapture: imageCapture
                            videoOutput: videoOutput
                        }
                                                        
                        // 摄像头组件
                    Camera {
                        id: camera
                            active: true
                        
                            // 组件加载后设置合适的分辨率
                        Component.onCompleted: {
                            // 获取摄像头设置
                            var savedCameraId = dbManager.getSetting("camera_device", "auto")
                            console.log("人脸识别弹窗 - 读取摄像头设置:", savedCameraId)
                            
                            if (savedCameraId === "auto") {
                                // 自动模式，使用默认摄像头
                                    var cameras = mediaDevices.videoInputs
                                    if (cameras.length > 0) {
                                        cameraDevice = cameras[0]
                                        console.log("人脸识别弹窗 - 使用默认摄像头:", cameraDevice.id)
                                }
                            } else if (savedCameraId !== "") {
                                // 使用指定的摄像头ID
                                var foundDevice = false
                                    var cameras = mediaDevices.videoInputs
                                // 先检查指定的ID是否在可用列表中
                                    for (var i = 0; i < cameras.length; i++) {
                                        if (cameras[i].id === savedCameraId) {
                                            cameraDevice = cameras[i]
                                        foundDevice = true
                                        break
                                    }
                                }
                                
                                if (foundDevice) {
                                        console.log("人脸识别弹窗 - 使用指定摄像头:", cameraDevice.id)
                                    } else if (cameras.length > 0) {
                                        cameraDevice = cameras[0]
                                        console.log("人脸识别弹窗 - 指定摄像头不可用，使用默认摄像头:", cameraDevice.id)
                                    }
                                }
                                
                                // 设置合适的分辨率
                                var closestFormat = null
                                var targetRes = Qt.size(640, 360)
                                var minDiff = Number.MAX_VALUE
                                
                                if (cameraDevice) {
                                    for (var i = 0; i < cameraDevice.videoFormats.length; i++) {
                                        var format = cameraDevice.videoFormats[i]
                                        var res = format.resolution
                                        var diff = Math.abs(res.width - targetRes.width) + Math.abs(res.height - targetRes.height)
                                        
                                        if (diff < minDiff) {
                                            minDiff = diff
                                            closestFormat = format
                                        }
                                    }
                                    
                                    if (closestFormat) {
                                        cameraFormat = closestFormat
                                        console.log("设置摄像头分辨率:", cameraFormat.resolution.width, "x", cameraFormat.resolution.height)
                                    }
                                }
                            }
                        }
                        
                        // 图像捕获组件
                        ImageCapture {
                            id: imageCapture
                            
                            onImageSaved: function(id, path) {
                                console.log("Image saved to: " + path)
                                
                                // 只有识别用的图片才触发人脸识别
                                if (path === faceRecognitionPopup.capturedImagePath && faceRecognitionPopup.isRecognizing) {
                                    faceRecognitionPopup.recognizeFaceInAllUsers(path)
                            }
                        }
                    }
                    
                        // 视频输出
                    VideoOutput {
                        id: videoOutput
                        anchors.fill: parent
                            //fillMode: VideoOutput.PreserveAspectFit
                        visible: true
                        
                        // 添加水平镜像变换
                        transform: [
                            Scale {
                                id: videoPopupTransform
                                xScale: -1
                                yScale: 1  // 明确设置yScale为1确保不会垂直翻转
                                    origin.x: videoOutput.width / 2
                                }
                            ]
                            
                            property rect contentRect: Qt.rect(0, 0, width, height)
                    }
                    
                    Image {
                        id: capturedImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        visible: false
                        rotation: 0 // 显式设置为0度，防止旋转
                        
                        // 添加水平镜像变换，与视频输出保持一致
                        transform: [
                            Scale {
                                xScale: -1
                                yScale: 1  // 明确设置yScale为1确保不会垂直翻转
                                origin.x: capturedImage.width / 2
                            }
                        ]
                    }
                    
                    // 人脸框辅助线 - 根据检测到的位置动态调整
                    Image {
                        id: faceFrame
                        source: "qrc:/images/FaceTracking.png"
                        visible: faceRecognitionPopup.isFaceDetected
                            opacity: 0.5 // 默认半透明
                        
                        // 如果检测到人脸，使用检测到的位置和大小
                        // 调整为正方形，保持中心点不变
                        property real frameSize: Math.max(faceRecognitionPopup.detectedFaceRect.width, faceRecognitionPopup.detectedFaceRect.height)
                        x: faceRecognitionPopup.detectedFaceRect.x + (faceRecognitionPopup.detectedFaceRect.width - frameSize) / 2
                        y: faceRecognitionPopup.detectedFaceRect.y + (faceRecognitionPopup.detectedFaceRect.height - frameSize) / 2
                        width: frameSize
                        height: frameSize
                        
                        // 平滑过渡效果
                        Behavior on x { NumberAnimation { duration: 200 } }
                        Behavior on y { NumberAnimation { duration: 200 } }
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on height { NumberAnimation { duration: 200 } }
                        
                        // 设置旋转属性和变换原点
                        transformOrigin: Item.Center
                        rotation: faceRecognitionPopup.isFaceDetected ? faceRecognizer.rotationAngle : 0
                        
                        // 平滑旋转动画
                        Behavior on rotation { NumberAnimation { duration: 50 } }
                        
                        // 监听旋转角度变化
                        Connections {
                            target: faceRecognizer
                            function onRotationAngleChanged() {
                                // 角度已通过rotation属性自动绑定，不需要额外处理
                            }
                        }
                    }
                }
                }
                
                // 取消按钮 - 移到摄像头预览区域下方
                Button {
                    id: cancelButton
                    width: 120
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // 使用Qt 6兼容的样式定制方式
                    Rectangle {
                        anchors.fill: parent
                        color: "#446688cc"
                    radius: 5
                    
                    Text {
                        anchors.centerIn: parent
                            text: "取消"
                        font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                            color: "white"
                        }
                    }
                    
                        onClicked: {
                        faceRecognitionPopup.close()
                    }
                }
            }
        }
    }

    // 错误提示对话框
    Dialog {
        id: errorDialog
        title: "错误"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 200
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#44ffffff"
            border.color: "#66ffffff"
            border.width: 1
            radius: 10
        }
        
        header: Rectangle {
            color: "#55000000"
            height: 40
            radius: 10
            
            Text {
                text: errorDialog.title
                color: "white"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                font.bold: true
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                id: errorMessageText
                text: errorDialog.text
                color: "white"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                wrapMode: Text.Wrap
                anchors.fill: parent
                anchors.margins: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 50
            
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: 120
                height: 40
                
                background: Rectangle {
                    color: "#446688cc"
                    radius: 5
                }
                
                contentItem: Text {
                    text: "确定"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    errorDialog.close()
                }
            }
        }
    }

    // 使用这个函数停止摄像头
    function stopCamera() {
        camera.active = false
    }

    // 开始人脸跟踪
    function startFaceTracking() {
        console.log("开始人脸跟踪...")
        faceTrackingTimer.start()
        statusText.text = "请将面部对准摄像头..."
        
        // 启动人脸追踪框逆时针旋转
        console.log("启动人脸追踪框逆时针旋转")
        faceRecognizer.startRotation(50, 1.5) // 50毫秒更新一次，每次旋转1.5度
    }

    // 退出确认对话框
    Dialog {
        id: exitDialog
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true
        title: "退出确认"
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        // 设置对话框标题区域
        header: Rectangle {
            color: "#404040"
            height: 40
            radius: 5
            
            Text {
                text: exitDialog.title
                color: "white"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                font.bold: true
                anchors.centerIn: parent
            }
        }
        
        // 设置对话框背景
        background: Rectangle {
            color: "#303030"
            border.color: "#505050"
            border.width: 1
            radius: 5
        }
        
        // 对话框内容
        Column {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20
            
            // 消息文本
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "确定要退出星火智能评测系统吗？"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                color: "white"
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // 按钮行
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30
                
                // 确认按钮
                Button {
                    width: 120
                    height: 50
                    background: Rectangle {
                        color: "#0078d7"
                        radius: 4
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
                        console.log("用户确认退出系统")
                        Qt.quit()
                    }
                }
                
                // 取消按钮
                Button {
                    width: 120
                    height: 50
                    background: Rectangle {
                        color: "#505050"
                        radius: 4
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
                        console.log("用户取消退出系统")
                        exitDialog.close()
                    }
                }
            }
        }
    }
    
    // 初始化组件时读取虚拟键盘设置
    Component.onCompleted: {
        // 从数据库读取虚拟键盘设置
        var savedVirtualKeyboard = dbManager.getSetting("enable_virtual_keyboard", "true")
        enableVirtualKeyboard = savedVirtualKeyboard.toLowerCase() === "true"
        console.log("从数据库读取虚拟键盘设置: " + savedVirtualKeyboard + " -> " + enableVirtualKeyboard)
    }
}
