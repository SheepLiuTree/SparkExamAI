import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.8
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
        
        // 刷新定时器
        Timer {
            id: refreshTimer
            interval: 3000 // 3秒后刷新
            repeat: false
            onTriggered: {
                console.log("刷新页面");
                webView.reload();
            }
        }
        
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
                    url: sparkAIAgentPage.aiAgentUrl
                    
                    // 设置自定义用户代理
                    profile: WebEngineProfile {
                        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
                        httpCacheType: WebEngineProfile.DiskHttpCache
                        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
                    }
                    
                    // 设置WebEngineView属性
                    settings {
                        // 启用必要的设置
                        javascriptEnabled: true
                        javascriptCanOpenWindows: true
                        autoLoadImages: true
                        errorPageEnabled: false // 不显示错误页面
                        pluginsEnabled: true // 启用插件支持
                        fullScreenSupportEnabled: true
                    }
                    
                    // 页面加载完成后执行
                    onLoadingChanged: function(loadRequest) {
                        if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                            console.log("网页加载成功")
                            // 在页面加载成功后注入JavaScript来处理浏览器兼容性问题
                            webView.runJavaScript(`
                                // 设置用户代理为最新版Chrome
                                Object.defineProperty(navigator, 'userAgent', {
                                    get: function () { 
                                        return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'; 
                                    }
                                });
                                
                                // 通用函数：处理兼容性警告
                                function handleCompatibilityWarnings() {
                                    // 检查是否存在兼容性警告
                                    const warningTexts = ['兼容性问题', '请切换', 'Chrome', 'Safari', 'Edge', 'Firefox', '浏览器', '升级'];
                                    const allElements = document.querySelectorAll('*');
                                    
                                    // 查找和处理警告元素
                                    allElements.forEach(el => {
                                        if (el.innerText) {
                                            for (const warningText of warningTexts) {
                                                if (el.innerText.includes(warningText)) {
                                                    // 找到包含警告的父容器并隐藏
                                                    let parent = el;
                                                    for (let i = 0; i < 5; i++) {
                                                        parent = parent.parentElement;
                                                        if (!parent) break;
                                                        if (parent.tagName === 'DIV' || parent.tagName === 'SECTION') {
                                                            parent.style.display = 'none';
                                                            console.log('已隐藏兼容性警告');
                                                            break;
                                                        }
                                                    }
                                                    break;
                                                }
                                            }
                                        }
                                    });
                                    
                                    // 查找并点击所有可能的升级/确认按钮
                                    const buttons = document.querySelectorAll('button, a');
                                    buttons.forEach(btn => {
                                        if (btn.innerText && (
                                            btn.innerText.includes('升级') || 
                                            btn.innerText.includes('继续') ||
                                            btn.innerText.includes('确定') ||
                                            btn.innerText.includes('我知道了')
                                        )) {
                                            try {
                                                btn.click();
                                                console.log('点击了按钮：' + btn.innerText);
                                            } catch (e) {}
                                        }
                                    });
                                    
                                    // 移除遮罩层
                                    const overlays = document.querySelectorAll('.overlay, [class*="modal"], [class*="mask"], [class*="popup"]');
                                    overlays.forEach(overlay => {
                                        overlay.style.display = 'none';
                                    });
                                    
                                    // 确保主要内容可见
                                    document.body.style.overflow = 'auto';
                                    document.body.style.pointerEvents = 'auto';
                                }
                                
                                // 立即执行一次
                                handleCompatibilityWarnings();
                                
                                // 设置定时检查，确保动态加载的内容也能被处理
                                setInterval(handleCompatibilityWarnings, 2000);
                            `);
                            
                            // 启动检查定时器
                            compatibilityCheckTimer.start();
                        } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                            console.error("网页加载失败: " + loadRequest.errorString)
                            contentLoader.sourceComponent = fallbackComponent
                        }
                    }
                    
                    // 添加检测并处理兼容性问题的JavaScript
                    onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
                        // 检测与兼容性相关的错误消息
                        if (message.indexOf("兼容性") >= 0 || message.indexOf("compatibility") >= 0) {
                            console.log("检测到兼容性问题，尝试解决...");
                            refreshTimer.start(); // 设置延迟刷新页面
                        }
                    }
                }
                
                // 添加定时器组件用于定期检查兼容性问题
                Timer {
                    id: compatibilityCheckTimer
                    interval: 5000 // 5秒检查一次
                    repeat: true
                    onTriggered: {
                        webView.runJavaScript(`
                            // 检查页面中是否存在兼容性问题提示
                            const pageText = document.body.innerText;
                            if (pageText.includes('兼容性问题') || 
                                pageText.includes('请切换') || 
                                pageText.includes('Chrome') ||
                                pageText.includes('Safari') ||
                                pageText.includes('Edge') ||
                                pageText.includes('Firefox')) {
                                
                                // 执行移除兼容性警告的函数
                                if (typeof handleCompatibilityWarnings === 'function') {
                                    handleCompatibilityWarnings();
                                }
                            }
                        `);
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
        
        // 从数据库加载智能体地址设置
        var savedAgentAddress = dbManager.getSetting("ai_agent_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        if (savedAgentAddress && savedAgentAddress.trim() !== "") {
            aiAgentUrl = savedAgentAddress
            console.log("从数据库加载智能体地址: " + aiAgentUrl)
        } else {
            console.log("使用默认智能体地址: " + aiAgentUrl)
        }
    }
} 