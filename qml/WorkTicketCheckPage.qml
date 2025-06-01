import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtWebEngine 1.8

Rectangle {
    id: workTicketCheckPage
    color: "transparent"
    // 是否已登录状态
    property bool isLoggedIn: false

    // 点击登录按钮
    loginButton.onClicked: {
        // 更新按钮文本为"登录中..."
        loginButton.text = "登录中..."
        loginButton.enabled = false

        // 输入工号和密码并点击登录
        webView.runJavaScript(
            "document.querySelector('input[name=\"username\"]').value = '" + usernameText.text + "';" +
            "document.querySelector('input[name=\"password\"]').value = '" + passwordText.text + "';" +
            "document.querySelector('button#login.log-btn[type=\"submit\"]').click();"
        );

        // 创建定时器监测登录状态
        var checkLoginTimer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', loginButton, "checkLoginTimer");
        checkLoginTimer.interval = 1000; // 每秒检查一次
        checkLoginTimer.repeat = true;
        checkLoginTimer.triggered.connect(function() {
            webView.runJavaScript(
                "document.documentElement.outerHTML",
                function(result) {
                    if (result.indexOf("施工调度管理二期系统【正式环境】") !== -1) {
                        // 登录成功
                        isLoggedIn = true;
                        checkLoginTimer.stop();
                        checkLoginTimer.destroy();
                        loginButton.text = "登录成功";
                        loginButton.enabled = true;
                    }
                }
            );
        });
        checkLoginTimer.start();
    }
} 