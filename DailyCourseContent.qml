import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "transparent"
    
    property var userData
    property var currentQuestions: []  // 当前题目列表
    property int currentQuestionIndex: 0  // 当前题目索引
    property var userAnswers: ({})  // 用户答案记录
    property var categoryStats: [
        {total: 0, correct: 0}, // 第一点
        {total: 0, correct: 0}, // 第二点
        {total: 0, correct: 0}, // 第三点
        {total: 0, correct: 0}, // 第四点
        {total: 0, correct: 0}  // 第五点
    ]
    
    // 从数据库加载今日题目
    Component.onCompleted: {
        loadTodayQuestions()
    }
    
    // 加载今日题目
    function loadTodayQuestions() {
        // 从数据库获取出题策略设置
        var dailyCount = parseInt(dbManager.getSetting("daily_question_count", "20"))
        var distributionsStr = dbManager.getSetting("question_bank_distributions", "{}")
        var distributions = JSON.parse(distributionsStr)
        
        // 获取五芒图点的题库分类
        var pentagonCategories = []
        for (var i = 0; i < 5; i++) {
            var categorySetting = dbManager.getSetting("pentagon_category_" + (i+1), "{}")
            try {
                pentagonCategories.push(JSON.parse(categorySetting))
            } catch (e) {
                console.error("解析五芒图分类设置失败:", e)
                pentagonCategories.push({})
            }
        }
        
        // 获取五芒图点的标题
        var pentagonTitles = []
        for (var i = 0; i < 5; i++) {
            var title = dbManager.getSetting("pentagon_title_" + (i+1), "")
            pentagonTitles.push(title)
        }
        
        // 从各个题库中抽取题目
        currentQuestions = []
        
        // 记录各五芒图点的题库ID列表
        var pentagonBankIds = [[], [], [], [], []]
        
        // 将题库按照五芒图分类
        for (var bankId in distributions) {
            var count = distributions[bankId]
            if (count > 0) {
                // 检查该题库属于哪些五芒图点
                var assigned = false
                for (var i = 0; i < 5; i++) {
                    if (pentagonCategories[i][bankId] === true) {
                        pentagonBankIds[i].push({
                            bankId: bankId,
                            count: count
                        })
                        assigned = true
                    }
                }
                
                // 如果没有分配到任何五芒图点，则按原样获取题目
                if (!assigned) {
                    var questions = dbManager.getRandomQuestions(bankId, count)
                    for (var j = 0; j < questions.length; j++) {
                        questions[j].category = "未分类"
                        currentQuestions.push(questions[j])
                    }
                }
            }
        }
        
        // 从各个五芒图点的题库中获取题目
        for (var i = 0; i < 5; i++) {
            if (pentagonBankIds[i].length > 0) {
                for (var j = 0; j < pentagonBankIds[i].length; j++) {
                    var bankData = pentagonBankIds[i][j]
                    var questions = dbManager.getRandomQuestions(bankData.bankId, bankData.count)
                    for (var k = 0; k < questions.length; k++) {
                        questions[k].category = pentagonTitles[i]
                        questions[k].categoryIndex = i
                        currentQuestions.push(questions[k])
                    }
                }
            }
        }
        
        // 重置当前题目索引和用户答案
        currentQuestionIndex = 0
        userAnswers = {}
        
        console.log("加载题目完成，共", currentQuestions.length, "道题目")
    }
    
    // 获取题目类型
    function getQuestionType(question) {
        if (!question) return "";
        if (question.options && question.options.length > 0) {
            return "单选题";
        }
        return "填空题";
    }
    
    // 顶部导航栏
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "transparent"
        
        // 返回按钮，放在左侧
        Button {
            id: backButton
            width: 100
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            background: Image {
                source: "qrc:/images/button_bg.png"
                fillMode: Image.Stretch
            }
            contentItem: Text {
                text: "返回"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                confirmDialog.dialogTitle = "返回确认"
                confirmDialog.dialogMessage = "确定要返回上一页吗？\n当前进度将不会保存。"
                confirmDialog.confirmAction = function() {
                    stackView.pop()
                }
                confirmDialog.open()
            }
        }
        
        // 标题文本，放在中央
        Text {
            text: "星火日课 - " + (userData ? userData.name : "用户")
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 24
            color: "white"
            anchors.centerIn: parent
        }
    }
    
    // 主要内容区域
    Rectangle {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        color: "#44ffffff"
        radius: 10
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // 左侧题目区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20
                    
                    // 题目信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "第 " + (currentQuestionIndex + 1) + " 题 / 共 " + currentQuestions.length + " 题"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // 添加题目分类信息
                            Text {
                                text: {
                                    if (!currentQuestions[currentQuestionIndex]) return ""
                                    return "分类: " + (currentQuestions[currentQuestionIndex].category || "未分类")
                                }
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: {
                                    if (!currentQuestions[currentQuestionIndex]) return "white"
                                    var categoryIndex = currentQuestions[currentQuestionIndex].categoryIndex
                                    var colors = ["#2c70b7", "#e67e22", "#27ae60", "#8e44ad", "#e74c3c"]
                                    return categoryIndex >= 0 && categoryIndex < 5 ? colors[categoryIndex] : "white"
                                }
                            }
                        }
                    }
                    
                    // 题目内容
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200  // 固定高度
                        color: "#33ffffff"
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!currentQuestions[currentQuestionIndex]) return ""
                                    var answer = currentQuestions[currentQuestionIndex].answer
                                    if (!currentQuestions[currentQuestionIndex].options || currentQuestions[currentQuestionIndex].options.length === 0) {
                                        return "判断题"
                                    } else if (answer.length > 1) {
                                        return "多选题"
                                    } else {
                                        return "单选题"
                                    }
                                }
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 20
                                color: "#2c70b7"
                                Layout.alignment: Qt.AlignLeft
                                font.bold: true
                            }
                            
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
            clip: true
                                
                                Text {
                                    text: currentQuestions[currentQuestionIndex] ? currentQuestions[currentQuestionIndex].content : ""
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }
                    }
                    
                    // 选项区域
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Layout.topMargin: 20
                        Layout.preferredHeight: 300
                        
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                Repeater {
                                    model: {
                                        if (!currentQuestions[currentQuestionIndex]) return []
                                        if (!currentQuestions[currentQuestionIndex].options || currentQuestions[currentQuestionIndex].options.length === 0) {
                                            // 判断题选项
                                            return [
                                                { index: 0, text: "正确" },
                                                { index: 1, text: "错误" }
                                            ]
                                        }
                                        return currentQuestions[currentQuestionIndex].options
                                    }
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 50
                                        color: {
                                            var answer = userAnswers[currentQuestionIndex]
                                            if (Array.isArray(answer)) {
                                                return answer.includes(modelData.index) ? "#2c70b7" : "#33ffffff"
                                            }
                                            return answer === modelData.index ? "#2c70b7" : "#33ffffff"
                                        }
                                        radius: 8
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            
                                            Text {
                                                text: String.fromCharCode(65 + modelData.index)
                                                font.family: "阿里妈妈数黑体"
                                                font.pixelSize: 16
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: modelData.text
                                                font.family: "阿里妈妈数黑体"
                                                font.pixelSize: 16
                                                color: "white"
                                                Layout.fillWidth: true
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var currentAnswer = userAnswers[currentQuestionIndex]
                                                var question = currentQuestions[currentQuestionIndex]
                                                
                                                if (!question.options || question.options.length === 0) {
                                                    // 判断题
                                                    userAnswers[currentQuestionIndex] = modelData.index
                                                } else if (question.answer.length > 1) {
                                                    // 多选题
                                                    if (!Array.isArray(currentAnswer)) {
                                                        currentAnswer = []
                                                    }
                                                    var index = currentAnswer.indexOf(modelData.index)
                                                    if (index === -1) {
                                                        currentAnswer.push(modelData.index)
                                                    } else {
                                                        currentAnswer.splice(index, 1)
                                                    }
                                                    // 如果所有选项都被取消，则设置为undefined
                                                    if (currentAnswer.length === 0) {
                                                        userAnswers[currentQuestionIndex] = undefined
                                                    } else {
                                                        userAnswers[currentQuestionIndex] = currentAnswer
                                                    }
                                                } else {
                                                    // 单选题
                                                    userAnswers[currentQuestionIndex] = modelData.index
                                                }
                                                
                                                // 强制更新UI
                                                userAnswers = Object.assign({}, userAnswers)
                                            }
                                        }
                                    }
                                }
                                
                                Item {
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }
                    
                    // 导航按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        Layout.topMargin: 20  // 添加顶部间距
                        
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            enabled: currentQuestionIndex > 0
                            background: Rectangle {
                                color: parent.enabled ? "#2c70b7" : "#666666"
                                radius: 4
                            }
                            contentItem: Text {
                                text: "上一题"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (currentQuestionIndex > 0) {
                                    currentQuestionIndex--
                                }
                            }
                        }
                        
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            enabled: currentQuestionIndex < currentQuestions.length - 1
                            background: Rectangle {
                                color: parent.enabled ? "#2c70b7" : "#666666"
                                radius: 4
                            }
                            contentItem: Text {
                                text: "下一题"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (currentQuestionIndex < currentQuestions.length - 1) {
                                    currentQuestionIndex++
                                }
                            }
                        }
                    }
                }
            }
            
            // 右侧答题卡
            Rectangle {
                Layout.preferredWidth: 230
                Layout.fillHeight: true
                color: "#33ffffff"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: "答题卡"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10
                        
                        Repeater {
                            model: currentQuestions.length
                            
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: {
                                    if (userAnswers[index] !== undefined) {
                                        return "#2c70b7"
                                    }
                                    return "#33ffffff"
                                }
                                radius: 4
                    
                    Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                                        currentQuestionIndex = index
                                    }
                                }
                            }
                        }
                    }
                    
                    // 提交按钮
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        Layout.alignment: Qt.AlignHCenter
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 5
                        }
                        contentItem: Text {
                            text: "提交答案"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            submitAnswers()
                        }
                    }
                }
            }
        }
    }
    
    // 计算各类别的正确率统计
    function calculateCategoryStats() {
        // 重置统计数据
        for (var i = 0; i < 5; i++) {
            categoryStats[i] = {total: 0, correct: 0}
        }
        
        // 统计各类别题目的正确率
        for (var i = 0; i < currentQuestions.length; i++) {
            var question = currentQuestions[i]
            var categoryIndex = question.categoryIndex
            
            // 只统计已分类的题目
            if (categoryIndex !== undefined && categoryIndex >= 0 && categoryIndex < 5) {
                categoryStats[categoryIndex].total++
                
                // 检查是否回答正确
                var userAnswer = userAnswers[i]
                if (userAnswer && userAnswer.toLowerCase() === question.answer.toLowerCase()) {
                    categoryStats[categoryIndex].correct++
                }
            }
        }
        
        console.log("分类统计完成:", JSON.stringify(categoryStats))
    }
    
    // 在提交答案前添加统计计算
    function submitAnswers() {
        // 计算正确率
        var correctCount = 0
        for (var i = 0; i < currentQuestions.length; i++) {
            var userAnswer = userAnswers[i] || ""
            var correctAnswer = currentQuestions[i].answer
            
            if (userAnswer.toLowerCase() === correctAnswer.toLowerCase()) {
                correctCount++
            }
        }
        
        // 计算各分类的统计信息
        calculateCategoryStats()
        
        // 显示成绩和解析
        pentagonResultDialog.correctCount = correctCount
        pentagonResultDialog.totalCount = currentQuestions.length
        pentagonResultDialog.open()
        
        // 保存答题记录到数据库
        var answerDataObj = {
            questions: currentQuestions,
            answers: userAnswers
        }
        
        var saveSuccess = dbManager.saveUserAnswerRecord(
            userData.workId,
            userData.name,
            "星火日课",
            currentQuestions.length,
            correctCount,
            JSON.stringify(answerDataObj)
        )
        
        console.log("保存答题记录:", saveSuccess)
    }
    
    // 获取错题列表
    function getWrongQuestions() {
        // 从详细答题数据中筛选出错题
        var wrongQuestions = []
        
        // 添加调试输出
        console.log("当前题目数量:", currentQuestions.length);
        console.log("用户答案:", JSON.stringify(userAnswers));
        
        for (var i = 0; i < currentQuestions.length; i++) {
            if (!currentQuestions[i]) {
                console.log("题目", i, "不存在");
                continue;
            }
            
            var userAnswer = userAnswers[i]
            if (userAnswer === undefined) {
                console.log("题目", i, "没有答案");
                continue;
            }
            
            var correctAnswer = currentQuestions[i].answer
            var isCorrect = false
            var userAnswerStr = ""
            
            console.log("处理题目", i, "正确答案:", correctAnswer);
            
            if (Array.isArray(userAnswer)) {
                // 多选题
                userAnswerStr = userAnswer.map(function(index) {
                    return String.fromCharCode(65 + index)
                }).join('')
                console.log("多选题用户答案:", userAnswerStr);
                
                // 对多选题，比较选项内容是否相同，忽略顺序
                if (userAnswerStr.length === correctAnswer.length) {
                    // 检查用户答案中的每个字符是否都在正确答案中
                    var allFound = true
                    for (var j = 0; j < userAnswerStr.length; j++) {
                        if (correctAnswer.indexOf(userAnswerStr[j]) === -1) {
                            allFound = false
                            break
                        }
                    }
                    // 检查正确答案中的每个字符是否都在用户答案中
                    if (allFound) {
                        for (var j = 0; j < correctAnswer.length; j++) {
                            if (userAnswerStr.indexOf(correctAnswer[j]) === -1) {
                                allFound = false
                                break
                            }
                        }
                    }
                    isCorrect = allFound
                } else {
                    isCorrect = false
                }
            } else {
                // 单选题或判断题
                userAnswerStr = String.fromCharCode(65 + userAnswer)
                console.log("单选题用户答案:", userAnswerStr);
                isCorrect = (userAnswerStr === correctAnswer)
            }
            
            console.log("题目", i, "是否正确:", isCorrect);
            
            if (!isCorrect) {
                wrongQuestions.push({
                    index: i,
                    question: currentQuestions[i],
                    userAnswer: userAnswer,
                    userAnswerStr: userAnswerStr
                });
                console.log("添加到错题列表:", i);
            }
        }
        
        console.log("错题列表长度:", wrongQuestions.length);
        return wrongQuestions;
    }
    
    // 结果对话框
    Dialog {
        id: pentagonResultDialog
        title: "答题结果"
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: Overlay.overlay
        width: Math.min(parent.width * 0.8, 600)
        
        property int correctCount: 0
        property int totalCount: 0
        
        background: Rectangle {
            color: "#2a2a2a"
            radius: 10
            border.color: "#3a3a3a"
            border.width: 1
        }
        
        header: Rectangle {
            color: "#333333"
            height: 50
            radius: 10
            
            Text {
                text: "答题结果"
                anchors.centerIn: parent
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                color: "white"
            }
        }
        
        contentItem: ColumnLayout {
            spacing: 20
            width: parent.width
            
            // 总体成绩
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#3c3c3c"
                radius: 8
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "您答对了 " + pentagonResultDialog.correctCount + " / " + pentagonResultDialog.totalCount + " 道题目"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 22
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "正确率: " + Math.round(pentagonResultDialog.correctCount / pentagonResultDialog.totalCount * 100) + "%"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "#2ecc71"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // 五芒图分类统计
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#3c3c3c"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: "五芒图各点答题统计"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "white"
                        font.bold: true
                    }
                    
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: 5
                        clip: true
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 30
                            color: "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                spacing: 10
                                
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    
                                    // 五芒图各点颜色
                                    color: {
                                        var colors = ["#2c70b7", "#e67e22", "#27ae60", "#8e44ad", "#e74c3c"]
                                        return colors[index]
                                    }
                                }
                                
                                Text {
                                    text: {
                                        var titles = []
                                        for (var i = 0; i < 5; i++) {
                                            var title = dbManager.getSetting("pentagon_title_" + (i+1), "")
                                            titles.push(title || "未设置")
                                        }
                                        return titles[index]
                                    }
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "white"
                                    Layout.preferredWidth: 100
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: {
                                        var stats = categoryStats[index]
                                        if (stats.total === 0) return "无题目"
                                        return stats.correct + " / " + stats.total
                                    }
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: "white"
                                }
                                
                                Text {
                                    text: {
                                        var stats = categoryStats[index]
                                        if (stats.total === 0) return ""
                                        return Math.round(stats.correct / stats.total * 100) + "%"
                                    }
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 14
                                    color: {
                                        var stats = categoryStats[index]
                                        if (stats.total === 0) return "white"
                                        var rate = stats.correct / stats.total
                                        if (rate >= 0.8) return "#2ecc71" // 绿色
                                        else if (rate >= 0.6) return "#f39c12" // 黄色
                                        else return "#e74c3c" // 红色
                                    }
                                    Layout.preferredWidth: 50
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }
            
            // 按钮区域
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 20
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "查看详情"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: parent.hovered ? "#2980b9" : "#3498db"
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        pentagonResultDialog.close()
                        analysisDialog.open()
                    }
                }
                
                Button {
                    text: "完成"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: parent.hovered ? "#16a085" : "#1abc9c"
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        pentagonResultDialog.close()
                        stackView.pop()
                    }
                }
            }
        }
    }
    
    // 错题对话框
    Dialog {
        id: wrongQuestionsDialog
        anchors.centerIn: parent
        width: 700
        height: 500
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        background: Rectangle {
            color: "#1e293b"
            radius: 12
            border.color: "#f97316"
            border.width: 2
        }
        
        contentItem: Rectangle {
            color: "transparent"
            anchors.fill: parent
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // 标题装饰图案
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 8
                    color: "#f97316"
                    
                    Text {
                        text: "错题集"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
                
                // 错题列表
                Flickable {
                    id: wrongQuestionsScrollView
                    width: parent.width
                    height: parent.height - 130
                    contentWidth: width
                    contentHeight: wrongQuestionsColumn.height
                    clip: true
                    
                    // 设置Flickable的属性以支持触摸和鼠标拖动
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    interactive: true
                    
                    // 添加ScrollBar
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        active: true
                        interactive: true
                        visible: wrongQuestionsColumn.height > wrongQuestionsScrollView.height
                    }
                    
                    Column {
                        id: wrongQuestionsColumn
                        width: parent.width - 20
                        spacing: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Repeater {
                            id: wrongQuestionsRepeater
                            model: {
                                // 添加调试输出，检查错题数量
                                var wrongQuestions = getWrongQuestions();
                                console.log("错题数量：", wrongQuestions.length);
                                return wrongQuestions;
                            }
                            
                            Rectangle {
                                width: parent.width
                                implicitHeight: wrongQuestionColumn.implicitHeight + 20
                                radius: 8
                                color: "#0f172a"
                                
                                Column {
                                    id: wrongQuestionColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 10
                                    spacing: 10
                                    
                                    // 题目标题
                                    Text {
                                        width: parent.width
                                        text: {
                                            try {
                                                return "第 " + (modelData.index + 1) + " 题：" + 
                                                       (modelData.question.options && modelData.question.options.length > 0 ? 
                                                       (modelData.question.answer.length > 1 ? "多选题" : "单选题") : "判断题");
                                            } catch(e) {
                                                console.error("显示题目标题错误:", e);
                                                return "题目标题";
                                            }
                                        }
                                        font.family: "阿里妈妈数黑体"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#f97316"
                                        wrapMode: Text.WordWrap
                                    }
                                    
                                    // 题目内容
                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(100, contentText.implicitHeight + 20)
                                        color: "#1a2942"
                                        radius: 4
                                        
                                        Text {
                                            id: contentText
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            text: {
                                                // 添加调试输出，检查内容是否能获取到
                                                console.log("错题内容：", modelData.question.content);
                                                if (modelData && modelData.question && modelData.question.content) {
                                                    return modelData.question.content;
                                                } else {
                                                    console.log("错题内容为空或不存在");
                                                    return "题目内容不可用";
                                                }
                                            }
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 16
                                            color: "white"
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideNone
                                            textFormat: Text.PlainText
                                        }
                                    }
                                    
                                    // 选项显示
                                    Rectangle {
                                        width: parent.width
                                        implicitHeight: optionsColumn.implicitHeight + 10
                                        color: "#21293a"
                                        radius: 4
                                        visible: modelData.question.options && modelData.question.options.length > 0
                                        
                                        Column {
                                            id: optionsColumn
                                            width: parent.width - 10
                                            anchors.centerIn: parent
                                            spacing: 8
                                            
                                            Repeater {
                                                model: {
                                                    if (!modelData.question.options || modelData.question.options.length === 0) {
                                                        // 判断题选项
                                                        return [
                                                            { index: 0, text: "正确" },
                                                            { index: 1, text: "错误" }
                                                        ]
                                                    }
                                                    return modelData.question.options
                                                }
                                                
                                                Row {
                                                    spacing: 10
                                                    width: parent.width
                                                    
                                                    Rectangle {
                                                        width: 25
                                                        height: 25
                                                        radius: 12.5
                                                        color: {
                                                            var userAns = modelData.index
                                                            var correctAns = modelData.question.answer
                                                            var letter = String.fromCharCode(65 + userAns)
                                                            
                                                            if (Array.isArray(modelData.userAnswer)) {
                                                                // 多选题
                                                                var isLetterInCorrectAns = correctAns.indexOf(letter) !== -1
                                                                var isUserSelected = modelData.userAnswer.includes(userAns)
                                                                
                                                                if (isUserSelected) {
                                                                    // 用户选择了此项
                                                                    return isLetterInCorrectAns ? "#22c55e" : "#ef4444"
                                                                } else {
                                                                    // 用户未选此项
                                                                    return isLetterInCorrectAns ? "#fde047" : "transparent"
                                                                }
                                                            } else {
                                                                // 单选
                                                                if (modelData.userAnswer === userAns) {
                                                                    // 用户选择了此项
                                                                    return letter === correctAns ? "#22c55e" : "#ef4444"
                                                                } else {
                                                                    // 用户未选此项
                                                                    return letter === correctAns ? "#fde047" : "transparent"
                                                                }
                                                            }
                                                        }
                                                        border.width: 1
                                                        border.color: "white"
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: String.fromCharCode(65 + modelData.index)
                                                            font.family: "阿里妈妈数黑体"
                                                            font.pixelSize: 14
                                                            color: "white"
                                                        }
                                                    }
                                                    
                                                    Text {
                                                        id: optionText
                                                        text: modelData.text
                                                        font.family: "阿里妈妈数黑体"
                                                        font.pixelSize: 14
                                                        color: "white"
                                                        width: parent.width - 35
                                                        wrapMode: Text.WordWrap
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 答案比对
                                    Rectangle {
                                        width: parent.width
                                        implicitHeight: answerCompareColumn.implicitHeight + 16
                                        color: "#0f2942"
                                        radius: 4
                                        
                                        Column {
                                            id: answerCompareColumn
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 8
                                            spacing: 8
                                            
                                            Rectangle {
                                                width: parent.width
                                                height: userAnswerText.implicitHeight + 10
                                                color: "#331e1e"
                                                radius: 4
                                                
                                                Text {
                                                    id: userAnswerText
                                                    anchors.fill: parent
                                                    anchors.margins: 5
                                                    text: "您的答案：" + modelData.userAnswerStr
                                                    font.family: "阿里妈妈数黑体"
                                                    font.pixelSize: 14
                                                    color: "#ef4444"
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                            
                                            Rectangle {
                                                width: parent.width
                                                height: correctAnswerText.implicitHeight + 10
                                                color: "#173320"
                                                radius: 4
                                                
                                                Text {
                                                    id: correctAnswerText
                                                    anchors.fill: parent
                                                    anchors.margins: 5
                                                    text: "正确答案：" + modelData.question.answer
                                                    font.family: "阿里妈妈数黑体"
                                                    font.pixelSize: 14
                                                    color: "#22c55e"
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 解析（如果有）
                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(80, analysisText.implicitHeight + 20)
                                        color: "#292524"
                                        radius: 4
                                        visible: modelData.question.analysis && modelData.question.analysis.length > 0
                                        
                                        Text {
                                            id: analysisText
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            text: {
                                                // 添加调试输出，检查解析是否能获取到
                                                console.log("错题解析：", modelData.question.analysis);
                                                if (modelData && modelData.question && modelData.question.analysis) {
                                                    return "解析：" + modelData.question.analysis;
                                                } else {
                                                    console.log("错题解析为空或不存在");
                                                    return "无解析";
                                                }
                                            }
                                            font.family: "阿里妈妈数黑体"
                                            font.pixelSize: 14
                                            color: "#fde047"
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideNone
                                            textFormat: Text.PlainText
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 如果没有错题
                        Item {
                            width: parent.width
                            height: 100
                            visible: wrongQuestionsRepeater.count === 0
                            
                            Text {
                                anchors.centerIn: parent
                                text: "恭喜您！全部答对，没有错题！"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 20
                                color: "#22c55e"
                            }
                        }
                    }
                }
                
                // 关闭按钮
                Button {
                    width: 150
                    height: 45
                    anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0891b2" }
                            GradientStop { position: 1.0; color: "#0e7490" }
                        }
                    }
                    contentItem: Text {
                        text: "返回结果页面"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        wrongQuestionsDialog.close()
                        pentagonResultDialog.open()
                    }
                }
            }
        }
        
        footer: null
    }
    
    // 消息对话框
    Dialog {
        id: messageDialog
        anchors.centerIn: parent
        width: 450
        height: 320
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        property string messageText: ""
        
        background: Rectangle {
            color: "#1e293b"
            radius: 10
            border.color: "#e11d48"
            border.width: 2
        }
        
        contentItem: Rectangle {
            color: "transparent"
            anchors.fill: parent
            
            Column {
                anchors.centerIn: parent
                spacing: 15
                width: parent.width - 60
                
                // 顶部留白
                Item {
                    width: parent.width
                    height: 10
                }
                
                // 标题
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 6
                    color: "#e11d48"
                    
                    Text {
                        text: "提示信息"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
                
                // 警告图标
                Text {
                    text: "⚠️"
                    font.pixelSize: 36
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // 消息内容区域，使用ScrollView确保内容过多时可滚动
                ScrollView {
                    width: parent.width
                    height: 120
                    clip: true
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        
                        Text {
                            width: parent.width - 20
                            text: messageDialog.messageText
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "#f0f9ff"
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                        }
                    }
                }
                
                // 确定按钮
                Button {
                    width: 120
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    background: Rectangle {
                        radius: 6
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#e11d48" }
                            GradientStop { position: 1.0; color: "#be123c" }
                        }
                    }
                    contentItem: Text {
                        text: "确定"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        messageDialog.close()
                    }
                }
                
                // 底部留白
                Item {
                    width: parent.width
                    height: 10
                }
            }
        }
        
        footer: null
    }
    
    // 确认对话框
    Dialog {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property string dialogTitle: "确认"
        property string dialogMessage: "确定执行此操作吗？"
        property var confirmAction: function() {}
        
        background: Rectangle {
            color: "#1e293b"
            radius: 10
            border.color: "#334155"
            border.width: 2
        }
        
        header: Rectangle {
            color: "#334155"
            height: 50
            radius: 8
            
            Text {
                text: confirmDialog.dialogTitle
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                width: parent.width - 40
                anchors.centerIn: parent
                text: confirmDialog.dialogMessage
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "#f0f9ff"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 70
            
            Row {
                anchors.centerIn: parent
                spacing: 30
                
                // 取消按钮
                Button {
                    width: 120
                    height: 40
                    background: Rectangle {
                        radius: 6
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#64748b" }
                            GradientStop { position: 1.0; color: "#475569" }
                        }
                    }
                    contentItem: Text {
                        text: "取消"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        confirmDialog.close()
                    }
                }
                
                // 确认按钮
                Button {
                    width: 120
                    height: 40
                    background: Rectangle {
                        radius: 6
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0891b2" }
                            GradientStop { position: 1.0; color: "#0e7490" }
                        }
                    }
                    contentItem: Text {
                        text: "确认"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        confirmDialog.confirmAction()
                        confirmDialog.close()
                    }
                }
            }
        }
    }
} 