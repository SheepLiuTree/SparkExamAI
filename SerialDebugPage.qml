import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: serialDebugPage
    width: parent.width
    height: parent.height
    color: "#1E1E1E"
    
    Text {
        id: pageTitle
        text: "串口调试页面"
        font.pixelSize: 32
        color: "white"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
    }
    
    ColumnLayout {
        anchors.top: pageTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20
        
        // 串口连接控制
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: "#252525"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                ComboBox {
                    id: portSelector
                    Layout.preferredWidth: 200
                    model: serialPortManager.availablePorts
                    onCurrentTextChanged: {
                        if (currentText != "") {
                            serialPortManager.currentPort = currentText
                        }
                    }
                }
                
                Button {
                    text: "刷新端口"
                    onClicked: serialPortManager.refreshPorts()
                }
                
                Button {
                    text: serialPortManager.connected ? "断开连接" : "连接"
                    onClicked: {
                        if (serialPortManager.connected) {
                            serialPortManager.disconnectFromPort()
                        } else {
                            serialPortManager.connectToPort()
                        }
                    }
                }
                
                Text {
                    text: "状态: " + (serialPortManager.connected ? "已连接" : "未连接")
                    color: serialPortManager.connected ? "green" : "red"
                }
            }
        }
        
        // 单灯控制
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: "#252525"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "单灯控制:"
                    color: "white"
                }
                
                ComboBox {
                    id: lightSelector
                    model: ["灯 1", "灯 2", "灯 3", "灯 4", "灯 5", "灯 6"]
                    Layout.preferredWidth: 100
                }
                
                Button {
                    text: "打开"
                    onClicked: {
                        var lightIndex = lightSelector.currentIndex + 1
                        serialPortManager.toggleLight(lightIndex, true)
                    }
                }
                
                Button {
                    text: "关闭"
                    onClicked: {
                        var lightIndex = lightSelector.currentIndex + 1
                        serialPortManager.toggleLight(lightIndex, false)
                    }
                }
            }
        }
        
        // 全部灯控制
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: "#252525"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "全部灯控制:"
                    color: "white"
                }
                
                Button {
                    text: "全部打开"
                    onClicked: {
                        var states = [true, true, true, true, true, true]
                        serialPortManager.toggleLights(states)
                    }
                }
                
                Button {
                    text: "全部关闭"
                    onClicked: {
                        var states = [false, false, false, false, false, false]
                        serialPortManager.toggleLights(states)
                    }
                }
                
                Button {
                    text: "获取状态"
                    onClicked: serialPortManager.getAllLightStatus()
                }
            }
        }
        
        // 灯光状态显示
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#252525"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20
                
                Repeater {
                    model: 6
                    
                    delegate: Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: {
                            var lightStatusList = serialPortManager.lightStatus
                            return (index < lightStatusList.length && lightStatusList[index]) ? 
                                   "yellow" : "gray"
                        }
                        
                        Text {
                            text: (index + 1)
                            color: "black"
                            anchors.centerIn: parent
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // 日志显示
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252525"
            radius: 10
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                
                TextArea {
                    id: logTextArea
                    readOnly: true
                    wrapMode: TextEdit.Wrap
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }
        
        // 返回按钮
        Button {
            text: "返回主页"
            Layout.alignment: Qt.AlignHCenter
            onClicked: stackView.pop()
        }
    }
    
    // 连接serialPortManager的信号
    Connections {
        target: serialPortManager
        
        function onSerialMessage(message) {
            logTextArea.text += "\n" + message
            logTextArea.cursorPosition = logTextArea.length - 1
        }
        
        function onSerialError(errorMessage) {
            logTextArea.text += "\n错误: " + errorMessage
            logTextArea.cursorPosition = logTextArea.length - 1
        }
        
        function onLightStatusChanged() {
            // 强制更新UI
            serialDebugPage.update()
        }
    }
    
    Component.onCompleted: {
        // 初始刷新串口列表
        serialPortManager.refreshPorts()
        logTextArea.text = "串口调试页面已加载"
    }
} 