import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: questionCollectionContent
    color: "transparent"
    
    property string userName: "管理员"
    property var questionBanks: []
    property var userData: ({})
    
    // 检测userData变化
    onUserDataChanged: {
        if (userData && userData.name) {
            userName = userData.name
            console.log("题集速录内容已接收用户数据: " + userName)
        }
    }
    
    // 初始化时从数据库加载题库
    Component.onCompleted: {
        loadQuestionBanks()
        
        // 如果已经有userData，则更新userName
        if (userData && userData.name) {
            userName = userData.name
            console.log("题集速录内容初始化完成，用户名: " + userName)
        }
    }
    
    // 从数据库加载题库
    function loadQuestionBanks() {
        questionBanks = dbManager.getAllQuestionBanks()
    }
    
    // 主内容区域
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "#33ffffff"
        radius: 8
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // 功能按钮区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#33ffffff"
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20
                    
                    Text {
                        text: "题库管理工具:"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                    
                    // 模板下载按钮
                    Button {
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 50
                        
                        background: Rectangle {
                            color: "#9C27B0"
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: "下载模板"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            // 打开文件夹选择对话框
                            folderSelectionDialog.open()
                        }
                    }
                    
                    // 批量导入按钮
                    Button {
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 50
                        
                        background: Rectangle {
                            color: "#2196F3"
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: "批量导入"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            // 显示批量导入对话框
                            batchImportDialog.open()
                        }
                    }
                    
                    // 占位
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    // 搜索框
                    TextField {
                        Layout.preferredWidth: 200
                        placeholderText: "搜索题库..."
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: "#99ffffff"
                            radius: 4
                            border.color: "#cccccc"
                            border.width: 1
                        }
                    }
                }
            }
            
            // 标题栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#4477aaee"
                radius: 5
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 10
                    
                    Text {
                        Layout.preferredWidth: 60
                        text: "操作"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: "题库名称"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
color: "white"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        Layout.preferredWidth: 100
                        text: "题目数量"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        Layout.preferredWidth: 120
                        text: "创建时间"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            // 题库列表
            ListView {
                id: questionBankList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                model: questionBanks
                
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: index % 2 === 0 ? "#22ffffff" : "#11ffffff"
                    border.color: "#33ffffff"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10
                        
                        // 操作按钮
                        RowLayout {
                            Layout.preferredWidth: 60
                            spacing: 5
                            
                            Button {
                                Layout.preferredWidth: 25
                                Layout.preferredHeight: 25
                                
                                background: Rectangle {
                                    color: "#4CAF50"
                                    radius: 3
                                }
                                
                                contentItem: Text {
                                    text: "✓"
                                    font.pixelSize: 12
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    console.log("选择题库: " + modelData.name)
                                }
                            }
                            
                            Button {
                                Layout.preferredWidth: 25
                                Layout.preferredHeight: 25
                                
                                background: Rectangle {
                                    color: "#F44336"
                                    radius: 3
                                }
                                
                                contentItem: Text {
                                    text: "×"
                                    font.pixelSize: 12
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    console.log("删除题库: " + modelData.name)
                                }
                            }
                        }
                        
                        // 题库名称
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name || "未命名题库"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            elide: Text.ElideRight
                        }
                        
                        // 题目数量
                        Text {
                            Layout.preferredWidth: 100
                            text: modelData.questionCount || "0"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        // 创建时间
                        Text {
                            Layout.preferredWidth: 120
                            text: modelData.createdAt || "未知"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
    
    // 文件夹选择对话框
    FileDialog {
        id: folderSelectionDialog
        title: "选择保存位置"
        folder: shortcuts.home
        selectFolder: true
        onAccepted: {
            console.log("选择文件夹: " + folder)
            // 这里可以添加模板下载逻辑
        }
    }
    
    // 批量导入对话框
    FileDialog {
        id: batchImportDialog
        title: "选择Excel文件"
        folder: shortcuts.home
        nameFilters: ["Excel文件 (*.xlsx *.xls)", "所有文件 (*)"]
        onAccepted: {
            console.log("选择文件: " + fileUrl)
            // 这里可以添加批量导入逻辑
        }
    }
}