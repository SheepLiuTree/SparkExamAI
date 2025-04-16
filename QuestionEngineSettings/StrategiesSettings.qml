import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: strategiesSettingsPage
    color: "transparent"
    
    // 状态信息
    property string statusMessage: ""
    property bool isSuccess: false
    
    // 题目配置
    property int dailyQuestionCount: 20
    property var questionBanks: []
    property var bankDistributions: ({})
    
    Component.onCompleted: {
        // 从数据库加载设置
        loadSettings()
        
        // 加载题库列表
        loadQuestionBanks()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // 星火日课配置区
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
                    text: "星火日课配置"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                }
                
                // 每日题目数量设置
                RowLayout {
                    Layout.fillWidth: true
                    height: 40
                    spacing: 10
                    
                    Text {
                        text: "题目数量:"
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
                            id: questionCountSlider
                            from: 5
                            to: 50
                            value: dailyQuestionCount
                            stepSize: 1
                            Layout.fillWidth: true
                            
                            onValueChanged: {
                                dailyQuestionCount = value
                                updateDistributions()
                            }
                            
                            background: Rectangle {
                                x: questionCountSlider.leftPadding
                                y: questionCountSlider.topPadding + questionCountSlider.availableHeight / 2 - height / 2
                                width: questionCountSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#88ffffff"
                                
                                Rectangle {
                                    width: questionCountSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#2c70b7"
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: questionCountSlider.leftPadding + questionCountSlider.visualPosition * (questionCountSlider.availableWidth - width)
                                y: questionCountSlider.topPadding + questionCountSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: questionCountSlider.pressed ? "#1e5b94" : "#2c70b7"
                                border.color: "#2c70b7"
                            }
                        }
                        
                        Text {
                            text: dailyQuestionCount
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            Layout.preferredWidth: 30
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
        
        // 题库分配区 - 让它填充中间区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#44ffffff"
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                Text {
                    text: "题库分配"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                }
                
                Text {
                    text: "设置每个题库的题目分配数量，总和应等于星火日课题目数量"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: "white"
                    opacity: 0.8
                }
                
                // 添加一个平均分配按钮
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        id: hintText
                        text: "提示: 分配总和必须等于题目数量 " + dailyQuestionCount
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        font.bold: true
                        color: isDistributionValid() ? "#99ff99" : "#ff9999"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "平均分配"
                        implicitWidth: 100
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
                            distributeEvenly()
                            bankListView.model = null
                            bankListView.model = questionBanks
                            statusUpdateTimer.restart()
                        }
                    }
                }
                
                // 题库分配列表 - 让它填充剩余空间
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
                        id: bankListView
                        width: parent.width
                        height: parent.height
                        model: questionBanks
                        spacing: 8
                        interactive: true
                        
                        delegate: Rectangle {
                            width: bankListView.width - 20
                            height: 60
                            color: "#33ffffff"
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                Text {
                                    text: modelData.name
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    Layout.preferredWidth: 160
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: "所属分类: " + getBankCategory(modelData.id)
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "#A5D6FF"
                                    opacity: 0.9
                                    Layout.preferredWidth: 150
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: "题库总量: " + modelData.count + "题"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "white"
                                    opacity: 0.8
                                    Layout.preferredWidth: 120
                                }
                                
                                Text {
                                    text: "分配:"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "white"
                                }
                                
                                SpinBox {
                                    id: distributionSpinBox
                                    from: 0
                                    to: Math.min(dailyQuestionCount, modelData.count)
                                    value: getBankDistribution(modelData.id)
                                    Layout.preferredWidth: 120
                                    
                                    onValueChanged: {
                                        updateBankDistribution(modelData.id, value)
                                    }
                                    
                                    contentItem: TextInput {
                                        z: 2
                                        text: distributionSpinBox.textFromValue(distributionSpinBox.value, distributionSpinBox.locale)
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 14
                                        color: "white"
                                        selectionColor: "#2c70b7"
                                        selectedTextColor: "white"
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        readOnly: !distributionSpinBox.editable
                                        validator: distributionSpinBox.validator
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    }
                                    
                                    up.indicator: Rectangle {
                                        x: parent.width - width
                                        height: parent.height
                                        implicitWidth: 30
                                        implicitHeight: 30
                                        color: distributionSpinBox.up.pressed ? "#1e5b94" : "transparent"
                                        border.color: "transparent"
                                        
                                        Text {
                                            text: "+"
                                            font.pixelSize: 16
                                            color: "white"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    down.indicator: Rectangle {
                                        x: 0
                                        height: parent.height
                                        implicitWidth: 30
                                        implicitHeight: 30
                                        color: distributionSpinBox.down.pressed ? "#1e5b94" : "transparent"
                                        border.color: "transparent"
                                        
                                        Text {
                                            text: "-"
                                            font.pixelSize: 16
                                            color: "white"
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        implicitWidth: 120
                                        implicitHeight: 30
                                        color: "#22ffffff"
                                        radius: 4
                                    }
                                }
                                
                                Text {
                                    text: "题"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "white"
                                }
                                
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
                
                // 分配信息
                Rectangle {
                    id: distributionStatusRect
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: isDistributionValid() ? "#33009900" : "#33990000"
                    radius: 4
                    
                    Text {
                        id: distributionStatusText
                        anchors.centerIn: parent
                        text: getDistributionStatus()
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                    }
                    
                    // 添加计时器用于延迟更新状态显示
                    Timer {
                        id: statusUpdateTimer
                        interval: 50
                        repeat: false
                        onTriggered: {
                            distributionStatusText.text = getDistributionStatus()
                            // 更新状态颜色
                            distributionStatusRect.color = isDistributionValid() ? "#33009900" : "#33990000"
                        }
                    }
                }
            }
        }
        
        // 底部操作区 - 固定在底部
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#44ffffff"
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                Item { Layout.fillWidth: true }
                
                // 保存按钮
                Button {
                    id: saveButton
                    width: 160
                    height: 40
                    enabled: isDistributionValid()
                    
                    background: Rectangle {
                        color: parent.enabled ? "#2c70b7" : "#88888888"
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
        // 加载每日题目数量
        var count = dbManager.getSetting("daily_question_count", "20")
        dailyQuestionCount = parseInt(count)
        
        // 加载题库分配设置
        var distributionsStr = dbManager.getSetting("question_bank_distributions", "{}")
        try {
            bankDistributions = JSON.parse(distributionsStr)
        } catch (e) {
            console.error("解析题库分配设置失败:", e)
            bankDistributions = {}
        }
        
        // 验证数据的有效性
        validateSettings()
        
        console.log("已从数据库加载设置")
    }
    
    // 验证设置的有效性
    function validateSettings() {
        // 验证dailyQuestionCount的范围
        if (isNaN(dailyQuestionCount) || dailyQuestionCount < 5 || dailyQuestionCount > 50) {
            console.warn("每日题目数量无效，重置为默认值20")
            dailyQuestionCount = 20
        }
        
        // 验证bankDistributions中的每个分配数量
        var needsUpdate = false
        for (var bankId in bankDistributions) {
            var value = bankDistributions[bankId]
            if (isNaN(value) || value < 0) {
                console.warn("题库分配数量无效，重置为0:", bankId)
                bankDistributions[bankId] = 0
                needsUpdate = true
            }
        }
        
        // 确保分配总和等于题目数量
        ensureDistributionMatchesTotal()
        
        // 如果有无效数据被修正，更新一下分配状态
        if (needsUpdate) {
            statusUpdateTimer.restart()
        }
    }
    
    // 确保分配总和与题目总数一致
    function ensureDistributionMatchesTotal() {
        var total = getTotalDistribution()
        console.log("当前总分配:", total, "目标总数:", dailyQuestionCount)
        
        if (total === 0 && questionBanks.length > 0) {
            // 如果当前没有分配且有题库，则进行平均分配
            distributeEvenly()
            return
        }
        
        if (total !== dailyQuestionCount) {
            console.warn("分配总和不等于题目总数，将进行调整")
            
            if (total < dailyQuestionCount) {
                // 如果总分配少于题目总数，把剩余题目分配给第一个题库
                var remaining = dailyQuestionCount - total
                if (questionBanks.length > 0) {
                    var firstBankId = questionBanks[0].id
                    var currentValue = bankDistributions[firstBankId] || 0
                    bankDistributions[firstBankId] = currentValue + remaining
                    console.log("将剩余", remaining, "题分配给题库", firstBankId)
                }
            } else {
                // 如果总分配多于题目总数，按比例缩减
                adjustDistributionsProportionally()
            }
        }
    }
    
    // 平均分配题目到所有题库
    function distributeEvenly() {
        if (questionBanks.length === 0) return
        
        // 计算平均分配数和余数
        var avgCount = Math.floor(dailyQuestionCount / questionBanks.length)
        var remainder = dailyQuestionCount % questionBanks.length
        
        console.log("平均分配每个题库", avgCount, "题，余", remainder, "题")
        
        // 重置分配
        bankDistributions = {}
        
        // 为每个题库分配平均数量的题目
        for (var i = 0; i < questionBanks.length; i++) {
            var bankId = questionBanks[i].id
            var count = avgCount
            
            // 将余数分配给前几个题库
            if (i < remainder) {
                count += 1
            }
            
            // 确保不超过题库题目总数
            count = Math.min(count, questionBanks[i].count)
            
            bankDistributions[bankId] = count
        }
        
        // 确保总和等于dailyQuestionCount
        ensureDistributionMatchesTotal()
    }
    
    // 按比例调整分配
    function adjustDistributionsProportionally() {
        var total = getTotalDistribution()
        if (total === 0) return
        
        var ratio = dailyQuestionCount / total
        console.log("按比例调整分配，比率:", ratio)
        
        // 首先按比例缩减所有分配
        var newDistributions = {}
        var newTotal = 0
        
        for (var bankId in bankDistributions) {
            var adjusted = Math.floor(bankDistributions[bankId] * ratio)
            newDistributions[bankId] = adjusted
            newTotal += adjusted
        }
        
        // 处理由于取整导致的差异
        var diff = dailyQuestionCount - newTotal
        
        if (diff > 0) {
            // 依次给每个有分配的题库增加1题，直到达到总数
            var bankIds = Object.keys(newDistributions)
            for (var i = 0; i < diff && i < bankIds.length; i++) {
                newDistributions[bankIds[i]] += 1
            }
        }
        
        // 更新分配
        bankDistributions = newDistributions
        
        // 更新保存按钮状态
        saveButton.enabled = isDistributionValid()
    }
    
    // 加载题库列表
    function loadQuestionBanks() {
        questionBanks = dbManager.getAllQuestionBanks()
        console.log("已加载题库列表, 共", questionBanks.length, "个题库")
    }
    
    // 获取题库所属分类
    function getBankCategory(bankId) {
        try {
            if (!dbManager) {
                console.error("dbManager未初始化");
                return "未分类";
            }
            
            // 获取五芒图所有点的分类设置
            for (var i = 1; i <= 5; i++) {
                var categoryKey = "pentagon_category_" + i;
                var categorySetting = dbManager.getSetting(categoryKey, "{}");
                var categoryData = JSON.parse(categorySetting);
                
                // 如果题库ID存在于该分类中且被选中
                if (categoryData[bankId] === true) {
                    // 获取该点的标题
                    var titleKey = "pentagon_title_" + i;
                    var title = dbManager.getSetting(titleKey, "");
                    return title;
                }
            }
            return "未分类";
        } catch (e) {
            console.error("获取题库分类失败:", e);
            return "未分类";
        }
    }
    
    // 获取题库分配数量
    function getBankDistribution(bankId) {
        return bankDistributions[bankId] || 0
    }
    
    // 更新题库分配数量
    function updateBankDistribution(bankId, value) {
        bankDistributions[bankId] = value
        console.log("更新题库分配:", bankId, "=>", value)
        
        // 检查分配是否有效
        var isValid = isDistributionValid()
        
        // 更新UI状态
        hintText.color = isValid ? "#99ff99" : "#ff9999"
        saveButton.enabled = isValid
        
        // 触发状态更新，刷新分配信息显示
        statusUpdateTimer.restart()
    }
    
    // 更新分配，确保总和不超过每日题目数量
    function updateDistributions() {
        // 如果总分配超过了每日题目数量，按比例缩减
        var total = getTotalDistribution()
        if (total > dailyQuestionCount) {
            var ratio = dailyQuestionCount / total
            
            for (var bankId in bankDistributions) {
                bankDistributions[bankId] = Math.floor(bankDistributions[bankId] * ratio)
            }
            
            // 刷新列表视图
            bankListView.model = null
            bankListView.model = questionBanks
        }
        
        // 检查分配是否有效并更新保存按钮状态
        var isValid = isDistributionValid()
        hintText.color = isValid ? "#99ff99" : "#ff9999"
        saveButton.enabled = isValid
        
        // 触发状态更新
        statusUpdateTimer.restart()
    }
    
    // 获取总分配数量
    function getTotalDistribution() {
        var total = 0
        for (var bankId in bankDistributions) {
            total += bankDistributions[bankId]
        }
        return total
    }
    
    // 检查分配是否有效
    function isDistributionValid() {
        return getTotalDistribution() === dailyQuestionCount
    }
    
    // 获取分配状态描述
    function getDistributionStatus() {
        var total = getTotalDistribution()
        var remaining = dailyQuestionCount - total
        
        if (remaining === 0) {
            return "题目分配完成，共 " + dailyQuestionCount + " 题"
        } else if (remaining > 0) {
            return "还需分配 " + remaining + " 题，当前已分配 " + total + " 题，共需 " + dailyQuestionCount + " 题"
        } else {
            return "分配超出 " + Math.abs(remaining) + " 题，当前已分配 " + total + " 题，共需 " + dailyQuestionCount + " 题"
        }
    }
    
    // 检查是否有未分类的题库被分配了题目
    function checkUncategorizedBanks() {
        var uncategorizedBanks = [];
        for (var i = 0; i < questionBanks.length; i++) {
            var bank = questionBanks[i];
            var category = getBankCategory(bank.id);
            if (category === "未分类" && bankDistributions[bank.id] > 0) {
                uncategorizedBanks.push(bank.name);
            }
        }
        return uncategorizedBanks;
    }
    
    // 保存设置
    function saveSettings() {
        if (!isDistributionValid()) {
            statusMessage = "分配无效，请调整后再保存"
            isSuccess = false
            return
        }
        
        // 检查是否有未分类的题库被分配了题目
        var uncategorizedBanks = checkUncategorizedBanks();
        if (uncategorizedBanks.length > 0) {
            // 创建警示弹窗
            var dialog = Qt.createQmlObject('
                import QtQuick 2.15
                import QtQuick.Controls 2.15
                import QtQuick.Layouts 1.15
                
                Dialog {
                    id: warningDialog
                    title: "警告"
                    modal: true
                    width: 400
                    height: 200
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    
                    property var bankNames: []
                    
                    background: Rectangle {
                        color: "#2c3e50"
                        radius: 8
                        border.color: "#e74c3c"
                        border.width: 1
                    }
                    
                    header: Rectangle {
                        color: "#2c3e50"
                        height: 40
                        radius: 8
                        border.color: "#e74c3c"
                        border.width: 1
                        
                        Text {
                            text: warningDialog.title
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Text {
                            text: "以下未分类的题库被分配了题目："
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        Text {
                            text: warningDialog.bankNames.join("、")
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "#e74c3c"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "未分类的题库不计入个人能力五芒图中！"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                            spacing: 10
                            
                            Button {
                                text: "取消"
                                background: Rectangle {
                                    color: "#34495e"
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
                                onClicked: warningDialog.close()
                            }
                            
                            Button {
                                text: "继续保存"
                                background: Rectangle {
                                    color: "#e74c3c"
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
                                    warningDialog.close()
                                    saveSettingsToDatabase()
                                }
                            }
                        }
                    }
                }
            ', strategiesSettingsPage, "warningDialog");
            
            // 设置弹窗的bankNames属性
            dialog.bankNames = uncategorizedBanks;
            dialog.open();
            return;
        }
        
        // 如果没有未分类的题库，直接保存
        saveSettingsToDatabase();
    }
    
    // 保存设置到数据库
    function saveSettingsToDatabase() {
        // 保存每日题目数量
        var countSuccess = dbManager.setSetting("daily_question_count", dailyQuestionCount.toString())
        
        // 保存题库分配设置
        var distributionsStr = JSON.stringify(bankDistributions)
        var distributionsSuccess = dbManager.setSetting("question_bank_distributions", distributionsStr)
        
        // 保存星火日课启用状态
        var enableSuccess = dbManager.setSetting("spark_daily_enabled", "true")
        
        // 保存设置时间
        var now = new Date()
        var timeStr = now.toISOString()
        var timeSuccess = dbManager.setSetting("question_settings_updated_time", timeStr)
        
        if (countSuccess && distributionsSuccess && enableSuccess) {
            statusMessage = "保存成功！设置已存入数据库"
            isSuccess = true
            console.log("成功保存出题策略设置:", timeStr)
        } else {
            statusMessage = "保存失败，请重试"
            isSuccess = false
            console.error("保存设置失败:", countSuccess, distributionsSuccess, enableSuccess)
        }
    }
} 