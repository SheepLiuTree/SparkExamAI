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
    
    // 顶部导航栏
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "transparent"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20
            
            Button {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
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
            stackView.pop()
        }
    }
    
    Text {
                text: "星火日课 - " + (userData ? userData.name : "用户")
        font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
        color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
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
                    
                    Button {
                        Layout.fillWidth: true
                        height: 40
                        background: Rectangle {
                            color: "#2c70b7"
                            radius: 4
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
            var message = "还有题目未作答：第 " + unanswered.join("、") + " 题"
            console.log(message)
            return
        }
        
        // 计算得分
        var score = 0
        var total = currentQuestions.length
        
        for (var i = 0; i < currentQuestions.length; i++) {
            var question = currentQuestions[i]
            var userAnswer = userAnswers[i]
            var correctAnswer = question.answer
            
            if (Array.isArray(userAnswer)) {
                // 多选题
                var userAnswerStr = userAnswer.map(function(index) {
                    return String.fromCharCode(65 + index)
                }).join('')
                if (userAnswerStr === correctAnswer) {
                    score++
                }
            } else {
                // 单选题或判断题
                var userAnswerStr = String.fromCharCode(65 + userAnswer)
                if (userAnswerStr === correctAnswer) {
                    score++
                }
            }
        }
        
        console.log("得分：" + score + "/" + total)
    }
} 