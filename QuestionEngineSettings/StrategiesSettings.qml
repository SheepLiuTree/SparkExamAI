import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: strategiesSettingsPage
    color: "transparent"
    
    property var strategies: [
        { id: 1, name: "知识点全覆盖", active: true, description: "确保所有重要知识点均被覆盖，适合系统复习" },
        { id: 2, name: "薄弱点强化", active: false, description: "根据学生历史答题情况，针对薄弱知识点进行强化训练" },
        { id: 3, name: "重点题型练习", active: true, description: "集中练习某一题型，提高特定解题能力" },
        { id: 4, name: "考前冲刺", active: false, description: "注重考点热点，提高应试能力" },
        { id: 5, name: "难度递进", active: true, description: "题目难度逐步提升，培养解题信心" },
        { id: 6, name: "错题重现", active: false, description: "重复错题，直到掌握" }
    ]
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "出题策略"
            font.pixelSize: 20
            font.bold: true
            color: "#333333"
            Layout.bottomMargin: 10
        }
        
        Text {
            text: "配置智能出题的策略，系统将根据选定的策略组合生成题目"
            font.pixelSize: 14
            color: "#666666"
            Layout.bottomMargin: 20
        }
        
        GridLayout {
            columns: 2
            columnSpacing: 20
            rowSpacing: 20
            Layout.fillWidth: true
            
            Repeater {
                model: strategies
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 6
                    color: modelData.active ? "#f5f9ff" : "#ffffff"
                    border.color: modelData.active ? "#2c70b7" : "#e0e0e0"
                    border.width: 1
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // 切换策略激活状态的逻辑
                            console.log("策略切换: " + modelData.name)
                        }
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Switch {
                                checked: modelData.active
                                onCheckedChanged: {
                                    // 切换状态处理逻辑
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#e0e0e0"
                        }
                        
                        Text {
                            text: modelData.description
                            font.pixelSize: 14
                            color: "#666666"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        
                        Button {
                            text: "配置参数"
                            implicitWidth: 100
                            implicitHeight: 36
                            
                            background: Rectangle {
                                color: modelData.active ? "#2c70b7" : "#f5f5f5"
                                border.color: modelData.active ? "#2c70b7" : "#d0d0d0"
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: modelData.active ? "white" : "#444444"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                // 打开配置对话框
                                configDialog.strategyId = modelData.id
                                configDialog.strategyName = modelData.name
                                configDialog.open()
                            }
                        }
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#f5f5f5"
            radius: 6
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                
                Image {
                    source: "qrc:/images/face_icon.png"
                    sourceSize.width: 32
                    sourceSize.height: 32
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    
                    Text {
                        visible: parent.status !== Image.Ready
                        text: "ℹ️"
                        font.pixelSize: 24
                        anchors.centerIn: parent
                    }
                }
                
                Text {
                    text: "提示：多种策略可以同时激活，系统将智能融合各策略进行出题。若需自定义策略，请点击右侧按钮。"
                    font.pixelSize: 14
                    color: "#666666"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "自定义策略"
                    implicitWidth: 120
                    implicitHeight: 36
                    
                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#2c70b7"
                        border.width: 1
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#2c70b7"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        // 打开自定义策略对话框
                        customStrategyDialog.open()
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 15
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "应用策略"
                implicitWidth: 120
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
                
                onClicked: {
                    // 应用策略逻辑
                    console.log("应用策略")
                }
            }
        }
    }
    
    // 策略配置对话框
    Dialog {
        id: configDialog
        title: "策略配置: " + strategyName
        modal: true
        width: 500
        height: 400
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property int strategyId: 0
        property string strategyName: ""
        
        contentItem: ColumnLayout {
            spacing: 20
            anchors.margins: 20
            
            Text {
                text: "调整 \"" + configDialog.strategyName + "\" 策略的参数设置"
                font.pixelSize: 14
                color: "#666666"
                Layout.fillWidth: true
            }
            
            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 15
                Layout.fillWidth: true
                
                Text {
                    text: "优先级:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                ComboBox {
                    model: ["高", "中", "低"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "触发频率:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                Slider {
                    from: 0
                    to: 100
                    value: 50
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
                
                Text {
                    text: "应用科目:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    CheckBox { text: "物理"; checked: true }
                    CheckBox { text: "化学"; checked: true }
                    CheckBox { text: "数学"; checked: true }
                    CheckBox { text: "生物"; checked: false }
                }
                
                Text {
                    text: "适用题型:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    CheckBox { text: "选择题"; checked: true }
                    CheckBox { text: "填空题"; checked: true }
                    CheckBox { text: "简答题"; checked: true }
                    CheckBox { text: "计算题"; checked: true }
                }
                
                Text {
                    text: "高级参数:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                Button {
                    text: "高级设置"
                    implicitWidth: 100
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
        
        footer: RowLayout {
            spacing: 10
            Layout.fillWidth: true
            anchors.margins: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "取消"
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
                
                onClicked: configDialog.reject()
            }
            
            Button {
                text: "保存"
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
                
                onClicked: configDialog.accept()
            }
        }
    }
    
    // 自定义策略对话框
    Dialog {
        id: customStrategyDialog
        title: "自定义策略"
        modal: true
        width: 500
        height: 450
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        contentItem: ColumnLayout {
            spacing: 20
            anchors.margins: 20
            
            Text {
                text: "创建新的出题策略"
                font.pixelSize: 14
                color: "#666666"
                Layout.fillWidth: true
            }
            
            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 15
                Layout.fillWidth: true
                
                Text {
                    text: "策略名称:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextField {
                    placeholderText: "输入策略名称"
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "策略描述:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextArea {
                    placeholderText: "输入策略描述"
                    wrapMode: TextArea.Wrap
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
                
                Text {
                    text: "构建规则:"
                    font.pixelSize: 14
                    color: "#333333"
                    Layout.alignment: Qt.AlignTop
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    ComboBox {
                        model: ["按知识点分布", "按题型分布", "按难度分布", "按错题率分布"]
                        Layout.fillWidth: true
                    }
                    
                    ComboBox {
                        model: ["优先最近学习内容", "优先薄弱环节", "平均分布", "自定义权重"]
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "添加规则"
                        implicitWidth: 100
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
        
        footer: RowLayout {
            spacing: 10
            Layout.fillWidth: true
            anchors.margins: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "取消"
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
                
                onClicked: customStrategyDialog.reject()
            }
            
            Button {
                text: "创建"
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
                
                onClicked: customStrategyDialog.accept()
            }
        }
    }
} 