import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./QuestionEngineSettings"

Rectangle {
    id: questionEnginePage
    color: "transparent"
    
    property var settingCategories: [
        { id: "general", name: "通用设置", icon: "qrc:/images/setting.png", component: "QuestionEngineSettings/GeneralSettings.qml" },
        { id: "collection", name: "题集速录", icon: "qrc:/images/collection.png", component: "QuestionCollectionPage.qml" },
        { id: "pentagon", name: "五芒图设置", icon: "qrc:/images/chart.png", component: "QuestionEngineSettings/PentagonalChartSettings.qml" },
        { id: "strategies", name: "出题策略", icon: "qrc:/images/strategy.png", component: "QuestionEngineSettings/StrategiesSettings.qml" },
        { id: "knowledge", name: "智点速览", icon: "qrc:/images/list.png", component: "QuestionEngineSettings/KnowledgePointSettings.qml" }
    ]
    
    property int selectedCategoryIndex: 0
    property string userName: "管理员"
    property var userData: ({})
    property int initialTabIndex: -1
    
    // 处理initialTabIndex变化
    onInitialTabIndexChanged: {
        if (initialTabIndex >= 0 && initialTabIndex < settingCategories.length) {
            console.log("题策引擎页面：切换到指定的初始选项卡索引 " + initialTabIndex)
            selectedCategoryIndex = initialTabIndex
            
            // 确保列表视图也更新选中项
            if (categoryListView) {
                categoryListView.currentIndex = initialTabIndex
            }
            
            // 只处理一次初始选项卡请求，处理后重置
            initialTabIndex = -1
        }
    }
    
    // 检测userData变化
    onUserDataChanged: {
        if (userData && userData.name) {
            userName = userData.name
            console.log("题策引擎页面已接收用户数据: " + userName)
            
            // 如果当前显示的是题集速录页面，则立即传递数据
            if (selectedCategoryIndex === 1 && settingsLoader.item) {
                settingsLoader.item.userData = userData
                console.log("已将用户数据传递到题集速录页面")
            }
        }
    }
    
    // 当selectedCategoryIndex变化时，确保加载对应的组件
    onSelectedCategoryIndexChanged: {
        console.log("选择的类别索引变为: " + selectedCategoryIndex)
        if (settingsLoader) {
            settingsLoader.source = getSettingComponent(selectedCategoryIndex)
        }
    }
    
    // 确保默认加载通用设置
    Component.onCompleted: {
        selectedCategoryIndex = 0
        if (categoryListView) {
            categoryListView.currentIndex = 0
        }
    }
    
    // 返回按钮
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
        onClicked: {
            // 显示确认对话框
            confirmDialog.open()
        }
    }
    
    // 页面标题
    Text {
        id: pageTitle
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: "题策引擎"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 36
        color: "white"
        font.bold: true
    }
    
    // 欢迎信息
    Text {
        id: welcomeText
        anchors.top: pageTitle.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "欢迎, " + userName + "!"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 20
        color: "white"
    }
    
    // 主内容区域
    Rectangle {
        anchors.top: welcomeText.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: parent.width * 0.9
        color: "#44ffffff"
        radius: 10
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // 左侧导航栏
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: "#33ffffff"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0
                    
                    Text {
                        text: "题策引擎设置"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                        padding: 20
                    }
                    
                    ListView {
                        id: categoryListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: settingCategories
                        currentIndex: 0
                        
                        Component.onCompleted: {
                            console.log("ListView初始化，确保通用设置被选中")
                            // 确保模型数据已加载
                            if (model && model.count > 0) {
                                currentIndex = 0
                                selectedCategoryIndex = 0
                            }
                        }
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 60
                            color: index === categoryListView.currentIndex ? "#66ffffff" : "transparent"
                            radius: 5
                            
                            Rectangle {
                                width: 4
                                height: parent.height * 0.8
                                color: index === categoryListView.currentIndex ? "#ffffff" : "transparent"
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 2
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onClicked: {
                                    selectedCategoryIndex = index
                                    categoryListView.currentIndex = index
                                }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 15
                                
                                Image {
                                    source: modelData.icon
                                    sourceSize.width: 24
                                    sourceSize.height: 24
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    
                                    Text {
                                        visible: parent.status !== Image.Ready
                                        anchors.centerIn: parent
                                        text: getIconFallback(modelData.id)
                                        font.pixelSize: 16
                                        color: index === categoryListView.currentIndex ? "#ffffff" : "#cccccc"
                                    }
                                }
                                
                                Text {
                                    text: modelData.name
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: index === categoryListView.currentIndex ? "#ffffff" : "#cccccc"
                                    font.bold: index === categoryListView.currentIndex
                                }
                            }
                        }
                    }
                }
            }
            
            // 右侧内容区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#33ffffff"
                radius: 8
                
                Loader {
                    id: settingsLoader
                    anchors.fill: parent
                    anchors.margins: 10
                    source: getSettingComponent(selectedCategoryIndex)
                    
                    Component.onCompleted: {
                        console.log("正在加载设置组件: " + source)
                    }
                    
                    onStatusChanged: {
                        if (status == Loader.Ready) {
                            console.log("设置组件加载完成: " + source)
                            
                            // 判断是否是题集速录页面，如果是则设置嵌入模式
                            if (settingCategories[selectedCategoryIndex].id === "collection" && item) {
                                item.isEmbedded = true
                                console.log("已将题集速录页面设置为嵌入模式")
                                
                                // 将用户数据传递给题集速录页面
                                item.userData = userData
                            }
                        }
                    }
                }
            }
        }
    }
    
    function getSettingComponent(index) {
        console.log("获取设置组件，索引: " + index)
        // 防止索引越界
        if (index < 0 || index >= settingCategories.length) {
            index = 0
        }
        return settingCategories[index].component
    }
    
    function getIconFallback(id) {
        switch(id) {
        case "general":
            return "⚙️"
        case "strategies":
            return "🎯"
        case "pentagon":
            return "📊"
        case "knowledge":
            return "📚"
        case "collection":
            return "📋"
        default:
            return ""
        }
    }
    
    // 确认对话框
    Dialog {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#1e293b"
            radius: 10
            border.color: "#334155"
            border.width: 2
        }
        
        header: Rectangle {
            color: "#334155"
            height: 50
            radius: 8
            
            Text {
                text: "返回确认"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                width: parent.width - 40
                anchors.centerIn: parent
                text: "确定要退出题策引擎吗？"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "#f0f9ff"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 70
            
            Row {
                anchors.centerIn: parent
                spacing: 30
                
                // 取消按钮
                Button {
                    width: 120
                    height: 40
                    background: Rectangle {
                        radius: 6
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#64748b" }
                            GradientStop { position: 1.0; color: "#475569" }
                        }
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
                        confirmDialog.close()
                    }
                }
                
                // 确认按钮
                Button {
                    width: 120
                    height: 40
                    background: Rectangle {
                        radius: 6
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0891b2" }
                            GradientStop { position: 1.0; color: "#0e7490" }
                        }
                    }
                    contentItem: Text {
                        text: "确认"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // 返回前确保首页用户列表会重新加载以应用新的排序设置
                        var mainPage = stackView.get(0)
                        console.log("返回前尝试刷新首页用户列表");
                        if (mainPage && mainPage.personal_page_column) {
                            console.log("找到首页personal_page_column，调用loadUserListFromDatabase");
                            mainPage.personal_page_column.loadUserListFromDatabase();
                        }
                        
                        // 确保返回时显示中间列，隐藏个人数据页面
                        if (mainPage) {
                            console.log("确保返回时显示中间列，隐藏个人数据页面");
                            if (mainPage.middle_column) {
                                mainPage.middle_column.visible = true;
                            }
                            if (mainPage.user_practice_data) {
                                mainPage.user_practice_data.visible = false;
                            }
                        }
                        
                        // 返回到主界面
                        stackView.pop(null)
                        
                        // 返回上一页
                        console.log("返回上一页")
                        confirmDialog.close()
                    }
                }
            }
        }
    }
} 
