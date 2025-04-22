import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pentagonalChartSettingsPage
    color: "transparent"
    
    // 通用题库归类弹窗组件
    Component {
        id: categoryPopupComponent
        
        Popup {
            id: categoryPopup
            width: 280
            height: Math.min(360, contentColumn.implicitHeight + 50)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            padding: 15
            closePolicy: Popup.CloseOnEscape  // 只允许通过ESC键关闭
            
            property int pointIndex: 0
            
            Component.onCompleted: {
                // 确保pentagonCategories和questionBanks已初始化
                if (!pentagonalChartSettingsPage.pentagonCategories || 
                    !Array.isArray(pentagonalChartSettingsPage.pentagonCategories) || 
                    pentagonalChartSettingsPage.pentagonCategories.length < 5) {
                    console.warn("pentagonCategories未正确初始化，正在重置");
                    pentagonalChartSettingsPage.pentagonCategories = [{}, {}, {}, {}, {}];
                }
                
                if (!pentagonalChartSettingsPage.questionBanks) {
                    console.warn("questionBanks未初始化，正在重置为空数组");
                    pentagonalChartSettingsPage.questionBanks = [];
                }
            }
            
            background: Rectangle {
                color: "#2c3e50"
                radius: 8
                border.color: "#3498db"
                border.width: 1
            }
            
            contentItem: Item {
                id: dialogContent
                implicitHeight: contentColumn.implicitHeight
            
                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: 12
                    
                    Text {
                        text: {
                            // 安全处理标题文本，避免undefined
                            var pointLabel = "第" + (pointIndex + 1) + "点";
                            if (!pentagonTitles || !Array.isArray(pentagonTitles) || 
                                pointIndex < 0 || pointIndex >= pentagonTitles.length) {
                                return "选择归类到\"" + pointLabel + "\"的题库：";
                            }
                            
                            // 避免可选链操作的使用
                            var title = null;
                            if (pentagonTitles && pentagonTitles[pointIndex] !== undefined) {
                                title = pentagonTitles[pointIndex];
                            }
                            
                            // 确保title是字符串且不为空
                            if (title && typeof title === 'string' && title.trim()) {
                                return "选择归类到\"" + title + "\"的题库：";
                            } else {
                                return "选择归类到\"" + pointLabel + "\"的题库：";
                            }
                        }
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "#ecf0f1"
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250
                        // 避免使用可选链
                        ScrollBar.horizontal { policy: ScrollBar.AlwaysOff }
                        clip: true
                        
                        Column {
                            width: parent.width
                            spacing: 5
                            
                            Repeater {
                                model: questionBanks || []
                                
                                CheckBox {
                                    width: parent.width
                                    text: {
                                        // 完全重写text属性逻辑，确保总是返回一个有效的字符串
                                        if (!modelData) return "";
                                        if (typeof modelData !== 'object') return String(modelData);
                                        if (modelData.name === undefined || modelData.name === null) return "";
                                        // 确保返回字符串类型
                                        return String(modelData.name);
                                    }
                                    checked: {
                                        // 安全处理checked状态，避免undefined
                                        if (!modelData || !modelData.id || !pentagonCategories || 
                                            !pentagonCategories[pointIndex]) {
                                            return false;
                                        }
                                        return pentagonCategories[pointIndex][modelData.id] === true;
                                    }
                                    enabled: {
                                        // 安全处理enabled状态，避免undefined
                                        if (!modelData || !modelData.id || !pentagonCategories ||
                                            !pentagonCategories[pointIndex]) {
                                            return false;
                                        }
                                        
                                        // 检查是否分配给其他点
                                        var otherPoint = isBankAssignedToOtherPoint(modelData.id, pointIndex);
                                        return otherPoint === 0; // 只有未分配给其他点时才启用
                                    }
                                    padding: 2
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        x: parent.leftPadding
                                        y: parent.height / 2 - height / 2
                                        radius: 3
                                        color: parent.enabled ? (parent.checked ? "#2980b9" : "#34495e") : "#555555"
                                        border.color: parent.enabled ? (parent.checked ? "#3498db" : "#7f8c8d") : "#7f8c8d"
                                        
                                        Rectangle {
                                            visible: parent.parent.checked
                                            color: "#ecf0f1"
                                            radius: 1
                                            anchors.margins: 5
                                            anchors.fill: parent
                                        }
                                    }
                                    
                                    contentItem: Item {
                                        anchors.fill: parent
                                        anchors.leftMargin: parent.indicator.width + 8
                                        anchors.rightMargin: 4
                                        
                                        Row {
                                            anchors.fill: parent
                                            spacing: 4
                                            
                                            // 题库名称文本
                                            Text {
                                                id: bankNameText
                                                width: parent.width - assignedInfo.width - 10
                                                height: parent.height
                                                text: parent.parent.parent.text || ""
                                                font.family: "阿里妈妈数黑体"
                                                font.pixelSize: 14
                                                color: parent.parent.parent.enabled ? "#ecf0f1" : "#95a5a6"
                                                elide: Text.ElideRight
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            
                                            // 已分配信息区域
                                            Item {
                                                id: assignedInfo
                                                width: 120
                                                height: parent.height
                                                visible: !parent.parent.parent.enabled
                                                
                                                Rectangle {
                                                    id: assignedBadge
                                                    visible: assignedText.text !== ""
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    height: 22
                                                    width: assignedText.contentWidth + 20
                                                    color: "#e74c3c22"
                                                    border.color: "#e74c3c"
                                                    border.width: 1
                                                    radius: 4
                                                    
                                                    Text {
                                                        id: assignedText
                                                        anchors.centerIn: parent
                                                        text: {
                                                            if (!modelData || !modelData.id) return "";
                                                            var pointNum = isBankAssignedToOtherPoint(modelData.id, pointIndex);
                                                            return pointNum > 0 ? "已分配给第" + pointNum + "点" : "";
                                                        }
                                                        font.family: "阿里妈妈数黑体"
                                                        font.pixelSize: 12
                                                        font.bold: true
                                                        color: "#e74c3c"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    onCheckedChanged: {
                                        try {
                                            // 加强对空值的检查
                                            if (!modelData || typeof modelData !== 'object' || 
                                                !modelData.id || !pentagonCategories || 
                                                !pentagonCategories[pointIndex]) {
                                                console.warn("无法更新分类：数据不完整");
                                                return;
                                            }
                                            
                                            // 确保bankId是有效的
                                            var bankId = String(modelData.id);
                                            if (!bankId) {
                                                console.warn("无法更新分类：题库ID无效");
                                                return;
                                            }
                                            
                                            updateCategory(pointIndex, bankId, checked);
                                        } catch (e) {
                                            console.error("更新分类时出错:", e);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    

                    
                    Button {
                        text: "关闭"
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 36
                        Layout.bottomMargin: 10 // 底部边距
                        background: Rectangle {
                            color: "#2980b9"
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
                            // 通知UI更新显示已分配题库数量
                            pentagonalChartSettingsPage.pentagonCategoriesChanged();
                            categoryPopup.close();
                        }
                    }
                }
            }
        }
    }
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    
    // 五芒图相关属性
    property var pentagonTitles: ["基础认知", "原理理解", "操作应用", "诊断分析", "安全规范"]
    
    // 题库分类相关属性
    property var questionBanks: []
    property var pentagonCategories: [{}, {}, {}, {}, {}]
    onPentagonCategoriesChanged: {
        console.log("五芒图分类数据已更新");
    }
    
    // 添加一个标志属性来控制是否处理更新
    property bool updatingUI: false
    
    Component.onCompleted: {
        console.log("五芒图设置页面初始化");
        
        // 确保pentagonCategories和questionBanks已初始化为有效值
        if (!pentagonCategories || !Array.isArray(pentagonCategories) || pentagonCategories.length < 5) {
            console.warn("初始化时发现pentagonCategories无效，正在重置");
            pentagonCategories = [{}, {}, {}, {}, {}];
        }
        
        if (!questionBanks) {
            console.warn("初始化时发现questionBanks无效，正在重置为空数组");
            questionBanks = [];
        }
        
        // 从数据库加载标题设置
        try {
            loadSettings();
        } catch (e) {
            console.error("加载设置失败:", e);
        }
        
        // 加载所有题库
        try {
            loadQuestionBanks();
        } catch (e) {
            console.error("加载题库失败:", e);
            questionBanks = []; // 确保至少是空数组
        }
        
        // 单独加载题库分类数据
        try {
            loadPentagonCategories();
            console.log("已加载五芒图题库分类数据");
        } catch (e) {
            console.error("加载五芒图题库分类失败:", e);
        }
        
        // 通知UI更新，触发题库数量的重新计算
        pentagonCategoriesChanged();
        
        // 打印调试信息
        console.log("五芒图设置初始化完成，题库数量:", 
                    (questionBanks && Array.isArray(questionBanks)) ? questionBanks.length : 0);
    }
    
    // 加载题库
    function loadQuestionBanks() {
        try {
            // 使用try-catch包裹可能出错的操作
            var banks = dbManager.getAllQuestionBanks();
            
            // 确保返回的是数组
            if (Array.isArray(banks)) {
                questionBanks = banks;
            } else if (banks && typeof banks === 'object') {
                // 如果返回了对象但不是数组，尝试转换为数组
                questionBanks = Object.values(banks);
            } else {
                // 其他情况初始化为空数组
                questionBanks = [];
            }
            
            console.log("已加载题库列表, 共", questionBanks.length, "个题库");
        } catch (e) {
            console.error("加载题库失败:", e);
            // 确保题库列表至少是空数组而不是undefined
            questionBanks = [];
        }
    }
    
    // 加载五芒图点的题库分类
    function loadPentagonCategories() {
        try {
            // 初始化五个点的分类对象
            for (var i = 0; i < 5; i++) {
                pentagonCategories[i] = pentagonCategories[i] || {};
                
                var categorySetting = dbManager.getSetting("pentagon_category_" + (i+1), "{}");
                try {
                    var parsed = JSON.parse(categorySetting);
                    // 确保解析结果是对象
                    if (parsed && typeof parsed === 'object') {
                        pentagonCategories[i] = parsed;
                        console.log("已加载五芒图点", i+1, "的题库分类, 分配题库数量:", countAssignedBanks(i));
                    } else {
                        pentagonCategories[i] = {};
                    }
                } catch (e) {
                    console.error("解析五芒图分类设置失败:", e);
                    pentagonCategories[i] = {};
                }
            }
            
            // 通知UI更新
            pentagonCategoriesChanged();
        } catch (e) {
            console.error("加载五芒图分类失败:", e);
            // 确保五个分类都是有效的对象
            pentagonCategories = [{}, {}, {}, {}, {}];
        }
    }
    
    // 根据题库ID检查该题库是否已被分配给除当前点外的其他点
    function isBankAssignedToOtherPoint(bankId, currentPointIndex) {
        try {
            // 安全检查参数
            if (!bankId || currentPointIndex === undefined || 
                !pentagonCategories || !Array.isArray(pentagonCategories)) {
                return 0;
            }
            
            // 确保currentPointIndex是有效数字
            currentPointIndex = parseInt(currentPointIndex);
            if (isNaN(currentPointIndex) || currentPointIndex < 0 || currentPointIndex >= 5) {
                return 0;
            }
            
            // 确保bankId是字符串
            bankId = String(bankId);
            
            // 检查所有点
            for (var i = 0; i < 5; i++) {
                // 跳过当前点
                if (i === currentPointIndex) {
                    continue;
                }
                
                // 安全访问pentagonCategories[i]
                if (!pentagonCategories[i] || typeof pentagonCategories[i] !== 'object') {
                    continue;
                }
                
                // 检查是否分配给了其他点
                if (pentagonCategories[i][bankId] === true) {
                    // 使用Number()确保结果是数字类型
                    return Number(i + 1); // 点序号从1开始
                }
            }
            
            return 0;
        } catch (e) {
            console.error("检查题库分配时出错:", e);
            return 0;
        }
    }
    
    // 更新单个题库分类
    function updateCategory(pointIndex, bankId, checked) {
        // 如果正在更新UI，不处理回调
        if (updatingUI) return;
        
        // 开始更新UI，防止重入
        updatingUI = true;
        
        // 如果要选中，需要先清除其他点的选择状态
        if (checked) {
            console.log("选中题库ID:", bankId, "到五芒图点:", pointIndex + 1);
            // 清除其他点的相同bankId设置
            for (var i = 0; i < 5; i++) {
                if (i !== pointIndex) {
                    if (pentagonCategories[i][bankId]) {
                        console.log("  清除五芒图点", i + 1, "中的相同题库");
                        pentagonCategories[i][bankId] = false;
                    }
                }
            }
        }
        
        // 更新当前点的设置
        pentagonCategories[pointIndex][bankId] = checked;
        console.log("更新五芒图点", pointIndex + 1, "的题库分类:", bankId, "=>", checked);
        
        // 通知UI更新，触发题库数量的重新计算
        pentagonCategoriesChanged();
        
        // 完成更新
        updatingUI = false;
    }
    
    // 统计某个点已分配的题库数量
    function countAssignedBanks(pointIndex) {
        try {
            // 安全检查
            if (!pentagonCategories || !Array.isArray(pentagonCategories) || 
                pointIndex < 0 || pointIndex >= pentagonCategories.length ||
                !pentagonCategories[pointIndex]) {
                return 0;
            }
            
            var count = 0;
            var categories = pentagonCategories[pointIndex];
            
            // 遍历分类对象的所有键，计算设为true的数量
            for (var key in categories) {
                if (categories.hasOwnProperty(key) && categories[key] === true) {
                    count++;
                }
            }
            
            return count;
        } catch (e) {
            console.error("统计已分配题库数量时出错:", e);
            return 0;
        }
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
        
        // 保存题库分类
        try {
            for (var i = 0; i < 5; i++) {
                // 确保数据是有效的对象
                if (!pentagonCategories[i] || typeof pentagonCategories[i] !== 'object') {
                    pentagonCategories[i] = {};
                }
                
                var categorySetting = JSON.stringify(pentagonCategories[i]);
                var success = dbManager.setSetting("pentagon_category_" + (i+1), categorySetting);
                console.log("保存五芒图点", i+1, "的题库分类:", success ? "成功" : "失败", 
                          "分配题库数量:", countAssignedBanks(i));
            }
            
            // 保存时间戳，用于标记最后修改时间
            var now = new Date();
            dbManager.setSetting("pentagon_settings_updated_time", now.toISOString());
            
            // 通知UI更新
            pentagonCategoriesChanged();
            
            // 显示成功消息
            statusMessage = "五芒图配置已保存"
            isSuccess = true
            statusUpdateTimer.restart()
        } catch (e) {
            console.error("保存五芒图设置失败:", e);
            statusMessage = "保存失败，请重试"
            isSuccess = false
            statusUpdateTimer.restart()
        }
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
            id: settingsFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: settingsColumn.height // 增加额外的底部空间
            clip: true
            boundsBehavior: Flickable.StopAtBounds // 防止过度滚动
            
            // 修改鼠标滚轮处理方式
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: function(wheel) {
                    // 增加滚动速度
                    var delta = wheel.angleDelta.y / 120 * 60;
                    
                    // 使用flickableItem.flick替代直接设置contentY
                    if (delta < 0) {
                        // 向下滚动
                        settingsFlickable.flick(0, -500);
                    } else {
                        // 向上滚动
                        settingsFlickable.flick(0, 500);
                    }
                    
                    wheel.accepted = true;
                }
                propagateComposedEvents: true
            }
            
            ColumnLayout {
                id: settingsColumn
                width: parent.width
                spacing: 25
                
                // 五芒图设置区域
                Rectangle {
                    Layout.fillWidth: true
                    height: contentLayout.implicitHeight + 20 // 从固定高度改为自适应高度
                    color: "#44ffffff"
                    radius: 10
                    
                    ColumnLayout {
                        id: contentLayout // 添加id以便引用
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
                            text: "设置各点标题及题库归类"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.topMargin: 0
                            Layout.bottomMargin: 5
                        }
                        
                        // 五个标题的设置
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.bottomMargin: 10
                            
                            // 第一点设置
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
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
                                    
                                    // 显示已分配题库数量
                                    Text {
                                        text: {
                                            var count = countAssignedBanks(0);
                                            return count > 0 ? "已分配" + count + "个题库" : "未分配题库";
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 13
                                        color: "#cccccc"
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: 120
                                    }
                                    
                                    // 第一点题库归类按钮
                                    Button {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 38
                                        background: Rectangle {
                                            color: "#33ffffff"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "题库归类"
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            var popup = categoryPopupComponent.createObject(pentagonalChartSettingsPage, {
                                                "pointIndex": 0
                                            });
                                            popup.open();
                                        }
                                    }
                                }
                            }
                            
                            // 第二点设置
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
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

                                    // 显示已分配题库数量
                                    Text {
                                        text: {
                                            var count = countAssignedBanks(1);
                                            return count > 0 ? "已分配" + count + "个题库" : "未分配题库";
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 13
                                        color: "#cccccc"
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: 120
                                    }
                                    
                                    // 第二点题库归类按钮
                                    Button {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 38
                                        background: Rectangle {
                                            color: "#33ffffff"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "题库归类"
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            var popup = categoryPopupComponent.createObject(pentagonalChartSettingsPage, {
                                                "pointIndex": 1
                                            });
                                            popup.open();
                                        }
                                    }
                                }
                            }
                            
                            // 第三点设置
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
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

                                    // 显示已分配题库数量
                                    Text {
                                        text: {
                                            var count = countAssignedBanks(2);
                                            return count > 0 ? "已分配" + count + "个题库" : "未分配题库";
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 13
                                        color: "#cccccc"
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: 120
                                    }
                                    
                                    // 第三点题库归类按钮
                                    Button {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 38
                                        background: Rectangle {
                                            color: "#33ffffff"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "题库归类"
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            var popup = categoryPopupComponent.createObject(pentagonalChartSettingsPage, {
                                                "pointIndex": 2
                                            });
                                            popup.open();
                                        }
                                    }
                                }
                            }
                            
                            // 第四点设置
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
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

                                    // 显示已分配题库数量
                                    Text {
                                        text: {
                                            var count = countAssignedBanks(3);
                                            return count > 0 ? "已分配" + count + "个题库" : "未分配题库";
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 13
                                        color: "#cccccc"
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: 120
                                    }
                                    
                                    // 第四点题库归类按钮
                                    Button {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 38
                                        background: Rectangle {
                                            color: "#33ffffff"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "题库归类"
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            var popup = categoryPopupComponent.createObject(pentagonalChartSettingsPage, {
                                                "pointIndex": 3
                                            });
                                            popup.open();
                                        }
                                    }
                                }
                            }
                            
                            // 第五点设置
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
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

                                    // 显示已分配题库数量
                                    Text {
                                        text: {
                                            var count = countAssignedBanks(4);
                                            return count > 0 ? "已分配" + count + "个题库" : "未分配题库";
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 13
                                        color: "#cccccc"
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: 120
                                    }
                                    
                                    // 第五点题库归类按钮
                                    Button {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 38
                                        background: Rectangle {
                                            color: "#33ffffff"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: "题库归类"
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            var popup = categoryPopupComponent.createObject(pentagonalChartSettingsPage, {
                                                "pointIndex": 4
                                            });
                                            popup.open();
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 保存按钮放回五芒图设置内部
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.topMargin: 5
                            Layout.bottomMargin: 5
                            
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
                    Layout.bottomMargin: 20 // 添加底部边距
                    
                    Text {
                        anchors.centerIn: parent
                        text: statusMessage
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                    }
                }
            }
            
            // 添加滚动指示器
            ScrollBar.vertical: ScrollBar {
                id: vScrollBar
                active: true
                visible: settingsFlickable.contentHeight > settingsFlickable.height
                policy: ScrollBar.AlwaysOn
                anchors.right: parent.right
                anchors.rightMargin: 2
            }
        }
    }
}