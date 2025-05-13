import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebView
import QtQuick.Layouts 1.15

Rectangle {
    id: sparkAIAgentPage
    color: "transparent"
    
    // 智能体地址属性
    property string aiAgentUrl: "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true" // 默认值
    
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
            // 获取主页引用
            var mainPage = stackView.get(0)
            
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
        
        WebView {
    id: webView
    anchors.fill: parent
    anchors.topMargin: 30
    url: aiAgentUrl

    // 显式声明参数并判断加载状态
    onLoadingChanged: function(loadRequest) {
        switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                console.log("网页开始加载...");
                break;
            case WebView.LoadSucceededStatus:
                console.log("网页加载成功!");
                webView.runJavaScript("document.documentElement.outerHTML", function(result) {
                sourceCode = result; // 将源码显示到右侧
                var regex = /<title>(.*?)<\/title>/;
                var match = sourceCode.match(regex);
                console.log("当前页面--》"+match[1])
                });
                break;
            case WebView.LoadFailedStatus:
                console.error("网页加载失败: " + loadRequest.errorString);
                break;
            }
        }
    }
    }
} 