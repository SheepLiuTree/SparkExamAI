import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.8

Rectangle {
    id: sparkAIAgentPage
    color: "transparent"
    
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
            stackView.pop()
        }
    }
    
    // 页面标题
    Text {
        id: pageTitle
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: "星火智能体"
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
        text: "欢迎使用星火智能体!"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 20
        color: "white"
    }
    
    // 内容区域
    Rectangle {
        anchors.top: welcomeText.bottom
        anchors.topMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.1
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.1
        color: "#44ffffff"
        radius: 10
        
        // 内容组件加载器
        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.margins: 10
            
            Component.onCompleted: {
                // 尝试加载WebEngine组件
                try {
                    contentLoader.sourceComponent = webViewComponent
                    console.log("WebEngine组件加载成功")
                } catch (e) {
                    console.error("WebEngine加载失败: " + e)
                    contentLoader.sourceComponent = fallbackComponent
                }
            }
        }
        
        // WebEngine组件
        Component {
            id: webViewComponent
            
            Item {
                anchors.fill: parent
                
                // 加载进度条
                Rectangle {
                    id: progressBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    color: "#4285f4"
                    width: webView.loadProgress / 100 * parent.width
                    visible: webView.loading
                }
                
                // Web视图
                WebEngineView {
                    id: webView
                    anchors.fill: parent
                    url: "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true"
                    
                    onLoadingChanged: function(loadRequest) {
                        if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                            console.log("百度网页加载成功")
                        } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                            console.error("百度网页加载失败: " + loadRequest.errorString)
                            contentLoader.sourceComponent = fallbackComponent
                        }
                    }
                }
            }
        }
        
        // 后备组件（在WebEngine不可用时显示）
        Component {
            id: fallbackComponent
            
            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 8
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Image {
                        source: "qrc:/images/SparkExamAI.png"
                        width: 120
                        height: 120
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "无法加载网页内容"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "#333333"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "您的系统可能不支持QtWebEngine组件"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    // 搜索框
                    Rectangle {
                        width: 400
                        height: 50
                        border.color: "#3388ff"
                        border.width: 2
                        radius: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 100
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "搜索关键词..."
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "#999999"
                                visible: !searchInput.text && !searchInput.activeFocus
                            }
                        }
                        
                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 100
                            color: "#3388ff"
                            radius: 8
                            
                            Text {
                                anchors.centerIn: parent
                                text: "百度一下"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("搜索: " + searchInput.text)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 组件初始化时，确保WebEngine模块可用
    Component.onCompleted: {
        console.log("星火智能体页面加载")
    }
} 