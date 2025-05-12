import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtCore

Rectangle {
    id: knowledgePointSettingsPage
    color: "transparent"
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    
    // 智点配置
    property int switchInterval: 7  // 默认7秒
    property var knowledgePoints: []  // 智点列表
    
    // 模板下载对话框
    FileDialog {
        id: folderDialog
        title: "请选择保存模板的文件夹"
        fileMode: FileDialog.OpenDirectory
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        
        onAccepted: {
            var folderPath = folderDialog.selectedFolder.toString()
            // 移除 file:/// 前缀
            folderPath = folderPath.replace(/^(file:\/{3})/,"")
            // 解码 URL 编码的路径
            folderPath = decodeURIComponent(folderPath)
            
            // 获取当前时间戳
            var now = new Date()
            var timestamp = now.getFullYear() + 
                           ("0" + (now.getMonth() + 1)).slice(-2) + 
                           ("0" + now.getDate()).slice(-2) + "_" + 
                           ("0" + now.getHours()).slice(-2) + 
                           ("0" + now.getMinutes()).slice(-2) + 
                           ("0" + now.getSeconds()).slice(-2)
            
            // 构建目标文件名
            var targetFileName = "智点模板_" + timestamp + ".xlsx"
            var targetPath = folderPath + "/" + targetFileName
            
            // 复制文件
            var appDir = fileManager.getApplicationDir()
            var sourcePath = appDir + "/templates/智点模板.xlsx"
            var success = fileManager.copyFile(sourcePath, targetPath)
            
            if (success) {
                statusMessage = "模板已成功保存到: " + targetPath
                isSuccess = true
            } else {
                statusMessage = "模板保存失败，请重试"
                isSuccess = false
            }
        }
    }
    
    // 导入智点文件对话框
    FileDialog {
        id: importDialog
        title: "请选择智点Excel文件"
        fileMode: FileDialog.OpenFile
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        nameFilters: ["Excel文件 (*.xlsx *.xls)"]
        
        onAccepted: {
            var filePath = importDialog.selectedFile.toString()
            // 移除 file:/// 前缀
            filePath = filePath.replace(/^(file:\/{3})/,"")
            // 解码 URL 编码的路径
            filePath = decodeURIComponent(filePath)
            
            console.log("导入文件:", filePath)
            
            // 验证Excel文件格式
            if (!fileManager.validateKnowledgePointExcelStructure(filePath)) {
                statusMessage = "Excel文件格式错误，请使用正确的智点模板"
                isSuccess = false
                return
            }
            
            // 读取Excel数据
            var excelData = fileManager.readExcelFile(filePath)
            
            if (excelData.length === 0) {
                statusMessage = "Excel文件中没有有效数据"
                isSuccess = false
                return
            }
            
            // 导入到数据库
            var importResult = dbManager.importKnowledgePoints(excelData)
            
            if (importResult) {
                // 刷新智点列表
                var tempPoints = dbManager.getAllKnowledgePoints()
                knowledgePoints = tempPoints
                
                // 重新绑定列表模型刷新显示
                knowledgePointListView.model = null
                knowledgePointListView.model = knowledgePoints
                
                statusMessage = "成功导入智点数据"
                isSuccess = true
            } else {
                statusMessage = "导入失败，请检查Excel文件格式或内容"
                isSuccess = false
            }
        }
    }
    
    Component.onCompleted: {
        // 从数据库加载设置
        loadSettings()
        
        // 加载智点列表
        loadKnowledgePoints()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // 智点配置区
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#44ffffff"
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                Text {
                    text: "智点配置"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                }
                
                // 切换间隔设置
                RowLayout {
                    Layout.fillWidth: true
                    height: 40
                    spacing: 10
                    
                    Text {
                        text: "切换间隔:"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Slider {
                            id: intervalSlider
                            from: 1
                            to: 30
                            value: switchInterval
                            stepSize: 1
                            Layout.fillWidth: true
                            
                            onValueChanged: {
                                switchInterval = value
                            }
                            
                            background: Rectangle {
                                x: intervalSlider.leftPadding
                                y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                width: intervalSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#88ffffff"
                                
                                Rectangle {
                                    width: intervalSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#2c70b7"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: intervalSlider.leftPadding + intervalSlider.visualPosition * (intervalSlider.availableWidth - width)
                                y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: intervalSlider.pressed ? "#1e5b94" : "#2c70b7"
                                border.color: "#2c70b7"
                            }
                        }
                        
                        Text {
                            text: switchInterval + "秒"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
        
        // 智点列表区
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#44ffffff"
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                // 标题和导入按钮行
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "智点列表"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // 下载模板按钮
                    Button {
                        text: "下载模板"
                        implicitWidth: 120
                        implicitHeight: 30
                        
                        background: Rectangle {
                            color: "#2c70b7"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            folderDialog.open()
                        }
                    }
                    
                    // 清空列表按钮
                    Button {
                        text: "清空列表"
                        implicitWidth: 120
                        implicitHeight: 30
                        
                        background: Rectangle {
                            color: "#cc3333"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            clearAllKnowledgePoints()
                        }
                    }
                    
                    // 智点导入按钮
                    Button {
                        text: "导入智点"
                        implicitWidth: 120
                        implicitHeight: 30
                        
                        background: Rectangle {
                            color: "#2c70b7"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            importDialog.open()
                        }
                    }
                }
                
                // 表头
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#33ffffff"
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        // 操作列
                        Text {
                            text: "操作"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        // 标题列
                        Text {
                            text: "标题"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.preferredWidth: 120
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        // 智点列
                        Text {
                            text: "智点内容"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                // 智点列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    clip: true
                    
                    MouseArea {
                        anchors.fill: parent
                        onPressed: mouse.accepted = false
                        onReleased: mouse.accepted = false
                    }
                    
                    ListView {
                        id: knowledgePointListView
                        width: parent.width
                        height: parent.height
                        model: knowledgePoints
                        spacing: 8
                        interactive: true
                        
                        delegate: Rectangle {
                            width: knowledgePointListView.width - 20
                            height: 60
                            color: "#33ffffff"
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                // 操作列 - 删除按钮
                                Button {
                                    text: "删除"
                                    implicitWidth: 80
                                    implicitHeight: 30
                                    
                                    background: Rectangle {
                                        color: "#cc3333"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 14
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: {
                                        // 从数据库删除智点
                                        var success = dbManager.deleteKnowledgePoint(modelData.id)
                                        
                                        if (success) {
                                            // 重新加载智点列表
                                            knowledgePoints = dbManager.getAllKnowledgePoints()
                                            
                                            // 刷新列表
                                            knowledgePointListView.model = null
                                            knowledgePointListView.model = knowledgePoints
                                            
                                            statusMessage = "已删除智点：" + modelData.title
                                            isSuccess = true
                                        } else {
                                            statusMessage = "删除失败，请重试"
                                            isSuccess = false
                                        }
                                    }
                                }
                                
                                // 标题列
                                Text {
                                    text: modelData.title || "无标题"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    Layout.preferredWidth: 120
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                // 智点列
                                Text {
                                    text: modelData.content || "无内容"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 保存设置按钮
        Button {
            id: saveButton
            text: "保存设置"
            implicitWidth: 120
            implicitHeight: 30
            enabled: true
            Layout.alignment: Qt.AlignRight
            
            background: Rectangle {
                color: saveButton.enabled ? "#2c70b7" : "#666666"
                radius: 4
            }
            
            contentItem: Text {
                text: parent.text
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                saveSettings()
            }
        }
        
        // 状态信息显示
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: isSuccess ? "#3366cc33" : "#33cc3333"
            radius: 4
            visible: statusMessage !== ""
            
            Text {
                anchors.centerIn: parent
                text: statusMessage
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 14
                color: "white"
            }
            
            // 3秒后自动隐藏消息
            Timer {
                running: statusMessage !== ""
                interval: 3000
                onTriggered: {
                    statusMessage = ""
                }
            }
        }
    }
    
    // 从数据库加载设置
    function loadSettings() {
        // 加载切换间隔
        var interval = dbManager.getSetting("knowledge_point_switch_interval", "7")
        switchInterval = parseInt(interval)
        
        console.log("已从数据库加载智点设置")
    }
    
    // 加载智点列表
    function loadKnowledgePoints() {
        // 从数据库获取智点列表
        knowledgePoints = dbManager.getAllKnowledgePoints()
        
        if (knowledgePoints.length === 0) {
            // 没有数据，直接显示空列表
            console.log("智点列表为空")
        }
        
        console.log("已加载智点列表, 共", knowledgePoints.length, "个智点")
    }
    
    // 保存设置
    function saveSettings() {
        // 保存切换间隔
        var intervalSuccess = dbManager.setSetting("knowledge_point_switch_interval", switchInterval.toString())
        
        if (intervalSuccess) {
            statusMessage = "保存成功！设置已存入数据库"
            isSuccess = true
            console.log("成功保存智点设置")
        } else {
            statusMessage = "保存失败，请重试"
            isSuccess = false
            console.error("保存设置失败")
        }
    }
    
    // 清空所有智点
    function clearAllKnowledgePoints() {
        // 从数据库清空所有智点
        var success = dbManager.clearAllKnowledgePoints()
        
        if (success) {
            // 清空本地列表
            knowledgePoints = []
            
            // 刷新列表
            knowledgePointListView.model = null
            knowledgePointListView.model = knowledgePoints
            
            statusMessage = "已清空所有智点"
            isSuccess = true
            console.log("已清空所有智点")
        } else {
            statusMessage = "清空失败，请重试"
            isSuccess = false
            console.error("清空智点列表失败")
        }
    }
} 