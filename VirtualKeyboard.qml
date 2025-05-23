import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Settings 2.15
import QtQuick.Layouts 1.15

Item {
    id: keyboardContainer
    width: 800
    height: inputPanel.height + 70
    z: 1000 // 确保在其他元素之上
    
    // 属性
    property bool keyboardVisible: visible
    property int minWidth: 500
    property int minHeight: 20
    
    // 信号
    signal closed()
    
    // 初始位置
    x: (Window.width - width) / 2
    y: Window.height - height - 50
    
    // 虚拟键盘设置
    Component.onCompleted: {
        console.log("初始化虚拟键盘...")
        VirtualKeyboardSettings.activeLocales = ["zh_CN", "en_US"]
        VirtualKeyboardSettings.locale = "zh_CN"
        VirtualKeyboardSettings.wordCandidateList.alwaysVisible = true
        
        // 确保输入法上下文正确设置
        if (Qt.inputMethod) {
            console.log("设置输入法可见性...")
            Qt.inputMethod.visibleChanged.connect(function() {
                if (Qt.inputMethod.visible) {
                    console.log("输入法变为可见")
                    keyboardContainer.visible = true
                }
            })
        } else {
            console.log("无法获取Qt.inputMethod对象")
        }
    }
    
    // 背景面板
    Rectangle {
        id: keyboardPanel
        anchors.fill: parent
        color: "#303030"
        opacity: 0.95
        radius: 10
        border.color: "#505050"
        border.width: 1
        
        // 顶部控制栏
        Rectangle {
            id: controlBar
            width: parent.width
            height: 40
            color: "#404040"
            radius: 10
            
            // 标题
            Text {
                anchors.centerIn: parent
                text: "虚拟键盘"
                color: "white"
                font.pixelSize: 16
            }
            
            // 关闭按钮
            Rectangle {
                id: closeButton
                width: 30
                height: 30
                radius: 15
                color: closeMouseArea.containsMouse ? "#FF6060" : "#D04040"
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // 在关闭键盘前，确保输入法上下文被正确处理
                        if (Qt.inputMethod) {
                            Qt.inputMethod.hide()
                        }
                        keyboardContainer.visible = false
                        keyboardContainer.closed()
                    }
                }
            }                        
            
            // 语言切换按钮
            Rectangle {
                id: languageButton
                width: 60
                height: 30
                radius: 15
                color: languageMouseArea.containsMouse ? "#60D060" : "#40B040"
                anchors.right: minimizeButton.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    id: languageText
                    anchors.centerIn: parent
                    text: VirtualKeyboardSettings.locale === "zh_CN" ? "中文" : "EN"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
                
                MouseArea {
                    id: languageMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (VirtualKeyboardSettings.locale === "zh_CN") {
                            VirtualKeyboardSettings.locale = "en_US"
                            languageText.text = "EN"
                        } else {
                            VirtualKeyboardSettings.locale = "zh_CN"
                            languageText.text = "中文"
                        }
                    }
                }
            }
            
            // 拖动区域
            MouseArea {
                id: dragArea
                anchors.left: parent.left
                anchors.right: languageButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                
                property int startX: 0
                property int startY: 0
                
                onPressed: {
                    startX = mouse.x
                    startY = mouse.y
                }
                
                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - startX
                        var deltaY = mouse.y - startY
                        
                        // 限制不超出屏幕边界
                        var newX = keyboardContainer.x + deltaX
                        var newY = keyboardContainer.y + deltaY
                        
                        if (newX >= 0 && newX + keyboardContainer.width <= Window.width) {
                            keyboardContainer.x = newX
                        }
                        
                        if (newY >= 0 && newY + keyboardContainer.height <= Window.height) {
                            keyboardContainer.y = newY
                        }
                    }
                }
            }
        }
        
        // 虚拟键盘
        InputPanel {
            id: inputPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: controlBar.bottom
            //anchors.bottom: resizeHandle.top
            anchors.margins: 5
            active: true
            visible: keyboardContainer.visible
            
            // 确保键盘跟随输入框
            Component.onCompleted: {
                console.log("初始化输入面板...")
                
                // 监听输入模式变化
                if (InputContext.priv && InputContext.priv.inputEngine) {
                    InputContext.priv.inputEngine.inputModeChanged.connect(function() {
                        console.log("输入模式变化")
                        if (InputContext.priv.inputEngine.inputMode !== InputEngine.InputMode.Latin) {
                            VirtualKeyboardSettings.locale = "zh_CN"
                            languageText.text = "中文"
                        } else {
                            VirtualKeyboardSettings.locale = "en_US"
                            languageText.text = "EN"
                        }
                    })
                } else {
                    console.log("无法获取InputContext.priv.inputEngine对象")
                }
            }
        }
        
        // 调整大小的手柄
        Rectangle {
            id: resizeHandle
            width: 20
            height: 20
            color: "transparent"
            anchors.top: inputPanel.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5
            
            Rectangle {
                width: 10
                height: 2
                color: "#808080"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
            }
            
            Rectangle {
                width: 6
                height: 2
                color: "#808080"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
            }
            
            Rectangle {
                width: 2
                height: 10
                color: "#808080"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 8
            }
            
            Rectangle {
                width: 2
                height: 6
                color: "#808080"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 5
            }
            
            MouseArea {
                id: resizeArea
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                
                property int startX: 0
                property int startY: 0
                
                onPressed: {
                    startX = mouse.x
                    startY = mouse.y
                }
                
                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - startX
                        var deltaY = mouse.y - startY
                        
                        var newWidth = keyboardContainer.width + deltaX
                        var newHeight = keyboardContainer.height + deltaY
                        
                        if (newWidth >= keyboardContainer.minWidth) {
                            keyboardContainer.width = newWidth                            
                        }
                        
                        if (newHeight >= keyboardContainer.minHeight) {
                            //keyboardContainer.height = newHeight
                            keyboardContainer.height = inputPanel.height + 70
                        }
                    }
                }
            }
        }
    }
    
    // 显示/隐藏动画
    states: [
        State {
            name: "visible"
            when: keyboardContainer.visible
            PropertyChanges { target: keyboardContainer; opacity: 1.0 }
        },
        State {
            name: "hidden"
            when: !keyboardContainer.visible
            PropertyChanges { target: keyboardContainer; opacity: 0.0 }
        }
    ]
    
    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            NumberAnimation { 
                properties: "opacity"; 
                duration: 200; 
                easing.type: Easing.OutQuad 
            }
        },
        Transition {
            from: "visible"; to: "hidden"
            NumberAnimation { 
                properties: "opacity"; 
                duration: 200; 
                easing.type: Easing.InQuad 
            }
        }
    ]
} 