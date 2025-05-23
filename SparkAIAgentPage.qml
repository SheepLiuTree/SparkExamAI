import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebView
import QtQuick.Layouts 1.15

Rectangle {
    id: sparkAIAgentPage
    color: "transparent"
    
    // 智能体地址属性
    property string aiAgentUrl: "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true" // 默认值
    
    // 新增：智能体登录信息
    property string aiAgentUsername: ""
    property string aiAgentPassword: ""
    
    // 新增：监测和自动化状态
    property string currentSourceCode: ""
    property bool isLoadingComplete: false
    property bool isMonitoring: false
    property bool isAutoLoginInProgress: false
    
    // 新增：调试信息控制和显示
    property bool showDebugInfo: false  // 控制是否显示调试信息
    property string debugMessage: ""   // 当前调试信息
    property string debugHistoryText: ""   // 调试历史文本
    
    // 页面初始化
    Component.onCompleted: {
        // 从数据库加载智能体设置
        loadAgentSettings()
        
        // 初始化调试信息
        if (showDebugInfo) {
            updateDebugInfo("系统初始化", "页面加载完成，开始初始化智能体设置")
        }
    }
    
    // 加载智能体设置
    function loadAgentSettings() {
        updateDebugInfo("设置加载", "开始从数据库加载智能体配置")
        
        // 加载智能体地址
        var savedAgentAddress = dbManager.getSetting("ai_agent_address", "https://www.coze.cn/store/agent/7485277516954271795?bot_id=true")
        aiAgentUrl = savedAgentAddress
        
        // 加载智能体用户名
        var savedAgentUsername = dbManager.getSetting("ai_agent_username", "")
        aiAgentUsername = savedAgentUsername
        
        // 加载智能体密码
        var savedAgentPassword = dbManager.getSetting("ai_agent_password", "")
        aiAgentPassword = savedAgentPassword
        
        console.log("已加载智能体设置:")
        console.log("地址: " + aiAgentUrl)
        console.log("用户名: " + (aiAgentUsername ? "已设置" : "未设置"))
        console.log("密码: " + (aiAgentPassword ? "已设置" : "未设置"))
        
        updateDebugInfo("设置加载", "配置加载完成 - 地址:" + aiAgentUrl.substring(0, 30) + "... 用户名:" + (aiAgentUsername ? "已设置" : "未设置") + " 密码:" + (aiAgentPassword ? "已设置" : "未设置"))
        
        // 设置WebView的URL
        webView.url = aiAgentUrl
        updateDebugInfo("页面导航", "开始加载智能体页面: " + aiAgentUrl.substring(0, 50) + "...")
    }
    
    // 源码监测函数
    function monitorSourceCode() {
        if (!isLoadingComplete || isAutoLoginInProgress) {
            return
        }
        
        updateDebugInfo("源码监测", "正在获取网页源码并检查关键内容")
        
        webView.runJavaScript("document.documentElement.outerHTML", function(result) {
            currentSourceCode = result
            
            // 检查是否包含"继续对话..."
            if (currentSourceCode.indexOf("继续对话...") !== -1) {
                console.log("检测到'继续对话...'，停止监测")
                updateDebugInfo("监测完成", "检测到'继续对话...'，用户已登录，停止监测")
                sourceMonitorTimer.stop()
                isMonitoring = false
                loadingOverlay.visible = false
                return
            }
            
            // 检查是否包含"立即注册扣子，免费体验与 AI 智能体聊天!"
            if (currentSourceCode.indexOf("立即注册扣子，免费体验与 AI 智能体聊天!") !== -1) {
                console.log("检测到注册提示，开始自动登录流程")
                updateDebugInfo("触发自动登录", "检测到需要登录的页面，开始自动登录流程")
                sourceMonitorTimer.stop()
                isMonitoring = false
                startAutoLogin()
            } else {
                console.log("源码检查：未发现目标内容，继续监测...")
                updateDebugInfo("源码监测", "未发现目标关键词，继续监测页面状态")
            }
        })
    }
    
    // 开始自动登录流程
    function startAutoLogin() {
        console.log("开始检查自动登录条件...")
        console.log("用户名设置状态: " + (aiAgentUsername ? "已设置(" + aiAgentUsername + ")" : "未设置"))
        console.log("密码设置状态: " + (aiAgentPassword ? "已设置(" + aiAgentPassword.length + "位)" : "未设置"))
        
        if (!aiAgentUsername || !aiAgentPassword) {
            console.warn("智能体用户名或密码未设置，无法自动登录")
            updateDebugInfo("自动登录错误", "用户名或密码未设置，无法执行自动登录")
            loadingOverlay.visible = false
            showLoginErrorDialog("智能体用户名或密码未设置", "请先在设置中配置智能体用户名和密码")
            return
        }
        
        if (aiAgentUsername.trim() === "" || aiAgentPassword.trim() === "") {
            console.warn("智能体用户名或密码为空，无法自动登录")
            updateDebugInfo("自动登录错误", "用户名或密码为空字符串，无法执行自动登录")
            loadingOverlay.visible = false
            showLoginErrorDialog("智能体用户名或密码为空", "请先在设置中配置有效的智能体用户名和密码")
            return
        }
        
        isAutoLoginInProgress = true
        updateDebugInfo("自动登录开始", "验证通过，开始执行6步自动登录流程")
        
        // 步骤1：点击"开始使用"按钮 - 增加重试机制
        console.log("步骤1：查找并点击'开始使用'按钮")
        loadingText.text = "正在查找'开始使用'按钮..."
        updateDebugInfo("登录步骤1", "查找并点击'开始使用'按钮")
        tryClickStartButton()
    }
    
    // 尝试点击开始使用按钮（带重试）
    function tryClickStartButton() {
        var clickStartButtonScript = `
            var startButton = document.querySelector('button.semi-button.semi-button-primary.button--RyQVYC9R3wokm6IF.button--JugmBM2UJZooRtOu.button-min-width--BBRqybhg3ct1GDe5');
            if (startButton) {
                console.log('找到开始使用按钮，执行点击');
                startButton.click();
                true;
            } else {
                console.log('未找到开始使用按钮，继续等待...');
                false;
            }
        `
        
        webView.runJavaScript(clickStartButtonScript, function(result) {
            if (result) {
                console.log("成功点击'开始使用'按钮")
                updateDebugInfo("登录步骤1", "成功点击'开始使用'按钮，进入步骤2")
                // 重置重试计数器并进入下一步
                autoLoginTimer.retryCount = 0
                autoLoginTimer.interval = 2000
                autoLoginTimer.currentStep = 2
                autoLoginTimer.start()
            } else {
                // 如果没找到，继续重试
                if (autoLoginTimer.retryCount < 10) { // 最多重试10次
                    autoLoginTimer.retryCount++
                    console.log("未找到'开始使用'按钮，第" + autoLoginTimer.retryCount + "次重试...")
                    updateDebugInfo("登录步骤1", "未找到'开始使用'按钮，第" + autoLoginTimer.retryCount + "/10次重试")
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 1
                    autoLoginTimer.start()
                } else {
                    console.error("多次重试后仍未找到'开始使用'按钮")
                    updateDebugInfo("登录步骤1", "重试10次后仍未找到'开始使用'按钮，登录失败")
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "页面可能已更新，未找到'开始使用'按钮")
                }
            }
        })
    }
    
    // 执行登录步骤2：点击"账号登录" - 增加重试机制
    function executeStep2() {
        console.log("步骤2：查找并点击'账号登录'")
        loadingText.text = "正在查找'账号登录'标签..."
        updateDebugInfo("登录步骤2", "查找并点击'账号登录'标签")
        tryClickLoginTab()
    }
    
    // 尝试点击账号登录标签（带重试）
    function tryClickLoginTab() {
        var clickLoginTabScript = `
            // 方法1：通过包含"账号登录"文本的div选择器
            var loginTab = Array.from(document.querySelectorAll('div.arco-tabs-header-title')).find(div => 
                div.textContent.includes('账号登录'));
            
            // 方法2：如果方法1失败，尝试通过role属性选择
            if (!loginTab) {
                loginTab = Array.from(document.querySelectorAll('div[role="tab"]')).find(div => 
                    div.textContent.includes('账号登录'));
            }
            
            // 方法3：如果以上都失败，尝试直接通过span找到父元素
            if (!loginTab) {
                var span = document.querySelector('span.arco-tabs-header-title-text');
                if (span && span.textContent === '账号登录') {
                    loginTab = span.parentElement;
                }
            }
            
            if (loginTab) {
                console.log('找到账号登录标签div，执行点击');
                loginTab.click();
                true;
            } else {
                console.log('未找到账号登录标签div，继续等待...');
                false;
            }
        `
        
        webView.runJavaScript(clickLoginTabScript, function(result) {
            if (result) {
                console.log("成功点击'账号登录'标签")
                updateDebugInfo("登录步骤2", "成功点击'账号登录'标签，进入步骤3")
                // 重置重试计数器并进入下一步
                autoLoginTimer.retryCount = 0
                autoLoginTimer.interval = 1500
                autoLoginTimer.currentStep = 3
                autoLoginTimer.start()
            } else {
                // 如果没找到，继续重试
                if (autoLoginTimer.retryCount < 10) { // 最多重试10次
                    autoLoginTimer.retryCount++
                    console.log("未找到'账号登录'标签，第" + autoLoginTimer.retryCount + "次重试...")
                    updateDebugInfo("登录步骤2", "未找到'账号登录'标签，第" + autoLoginTimer.retryCount + "/10次重试")
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 2
                    autoLoginTimer.start()
                } else {
                    console.error("多次重试后仍未找到'账号登录'标签")
                    updateDebugInfo("登录步骤2", "重试10次后仍未找到'账号登录'标签，登录失败")
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "页面可能已更新，未找到'账号登录'标签")
                }
            }
        })
    }
    
    // 执行登录步骤3：输入用户名 - 增加重试机制
    function executeStep3() {
        console.log("步骤3：输入用户名")
        loadingText.text = "正在查找用户名输入框..."
        updateDebugInfo("登录步骤3", "查找用户名输入框并输入: " + aiAgentUsername)
        tryInputUsername()
    }
    
    // 尝试输入用户名（带重试）- 模拟人类键盘输入
    function tryInputUsername() {
        console.log("准备输入用户名: " + aiAgentUsername)
        updateDebugInfo("登录步骤3", "准备模拟键盘输入用户名: " + aiAgentUsername)
        
        var inputUsernameScript = 
            "var usernameInput = document.querySelector('input[name=\"Identity\"]');" +
            "if (usernameInput) {" +
                "console.log('找到用户名输入框，开始模拟键盘输入');" +
                "usernameInput.focus();" +
                "usernameInput.value = '';" +
                "usernameInput.dispatchEvent(new Event('focus', { bubbles: true }));" +
                "true;" +
            "} else {" +
                "console.log('未找到用户名输入框，继续等待...');" +
                "false;" +
            "}"
        
        webView.runJavaScript(inputUsernameScript, function(result) {
            if (result) {
                console.log("找到用户名输入框，开始模拟人类键盘输入")
                updateDebugInfo("登录步骤3", "找到用户名输入框，开始逐字符模拟输入")
                // 开始逐字符输入用户名
                simulateTypingUsername(0)
            } else {
                console.log("用户名输入框查找失败")
                // 如果没找到，继续重试
                if (autoLoginTimer.retryCount < 10) {
                    autoLoginTimer.retryCount++
                    console.log("用户名输入框未找到，第" + autoLoginTimer.retryCount + "次重试...")
                    updateDebugInfo("登录步骤3", "用户名输入框未找到，第" + autoLoginTimer.retryCount + "/10次重试")
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 3
                    autoLoginTimer.start()
                } else {
                    console.error("多次重试后仍未找到用户名输入框")
                    updateDebugInfo("登录步骤3", "重试10次后仍未找到用户名输入框，登录失败")
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "无法找到用户名输入框，请检查页面是否正常")
                }
            }
        })
    }
    
    // 模拟逐字符输入用户名
    function simulateTypingUsername(charIndex) {
        if (charIndex >= aiAgentUsername.length) {
            // 输入完成，验证结果
            console.log("用户名模拟输入完成，验证结果")
            updateDebugInfo("登录步骤3", "用户名模拟输入完成，验证输入结果")
            verifyUsernameInput()
            return
        }
        
        var currentChar = aiAgentUsername.charAt(charIndex)
        var safeChar = JSON.stringify(currentChar)
        updateDebugInfo("登录步骤3", "正在输入第" + (charIndex + 1) + "个字符: " + currentChar)
        
        var typeCharScript = 
            "var usernameInput = document.querySelector('input[name=\"Identity\"]');" +
            "if (usernameInput) {" +
                "var char = " + safeChar + ";" +
                "var keyCode = char.charCodeAt(0);" +
                "usernameInput.focus();" +
                
                // 触发keydown事件
                "var keydownEvent = new KeyboardEvent('keydown', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "usernameInput.dispatchEvent(keydownEvent);" +
                
                // 触发keypress事件
                "var keypressEvent = new KeyboardEvent('keypress', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "charCode: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "usernameInput.dispatchEvent(keypressEvent);" +
                
                // 添加字符到输入框
                "usernameInput.value = usernameInput.value + char;" +
                
                // 触发input事件
                "var inputEvent = new Event('input', {" +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "usernameInput.dispatchEvent(inputEvent);" +
                
                // 触发keyup事件
                "var keyupEvent = new KeyboardEvent('keyup', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "usernameInput.dispatchEvent(keyupEvent);" +
                
                "console.log('输入字符: ' + char + ', 当前值: ' + usernameInput.value);" +
                "true;" +
            "} else {" +
                "false;" +
            "}"
        
        webView.runJavaScript(typeCharScript, function(result) {
            if (result) {
                // 人类输入间隔：80-150毫秒
                var delay = Math.floor(Math.random() * 70) + 80
                charInputTimer.inputType = "username"
                charInputTimer.nextCharIndex = charIndex + 1
                charInputTimer.interval = delay
                charInputTimer.start()
            } else {
                console.error("字符输入失败，输入框可能丢失")
                updateDebugInfo("登录步骤3", "字符输入失败，输入框可能丢失")
                isAutoLoginInProgress = false
                loadingOverlay.visible = false
                showLoginErrorDialog("自动登录失败", "用户名输入过程中输入框丢失")
            }
        })
    }
    
    // 验证用户名输入结果
    function verifyUsernameInput() {
        var verifyScript = 
            "var usernameInput = document.querySelector('input[name=\"Identity\"]');" +
            "if (usernameInput && usernameInput.value.length > 0) {" +
                "console.log('用户名输入验证成功，值: ' + usernameInput.value);" +
                "usernameInput.dispatchEvent(new Event('change', { bubbles: true }));" +
                "usernameInput.dispatchEvent(new Event('blur', { bubbles: true }));" +
                "true;" +
            "} else {" +
                "false;" +
            "}"
        
        webView.runJavaScript(verifyScript, function(result) {
            if (result) {
                console.log("用户名输入验证成功")
                updateDebugInfo("登录步骤3", "用户名输入成功，进入密码输入步骤")
                // 重置重试计数器并进入下一步
                autoLoginTimer.retryCount = 0
                autoLoginTimer.interval = 1000
                autoLoginTimer.currentStep = 4
                autoLoginTimer.start()
            } else {
                console.error("用户名输入验证失败")
                updateDebugInfo("登录步骤3", "用户名输入验证失败，重新尝试")
                if (autoLoginTimer.retryCount < 5) {
                    autoLoginTimer.retryCount++
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 3
                    autoLoginTimer.start()
                } else {
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "用户名输入多次验证失败")
                }
            }
        })
    }
    
    // 执行登录步骤4：输入密码 - 增加重试机制
    function executeStep4() {
        console.log("步骤4：输入密码")
        loadingText.text = "正在查找密码输入框..."
        updateDebugInfo("登录步骤4", "查找密码输入框并输入密码")
        tryInputPassword()
    }
    
    // 尝试输入密码（带重试）- 模拟人类键盘输入
    function tryInputPassword() {
        console.log("准备输入密码: [" + aiAgentPassword.length + "位密码]")
        updateDebugInfo("登录步骤4", "准备模拟键盘输入密码 (长度: " + aiAgentPassword.length + ")")
        
        var inputPasswordScript = 
            "var passwordInput = document.querySelector('input[id=\"Password_input\"]');" +
            "if (passwordInput) {" +
                "console.log('找到密码输入框，开始模拟键盘输入');" +
                "passwordInput.focus();" +
                "passwordInput.value = '';" +
                "passwordInput.dispatchEvent(new Event('focus', { bubbles: true }));" +
                "true;" +
            "} else {" +
                "console.log('未找到密码输入框，继续等待...');" +
                "false;" +
            "}"
        
        webView.runJavaScript(inputPasswordScript, function(result) {
            if (result) {
                console.log("找到密码输入框，开始模拟人类键盘输入")
                updateDebugInfo("登录步骤4", "找到密码输入框，开始逐字符模拟输入")
                // 开始逐字符输入密码
                simulateTypingPassword(0)
            } else {
                console.log("密码输入框查找失败")
                // 如果没找到，继续重试
                if (autoLoginTimer.retryCount < 10) {
                    autoLoginTimer.retryCount++
                    console.log("密码输入框未找到，第" + autoLoginTimer.retryCount + "次重试...")
                    updateDebugInfo("登录步骤4", "密码输入框未找到，第" + autoLoginTimer.retryCount + "/10次重试")
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 4
                    autoLoginTimer.start()
                } else {
                    console.error("多次重试后仍未找到密码输入框")
                    updateDebugInfo("登录步骤4", "重试10次后仍未找到密码输入框，登录失败")
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "无法找到密码输入框，请检查页面是否正常")
                }
            }
        })
    }
    
    // 模拟逐字符输入密码
    function simulateTypingPassword(charIndex) {
        if (charIndex >= aiAgentPassword.length) {
            // 输入完成，验证结果
            console.log("密码模拟输入完成，验证结果")
            updateDebugInfo("登录步骤4", "密码模拟输入完成，验证输入结果")
            verifyPasswordInput()
            return
        }
        
        var currentChar = aiAgentPassword.charAt(charIndex)
        var safeChar = JSON.stringify(currentChar)
        updateDebugInfo("登录步骤4", "正在输入第" + (charIndex + 1) + "个密码字符")
        
        var typeCharScript = 
            "var passwordInput = document.querySelector('input[id=\"Password_input\"]');" +
            "if (passwordInput) {" +
                "var char = " + safeChar + ";" +
                "var keyCode = char.charCodeAt(0);" +
                "passwordInput.focus();" +
                
                // 触发keydown事件
                "var keydownEvent = new KeyboardEvent('keydown', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "passwordInput.dispatchEvent(keydownEvent);" +
                
                // 触发keypress事件
                "var keypressEvent = new KeyboardEvent('keypress', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "charCode: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "passwordInput.dispatchEvent(keypressEvent);" +
                
                // 添加字符到输入框
                "passwordInput.value = passwordInput.value + char;" +
                
                // 触发input事件
                "var inputEvent = new Event('input', {" +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "passwordInput.dispatchEvent(inputEvent);" +
                
                // 触发keyup事件
                "var keyupEvent = new KeyboardEvent('keyup', {" +
                    "key: char," +
                    "code: 'Key' + char.toUpperCase()," +
                    "keyCode: keyCode," +
                    "which: keyCode," +
                    "bubbles: true," +
                    "cancelable: true" +
                "});" +
                "passwordInput.dispatchEvent(keyupEvent);" +
                
                "console.log('输入字符，当前长度: ' + passwordInput.value.length);" +
                "true;" +
            "} else {" +
                "false;" +
            "}"
        
        webView.runJavaScript(typeCharScript, function(result) {
            if (result) {
                // 人类输入间隔：80-150毫秒，密码可能稍慢一些
                var delay = Math.floor(Math.random() * 100) + 90
                charInputTimer.inputType = "password"
                charInputTimer.nextCharIndex = charIndex + 1
                charInputTimer.interval = delay
                charInputTimer.start()
            } else {
                console.error("密码字符输入失败，输入框可能丢失")
                updateDebugInfo("登录步骤4", "密码字符输入失败，输入框可能丢失")
                isAutoLoginInProgress = false
                loadingOverlay.visible = false
                showLoginErrorDialog("自动登录失败", "密码输入过程中输入框丢失")
            }
        })
    }
    
    // 验证密码输入结果
    function verifyPasswordInput() {
        var verifyScript = 
            "var passwordInput = document.querySelector('input[id=\"Password_input\"]');" +
            "if (passwordInput && passwordInput.value.length > 0) {" +
                "console.log('密码输入验证成功，长度: ' + passwordInput.value.length);" +
                "passwordInput.dispatchEvent(new Event('change', { bubbles: true }));" +
                "passwordInput.dispatchEvent(new Event('blur', { bubbles: true }));" +
                "true;" +
            "} else {" +
                "false;" +
            "}"
        
        webView.runJavaScript(verifyScript, function(result) {
            if (result) {
                console.log("密码输入验证成功")
                updateDebugInfo("登录步骤4", "密码输入成功，进入登录按钮点击步骤")
                // 重置重试计数器并进入下一步
                autoLoginTimer.retryCount = 0
                autoLoginTimer.interval = 1000
                autoLoginTimer.currentStep = 5
                autoLoginTimer.start()
            } else {
                console.error("密码输入验证失败")
                updateDebugInfo("登录步骤4", "密码输入验证失败，重新尝试")
                if (autoLoginTimer.retryCount < 5) {
                    autoLoginTimer.retryCount++
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 4
                    autoLoginTimer.start()
                } else {
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "密码输入多次验证失败")
                }
            }
        })
    }
    
    // 执行登录步骤5：点击登录按钮 - 增加重试机制
    function executeStep5() {
        console.log("步骤5：点击登录按钮")
        loadingText.text = "正在查找登录按钮..."
        updateDebugInfo("登录步骤5", "查找登录按钮并验证输入框数据完整性")
        tryClickLoginButton()
    }
    
    // 尝试点击登录按钮（带重试）
    function tryClickLoginButton() {
        var clickLoginButtonScript = 
            "var usernameInput = document.querySelector('input[name=\"Identity\"]');" +
            "var passwordInput = document.querySelector('input[id=\"Password_input\"]');" +
            "var loginButton = document.querySelector('button[data-monitor-click-id=\"d585165\"]');" +
            "if (!usernameInput || !passwordInput || !loginButton) {" +
                "console.log('未找到必要的输入框或登录按钮，继续等待...');" +
                "false;" +
            "} else {" +
                "var usernameValue = usernameInput.value.trim();" +
                "var passwordValue = passwordInput.value.trim();" +
                "console.log('当前用户名值:', usernameValue ? '已填写(' + usernameValue.length + '字符)' : '空');" +
                "console.log('当前密码值:', passwordValue ? '已填写(' + passwordValue.length + '字符)' : '空');" +
                "if (usernameValue && passwordValue) {" +
                    "console.log('找到登录按钮且输入框已填写，执行点击');" +
                    "loginButton.click();" +
                    "true;" +
                "} else {" +
                    "console.log('输入框为空，需要重新输入');" +
                    "false;" +
                "}" +
            "}"
        
        webView.runJavaScript(clickLoginButtonScript, function(result) {
            if (result) {
                console.log("成功点击登录按钮")
                loadingText.text = "正在验证登录结果..."
                updateDebugInfo("登录步骤5", "成功点击登录按钮，开始验证登录结果")
                // 重置重试计数器并进入下一步
                autoLoginTimer.retryCount = 0
                autoLoginTimer.interval = 3000
                autoLoginTimer.currentStep = 6
                autoLoginTimer.start()
            } else {
                // 如果没找到，继续重试
                if (autoLoginTimer.retryCount < 10) { // 最多重试10次
                    autoLoginTimer.retryCount++
                    console.log("未找到登录按钮或输入框有问题，第" + autoLoginTimer.retryCount + "次重试...")
                    
                    // 如果重试次数较多，可能需要重新输入
                    if (autoLoginTimer.retryCount > 5) {
                        console.log("多次重试失败，可能需要重新输入账号密码...")
                        loadingText.text = "重新验证输入内容..."
                        updateDebugInfo("登录步骤5", "多次重试失败，回到步骤3重新输入账号密码")
                        autoLoginTimer.interval = 3000
                        autoLoginTimer.currentStep = 3  // 回到输入用户名步骤
                    } else {
                        updateDebugInfo("登录步骤5", "未找到登录按钮或输入框异常，第" + autoLoginTimer.retryCount + "/10次重试")
                        autoLoginTimer.interval = 2000
                        autoLoginTimer.currentStep = 5
                    }
                    autoLoginTimer.start()
                } else {
                    console.error("多次重试后仍未找到登录按钮")
                    updateDebugInfo("登录步骤5", "重试10次后仍未找到登录按钮或输入框异常，登录失败")
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    showLoginErrorDialog("自动登录失败", "页面可能已更新，未找到登录按钮或输入框数据异常")
                }
            }
        })
    }
    
    // 执行登录步骤6：检查登录结果
    function executeStep6() {
        console.log("步骤6：检查登录结果")
        loadingText.text = "正在检查登录状态..."
        updateDebugInfo("登录步骤6", "检查页面源码，验证登录是否成功")
        webView.runJavaScript("document.documentElement.outerHTML", function(result) {
            currentSourceCode = result
            
            // 检查是否登录成功（包含"继续对话..."）
            if (currentSourceCode.indexOf("继续对话...") !== -1) {
                console.log("自动登录成功！检测到'继续对话...'")
                updateDebugInfo("登录成功", "检测到'继续对话...'，自动登录成功完成！")
                isAutoLoginInProgress = false
                loadingOverlay.visible = false
                // 登录成功，直接关闭加载遮罩，不显示成功对话框
            } else if (currentSourceCode.indexOf("用户名或密码错误") !== -1 || 
                      currentSourceCode.indexOf("登录失败") !== -1 ||
                      currentSourceCode.indexOf("账号或密码错误") !== -1) {
                console.error("登录失败：用户名或密码错误")
                updateDebugInfo("登录失败", "检测到用户名或密码错误提示")
                isAutoLoginInProgress = false
                loadingOverlay.visible = false
                showLoginErrorDialog("登录失败", "用户名或密码错误，请检查设置")
            } else {
                // 没有检测到明确的成功或失败状态，继续等待
                console.log("登录结果检查：页面仍在加载或转换中，继续等待...")
                if (autoLoginTimer.retryCount < 15) { // 最多等待15次（约30秒）
                    autoLoginTimer.retryCount++
                    console.log("等待登录结果，第" + autoLoginTimer.retryCount + "次检查...")
                    loadingText.text = "等待登录验证... (" + autoLoginTimer.retryCount + "/15)"
                    updateDebugInfo("登录步骤6", "页面仍在转换中，等待登录验证 (" + autoLoginTimer.retryCount + "/15)")
                    autoLoginTimer.interval = 2000
                    autoLoginTimer.currentStep = 6
                    autoLoginTimer.start()
                } else {
                    // 超时后检查是否可能已经登录成功
                    console.log("登录验证超时，进行最终状态检查...")
                    updateDebugInfo("登录步骤6", "等待超时，进行最终状态检查")
                    
                    // 最终检查：如果页面没有登录相关元素，可能已经成功
                    webView.runJavaScript(`
                        var hasLoginElements = document.querySelector('input[name="Identity"]') || 
                                             document.querySelector('input[id="Password_input"]') ||
                                             document.querySelector('button[data-monitor-click-id="d585165"]');
                        !hasLoginElements; // 如果没有登录元素，返回true表示可能已登录
                    `, function(possiblyLoggedIn) {
                        if (possiblyLoggedIn) {
                            console.log("未检测到登录元素，可能已经成功登录")
                            updateDebugInfo("登录结果", "未检测到登录元素，可能已成功登录")
                            isAutoLoginInProgress = false
                            loadingOverlay.visible = false
                        } else {
                            console.log("登录流程完成，但无法确定最终状态")
                            updateDebugInfo("登录结果", "登录流程完成，但状态不明确")
                            isAutoLoginInProgress = false
                            loadingOverlay.visible = false
                            showLoginErrorDialog("登录状态不明", "登录流程已完成，请手动检查登录状态")
                        }
                    })
                }
            }
        })
    }
    
    // 显示登录错误对话框
    function showLoginErrorDialog(title, message) {
        loginErrorDialog.title = title
        loginErrorDialog.message = message
        loginErrorDialog.open()
    }
    
    // 返回按钮 - 使用纯基本组件而不依赖样式
    Rectangle {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: 100
        height: 40
        color: "transparent"
        radius: 5
        z: 10
        
        Image {
            id: buttonBg
            anchors.fill: parent
            source: "qrc:/images/button_bg.png"
            fillMode: Image.Stretch
        }
        
        Text {
            anchors.centerIn: parent
            text: "返回"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 18
            color: "white"
        }
        
        MouseArea {
            id: backButtonMouse
            anchors.fill: parent
            onClicked: {
                updateDebugInfo("页面导航", "用户点击返回按钮，退出智能体页面")
                
                // 停止所有定时器
                sourceMonitorTimer.stop()
                autoLoginTimer.stop()
                
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
        z: 5
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
        z: 5
    }
    
    // 内容区域
    Rectangle {
        id: contentArea
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
            anchors.topMargin: 10
            url: ""

    // 显式声明参数并判断加载状态
    onLoadingChanged: function(loadRequest) {
        switch (loadRequest.status) {
            case WebView.LoadStartedStatus:
                        console.log("网页开始加载...")
                        updateDebugInfo("网页加载", "开始加载智能体页面")
                        isLoadingComplete = false
                        loadingOverlay.visible = true
                        loadingText.text = "正在加载智能体..."
                        break
                        
            case WebView.LoadSucceededStatus:
                        console.log("网页加载成功!")
                        updateDebugInfo("网页加载", "页面加载成功，准备开始源码监测")
                        isLoadingComplete = true
                        loadingText.text = "正在检测页面状态..."
                        
                        // 延迟一秒后开始监测源码
                        Qt.callLater(function() {
                            sourceMonitorTimer.interval = 1000
                            sourceMonitorTimer.start()
                            isMonitoring = true
                            updateDebugInfo("源码监测", "开始定时监测页面状态，每2秒检查一次")
                        })
                        break
                        
            case WebView.LoadFailedStatus:
                        console.error("网页加载失败: " + loadRequest.errorString)
                        updateDebugInfo("网页加载", "页面加载失败: " + loadRequest.errorString)
                        isLoadingComplete = false
                        loadingOverlay.visible = false
                        showLoginErrorDialog("加载失败", "网页加载失败: " + loadRequest.errorString)
                        break
                }
            }
        }
        
        // 加载遮罩
        Rectangle {
            id: loadingOverlay
            anchors.fill: parent
            color: "#80000000"
            radius: 10
            visible: false
            z: 100
            
            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 150
                color: "#333333"
                radius: 10
                border.color: "#666666"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // 加载动画和当前状态
                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        
                        // 加载动画
                        Rectangle {
                            width: 50
                            height: 50
                            color: "transparent"
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Rectangle {
                                id: loadingSpinner
                                width: 40
                                height: 40
                                color: "transparent"
                                border.color: "#2c70b7"
                                border.width: 4
                                radius: 20
                                anchors.centerIn: parent
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    color: "#2c70b7"
                                    radius: 4
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.topMargin: -4
                                }
                                
                                RotationAnimation {
                                    target: loadingSpinner
                                    property: "rotation"
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: loadingOverlay.visible
                                }
                            }
                        }
                        
                        // 加载文本
                        Text {
                            id: loadingText
                            text: "正在加载..."
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
    
    // 源码监测定时器
    Timer {
        id: sourceMonitorTimer
        interval: 2000
        repeat: true
        running: false
        
        onTriggered: {
            if (isMonitoring) {
                monitorSourceCode()
            }
        }
    }
    
    // 自动登录步骤定时器
    Timer {
        id: autoLoginTimer
        interval: 1000
        repeat: false
        running: false
        
        property int currentStep: 1
        property int retryCount: 0
        
        onTriggered: {
            console.log("执行自动登录步骤: " + currentStep + " (重试次数: " + retryCount + ")")
            
            switch (currentStep) {
                case 1:
                    tryClickStartButton()
                    break
                case 2:
                    tryClickLoginTab()
                    break
                case 3:
                    tryInputUsername()
                    break
                case 4:
                    tryInputPassword()
                    break
                case 5:
                    tryClickLoginButton()
                    break
                case 6:
                    executeStep6()
                    break
                default:
                    console.log("未知的自动登录步骤: " + currentStep)
                    isAutoLoginInProgress = false
                    loadingOverlay.visible = false
                    break
            }
        }
    }
    
    // 登录错误对话框
    Dialog {
        id: loginErrorDialog
        title: "登录错误"
        property string message: ""
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
            color: "#cc3333"
            height: 40
            width: parent.width
            radius: 5
            
            Text {
                text: loginErrorDialog.title
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
                text: loginErrorDialog.message
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
            
            Button {
                anchors.centerIn: parent
                text: "确定"
                width: 120
                height: 40
                
                background: Rectangle {
                    color: "#cc3333"
                    radius: 4
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
                    loginErrorDialog.close()
                }
            }
        }
    }
    
    
    // 新增：更新调试信息的函数
    function updateDebugInfo(operation, details) {
        if (!showDebugInfo) return
        
        var timestamp = new Date().toLocaleTimeString()
        debugMessage = "[" + timestamp + "] " + operation + ": " + details
        
        // 添加到历史记录文本
        debugHistoryText = debugHistoryText + debugMessage + "\n"
        
        // 保持最新10行记录
        var lines = debugHistoryText.split("\n")
        if (lines.length > 11) { // 多一行因为最后有空行
            lines = lines.slice(-11)
            debugHistoryText = lines.join("\n")
        }
        
        console.log("调试信息: " + debugMessage)
    }
    
    // 新增：字符输入延迟定时器
    Timer {
        id: charInputTimer
        interval: 100
        repeat: false
        running: false
        
        property string inputType: ""  // "username" 或 "password"
        property int nextCharIndex: 0
        
        onTriggered: {
            if (inputType === "username") {
                simulateTypingUsername(nextCharIndex)
            } else if (inputType === "password") {
                simulateTypingPassword(nextCharIndex)
            }
        }
    }
} 