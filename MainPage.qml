import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: mainPage
    color: "transparent"
    
    property var userData
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        
        // 顶部欢迎区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // 用户头像和欢迎文本
                RowLayout {
                    spacing: 15
                    
                    // 头像
                    Rectangle {
                        width: 60
                        height: 60
                        radius: 30
                        color: "#f0f0f0"
                        
                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            anchors.margins: 2
                            source: userData && userData.avatarPath ? userData.avatarPath : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: status === Image.Ready
                            
                            // 圆形裁剪
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: avatarImage.width
                                    height: avatarImage.height
                                    radius: width / 2
                                }
                            }
                        }
                        
                        // 如果头像未加载，显示用户名首字母
                        Text {
                            anchors.centerIn: parent
                            visible: avatarImage.status !== Image.Ready
                            text: userData && userData.name ? userData.name.charAt(0).toUpperCase() : "U"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#666666"
                        }
                    }
                    
                    // 欢迎文本
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "欢迎回来，"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                        
                        Text {
                            text: userData ? userData.name : "用户"
                            font.pixelSize: 22
                            font.bold: true
                            color: "#333333"
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 日期和时间
                Column {
                    spacing: 5
                    Layout.alignment: Qt.AlignRight
                    
                    Text {
                        id: dateText
                        text: new Date().toLocaleDateString(Qt.locale(), "yyyy年MM月dd日")
                        font.pixelSize: 16
                        color: "#333333"
                    }
                    
                    Text {
                        id: timeText
                        text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                        font.pixelSize: 14
                        color: "#666666"
                    }
                    
                    // 定时更新时间
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            var now = new Date();
                            dateText.text = now.toLocaleDateString(Qt.locale(), "yyyy年MM月dd日");
                            timeText.text = now.toLocaleTimeString(Qt.locale(), "hh:mm");
                        }
                    }
                }
            }
        }
        
        // 功能区域
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            columns: 3
            rowSpacing: 20
            columnSpacing: 20
            
            // 日课功能卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#f5f9ff"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开日课页面
                        console.log("打开日课页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "星火日课"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#2c70b7"
                    }
                    
                    Text {
                        text: "每日学习计划与练习"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#2c70b7"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "立即学习"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "今日进度: 30%"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 题策引擎卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#fff9f5"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开题策引擎页面
                        stackView.push("QuestionEnginePage.qml")
                        console.log("打开题策引擎页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "题策引擎"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e67e22"
                    }
                    
                    Text {
                        text: "智能出题与练习管理"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#e67e22"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "开始练习"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "新题库: 120题"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 数据分析卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#f5fff9"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开数据分析页面
                        console.log("打开数据分析页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "学习分析"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#27ae60"
                    }
                    
                    Text {
                        text: "个人学习数据与统计"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#27ae60"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "查看报告"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "上周进步: 15%"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 错题本卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#fff5f5"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开错题本页面
                        console.log("打开错题本页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "错题本"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e74c3c"
                    }
                    
                    Text {
                        text: "错题集中复习与记录"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#e74c3c"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "开始复习"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "未复习: 23题"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 题型练习卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#f5f5ff"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开题型练习页面
                        console.log("打开题型练习页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "题型练习"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#9b59b6"
                    }
                    
                    Text {
                        text: "专项题型训练与提高"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#9b59b6"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "开始训练"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "推荐: 计算题"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
            
            // 学习资源卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#f5ffff"
                border.color: "#e0e0e0"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 打开学习资源页面
                        console.log("打开学习资源页面")
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "学习资源"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#3498db"
                    }
                    
                    Text {
                        text: "辅助学习材料与资源"
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#3498db"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "浏览资源"
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "新增: 5份资料"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                    }
                }
            }
        }
    }
} 