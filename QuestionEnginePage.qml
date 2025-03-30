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
        { id: "strategies", name: "出题策略", icon: "qrc:/images/menu.png", component: "QuestionEngineSettings/StrategiesSettings.qml" },
        { id: "permissions", name: "用户权限", icon: "qrc:/images/064.png", component: "QuestionEngineSettings/UserPermissionsSettings.qml" }
    ]
    
    property int selectedCategoryIndex: 0
    property string userName: "管理员"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 顶部导航栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#f5f5f5"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10
                
                Button {
                    id: backButton
                    implicitWidth: 40
                    implicitHeight: 40
                    flat: true
                    
                    background: Item {}
                    
                    contentItem: Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 18
                        color: parent.hovered ? "#e0e0e0" : "transparent"
                        
                        Text {
                            text: "←"
                            font.pixelSize: 24
                            color: "#333333"
                            anchors.centerIn: parent
                        }
                    }
                    
                    onClicked: {
                        // 返回到主界面
                        stackView.pop(null)
                        // 返回上一页
                        console.log("返回上一页")
                    }
                }
                
                Text {
                    text: "题策引擎"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333333"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "欢迎，" + userName
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        // 主内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                // 左侧导航栏
                Rectangle {
                    Layout.preferredWidth: 220
                    Layout.fillHeight: true
                    color: "#f5f5f5"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 0
                        spacing: 0
                        
                        Text {
                            text: "题策引擎设置"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#333333"
                            padding: 20
                        }
                        
                        ListView {
                            id: categoryListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: settingCategories
                            currentIndex: selectedCategoryIndex
                            
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 60
                                color: index === ListView.view.currentIndex ? "#ffffff" : "#f5f5f5"
                                
                                Rectangle {
                                    width: 4
                                    height: parent.height
                                    color: index === ListView.view.currentIndex ? "#2c70b7" : "transparent"
                                    anchors.left: parent.left
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
                                            color: ListView.view ? (index === ListView.view.currentIndex ? "#2c70b7" : "#666666") : "#666666"
                                        }
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 16
                                        color: ListView.view ? (index === ListView.view.currentIndex ? "#2c70b7" : "#666666") : "#666666"
                                        font.bold: ListView.view ? (index === ListView.view.currentIndex) : false
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
                    color: "#ffffff"
                    
                    Loader {
                        id: settingsLoader
                        anchors.fill: parent
                        source: getSettingComponent(selectedCategoryIndex)
                    }
                }
            }
        }
    }
    
    function getSettingComponent(index) {
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
        case "permissions":
            return "👥"
        default:
            return "📄"
        }
    }
} 
