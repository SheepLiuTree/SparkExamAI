import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.8
import QtQuick.Layouts 1.15

Rectangle {
    id: sparkAIAgentPage
    color: "transparent"
    
    // 智能体地址属性
    property string aiAgentUrl: "https://www.coze.cn/s/hn97Tsa7-fw/" // 默认值
    
    // 下载目录属性
    property string downloadPath: "C:/Users/15504/Desktop/" // 默认下载目录为桌面，可根据需要修改
    
    // 生成带时间戳的文件名
    function getTimestampedFileName(originalFileName) {
        // 获取当前时间
        var now = new Date();
        var timestamp = now.getFullYear() +
                      ("0" + (now.getMonth() + 1)).slice(-2) +
                      ("0" + now.getDate()).slice(-2) +
                      ("0" + now.getHours()).slice(-2) +
                      ("0" + now.getMinutes()).slice(-2) +
                      ("0" + now.getSeconds()).slice(-2);
        
        // 分离文件名和扩展名
        var dotIndex = originalFileName.lastIndexOf(".");
        var nameWithoutExt = originalFileName;
        var extension = "";
        
        if (dotIndex !== -1) {
            nameWithoutExt = originalFileName.substring(0, dotIndex);
            extension = originalFileName.substring(dotIndex);
        }
        
        // 返回带时间戳的文件名
        return nameWithoutExt + "_" + timestamp + extension;
    }
    
    // 返回按钮
    Button {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: 120
        height: 45
        background: Image {
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }
        contentItem: Text {
            text: "返回"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 16
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
    
    // 浏览器打开按钮
    Button {
        id: browserButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: backButton.right
        anchors.leftMargin: 10
        width: 150
        height: 45
        background: Image {
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }
        contentItem: Text {
            text: "浏览器打开"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 16
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: {
            console.log("在浏览器中打开网址: " + aiAgentUrl)
            Qt.openUrlExternally(aiAgentUrl)
        }
    }
    
    // 下载进度显示
    Rectangle {
        id: downloadProgressContainer
        anchors.left: contentContainer.left
        anchors.right: welcomeText.left
        anchors.rightMargin: 20
        anchors.bottom: contentContainer.top
        anchors.bottomMargin: 10
        height: 40
        color: "#33000000"
        radius: 5
        visible: false
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 20
            
            Text {
                id: downloadStatusText
                text: "下载中..."
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 14
                color: "white"
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }
            
            Rectangle {
                id: downloadProgressBar
                Layout.fillWidth: true
                Layout.fillHeight: true
                height: 20
                color: "#44000000"
                radius: 10
                
                Rectangle {
                    id: downloadProgressFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 0
                    color: "#4285f4"
                    radius: 10
                }
            }
            
            Text {
                id: downloadPercentText
                text: "0%"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 14
                color: "white"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }
    }
    
    // 下载完成隐藏定时器
    Timer {
        id: downloadHideTimer
        interval: 3000
        repeat: false
        onTriggered: {
            downloadProgressContainer.visible = false
        }
    }
    
    // 页面标题
    Text {
        id: pageTitle
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter
        text: dbManager.getSetting("tuanwei_button2_text", "智能体")
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 36
        color: "white"
        font.bold: true
    }
    
    // 欢迎信息
    Text {
        id: welcomeText
        anchors.top: pageTitle.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        text: "欢迎使用" + dbManager.getSetting("tuanwei_button2_text", "智能体") + "!"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 20
        color: "white"
    }
    
    // 内容区域
    Rectangle {
        id: contentContainer
        anchors.top: welcomeText.bottom
        anchors.topMargin: 25
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.left: parent.left
        anchors.leftMargin: Math.max(20, parent.width * 0.08)
        anchors.right: parent.right
        anchors.rightMargin: Math.max(20, parent.width * 0.08)
        color: "#44ffffff"
        radius: 10
        
        // 内容组件加载器
        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.margins: 15
            
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
                
                // 页面加载超时定时器
                Timer {
                    id: loadingTimeoutTimer
                    interval: 45000 // 增加到45秒超时，给Coze页面更多加载时间
                    repeat: false
                    onTriggered: {
                        console.log("页面加载超时，尝试重新加载页面");
                        if (webView.loading) {
                            webView.reload();
                            loadingTimeoutTimer.start(); // 重新启动定时器
                        }
                    }
                }
                
                // 页面重试计数器
                property int retryCount: 0
                property int maxRetries: 3
                
                // 延迟重试定时器
                Timer {
                    id: retryTimer
                    interval: 2000 // 2秒后重试
                    repeat: false
                    onTriggered: {
                        if (webView.retryCount < webView.maxRetries) {
                            console.log("尝试重新加载页面，重试次数: " + (webView.retryCount + 1));
                            webView.retryCount++;
                            webView.reload();
                            loadingTimeoutTimer.start();
                        } else {
                            console.log("达到最大重试次数，停止重试");
                            webView.retryCount = 0;
                        }
                    }
                }
                
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
                    
                    // 添加加载完成后的额外处理
                    Component.onCompleted: {
                        // 设置视口元数据
                        settings.localStorageEnabled = true
                        settings.webGLEnabled = true
                        settings.accelerated2dCanvasEnabled = true
                        settings.hyperlinkAuditingEnabled = false
                        settings.localStorageEnabled = true
                        settings.dnsPrefetchEnabled = true
                    }
                    
                    // 设置自定义用户代理
                    profile: WebEngineProfile {
                        httpUserAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
                        httpCacheType: WebEngineProfile.DiskHttpCache
                        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
                        httpAcceptLanguage: "zh-CN,zh;q=0.9,en;q=0.8,en-US;q=0.7"
                        httpCacheMaximumSize: 104857600 // 100MB 缓存
                        offTheRecord: false
                        storageName: "CozeProfile"
                        persistentStoragePath: ""
                        
                        // 下载请求处理
                        onDownloadRequested: function(download) {
                            console.log("下载请求: " + download.url)
                            console.log("下载到: " + sparkAIAgentPage.downloadPath)
                            
                            // 生成带时间戳的文件名
                            var timestampedFileName = sparkAIAgentPage.getTimestampedFileName(download.suggestedFileName)
                            
                            // 设置下载路径
                            download.path = sparkAIAgentPage.downloadPath + timestampedFileName
                            
                            // 显示下载进度条
                            downloadProgressContainer.visible = true
                            downloadStatusText.text = "下载中: " + download.suggestedFileName
                            downloadPercentText.text = "0%"
                            downloadProgressFill.width = 0
                            
                            // 接受下载
                            download.accept()
                            
                            // 使用定时器来更新下载进度
                            var progressTimer = Qt.createQmlObject('import QtQuick 2.15; Timer { interval: 100; repeat: true }', sparkAIAgentPage);
                            
                            // 更新下载进度
                            progressTimer.triggered.connect(function() {
                                if (download.totalBytes > 0) {
                                    var percent = (download.receivedBytes / download.totalBytes) * 100;
                                    console.log("下载进度: " + percent + "%")
                                    downloadPercentText.text = Math.round(percent) + "%"
                                    downloadProgressFill.width = (percent / 100) * downloadProgressBar.width
                                }
                                
                                // 检查下载状态
                                if (download.state === WebEngineDownloadItem.DownloadCompleted) {
                                    console.log("下载完成: " + download.path)
                                    downloadStatusText.text = "下载完成: " + download.suggestedFileName
                                    downloadPercentText.text = "100%"
                                    downloadProgressFill.width = downloadProgressBar.width
                                    
                                    // 停止定时器
                                    progressTimer.stop()
                                    
                                    // 3秒后隐藏下载进度条
                                    downloadHideTimer.start()
                                    
                                    // 清理定时器
                                    progressTimer.destroy()
                                } else if (download.state === WebEngineDownloadItem.DownloadInterrupted) {
                                    console.log("下载中断: " + download.interruptReasonString)
                                    downloadStatusText.text = "下载中断: " + download.interruptReasonString
                                    
                                    // 停止定时器
                                    progressTimer.stop()
                                    
                                    // 清理定时器
                                    progressTimer.destroy()
                                }
                            })
                            
                            // 启动定时器
                            progressTimer.start()
                        }
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
                        localContentCanAccessRemoteUrls: true
                        allowRunningInsecureContent: true
                        spatialNavigationEnabled: true
                        touchIconsEnabled: true
                        webGLEnabled: true
                        accelerated2dCanvasEnabled: true
                        hyperlinkAuditingEnabled: false
                        focusOnNavigationEnabled: true
                        printElementBackgrounds: true
                        
                        // 添加对现代Web应用的支持
                        localStorageEnabled: true
                        dnsPrefetchEnabled: true
                        screenCaptureEnabled: true
                        localContentCanAccessFileUrls: true
                        allowGeolocationOnInsecureOrigins: true
                        
                        // 性能优化
                        autoLoadIconsForPage: true
                        
                        // 安全设置
                        allowWindowActivationFromJavaScript: true
                    }
                    
                    // 设置缩放因子
                    zoomFactor: 1.0
                    
                    // 添加视口大小调整处理
                    onWidthChanged: {
                        console.log("WebView宽度变化: " + width);
                        // 当宽度变化时，重新运行JavaScript以确保页面适应新尺寸
                        if (url.toString() !== "about:blank") {
                            runJavaScript(`
                                // 调整视口大小
                                if (window.innerWidth !== ${width}) {
                                    window.innerWidth = ${width};
                                }
                                
                                // 触发resize事件
                                window.dispatchEvent(new Event('resize'));
                                
                                // 重新应用布局修复
                                document.body.style.width = '100%';
                                document.body.style.maxWidth = '100%';
                                document.body.style.overflowX = 'hidden';
                                
                                // 确保所有容器都适应新宽度
                                var containers = document.querySelectorAll('.container, .main, .content, .wrapper, .app-container, .app-main, .app-content');
                                containers.forEach(function(el) {
                                    el.style.width = '100%';
                                    el.style.maxWidth = '100%';
                                });
                            `);
                        }
                    }
                    
                    onHeightChanged: {
                        console.log("WebView高度变化: " + height);
                        // 当高度变化时，重新运行JavaScript以确保页面适应新尺寸
                        if (url.toString() !== "about:blank") {
                            runJavaScript(`
                                // 调整视口大小
                                if (window.innerHeight !== ${height}) {
                                    window.innerHeight = ${height};
                                }
                                
                                // 触发resize事件
                                window.dispatchEvent(new Event('resize'));
                                
                                // 重新应用布局修复
                                document.body.style.height = 'auto';
                                document.body.style.minHeight = '100%';
                                
                                // 确保所有容器都适应新高度
                                var containers = document.querySelectorAll('.container, .main, .content, .wrapper, .app-container, .app-main, .app-content');
                                containers.forEach(function(el) {
                                    el.style.height = 'auto';
                                    el.style.minHeight = '100%';
                                });
                            `);
                        }
                    }
                    
                    // 页面加载完成后执行
                    onLoadingChanged: function(loadRequest) {
                        console.log("页面加载状态变化: " + loadRequest.status)
                        if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                            console.log("网页加载成功")
                            console.log("当前URL: " + webView.url)
                            // 停止超时定时器
                            loadingTimeoutTimer.stop()
                            
                            // 增强的JavaScript注入，修复显示问题
                            webView.runJavaScript(`
                                console.log('页面已加载，当前URL: ' + window.location.href);
                                console.log('页面标题: ' + document.title);
                                
                                // 设置用户代理为最新版Chrome
                                Object.defineProperty(navigator, 'userAgent', {
                                    get: function () {
                                        return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36';
                                    }
                                });
                                
                                // 模拟更多浏览器特性
                                Object.defineProperty(navigator, 'platform', {
                                    get: function () {
                                        return 'Win32';
                                    }
                                });
                                
                                Object.defineProperty(navigator, 'vendor', {
                                    get: function () {
                                        return 'Google Inc.';
                                    }
                                });
                                
                                Object.defineProperty(window, 'chrome', {
                                    get: function () {
                                        return {
                                            runtime: {},
                                            app: {},
                                            webstore: {}
                                        };
                                    }
                                });
                                
                                // 添加常用Web API
                                if (typeof Notification === 'undefined') {
                                    window.Notification = {
                                        permission: 'granted',
                                        requestPermission: function(callback) {
                                            callback('granted');
                                        }
                                    };
                                }
                                
                                // 模拟触摸设备支持
                                if (!('ontouchstart' in window)) {
                                    window.ontouchstart = null;
                                    window.ontouchend = null;
                                    window.ontouchmove = null;
                                }
                                
                                // 添加设备内存信息
                                if (typeof navigator.deviceMemory === 'undefined') {
                                    Object.defineProperty(navigator, 'deviceMemory', {
                                        get: function () {
                                            return 8;
                                        }
                                    });
                                }
                                
                                // 添加硬件并发信息
                                if (typeof navigator.hardwareConcurrency === 'undefined') {
                                    Object.defineProperty(navigator, 'hardwareConcurrency', {
                                        get: function () {
                                            return 8;
                                        }
                                    });
                                }
                                
                                // 添加连接信息
                                if (typeof navigator.connection === 'undefined') {
                                    Object.defineProperty(navigator, 'connection', {
                                        get: function () {
                                            return {
                                                effectiveType: '4g',
                                                downlink: 10,
                                                rtt: 100
                                            };
                                        }
                                    });
                                }
                                
                                // 添加修复显示问题的CSS - 更加温和的修复策略
                                var fixStyle = document.createElement('style');
                                fixStyle.innerHTML = \`
                                    /* 基础布局修复 */
                                    * {
                                        box-sizing: border-box;
                                    }
                                    
                                    /* 确保页面基础容器正常显示 */
                                    body, html {
                                        overflow-x: auto;
                                        overflow-y: auto;
                                        width: 100%;
                                        height: 100%;
                                        min-height: 100vh;
                                        position: relative;
                                    }
                                    
                                    /* 设置视口元数据 */
                                    @viewport {
                                        width: device-width;
                                        initial-scale: 1.0;
                                        maximum-scale: 1.0;
                                        user-scalable: no;
                                    }
                                    
                                    /* 确保网页内容适应控件大小 */
                                    html {
                                        transform-origin: top left;
                                        transform: scale(1.0);
                                        width: 100%;
                                        height: 100%;
                                    }
                                    
                                    body {
                                        width: 100%;
                                        max-width: 100%;
                                        overflow-x: hidden;
                                        margin: 0;
                                        padding: 0;
                                    }
                                    
                                    /* 修复主要容器布局 - 只针对可能的问题容器 */
                                    .container, .main, .content, .wrapper {
                                        width: 100%;
                                        max-width: 100%;
                                        margin: 0 auto;
                                        box-sizing: border-box;
                                    }
                                    
                                    /* 确保交互元素可见 - 只修复真正需要修复的元素 */
                                    button, input, select, textarea, .btn, .button, .submit, .action {
                                        display: inline-block;
                                        visibility: visible;
                                        opacity: 1;
                                        position: relative;
                                        z-index: 1;
                                    }
                                    
                                    /* 修复文本显示问题 */
                                    body, p, span, div, h1, h2, h3, h4, h5, h6 {
                                        text-overflow: ellipsis;
                                        white-space: normal;
                                        word-wrap: break-word;
                                        overflow: visible;
                                    }
                                    
                                    /* 修复可能的z-index问题 - 只针对负值 */
                                    [style*="z-index: -"] {
                                        z-index: 1;
                                    }
                                    
                                    /* 修复可能的transform问题 - 只针对导致不可见的transform */
                                    [style*="transform: translate"] {
                                        transform: none;
                                    }
                                    
                                    /* 针对Coze网站的特定修复 */
                                    .coze-chat-container, .coze-chat-input, .coze-chat-messages {
                                        width: 100% !important;
                                        max-width: 100% !important;
                                        overflow: visible !important;
                                        box-sizing: border-box !important;
                                        display: flex !important;
                                        flex-direction: column !important;
                                    }
                                    
                                    .coze-message {
                                        width: auto !important;
                                        max-width: 80% !important;
                                        margin: 5px 0 !important;
                                        box-sizing: border-box !important;
                                        word-wrap: break-word !important;
                                        overflow: visible !important;
                                    }
                                    
                                    .coze-input-area {
                                        width: 100% !important;
                                        min-height: 50px !important;
                                        padding: 10px !important;
                                        box-sizing: border-box !important;
                                        display: flex !important;
                                        flex-direction: row !important;
                                        align-items: center !important;
                                    }
                                    
                                    /* 隐藏触发器元素 */
                                    [data-testid="coze.assistant.pop.ui.trigger"] {
                                        display: none !important;
                                        visibility: hidden !important;
                                        opacity: 0 !important;
                                        width: 0 !important;
                                        height: 0 !important;
                                        overflow: hidden !important;
                                    }
                                    
                                    [data-testid="coze.assistant.pop.ui.trigger"] > div {
                                        display: none !important;
                                        visibility: hidden !important;
                                        opacity: 0 !important;
                                        width: 0 !important;
                                        height: 0 !important;
                                        overflow: hidden !important;
                                    }
                                    
                                    /* 修复textarea容器宽度问题 */
                                    .textarea-with-actions-container--vZmOWDDoAgGmFoiU {
                                        width: 100% !important;
                                        max-width: 100% !important;
                                        box-sizing: border-box !important;
                                        padding: 8px 8px 8px 20px !important;
                                        display: flex !important;
                                        flex-direction: row !important;
                                        align-items: center !important;
                                        overflow: visible !important;
                                    }
                                    
                                    .textarea-with-actions-container__row--LQiovzz36EjPClsO {
                                        width: 100% !important;
                                        max-width: 100% !important;
                                        box-sizing: border-box !important;
                                        display: flex !important;
                                        flex-direction: row !important;
                                        align-items: center !important;
                                        overflow: visible !important;
                                    }
                                    
                                    [data-testid="bot.ide.chat_area.chat_input.textarea"] {
                                        width: 100% !important;
                                        max-width: 100% !important;
                                        min-height: 24px !important;
                                        max-height: 104px !important;
                                        height: 24px !important;
                                        box-sizing: border-box !important;
                                        resize: none !important;
                                        overflow-y: hidden !important;
                                        font-size: 14px !important;
                                    }
                                    
                                    /* 确保所有容器都正确适应父容器 */
                                    .app-container, .app-main, .app-content {
                                        width: 100% !important;
                                        max-width: 100% !important;
                                        height: auto !important;
                                        min-height: 100% !important;
                                        overflow: visible !important;
                                        box-sizing: border-box !important;
                                    }
                                \`;
                                document.head.appendChild(fixStyle);
                                
                                // 添加修复显示问题的JavaScript - 更加精准的修复策略
                                setTimeout(function() {
                                    // 移除特定的Coze触发器元素
                                    var cozeTrigger = document.querySelector('[data-testid="coze.assistant.pop.ui.trigger"]');
                                    if (cozeTrigger) {
                                        cozeTrigger.style.display = 'none';
                                        cozeTrigger.style.visibility = 'hidden';
                                        cozeTrigger.style.opacity = '0';
                                        cozeTrigger.style.width = '0';
                                        cozeTrigger.style.height = '0';
                                        cozeTrigger.style.overflow = 'hidden';
                                        console.log('已隐藏Coze触发器元素');
                                    }
                                    
                                    var textareaContainer = document.querySelector('.textarea-with-actions-container--vZmOWDDoAgGmFoiU');
                                    if (textareaContainer) {
                                        textareaContainer.style.width = '100%';
                                        textareaContainer.style.maxWidth = '100%';
                                        textareaContainer.style.boxSizing = 'border-box';
                                        textareaContainer.style.padding = '8px 8px 8px 20px';
                                        textareaContainer.style.display = 'flex';
                                        textareaContainer.style.flexDirection = 'row';
                                        textareaContainer.style.alignItems = 'center';
                                        textareaContainer.style.overflow = 'visible';
                                        console.log('修复了textarea容器宽度');
                                    }
                                    
                                    var chatInputTextarea = document.querySelector('[data-testid="bot.ide.chat_area.chat_input.textarea"]');
                                    if (chatInputTextarea) {
                                        chatInputTextarea.style.width = '100%';
                                        chatInputTextarea.style.maxWidth = '100%';
                                        chatInputTextarea.style.minHeight = '24px';
                                        chatInputTextarea.style.maxHeight = '104px';
                                        chatInputTextarea.style.height = '24px';
                                        chatInputTextarea.style.boxSizing = 'border-box';
                                        chatInputTextarea.style.resize = 'none';
                                        chatInputTextarea.style.overflowY = 'hidden';
                                        chatInputTextarea.style.fontSize = '14px';
                                        console.log('修复了chat input textarea');
                                    }
                                    
                                    // 只修复重要的交互元素，而不是所有元素
                                    var importantSelectors = [
                                        'button', 'input', 'select', 'textarea', 'a',
                                        '.btn', '.button', '.submit', '.action',
                                        '.coze-chat-input', '.coze-send-button',
                                        '.message-input', '.send-button'
                                    ];
                                    
                                    importantSelectors.forEach(function(selector) {
                                        var elements = document.querySelectorAll(selector);
                                        elements.forEach(function(el) {
                                            var computedStyle = window.getComputedStyle(el);
                                            if (computedStyle.display === 'none' ||
                                                computedStyle.visibility === 'hidden' ||
                                                computedStyle.opacity === '0' ||
                                                el.offsetWidth === 0 ||
                                                el.offsetHeight === 0) {
                                                
                                                // 检查元素是否在可视区域内
                                                var rect = el.getBoundingClientRect();
                                                if (rect.width === 0 || rect.height === 0) {
                                                    el.style.display = 'inline-block';
                                                    el.style.visibility = 'visible';
                                                    el.style.opacity = '1';
                                                    el.style.width = 'auto';
                                                    el.style.height = 'auto';
                                                    console.log('修复了隐藏元素:', selector, el.className);
                                                }
                                            }
                                        });
                                    });
                                    
                                    // 只修复可能导致内容被截断的溢出问题
                                    var containerSelectors = [
                                        '.container', '.main', '.content', '.wrapper',
                                        '.coze-chat-container', '.coze-chat-messages',
                                        '.message-container', '.chat-container'
                                    ];
                                    
                                    containerSelectors.forEach(function(selector) {
                                        var elements = document.querySelectorAll(selector);
                                        elements.forEach(function(el) {
                                            var computedStyle = window.getComputedStyle(el);
                                            if (computedStyle.overflow === 'hidden' ||
                                                computedStyle.overflowX === 'hidden' ||
                                                computedStyle.overflowY === 'hidden') {
                                                
                                                // 检查是否有子元素被截断
                                                var children = el.children;
                                                var hasOverflow = false;
                                                for (var i = 0; i < children.length; i++) {
                                                    var childRect = children[i].getBoundingClientRect();
                                                    var parentRect = el.getBoundingClientRect();
                                                    if (childRect.right > parentRect.right ||
                                                        childRect.bottom > parentRect.bottom) {
                                                        hasOverflow = true;
                                                        break;
                                                    }
                                                }
                                                
                                                if (hasOverflow) {
                                                    el.style.overflow = 'auto';
                                                    el.style.overflowX = 'auto';
                                                    el.style.overflowY = 'auto';
                                                    console.log('修复了溢出容器:', selector);
                                                }
                                            }
                                        });
                                    });
                                    
                                    console.log('显示问题修复完成 - 使用精准修复策略');
                                }, 1500);
                                
                                console.log('用户代理已设置为Chrome，显示问题修复脚本已注入');
                            `);
                        } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                            console.error("网页加载失败: " + loadRequest.errorString)
                            // 停止超时定时器
                            loadingTimeoutTimer.stop()
                            
                            // 尝试重试加载
                            if (webView.retryCount < webView.maxRetries) {
                                console.log("页面加载失败，准备重试");
                                retryTimer.start();
                            } else {
                                console.log("页面加载失败且已达到最大重试次数，显示后备组件");
                                webView.retryCount = 0; // 重置重试计数器
                                contentLoader.sourceComponent = fallbackComponent
                            }
                        } else if (loadRequest.status === WebEngineLoadRequest.LoadStartedStatus) {
                            console.log("网页开始加载: " + webView.url)
                            // 启动超时定时器
                            loadingTimeoutTimer.start()
                        }
                    }
                    
                    // 添加检测并处理兼容性问题的JavaScript
                    onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
                        // 只记录兼容性错误，不再自动刷新页面
                        if ((message.indexOf("兼容性") >= 0 || message.indexOf("compatibility") >= 0) &&
                            (message.indexOf("错误") >= 0 || message.indexOf("error") >= 0 ||
                             message.indexOf("不支持") >= 0 || message.indexOf("not supported") >= 0)) {
                            console.log("检测到兼容性错误: " + message);
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
        console.log(dbManager.getSetting("tuanwei_button2_text", "智能体2") + "页面加载")
        
        // 从数据库加载智能体地址设置
        var savedAgentAddress = dbManager.getSetting("ai_agent2_address", "https://www.coze.cn/s/hn97Tsa7-fw/")
        if (savedAgentAddress && savedAgentAddress.trim() !== "") {
            aiAgentUrl = savedAgentAddress
            console.log("从数据库加载智能体地址: " + aiAgentUrl)
        } else {
            console.log("使用默认智能体地址: " + aiAgentUrl)
        }
        
        // 从数据库加载下载目录设置
        var savedDownloadPath = dbManager.getSetting("download_path", "C:/Users/15504/Desktop/")
        if (savedDownloadPath && savedDownloadPath.trim() !== "") {
            downloadPath = savedDownloadPath
            console.log("从数据库加载下载目录: " + downloadPath)
        } else {
            console.log("使用默认下载目录: " + downloadPath)
        }
    }
}
