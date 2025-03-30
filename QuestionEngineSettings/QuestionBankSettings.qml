import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: questionBankSettingsPage
    color: "transparent"
    
    property var questionBanks: [
        { id: 1, name: "高中物理题库", count: 1200, active: true, lastUpdate: "2023-05-15" },
        { id: 2, name: "高中化学题库", count: 950, active: true, lastUpdate: "2023-06-10" },
        { id: 3, name: "高中数学题库", count: 1500, active: true, lastUpdate: "2023-04-22" },
        { id: 4, name: "高中生物题库", count: 850, active: false, lastUpdate: "2023-03-18" },
        { id: 5, name: "高中英语题库", count: 1320, active: true, lastUpdate: "2023-06-25" },
        { id: 6, name: "高中语文题库", count: 1100, active: true, lastUpdate: "2023-05-30" }
    ]
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "题库管理"
                font.pixelSize: 20
                font.bold: true
                color: "#333333"
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "导入题库"
                implicitWidth: 100
                implicitHeight: 36
                
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
                
                onClicked: fileDialog.open()
            }
            
            Button {
                text: "新建题库"
                implicitWidth: 100
                implicitHeight: 36
                
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
                
                onClicked: newBankDialog.open()
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#f0f0f0"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                
                Text {
                    text: "题库名称"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444444"
                    Layout.preferredWidth: 200
                }
                
                Text {
                    text: "题目数量"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444444"
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    text: "状态"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444444"
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    text: "最后更新"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444444"
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    text: "操作"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444444"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        
        ListView {
            id: bankListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: questionBanks
            
            delegate: Rectangle {
                width: bankListView.width
                height: 60
                color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    
                    Text {
                        text: modelData.name
                        font.pixelSize: 14
                        color: "#333333"
                        Layout.preferredWidth: 200
                    }
                    
                    Text {
                        text: modelData.count
                        font.pixelSize: 14
                        color: "#333333"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 26
                        color: modelData.active ? "#e6f7e6" : "#f7e6e6"
                        radius: 13
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.active ? "已启用" : "已禁用"
                            font.pixelSize: 12
                            color: modelData.active ? "#4caf50" : "#f44336"
                        }
                    }
                    
                    Text {
                        text: modelData.lastUpdate
                        font.pixelSize: 14
                        color: "#666666"
                        Layout.preferredWidth: 120
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            text: modelData.active ? "禁用" : "启用"
                            flat: true
                            implicitWidth: 60
                            implicitHeight: 30
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: modelData.active ? "#f44336" : "#4caf50"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            text: "编辑"
                            flat: true
                            implicitWidth: 60
                            implicitHeight: 30
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#2196f3"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            text: "删除"
                            flat: true
                            implicitWidth: 60
                            implicitHeight: 30
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#f44336"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
    
    FileDialog {
        id: fileDialog
        title: "选择题库文件"
        nameFilters: ["Excel 文件 (*.xlsx)", "CSV 文件 (*.csv)", "JSON 文件 (*.json)"]
        selectMultiple: false
        
        onAccepted: {
            console.log("选择的文件: " + fileDialog.fileUrl)
            // 处理文件导入逻辑
        }
    }
    
    Dialog {
        id: newBankDialog
        title: "新建题库"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400
        height: 250
        modal: true
        closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
        
        contentItem: ColumnLayout {
            spacing: 15
            anchors.margins: 20
            
            Text {
                text: "请输入题库信息"
                font.pixelSize: 16
                color: "#333333"
            }
            
            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 15
                
                Text {
                    text: "题库名称:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                TextField {
                    id: bankNameField
                    placeholderText: "请输入题库名称"
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "科目类别:"
                    font.pixelSize: 14
                    color: "#333333"
                }
                
                ComboBox {
                    id: subjectComboBox
                    model: ["物理", "化学", "数学", "生物", "英语", "语文", "历史", "地理", "政治"]
                    Layout.fillWidth: true
                }
            }
        }
        
        onAccepted: {
            console.log("新建题库: " + bankNameField.text + ", 科目: " + subjectComboBox.currentText)
            // 处理新建题库逻辑
        }
    }
} 