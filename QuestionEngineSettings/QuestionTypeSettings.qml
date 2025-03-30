import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: questionTypeSettingsPage
    color: "transparent"
    
    property var questionTypes: [
        { id: 1, name: "选择题", enabled: true, difficulty: 3, timeLimit: 60, scoreWeight: 1.0, description: "包含单选和多选题型，考察基础知识掌握情况" },
        { id: 2, name: "填空题", enabled: true, difficulty: 4, timeLimit: 90, scoreWeight: 1.2, description: "需要填写特定内容，考察关键概念记忆能力" },
        { id: 3, name: "简答题", enabled: true, difficulty: 4, timeLimit: 300, scoreWeight: 1.5, description: "需要简要回答问题，考察对知识点的理解和应用" },
        { id: 4, name: "计算题", enabled: true, difficulty: 5, timeLimit: 360, scoreWeight: 1.8, description: "需要进行数学计算并给出过程，考察解题能力" },
        { id: 5, name: "实验题", enabled: false, difficulty: 4, timeLimit: 240, scoreWeight: 1.6, description: "分析或设计实验，考察实验能力和科学思维" },
        { id: 6, name: "综合题", enabled: true, difficulty: 5, timeLimit: 420, scoreWeight: 2.0, description: "结合多个知识点，考察综合分析和应用能力" }
    ]
    
    property var difficultyLabels: ["非常简单", "简单", "中等", "较难", "困难"]
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "题型设置"
            font.pixelSize: 20
            font.bold: true
            color: "#333333"
            Layout.bottomMargin: 10
        }
        
        Text {
            text: "调整各题型在出题策略中的参数设置，包括启用状态、难度系数、时间限制和分数权重"
            font.pixelSize: 14
            color: "#666666"
            Layout.bottomMargin: 10
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            Column {
                width: parent.width
                spacing: 20
                
                Repeater {
                    model: questionTypes
                    
                    Rectangle {
                        width: parent.width
                        height: 200
                        radius: 6
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#333333"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Switch {
                                    checked: modelData.enabled
                                    text: checked ? "已启用" : "已禁用"
                                }
                            }
                            
                            Text {
                                text: modelData.description
                                font.pixelSize: 14
                                color: "#666666"
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                Layout.bottomMargin: 10
                            }
                            
                            GridLayout {
                                columns: 2
                                rowSpacing: 15
                                columnSpacing: 20
                                Layout.fillWidth: true
                                
                                // 难度系数
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    RowLayout {
                                        Text {
                                            text: "难度系数:"
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }
                                        
                                        Text {
                                            text: difficultyLabels[modelData.difficulty - 1]
                                            font.pixelSize: 14
                                            color: "#2c70b7"
                                            font.bold: true
                                        }
                                    }
                                    
                                    Slider {
                                        from: 1
                                        to: 5
                                        stepSize: 1
                                        value: modelData.difficulty
                                        Layout.fillWidth: true
                                        
                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            width: parent.availableWidth
                                            height: 4
                                            radius: 2
                                            color: "#e0e0e0"
                                            
                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#2c70b7"
                                                radius: 2
                                            }
                                        }
                                        
                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: parent.pressed ? "#1e5b94" : "#2c70b7"
                                            border.color: "#2c70b7"
                                        }
                                    }
                                }
                                
                                // 时间限制
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    RowLayout {
                                        Text {
                                            text: "时间限制:"
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }
                                        
                                        Text {
                                            text: modelData.timeLimit + " 秒"
                                            font.pixelSize: 14
                                            color: "#2c70b7"
                                            font.bold: true
                                        }
                                    }
                                    
                                    SpinBox {
                                        from: 10
                                        to: 600
                                        stepSize: 10
                                        value: modelData.timeLimit
                                        Layout.fillWidth: true
                                        
                                        contentItem: TextInput {
                                            text: parent.textFromValue(parent.value, parent.locale)
                                            anchors.right: parent.right
                                            anchors.rightMargin: 40
                                            anchors.verticalCenter: parent.verticalCenter
                                            font.pixelSize: 14
                                            color: "#333333"
                                            selectByMouse: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            validator: parent.validator
                                        }
                                    }
                                }
                                
                                // 分数权重
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    RowLayout {
                                        Text {
                                            text: "分数权重:"
                                            font.pixelSize: 14
                                            color: "#333333"
                                        }
                                        
                                        Text {
                                            text: modelData.scoreWeight.toFixed(1) + "x"
                                            font.pixelSize: 14
                                            color: "#2c70b7"
                                            font.bold: true
                                        }
                                    }
                                    
                                    Slider {
                                        from: 0.5
                                        to: 3.0
                                        stepSize: 0.1
                                        value: modelData.scoreWeight
                                        Layout.fillWidth: true
                                        
                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            width: parent.availableWidth
                                            height: 4
                                            radius: 2
                                            color: "#e0e0e0"
                                            
                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#2c70b7"
                                                radius: 2
                                            }
                                        }
                                        
                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: parent.pressed ? "#1e5b94" : "#2c70b7"
                                            border.color: "#2c70b7"
                                        }
                                    }
                                }
                                
                                // 高级设置按钮
                                Button {
                                    text: "高级设置"
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    
                                    background: Rectangle {
                                        color: "#f5f5f5"
                                        border.color: "#d0d0d0"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        color: "#444444"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 底部额外空间
                Item {
                    width: parent.width
                    height: 20
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 15
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "恢复默认"
                implicitWidth: 100
                implicitHeight: 40
                
                background: Rectangle {
                    color: "#f0f0f0"
                    border.color: "#d0d0d0"
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "#444444"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "保存设置"
                implicitWidth: 100
                implicitHeight: 40
                
                background: Rectangle {
                    color: "#2c70b7"
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
} 