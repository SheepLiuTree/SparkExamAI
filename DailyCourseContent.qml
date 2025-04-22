import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "transparent"
    
    property var userData
    property var currentQuestions: []  // 当前题目列表
    property int currentQuestionIndex: 0  // 当前题目索引
    property var userAnswers: ({})  // 用户答案记录
    
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
        
        // 从各个题库中抽取题目
        currentQuestions = []
        for (var bankId in distributions) {
            var count = distributions[bankId]
            if (count > 0) {
                var questions = dbManager.getRandomQuestions(bankId, count)
                currentQuestions = currentQuestions.concat(questions)
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
    
    // 辅助函数：查找mainPage组件
    function findMainPage(parent) {
        if (!parent) return null
        for (var i = 0; i < parent.children.length; i++) {
            var child = parent.children[i]
            if (child.objectName === "mainPage") {
                return child
            }
            
            // 递归搜索子项的子项
            var result = findMainPage(child)
            if (result) return result
        }
        return null
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
                    // 如果有用户数据，更新练习数据
                    if (userData && userData.workId) {
                        console.log("返回时准备更新用户数据，工号: " + userData.workId)
                        
                        try {
                            // 获取应用程序窗口并调用全局更新函数
                            var rootWindow = Qt.application.activeWindow
                            if (rootWindow && typeof rootWindow.updateUserData === "function") {
                                var success = rootWindow.updateUserData(userData.workId)
                                console.log("通过全局函数更新用户数据：" + (success ? "成功" : "失败"))
                                
                                // 同时更新首页排序
                                if (typeof rootWindow.updateUserListSorting === "function") {
                                    var sortUpdateSuccess = rootWindow.updateUserListSorting()
                                    console.log("通过全局函数更新首页排序：" + (sortUpdateSuccess ? "成功" : "失败"))
                                }
                            } else {
                                console.error("无法获取根窗口或更新函数不存在")
                                
                                // 备用方法：尝试手动查找组件
                                var mainPageItem = findMainPage(stackView)
                                
                                if (mainPageItem) {
                                    console.log("成功找到mainPage")
                                    // 找到user_practice_data
                                    var practiceDataItem = null
                                    for (var i = 0; i < mainPageItem.children.length; i++) {
                                        var child = mainPageItem.children[i]
                                        if (child.objectName === "user_practice_data") {
                                            practiceDataItem = child
                                            break
                                        }
                                    }
                                    
                                    if (practiceDataItem) {
                                        console.log("成功找到user_practice_data")
                                        // 先清空ID然后设置ID以确保触发变更
                                        practiceDataItem.currentUserId = ""
                                        practiceDataItem.currentUserId = userData.workId
                                        practiceDataItem.loadUserPracticeData(userData.workId)
                                        console.log("已直接调用更新用户练习数据函数，工号：" + userData.workId)
                                        
                                        // 手动更新首页排序
                                        if (mainPageItem.personal_page_column) {
                                            console.log("尝试手动更新首页排序")
                                            Qt.callLater(function() {
                                                mainPageItem.personal_page_column.loadUserListFromDatabase()
                                                console.log("已手动调用首页排序更新")
                                            })
                                        }
                                    }
                                }
                            }
                        } catch (e) {
                            console.error("更新用户数据时发生错误:", e)
                        }
                    }
                    
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
    
    // 提交答案
    function submitAnswers() {
        // 检查是否所有题目都已作答
        var unanswered = []
        for (var i = 0; i < currentQuestions.length; i++) {
            if (userAnswers[i] === undefined || 
                (Array.isArray(userAnswers[i]) && userAnswers[i].length === 0)) {
                unanswered.push(i + 1)
            }
        }
        
        if (unanswered.length > 0) {
            // 显示未答题提示
            var message = ""
            
            if (unanswered.length <= 5) {
                message = "您有题目尚未作答：\n第 " + unanswered.join("、") + " 题"
            } else {
                // 如果未答题目较多，只显示数量和题号
                message = "您有 " + unanswered.length + " 道题目尚未作答：\n第 "
                
                // 所有题号一起显示，用顿号分隔
                message += unanswered.join("、") + " 题"
            }
            
            console.log(message)
            // 显示提示对话框
            messageDialog.messageText = message
            messageDialog.open()
            return
        }
        
        // 计算得分
        var score = 0
        var total = currentQuestions.length
        var detailedAnswers = []
        
        // 收集题库和分类信息
        var questionBanks = {}
        var pentagonTypes = {}
        
        for (var i = 0; i < currentQuestions.length; i++) {
            var question = currentQuestions[i]
            var userAnswer = userAnswers[i]
            var correctAnswer = question.answer
            var isCorrect = false
            var userAnswerStr = ""
            
            // 获取题库信息
            var bankId = question.bankId
            console.log("题目ID:", question.id, "题库ID:", bankId, "类型:", typeof bankId)
            
            // 确保bankId是有效值
            if (bankId === undefined || bankId === null) {
                console.error("题库ID无效:", bankId)
                bankId = -1 // 使用默认值
            }
            
            var bankInfo = dbManager.getQuestionBankById(bankId)
            console.log("题库信息:", JSON.stringify(bankInfo))
            var bankName = bankInfo && bankInfo.name ? bankInfo.name : "未知题库"
            console.log("最终题库名称:", bankName)
            
            // 获取五芒图分类信息
            var pentagonType = "未分类"
            try {
                // 记录题库ID的类型
                console.log("bankId类型:", typeof bankId, "值:", bankId)
                
                // 尝试不同格式的题库ID
                var bankIdStr = String(bankId)
                var bankIdNum = parseInt(bankId)
                
                console.log("检查bankId不同格式:", bankIdStr, bankIdNum)
                
                for (var j = 1; j <= 5; j++) {
                    var categoryKey = "pentagon_category_" + j
                    var categorySetting = dbManager.getSetting(categoryKey, "{}")
                    console.log("五芒图点", j, "设置:", categorySetting)
                    
                    try {
                        var categoryData = JSON.parse(categorySetting)
                        
                        // 打印出categoryData的内容和类型
                        console.log("五芒图点", j, "数据:", JSON.stringify(categoryData))
                        
                        // 尝试不同格式的bankId进行匹配
                        var found = false
                        
                        if (categoryData[bankIdStr] === true) {
                            console.log("找到匹配(字符串ID):", bankIdStr)
                            found = true
                        } else if (categoryData[bankIdNum] === true) {
                            console.log("找到匹配(数字ID):", bankIdNum)
                            found = true
                        } else {
                            // 遍历所有键寻找匹配
                            for (var key in categoryData) {
                                if (categoryData[key] === true) {
                                    console.log("检查键:", key, "类型:", typeof key, "与bankId比较:", key == bankIdStr, key == bankIdNum)
                                    if (key == bankIdStr || key == bankIdNum) {
                                        console.log("通过键比较找到匹配:", key)
                                        found = true
                                        break
                                    }
                                }
                            }
                        }
                        
                        if (found) {
                            // 获取该点的标题
                            var titleKey = "pentagon_title_" + j
                            var title = dbManager.getSetting(titleKey, "")
                            console.log("找到分类:", title, "对应五芒图点:", j)
                            if (title && title.length > 0) {
                                pentagonType = title
                                break
                            }
                        }
                    } catch (e) {
                        console.error("解析五芒图点", j, "分类数据失败:", e)
                    }
                }
                console.log("最终确定的题目分类:", pentagonType)
            } catch (e) {
                console.error("解析五芒图分类失败:", e, "题库ID:", bankId)
            }
            
            // 统计题库和分类信息
            if (questionBanks[bankName]) {
                questionBanks[bankName]++
            } else {
                questionBanks[bankName] = 1
            }
            
            if (pentagonTypes[pentagonType]) {
                pentagonTypes[pentagonType]++
            } else {
                pentagonTypes[pentagonType] = 1
            }
            
            if (Array.isArray(userAnswer)) {
                // 多选题
                userAnswerStr = userAnswer.map(function(index) {
                    return String.fromCharCode(65 + index)
                }).join('')
                
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
                isCorrect = (userAnswerStr === correctAnswer)
            }
            
            if (isCorrect) {
                score++
            }
            
            // 记录详细答题数据
            detailedAnswers.push({
                "questionId": question.id,
                "questionContent": question.content,
                "correctAnswer": correctAnswer,
                "userAnswer": userAnswerStr,
                "isCorrect": isCorrect,
                "bankId": bankId,
                "bankName": bankName,
                "pentagonType": pentagonType
            })
        }
        
        console.log("得分：" + score + "/" + total)
        
        // 准备保存到数据库的数据
        var answerData = JSON.stringify(detailedAnswers)
        
        // 准备题库和五芒图分类信息
        var questionBankInfoArray = []
        var pentagonTypeInfoArray = []
        
        // 先过滤掉重复项，并记录每个类型数量、正确数量和正确率
        var bankCounts = {}
        var bankCorrects = {}
        var typeCounts = {}
        var typeCorrects = {}
        
        for (var i = 0; i < detailedAnswers.length; i++) {
            var answer = detailedAnswers[i]
            var bankName = answer.bankName || "未知题库"
            var pentagonType = answer.pentagonType || "未分类"
            var isCorrect = answer.isCorrect || false
            
            // 记录题库数量和正确数
            if (bankCounts[bankName] === undefined) {
                bankCounts[bankName] = 0
                bankCorrects[bankName] = 0
            }
            bankCounts[bankName]++
            if (isCorrect) {
                bankCorrects[bankName]++
            }
            
            // 记录分类数量和正确数
            if (typeCounts[pentagonType] === undefined) {
                typeCounts[pentagonType] = 0
                typeCorrects[pentagonType] = 0
            }
            typeCounts[pentagonType]++
            if (isCorrect) {
                typeCorrects[pentagonType]++
            }
        }
        
        // 生成统计字符串
        for (var bank in bankCounts) {
            var bankTotal = bankCounts[bank]
            var bankCorrect = bankCorrects[bank]
            var bankRate = Math.round(bankCorrect / bankTotal * 100)
            questionBankInfoArray.push(bank + "：" + bankTotal + "题，正确" + bankCorrect + "题，正确率" + bankRate + "%")
        }
        
        for (var type in typeCounts) {
            var typeTotal = typeCounts[type]
            var typeCorrect = typeCorrects[type]
            var typeRate = Math.round(typeCorrect / typeTotal * 100)
            pentagonTypeInfoArray.push(type + "：" + typeTotal + "题，正确" + typeCorrect + "题，正确率" + typeRate + "%")
        }
        
        // 排序显示（可选）
        questionBankInfoArray.sort()
        pentagonTypeInfoArray.sort()
        
        var questionBankInfoStr = questionBankInfoArray.join("，")
        var pentagonTypeInfoStr = pentagonTypeInfoArray.join("，")
        
        console.log("题库分布:", questionBankInfoStr)
        console.log("能力分布:", pentagonTypeInfoStr)
        
        // 检查用户数据是否存在
        if (!userData || !userData.workId) {
            console.error("用户数据不存在，无法保存答题记录")
            messageDialog.messageText = "用户数据不存在，无法保存答题记录"
            messageDialog.open()
            return
        }
        
        // 保存到数据库
        var success = dbManager.saveUserAnswerRecord(
            userData.workId,
            userData.name,
            "星火日课",
            total,
            score,
            answerData,
            questionBankInfoStr,
            pentagonTypeInfoStr
        )
        
        if (success) {
            console.log("答题记录已保存到数据库")
            
            // 显示得分结果
            resultDialog.score = score
            resultDialog.total = total
            resultDialog.percentage = Math.round(score / total * 100)
            resultDialog.questionBankInfo = questionBankInfoStr
            resultDialog.pentagonTypeInfo = pentagonTypeInfoStr
            resultDialog.open()
        } else {
            console.error("保存答题记录失败")
            messageDialog.messageText = "保存答题记录失败，请重试"
            messageDialog.open()
        }
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
        id: resultDialog
        anchors.centerIn: parent
        width: 500
        height: 360
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        property int score: 0
        property int total: 0
        property int percentage: 0
        property string questionBankInfo: ""
        property string pentagonTypeInfo: ""
        
        background: Rectangle {
            color: "#1e293b"
            radius: 12
            border.color: "#2c70b7"
            border.width: 2
        }
        
        contentItem: Rectangle {
            color: "transparent"
            anchors.fill: parent
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width - 60
                
                // 标题装饰图案
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 8
                    color: "#2c70b7"
                    
                    Text {
                        text: "✨ 星火日课结果 ✨"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
                
                Text {
                    text: "恭喜完成本次学习任务！"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    color: "#f0f9ff"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // 分数展示区域
                Rectangle {
                    width: parent.width
                    height: 80
                    radius: 8
                    color: "#0c4a82"
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 15
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "得分"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "#a5f3fc"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: resultDialog.score + "/" + resultDialog.total
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        
                        Rectangle {
                            width: 1
                            height: 50
                            color: "#4d84b8"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "正确率"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "#a5f3fc"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: resultDialog.percentage + "%"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 24
                                font.bold: true
                                color: {
                                    var percent = resultDialog.percentage
                                    if (percent >= 90) return "#4ade80"
                                    else if (percent >= 80) return "#22d3ee"
                                    else if (percent >= 60) return "#fcd34d"
                                    else return "#f87171"
                                }
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
                
                // 评价显示
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 8
                    color: {
                        var percent = resultDialog.percentage
                        if (percent >= 90) return "#064e3b"
                        else if (percent >= 80) return "#065f46"
                        else if (percent >= 60) return "#854d0e"
                        else return "#7f1d1d"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: {
                            var percent = resultDialog.percentage
                            if (percent >= 90) return "评价：优秀，继续保持！🏆"
                            else if (percent >= 80) return "评价：良好，再接再厉！👍"
                            else if (percent >= 60) return "评价：及格，需要更多努力！💪"
                            else return "评价：需要加强复习，不要气馁！📚"
                        }
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "#ffffff"
                        width: parent.width - 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                // 按钮行
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // 退出按钮
                    Button {
                        width: 150
                        height: 45
                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#64748b" }
                                GradientStop { position: 1.0; color: "#475569" }
                            }
                        }
                        contentItem: Text {
                            text: "退出"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            confirmDialog.dialogTitle = "退出确认"
                            confirmDialog.dialogMessage = "确定要退出星火日课吗？"
                            confirmDialog.confirmAction = function() {
                                // 关闭结果对话框
                                resultDialog.close()
                                
                                // 如果有用户数据，更新练习数据
                                if (userData && userData.workId) {
                                    console.log("准备更新用户数据，工号: " + userData.workId)
                                    
                                    try {
                                        // 获取应用程序窗口并调用全局更新函数
                                        var rootWindow = Qt.application.activeWindow
                                        if (rootWindow && typeof rootWindow.updateUserData === "function") {
                                            var success = rootWindow.updateUserData(userData.workId)
                                            console.log("通过全局函数更新用户数据：" + (success ? "成功" : "失败"))
                                            
                                            // 同时更新首页排序
                                            if (typeof rootWindow.updateUserListSorting === "function") {
                                                var sortUpdateSuccess = rootWindow.updateUserListSorting()
                                                console.log("通过全局函数更新首页排序：" + (sortUpdateSuccess ? "成功" : "失败"))
                                            }
                                        } else {
                                            console.error("无法获取根窗口或更新函数不存在")
                                            
                                            // 备用方法：尝试手动查找组件
                                            var mainPageItem = findMainPage(stackView)
                                            
                                            if (mainPageItem) {
                                                console.log("成功找到mainPage")
                                                // 找到user_practice_data
                                                var practiceDataItem = null
                                                for (var i = 0; i < mainPageItem.children.length; i++) {
                                                    var child = mainPageItem.children[i]
                                                    if (child.objectName === "user_practice_data") {
                                                        practiceDataItem = child
                                                        break
                                                    }
                                                }
                                                
                                                if (practiceDataItem) {
                                                    console.log("成功找到user_practice_data")
                                                    // 先清空ID然后设置ID以确保触发变更
                                                    practiceDataItem.currentUserId = ""
                                                    practiceDataItem.currentUserId = userData.workId
                                                    practiceDataItem.loadUserPracticeData(userData.workId)
                                                    console.log("已直接调用更新用户练习数据函数，工号：" + userData.workId)
                                                }
                                                
                                                // 手动更新首页排序
                                                if (mainPageItem.personal_page_column) {
                                                    console.log("尝试手动更新首页排序")
                                                    Qt.callLater(function() {
                                                        mainPageItem.personal_page_column.loadUserListFromDatabase()
                                                        console.log("已手动调用首页排序更新")
                                                    })
                                                }
                                            }
                                        }
                                    } catch (e) {
                                        console.error("更新用户数据时发生错误:", e)
                                    }
                                }
                                
                                // 退出到主界面
                                stackView.pop()
                            }
                            confirmDialog.open()
                        }
                    }
                    
                    // 查看错题按钮
                    Button {
                        width: 150
                        height: 45
                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#2563eb" }
                                GradientStop { position: 1.0; color: "#1d4ed8" }
                            }
                        }
                        contentItem: Text {
                            text: "查看错题"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            resultDialog.close()
                            wrongQuestionsDialog.open()
                        }
                    }
                }
            }
        }
        
        footer: null
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
                        resultDialog.open()
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