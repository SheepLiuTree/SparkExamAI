import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./QuestionEngineSettings"

Rectangle {
    id: questionEnginePage
    color: "transparent"
    
    property var settingCategories: [
        { id: "general", name: "通用设置", icon: "qrc:/images/button_bg.png", component: "QuestionEngineSettings/GeneralSettings.qml" },
        { id: "banks", name: "题库管理", icon: "qrc:/images/personal_button_bg.png", component: "QuestionEngineSettings/QuestionBankSettings.qml" },
        { id: "types", name: "题型设置", icon: "qrc:/images/face_icon.png", component: "QuestionEngineSettings/QuestionTypeSettings.qml" },
        { id: "strategies", name: "出题策略", icon: "qrc:/images/menu.png", component: "QuestionEngineSettings/StrategiesSettings.qml" }
    ]
    
    property int selectedCategoryIndex: 0
    property string userName: "管理员"
    
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
            // 返回到主界面
            stackView.pop(null)
            
            // 返回上一页
            console.log("返回上一页")
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
        case "banks":
            return "📚"
        case "types":
            return "📝"
        case "strategies":
            return "🎯"
        default:
            return ""
        }
    }
} 
