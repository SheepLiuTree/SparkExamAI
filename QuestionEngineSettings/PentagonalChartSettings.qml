import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pentagonalChartSettingsPage
    color: "transparent"
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    
    // 五芒图相关属性
    property var pentagonTitles: ["基础认知", "原理理解", "操作应用", "诊断分析", "安全规范"]
    
    Component.onCompleted: {
        // 从数据库加载设置
        loadSettings()
    }
    
    // 加载设置
    function loadSettings() {
        // 从数据库加载五芒图的标题
        var title1 = dbManager.getSetting("pentagon_title_1", "基础认知")
        var title2 = dbManager.getSetting("pentagon_title_2", "原理理解")
        var title3 = dbManager.getSetting("pentagon_title_3", "操作应用")
        var title4 = dbManager.getSetting("pentagon_title_4", "诊断分析")
        var title5 = dbManager.getSetting("pentagon_title_5", "安全规范")
        
        pentagonTitles = [title1, title2, title3, title4, title5]
        
        // 更新输入框
        titleField1.text = pentagonTitles[0]
        titleField2.text = pentagonTitles[1]
        titleField3.text = pentagonTitles[2]
        titleField4.text = pentagonTitles[3]
        titleField5.text = pentagonTitles[4]
    }
    
    // 保存设置
    function saveSettings() {
        // 将五个标题保存到数据库
        dbManager.setSetting("pentagon_title_1", pentagonTitles[0])
        dbManager.setSetting("pentagon_title_2", pentagonTitles[1])
        dbManager.setSetting("pentagon_title_3", pentagonTitles[2])
        dbManager.setSetting("pentagon_title_4", pentagonTitles[3])
        dbManager.setSetting("pentagon_title_5", pentagonTitles[4])
        
        // 显示成功消息
        statusMessage = "五芒图配置已保存"
        isSuccess = true
        statusUpdateTimer.restart()
    }
    
    // 状态更新计时器
    Timer {
        id: statusUpdateTimer
        interval: 3000
        onTriggered: {
            statusMessage = ""
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: settingsColumn.height
            clip: true
            
            ColumnLayout {
                id: settingsColumn
                width: parent.width
                spacing: 25
                
                // 五芒图设置区域
                Rectangle {
                    Layout.fillWidth: true
                    height: 630
                    color: "#44ffffff"
                    radius: 10
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        
                        Text {
                            text: "五芒图设置"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                            Layout.bottomMargin: 0
                        }
                        
                        // 自定义五芒图各顶点显示的名称
                        Text {
                            id: descriptionText
                            text: "自定义五芒图各顶点显示的名称"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                            opacity: 0.8
                            Layout.bottomMargin: 5
                        }
                        
                        // 五芒图预览
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 230
                            Layout.topMargin: 0
                            Layout.bottomMargin: 0
                            clip: false
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: Math.min(parent.width * 0.85, 500)
                                height: width
                                color: "transparent"
                                clip: false
                                
                                // 绘制五芒图
                                Canvas {
                                    id: pentagonCanvas
                                    anchors.centerIn: parent
                                    width: parent.width * 0.8
                                    height: width
                                    clip: false
                                    
                                    // 图例数据 - 示例值
                                    property var dataValues: [0.8, 0.6, 0.9, 0.7, 0.5]
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        
                                        var centerX = width / 2
                                        var centerY = height / 2
                                        var radius = Math.min(width, height) / 2 - 80
                                        var angleStep = Math.PI * 2 / 5
                                        
                                        // 绘制五边形网格 (3层)
                                        for (var layer = 1; layer <= 3; layer++) {
                                            var layerRadius = radius * layer / 3
                                            ctx.beginPath()
                                            for (var i = 0; i <= 5; i++) {
                                                var angle = -Math.PI / 2 + i * angleStep
                                                var x = centerX + layerRadius * Math.cos(angle)
                                                var y = centerY + layerRadius * Math.sin(angle)
                                                if (i === 0) {
                                                    ctx.moveTo(x, y)
                                                } else {
                                                    ctx.lineTo(x, y)
                                                }
                                            }
                                            ctx.closePath()
                                            ctx.strokeStyle = "rgba(255, 255, 255, 0.3)"
                                            ctx.lineWidth = 1
                                            ctx.stroke()
                                        }
                                        
                                        // 绘制从中心到顶点的辐射线
                                        for (var i = 0; i < 5; i++) {
                                            var angle = -Math.PI / 2 + i * angleStep
                                            var x = centerX + radius * Math.cos(angle)
                                            var y = centerY + radius * Math.sin(angle)
                                            ctx.beginPath()
                                            ctx.moveTo(centerX, centerY)
                                            ctx.lineTo(x, y)
                                            ctx.strokeStyle = "rgba(255, 255, 255, 0.3)"
                                            ctx.lineWidth = 1
                                            ctx.stroke()
                                        }
                                        
                                        // 绘制数据图形
                                        ctx.beginPath()
                                        for (var i = 0; i < 5; i++) {
                                            var angle = -Math.PI / 2 + i * angleStep
                                            var value = dataValues[i]
                                            var x = centerX + radius * value * Math.cos(angle)
                                            var y = centerY + radius * value * Math.sin(angle)
                                            if (i === 0) {
                                                ctx.moveTo(x, y)
                                            } else {
                                                ctx.lineTo(x, y)
                                            }
                                        }
                                        ctx.closePath()
                                        ctx.fillStyle = "rgba(44, 112, 183, 0.3)"
                                        ctx.fill()
                                        ctx.strokeStyle = "rgba(44, 112, 183, 0.8)"
                                        ctx.lineWidth = 2
                                        ctx.stroke()
                                        
                                        // 绘制顶点标签
                                        ctx.fillStyle = "white"
                                        ctx.font = "bold 16px 阿里妈妈数黑体"
                                        
                                        // 文本位置计算 - 使用更大的偏移距离，确保文字不被裁切
                                        var positions = [
                                            { x: centerX, y: centerY - radius - 20, align: "center", baseline: "bottom" },          // 上
                                            { x: centerX + radius + 10, y: centerY - radius * 0.35, align: "left", baseline: "middle" },  // 右上
                                            { x: centerX + radius - 10, y: centerY + radius * 0.7, align: "left", baseline: "middle" },  // 右下
                                            { x: centerX - radius + 10, y: centerY + radius * 0.7, align: "right", baseline: "middle" }, // 左下
                                            { x: centerX - radius - 10, y: centerY - radius * 0.35, align: "right", baseline: "middle" }  // 左上
                                        ];
                                        
                                        // 先绘制文字阴影，增强可读性
                                        ctx.shadowColor = "rgba(0, 0, 0, 0.7)"
                                        ctx.shadowBlur = 3
                                        ctx.shadowOffsetX = 1
                                        ctx.shadowOffsetY = 1
                                        
                                        // 直接绘制文本
                                        for (var i = 0; i < 5; i++) {
                                            var pos = positions[i];
                                            ctx.textAlign = pos.align;
                                            ctx.textBaseline = pos.baseline;
                                            ctx.fillText(pentagonTitles[i], pos.x, pos.y);
                                        }
                                        
                                        // 重置阴影
                                        ctx.shadowColor = "transparent"
                                    }
                                }
                            }
                        }
                        
                        // 输入框区域标题
                        Text {
                            text: "设置各点标题"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.topMargin: 0
                            Layout.bottomMargin: 5
                        }
                        
                        // 五个标题的设置
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 15
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.bottomMargin: 10
                            
                            // 标题1
                            Text {
                                text: "第一点:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                color: "#22ffffff"
                                radius: 5
                                
                                TextField {
                                    id: titleField1
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: pentagonTitles[0]
                                    color: "white"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    placeholderText: "请输入第一点标题"
                                    placeholderTextColor: "#cccccc"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: {
                                        pentagonTitles[0] = text
                                        pentagonCanvas.requestPaint()
                                    }
                                }
                            }
                            
                            // 标题2
                            Text {
                                text: "第二点:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                color: "#22ffffff"
                                radius: 5
                                
                                TextField {
                                    id: titleField2
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: pentagonTitles[1]
                                    color: "white"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    placeholderText: "请输入第二点标题"
                                    placeholderTextColor: "#cccccc"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: {
                                        pentagonTitles[1] = text
                                        pentagonCanvas.requestPaint()
                                    }
                                }
                            }
                            
                            // 标题3
                            Text {
                                text: "第三点:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                color: "#22ffffff"
                                radius: 5
                                
                                TextField {
                                    id: titleField3
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: pentagonTitles[2]
                                    color: "white"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    placeholderText: "请输入第三点标题"
                                    placeholderTextColor: "#cccccc"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: {
                                        pentagonTitles[2] = text
                                        pentagonCanvas.requestPaint()
                                    }
                                }
                            }
                            
                            // 标题4
                            Text {
                                text: "第四点:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                color: "#22ffffff"
                                radius: 5
                                
                                TextField {
                                    id: titleField4
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: pentagonTitles[3]
                                    color: "white"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    placeholderText: "请输入第四点标题"
                                    placeholderTextColor: "#cccccc"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: {
                                        pentagonTitles[3] = text
                                        pentagonCanvas.requestPaint()
                                    }
                                }
                            }
                            
                            // 标题5
                            Text {
                                text: "第五点:"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                color: "#22ffffff"
                                radius: 5
                                
                                TextField {
                                    id: titleField5
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: pentagonTitles[4]
                                    color: "white"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    placeholderText: "请输入第五点标题"
                                    placeholderTextColor: "#cccccc"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: {
                                        pentagonTitles[4] = text
                                        pentagonCanvas.requestPaint()
                                    }
                                }
                            }
                        }
                        
                        // 保存按钮
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.bottomMargin: 0
                            
                            Button {
                                anchors.right: parent.right
                                width: 120
                                height: 38
                                background: Rectangle {
                                    color: "#2c70b7"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: "保存设置"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 18
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    saveSettings()
                                }
                            }
                        }
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
                }
            }
        }
    }
} 