import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "transparent"
    
    property var userData
    property int questionBankId: -1
    property string questionBankName: ""
    property bool wrongQuestionsMode: false
    
    property var currentQuestions: []
    property int currentQuestionIndex: 0
    property var userAnswers: ({})
    property var wrongQuestionIds: []
    
    // 新增：记录本次新产生的错题ID集合
    property var newWrongQuestionIds: []
    
    // 当前多选题选中的选项
    property var currentMultiSelections: []
    
    // 从数据库加载题目
    function loadQuestions() {
        currentQuestions = []
        userAnswers = {}
        
        // 重置新产生的错题ID
        newWrongQuestionIds = []
        
        if (wrongQuestionsMode) {
            // 加载错题
            if (userData && userData.workId) {
                // 直接从新的用户错题表加载错题ID
                console.log("准备从错题表加载错题，题库ID:", questionBankId)
                wrongQuestionIds = dbManager.getUserWrongQuestionIds(userData.workId, questionBankId)
                console.log("从错题表加载错题ID:", wrongQuestionIds)
                
                // 如果用户错题表中没有数据，尝试从旧的答题记录中提取错题
                if (wrongQuestionIds.length === 0) {
                    console.log("错题表中无数据，尝试从旧答题记录中提取")
                    var records = dbManager.getUserAnswerRecords(userData.workId, 1000, 0)
                    var tempWrongIds = []
                    
                    // 遍历用户的答题记录，找出当前题库的错题
                    for (var i = 0; i < records.length; i++) {
                        var record = records[i]
                        var answerData = JSON.parse(record.answer_data || "{}")
                        var bankInfo = JSON.parse(record.question_bank_info || "{}")
                        
                        // 检查是否包含当前题库的题目
                        for (var questionId in answerData) {
                            // 检查题目是否属于当前题库
                            var bankId = bankInfo[questionId]
                            // 确保两个值都是数字类型进行比较
                            if (parseInt(bankId) === parseInt(questionBankId)) {
                                // 检查是否答错
                                var questionAnswer = answerData[questionId]
                                if (questionAnswer && !questionAnswer.correct) {
                                    tempWrongIds.push(parseInt(questionId))
                                }
                            }
                        }
                    }
                    
                    // 移除重复的题目ID
                    wrongQuestionIds = [...new Set(tempWrongIds)]
                    console.log("从旧记录加载错题ID:", wrongQuestionIds)
                    
                    // 保存错题到新表中
                    if (wrongQuestionIds.length > 0) {
                        var updateSuccess = dbManager.updateUserWrongQuestions(userData.workId, questionBankId, wrongQuestionIds)
                        console.log("更新错题集" + (updateSuccess ? "成功" : "失败"))
                    }
                }
                
                // 加载每个错题的详细信息
                for (var j = 0; j < wrongQuestionIds.length; j++) {
                    var question = dbManager.getQuestionById(wrongQuestionIds[j])
                    if (Object.keys(question).length > 0) {
                        currentQuestions.push(question)
                    }
                }
            }
        } else {
            // 加载所有题目（顺序模式）
            currentQuestions = dbManager.getQuestionsByBankId(questionBankId)
        }
        
        // 重置当前题目索引
        currentQuestionIndex = 0
        
        console.log("加载题目完成，共", currentQuestions.length, "道题目")
        
        // 更新UI显示状态
        noQuestionsText.visible = (currentQuestions.length === 0)
        questionsContainer.visible = (currentQuestions.length > 0)
        
        // 如果没有题目，显示提示信息
        if (currentQuestions.length === 0) {
            if (wrongQuestionsMode) {
                noQuestionsText.text = "暂无错题记录"
            } else {
                noQuestionsText.text = "该题库暂无题目"
            }
            return;
        }
        
        // 加载用户之前的题库进度
        if (userData && userData.workId && !wrongQuestionsMode) {
            var progress = dbManager.getUserBankProgress(userData.workId, questionBankId)
            
            if (progress.hasProgress) {
                // 恢复题目索引和用户答案
                currentQuestionIndex = progress.currentQuestionIndex
                if (currentQuestionIndex >= currentQuestions.length) {
                    currentQuestionIndex = 0;
                }
                
                // 恢复用户答案
                var savedAnswers = JSON.parse(progress.userAnswers || "{}")
                userAnswers = savedAnswers
                
                console.log("已恢复用户进度，当前题目索引:", currentQuestionIndex, "已答题数:", Object.keys(userAnswers).length)
                
                // 恢复当前题目的状态
                restoreTemporarySelections()
            }
        }
        
        // 强制更新UI
        refresh()
    }
    
    // 强制刷新UI
    function refresh() {
        // 通知数据模型已更新
        var temp = currentQuestionIndex
        currentQuestionIndex = -1
        currentQuestionIndex = temp
        
        // 触发绑定更新
        currentQuestionsChanged()
        currentQuestionIndexChanged()
    }
    
    // 获取题目类型
    function getQuestionType(question) {
        if (!question) return "";
        
        // 直接判断题目类型
        if (question.type === "判断题") return "判断题";
        
        // 有选项的情况
        if (question.options && question.options.length > 0) {
            // 根据答案长度判断是单选题还是多选题
            var answer = question.answer || "";
            // 如果答案长度大于1，则为多选题，否则为单选题
            return answer.length > 1 ? "多选题" : "单选题";
        }
        
        // 无选项的情况：视为判断题
        return "判断题";
    }
    
    // 处理判断题无选项情况，生成A/B选项
    function getDisplayOptions(question) {
        if (!question) return [];
        
        // 如果是判断题且没有选项，则生成标准选项
        if (getQuestionType(question) === "判断题" && 
            (!question.options || question.options.length === 0)) {
            return ["正确", "错误"];
        }
        
        // 如果题目有选项，直接返回
        if (question.options && question.options.length > 0) {
            return question.options;
        }
        
        // 默认返回空数组
        return [];
    }
    
    // 保存答题记录和更新错题集
    function saveAnswerRecord() {
        if (!userData || !userData.workId || Object.keys(userAnswers).length === 0) {
            console.log("无需保存答题记录")
            return
        }
        
        var correctCount = 0
        var totalAnswered = 0
        var wrongQuestions = []
        
        // 计算正确题目数量和收集错题
        for (var questionId in userAnswers) {
            totalAnswered++
            if (userAnswers[questionId].correct) {
                correctCount++
            } else {
                // 收集错题ID
                wrongQuestions.push(parseInt(questionId))
            }
        }
        
        if (totalAnswered === 0) {
            console.log("没有回答任何题目，不保存记录")
            return
        }
        
        // 准备题库信息，记录每个题目属于哪个题库
        var questionBankInfo = {}
        for (var i = 0; i < currentQuestions.length; i++) {
            var question = currentQuestions[i]
            questionBankInfo[question.id] = questionBankId
        }
        
        // 保存答题记录
        var examType = wrongQuestionsMode ? "错题练习" : "顺序练习"
        var success = dbManager.saveUserAnswerRecord(
            userData.workId,
            userData.name,
            examType + "-" + questionBankName,
            totalAnswered,
            correctCount,
            JSON.stringify(userAnswers),
            JSON.stringify(questionBankInfo)
        )
        
        console.log("保存答题记录" + (success ? "成功" : "失败"))
        
        // 顺序刷题模式下，保存本次新产生的错题
        if (!wrongQuestionsMode && newWrongQuestionIds.length > 0) {
            saveNewWrongQuestions();
        }
        // 错题刷题模式下，更新错题集
        else if (wrongQuestionsMode) {
            var updateSuccess = dbManager.updateUserWrongQuestions(
                userData.workId, 
                questionBankId, 
                wrongQuestionIds
            )
            console.log("更新错题集" + (updateSuccess ? "成功" : "失败") + "，共" + wrongQuestionIds.length + "道错题")
        }
        
        // 保存用户当前的题库进度
        saveUserProgress()
    }
    
    // 保存本次新产生的错题到错题集
    function saveNewWrongQuestions() {
        if (!userData || !userData.workId || newWrongQuestionIds.length === 0) {
            return;
        }
        
        console.log("准备保存新产生的错题，题库ID:", questionBankId);
        console.log("新错题ID列表:", newWrongQuestionIds);
        
        // 先获取现有错题集
        var existingWrongQuestionIds = dbManager.getUserWrongQuestionIds(userData.workId, questionBankId);
        console.log("现有错题ID列表:", existingWrongQuestionIds);
        
        // 将新错题合并到现有错题集中
        var allWrongQuestionIds = existingWrongQuestionIds.slice();
        for (var i = 0; i < newWrongQuestionIds.length; i++) {
            var questionId = newWrongQuestionIds[i];
            if (allWrongQuestionIds.indexOf(questionId) === -1) {
                allWrongQuestionIds.push(questionId);
            }
        }
        
        // 更新错题集
        var updateSuccess = dbManager.updateUserWrongQuestions(
            userData.workId, 
            questionBankId, 
            allWrongQuestionIds
        );
        console.log("保存新错题" + (updateSuccess ? "成功" : "失败") + 
                   "，新增" + newWrongQuestionIds.length + "道错题，" +
                   "错题集现共有" + allWrongQuestionIds.length + "道题");
        
        // 清空新产生的错题集合
        newWrongQuestionIds = [];
    }
    
    // 保存用户进度到数据库
    function saveUserProgress() {
        if (!userData || !userData.workId) {
            console.log("无法保存进度：未登录用户")
            return
        }
        
        // 当前是错题模式不保存进度
        if (wrongQuestionsMode) return
        
        var success = dbManager.saveUserBankProgress(
            userData.workId,
            questionBankId,
            currentQuestionIndex,
            JSON.stringify(userAnswers)
        )
        
        console.log("保存用户题库进度" + (success ? "成功" : "失败"))
    }
    
    // 清空用户题库进度
    function clearUserProgress() {
        if (!userData || !userData.workId) {
            console.log("无法清空进度：未登录用户")
            return
        }
        
        // 当前是错题模式不清空进度
        if (wrongQuestionsMode) return
        
        var success = dbManager.deleteUserBankProgress(
            userData.workId,
            questionBankId
        )
        
        if (success) {
            // 重置内存中的数据
            userAnswers = {}
            currentQuestionIndex = 0
            
            // 隐藏答案分析面板
            answerPanel.visible = false
            
            // 清空选项选择
            clearSelections()
            
            // 清空填空题输入
            fillAnswerInput.text = ""
            
            // 刷新UI
            refresh()
            
            console.log("清空用户题库进度成功")
        } else {
            console.log("清空用户题库进度失败")
        }
    }
    
    // 检查一个选项是否已选中
    function isOptionSelected(index) {
        return currentMultiSelections.indexOf(String.fromCharCode(65 + index)) !== -1;
    }
    
    // 添加或移除选项
    function toggleOption(index) {
        var option = String.fromCharCode(65 + index);
        var pos = currentMultiSelections.indexOf(option);
        
        if (pos === -1) {
            // 添加选项
            currentMultiSelections.push(option);
        } else {
            // 移除选项
            currentMultiSelections.splice(pos, 1);
        }
        
        // 触发UI更新
        var temp = currentMultiSelections;
        currentMultiSelections = [];
        currentMultiSelections = temp;
    }
    
    // 清空已选项
    function clearSelections() {
        currentMultiSelections = [];
        currentMultiSelectionsChanged();
    }
    
    // 提交多选题答案
    function submitMultiAnswer() {
        if (currentMultiSelections.length === 0) return;
        
        // 排序选项以保持一致性
        currentMultiSelections.sort();
        var answer = currentMultiSelections.join("");
        submitAnswer(answer);
        
        // 清空选择
        clearSelections();
    }
    
    // 提交当前题目的答案
    function submitAnswer(answer) {
        if (currentQuestionIndex >= currentQuestions.length) return
        
        var currentQuestion = currentQuestions[currentQuestionIndex]
        var questionId = currentQuestion.id
        var correctAnswer = currentQuestion.answer
        
        // 用于判断正确性的答案变量
        var answerForCheck = answer
        
        // 判断题处理
        if (getQuestionType(currentQuestion) === "判断题") {
            if (answer === "A" || answer === "B") {
                // 将A/B转换为正确/错误（用于存储和比较）
                answerForCheck = answer === "A" ? "正确" : "错误"
            }
            
            // 如果系统存储的正确答案是A/B，则转换为正确/错误进行比较
            if (correctAnswer === "A" || correctAnswer === "B") {
                correctAnswer = correctAnswer === "A" ? "正确" : "错误"
            }
        }
        
        var isCorrect = (correctAnswer === answerForCheck)
        
        // 记录用户答案（保存转换后的答案以确保正确性检查）
        userAnswers[questionId] = {
            userAnswer: answerForCheck,
            correct: isCorrect,
            correctAnswer: correctAnswer
        }
        
        // 通知答题卡更新
        userAnswersChanged()
        
        // 错题刷题模式下，如果答对了，从错题集中移除
        if (wrongQuestionsMode && isCorrect && userData && userData.workId) {
            removeFromWrongQuestions(questionId);
            return; // 移除错题函数会处理UI更新
        } else if (!wrongQuestionsMode && !isCorrect) {
            // 顺序刷题模式下，如果答错了，记录到新错题集合中
            if (newWrongQuestionIds.indexOf(questionId) === -1) {
                newWrongQuestionIds.push(questionId);
                console.log("将题目添加到新错题集中:", questionId);
                console.log("当前新错题集:", newWrongQuestionIds);
            }
        }
        
        // 显示答案分析
        answerAnalysisText.text = currentQuestion.analysis || "无解析"
        
        // 处理显示的答案文本
        var displayUserAnswer = answerForCheck
        var displayCorrectAnswer = correctAnswer
        
        // 判断题特殊处理显示
        if (getQuestionType(currentQuestion) === "判断题") {
            displayUserAnswer = answerForCheck === "正确" ? "A" : "B"
            displayCorrectAnswer = correctAnswer === "正确" ? "A" : "B"
        }
        
        answerResultText.text = isCorrect ? 
            "回答正确！我的答案：" + displayUserAnswer : 
            "回答错误！正确答案：" + displayCorrectAnswer + "，我的答案：" + displayUserAnswer
        answerResultText.color = isCorrect ? "#4CAF50" : "#F44336"
        answerPanel.visible = true
        
        // 调试信息
        console.log("题目类型:", getQuestionType(currentQuestion), 
                   "用户选择:", answer, 
                   "转换后答案:", answerForCheck, 
                   "正确答案:", correctAnswer, 
                   "是否正确:", isCorrect)
        
        // 保存用户题库进度
        saveUserProgress()
    }
    
    // 从错题集中移除指定题目
    function removeFromWrongQuestions(questionId) {
        console.log("准备从错题集移除题目:", questionId, "当前错题总数:", wrongQuestionIds.length);
        
        // 在currentQuestions中找出所有除当前题目外的错题ID
        var remainingWrongQuestionIds = [];
        for (var i = 0; i < wrongQuestionIds.length; i++) {
            if (wrongQuestionIds[i] !== questionId) {
                remainingWrongQuestionIds.push(wrongQuestionIds[i]);
            }
        }
        
        // 更新内存中的错题ID列表
        var questionRemoved = remainingWrongQuestionIds.length < wrongQuestionIds.length;
        wrongQuestionIds = remainingWrongQuestionIds;
        console.log("更新后的错题ID列表:", JSON.stringify(wrongQuestionIds), "长度:", wrongQuestionIds.length);
        
        // 更新数据库中的错题记录
        var updateSuccess = dbManager.updateUserWrongQuestions(
            userData.workId, 
            questionBankId, 
            remainingWrongQuestionIds // 即使是空数组也能被正确处理
        );
        console.log("从错题集移除题目" + (updateSuccess ? "成功" : "失败") + ", 剩余错题数:" + remainingWrongQuestionIds.length);
        
        // 在答题完成时提示用户
        if (questionRemoved) {
            // 记录该题目已从错题集移除
            var questionIdStr = questionId.toString();
            if (!userAnswers[questionIdStr]) {
                userAnswers[questionIdStr] = { 
                    removedFromWrongQuestions: true,
                    correct: true  // 确保此题被标记为正确答案
                };
            } else {
                userAnswers[questionIdStr].removedFromWrongQuestions = true;
                userAnswers[questionIdStr].correct = true;  // 确保此题被标记为正确答案
            }
            
            if (wrongQuestionIds.length === 0) {
                // 没有错题了，显示完成提示
                answerResultText.text += "\n\n恭喜！你已经完成了所有错题！";
                
                // 启用完成按钮（通过强制设置answerPanel.visible为true）
                answerPanel.visible = true;
                
                // 延迟显示完成对话框
                Qt.setTimeout(function() {
                    var correctCount = 0;
                    var totalAnswered = Object.keys(userAnswers).length;
                    var removedCount = 0;
                    
                    for (var qId in userAnswers) {
                        if (userAnswers[qId].correct) {
                            correctCount++;
                        }
                        if (userAnswers[qId].removedFromWrongQuestions) {
                            removedCount++;
                        }
                    }
                    
                    completionDialog.dialogMessage = "错题练习完成！\n" + 
                        "共练习 " + totalAnswered + " 道错题\n" +
                        "本次答对 " + correctCount + " 道\n" +
                        "已从错题集移除 " + removedCount + " 道题";
                    
                    completionDialog.open();
                }, 2000); // 2秒后显示完成对话框
            } else {
                // 还有错题，显示已移除提示
                answerResultText.text += "\n\n回答正确！该题已从错题集中移除。";
                
                // 启用下一题按钮
                answerPanel.visible = true;
            }
        }
    }
    
    // 前往下一题
    function nextQuestion() {
        if (currentQuestionIndex < currentQuestions.length - 1) {
            // 如果当前题目已作答，则清除临时选择状态
            // 否则保存临时选择的状态为当前题目的答案
            saveTemporarySelections();
            
            currentQuestionIndex++;
            console.log("前往下一题:", currentQuestionIndex + 1);
            
            answerPanel.visible = false;
            fillAnswerInput.text = "";
            clearSelections();
            
            // 如果当前题目已有用户临时选择，恢复选择状态
            restoreTemporarySelections();
            
            // 保存用户题库进度
            saveUserProgress();
            
            // 强制刷新UI
            refresh();
        } else {
            // 已经是最后一题，保存记录
            saveTemporarySelections();
            saveAnswerRecord();
            
            // 错题刷题模式下，显示不同的完成信息
            var correctCount = 0;
            var totalAnswered = Object.keys(userAnswers).length;
            var removedCount = 0;
            
            for (var questionId in userAnswers) {
                if (userAnswers[questionId].correct) {
                    correctCount++;
                }
                if (userAnswers[questionId].removedFromWrongQuestions) {
                    removedCount++;
                }
            }
            
            if (wrongQuestionsMode) {
                completionDialog.dialogMessage = "错题练习完成！\n" + 
                    "共练习 " + totalAnswered + " 道错题\n" +
                    "本次答对 " + correctCount + " 道\n" +
                    "已从错题集移除 " + removedCount + " 道题";
                
                console.log("错题练习结束统计 - 总题数:", totalAnswered, 
                           "答对:", correctCount, 
                           "移除:", removedCount);
            } else {
                var wrongCount = totalAnswered - correctCount;
                var newWrongCount = newWrongQuestionIds.length;
                completionDialog.dialogMessage = "练习完成！\n" + 
                    "共完成 " + totalAnswered + " 道题目\n" + 
                    "正确 " + correctCount + " 道，错误 " + wrongCount + " 道\n" +
                    "本次新增错题 " + newWrongCount + " 道";
            }
            
            completionDialog.open();
        }
    }
    
    // 前往上一题
    function previousQuestion() {
        if (currentQuestionIndex > 0) {
            // 保存当前题目的临时选择状态
            saveTemporarySelections();
            
            currentQuestionIndex--;
            console.log("前往上一题:", currentQuestionIndex + 1);
            
            answerPanel.visible = false;
            fillAnswerInput.text = "";
            clearSelections();
            
            // 恢复之前题目的临时选择状态
            restoreTemporarySelections();
            
            // 保存用户题库进度
            saveUserProgress();
            
            // 强制刷新UI
            refresh();
        }
    }
    
    // 保存临时选择的状态
    function saveTemporarySelections() {
        if (currentQuestionIndex >= currentQuestions.length) return;
        
        var currentQuestion = currentQuestions[currentQuestionIndex];
        var questionId = currentQuestion.id;
        
        // 如果当前题目已有答案，不要清除
        if (userAnswers[questionId]) return;
        
        // 如果是多选题且有选择，保存临时选择
        if (currentMultiSelections.length > 0 && getQuestionType(currentQuestion) === "多选题") {
            // 排序并拼接为答案
            var tempSelections = [...currentMultiSelections];
            tempSelections.sort();
            var answer = tempSelections.join("");
            
            // 记录为临时答案
            userAnswers[questionId] = {
                userAnswer: answer,
                correct: answer === currentQuestion.answer,
                correctAnswer: currentQuestion.answer,
                isTemporary: true  // 标记为临时答案
            };
            
            // 保存用户进度
            saveUserProgress();
        }
    }
    
    // 恢复临时选择状态
    function restoreTemporarySelections() {
        if (currentQuestionIndex >= currentQuestions.length) return;
        
        var currentQuestion = currentQuestions[currentQuestionIndex];
        var questionId = currentQuestion.id;
        
        // 清除当前选择状态
        clearSelections();
        
        // 如果当前题目有临时答案且是多选题，恢复选择状态
        if (userAnswers[questionId] && getQuestionType(currentQuestion) === "多选题") {
            var answer = userAnswers[questionId].userAnswer;
            
            // 将答案拆分为单个字母，作为选项索引
            for (var i = 0; i < answer.length; i++) {
                var optionIndex = answer.charCodeAt(i) - 65;  // 'A' 的 ASCII 码为 65
                if (optionIndex >= 0 && optionIndex < currentQuestion.options.length) {
                    toggleOption(optionIndex);
                }
            }
        }
        
        // 如果当前题目已有答案，显示答案分析
        if (userAnswers[questionId]) {
            answerAnalysisText.text = currentQuestion.analysis || "无解析";
            
            // 处理显示的答案文本
            var displayUserAnswer = userAnswers[questionId].userAnswer
            var displayCorrectAnswer = userAnswers[questionId].correctAnswer
            
            // 判断题特殊处理显示
            if (getQuestionType(currentQuestion) === "判断题") {
                displayUserAnswer = displayUserAnswer === "正确" ? "A" : "B"
                displayCorrectAnswer = displayCorrectAnswer === "正确" ? "A" : "B"
            }
            
            answerResultText.text = userAnswers[questionId].correct ? 
                "回答正确！我的答案：" + displayUserAnswer : 
                "回答错误！正确答案：" + displayCorrectAnswer + "，我的答案：" + displayUserAnswer;
            answerResultText.color = userAnswers[questionId].correct ? "#4CAF50" : "#F44336";
            answerPanel.visible = true;
        }
    }
    
    // 导航到指定题目
    function navigateToQuestion(index) {
        if (index >= 0 && index < currentQuestions.length && index !== currentQuestionIndex) {
            // 保存当前题目状态
            saveTemporarySelections();
            
            // 切换到新题目
            currentQuestionIndex = index;
            console.log("导航到题目:", index + 1);
            
            // 重置界面状态
            answerPanel.visible = false;
            fillAnswerInput.text = "";
            clearSelections();
            
            // 恢复选择状态
            restoreTemporarySelections();
            
            // 强制刷新UI
            refresh();
        }
    }
    
    // 获取题目答题状态
    function getQuestionStatus(index) {
        if (index < 0 || index >= currentQuestions.length) return "unanswered"
        
        var questionId = currentQuestions[index].id
        if (userAnswers[questionId]) {
            return userAnswers[questionId].correct ? "correct" : "wrong"
        }
        return "unanswered"
    }
    
    // 获取当前题目的用户选择
    function getQuestionUserAnswer(questionId) {
        if (userAnswers[questionId]) {
            return userAnswers[questionId].userAnswer;
        }
        return null;
    }
    
    // 检查选项是否为当前用户答案
    function isOptionUserAnswer(index) {
        if (currentQuestionIndex >= currentQuestions.length) return false;
        
        var currentQuestion = currentQuestions[currentQuestionIndex];
        var questionId = currentQuestion.id;
        
        // 获取用户答案
        var userAnswer = getQuestionUserAnswer(questionId);
        if (!userAnswer) return false;
        
        // 单选题
        if (getQuestionType(currentQuestion) !== "多选题") {
            var optionLetter = String.fromCharCode(65 + index);
            return userAnswer === optionLetter;
        }
        // 多选题
        else {
            // 多选题，检查字母是否在用户答案中
            var optionLetter = String.fromCharCode(65 + index);
            return userAnswer.indexOf(optionLetter) !== -1;
        }
    }
    
    // 获取选项的显示颜色
    function getOptionColor(index) {
        if (currentQuestionIndex >= currentQuestions.length) return "#55000000";
        
        var currentQuestion = currentQuestions[currentQuestionIndex];
        var questionId = currentQuestion.id;
        
        // 检查题目是否已答
        if (!userAnswers[questionId]) {
            // 未提交答案，显示选中状态
            return isOptionSelected(index) ? "#335599" : "#55000000";
        }
        
        // 已提交答案，显示正确/错误状态
        var optionLetter = String.fromCharCode(65 + index);
        var correctAnswer = currentQuestion.answer;
        var isCorrectOption = correctAnswer.indexOf(optionLetter) !== -1;
        var isUserSelectedOption = isOptionUserAnswer(index);
        
        if (isCorrectOption) {
            // 正确选项总是显示绿色
            return "#4CAF50";
        } else if (isUserSelectedOption) {
            // 用户选择了错误选项，显示红色
            return "#F44336";
        }
        
        // 默认背景色
        return "#55000000";
    }
    
    // 页面初始化时加载题目
    Component.onCompleted: {
        loadQuestions()
        
        // 在第一次加载时，如果是错题模式但没有找到错题，尝试分析答题记录找出错题
        if (wrongQuestionsMode && currentQuestions.length === 0 && userData && userData.workId) {
            console.log("尝试从答题记录中提取错题...")
            
            // 从答题记录中查找错题
            var records = dbManager.getUserAnswerRecords(userData.workId, 1000, 0)
            var wrongIds = []
            
            // 遍历用户的答题记录，找出当前题库的错题
            for (var i = 0; i < records.length; i++) {
                var record = records[i]
                var answerData = JSON.parse(record.answer_data || "{}")
                var bankInfo = JSON.parse(record.question_bank_info || "{}")
                
                // 检查是否包含当前题库的题目
                for (var questionId in answerData) {
                    // 检查题目是否属于当前题库
                    var bankId = bankInfo[questionId]
                    // 确保两个值都是数字类型进行比较
                    if (parseInt(bankId) === parseInt(questionBankId)) {
                        // 检查是否答错
                        var questionAnswer = answerData[questionId]
                        if (questionAnswer && !questionAnswer.correct) {
                            wrongIds.push(parseInt(questionId))
                        }
                    }
                }
            }
            
            // 移除重复的题目ID
            wrongQuestionIds = [...new Set(wrongIds)]
            
            if (wrongQuestionIds.length > 0) {
                console.log("从答题记录找到", wrongQuestionIds.length, "道错题")
                
                // 更新错题集
                var updateSuccess = dbManager.updateUserWrongQuestions(userData.workId, questionBankId, wrongQuestionIds)
                console.log("更新错题集" + (updateSuccess ? "成功" : "失败"))
                
                // 重新加载错题
                for (var j = 0; j < wrongQuestionIds.length; j++) {
                    var question = dbManager.getQuestionById(wrongQuestionIds[j])
                    if (Object.keys(question).length > 0) {
                        currentQuestions.push(question)
                    }
                }
                
                // 更新UI
                if (currentQuestions.length > 0) {
                    noQuestionsText.visible = false;
                    questionsContainer.visible = true;
                    // 强制刷新UI
                    refresh();
                }
            }
        }
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
                // 显示确认对话框
                confirmDialog.dialogTitle = "返回确认"
                confirmDialog.dialogMessage = "确定要返回题库列表吗？\n当前练习进度将会保存。"
                confirmDialog.confirmAction = function() {
                    // 保存临时选择
                    saveTemporarySelections()
                    
                    // 保存答题记录
                    saveAnswerRecord()
                    
                    // 返回上一页
                    stackView.pop()
                }
                confirmDialog.open()
            }
        }
        
        // 清空数据按钮，放在返回按钮右侧（只在非错题模式下显示）
        Button {
            id: clearDataButton
            width: 150
            height: 40
            anchors.left: backButton.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: !wrongQuestionsMode // 只在顺序练习模式下显示
            background: Image {
                source: "qrc:/images/button_bg.png"
                fillMode: Image.Stretch
            }
            contentItem: Text {
                text: "清空答题数据"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                // 显示确认对话框
                confirmDialog.dialogTitle = "清空数据确认"
                confirmDialog.dialogMessage = "确定要清空该题库的所有答题数据吗？\n注意：错题集不会被清空。"
                confirmDialog.confirmAction = function() {
                    // 清空用户题库进度
                    clearUserProgress()
                }
                confirmDialog.open()
            }
        }
        
        // 标题文本，放在中央
        Text {
            text: questionBankName + (wrongQuestionsMode ? " - 错题练习" : " - 顺序练习") + " - " + (userData ? userData.name : "用户")
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
        anchors.right: answerCardPanel.left
        anchors.bottom: parent.bottom
        anchors.margins: 20
        color: "#44ffffff"
        radius: 10
        
        // 无题目时显示的提示文本
        Text {
            id: noQuestionsText
            visible: currentQuestions.length === 0
            text: wrongQuestionsMode ? "暂无错题记录" : "该题库暂无题目"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 24
            color: "white"
            anchors.centerIn: parent
        }
        
        // 有题目时显示的内容
        Rectangle {
            id: questionsContainer
            visible: currentQuestions.length > 0
            anchors.fill: parent
            color: "transparent"
            
            // 题目进度信息
            Rectangle {
                id: progressInfoArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "transparent"
                
                Text {
                    text: "题目 " + (currentQuestionIndex + 1) + " / " + currentQuestions.length
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 18
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            
            // 题目内容区域
            Rectangle {
                id: questionContentArea
                anchors.top: progressInfoArea.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: navigationArea.top
                anchors.margins: 10
                color: "#66000000"
                radius: 10
                
                // 内容垂直布局
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    // 题目类型
                    Text {
                        Layout.fillWidth: true
                        text: currentQuestions.length > 0 && currentQuestionIndex < currentQuestions.length ? 
                              getQuestionType(currentQuestions[currentQuestionIndex]) : ""
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 18
                        color: "#AADDFF"
                    }
                    
                    // 题目内容
                    Text {
                        Layout.fillWidth: true
                        text: currentQuestions.length > 0 && currentQuestionIndex < currentQuestions.length ? 
                              currentQuestions[currentQuestionIndex].content : ""
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        wrapMode: Text.WordWrap
                    }
                    
                    // 选项区域（选择题）
                    Column {
                        id: optionsColumn
                        Layout.fillWidth: true
                        spacing: 10
                        visible: currentQuestions.length > 0 && 
                                currentQuestionIndex < currentQuestions.length
                        
                        property bool isMultiSelect: currentQuestions.length > 0 && 
                                                    currentQuestionIndex < currentQuestions.length ? 
                                                    getQuestionType(currentQuestions[currentQuestionIndex]) === "多选题" : false
                        
                        Repeater {
                            id: optionsRepeater
                            model: currentQuestions.length > 0 && 
                                   currentQuestionIndex < currentQuestions.length ? 
                                   getDisplayOptions(currentQuestions[currentQuestionIndex]) : []
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 50
                                color: getOptionColor(index)
                                radius: 5
                                
                                // 选项标记（A、B、C、D...）
                                Text {
                                    id: optionLabel
                                    text: String.fromCharCode(65 + index)  // A, B, C, D...
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 20
                                    color: "white"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                // 选项内容
                                Text {
                                    text: modelData.text || modelData
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 18
                                    color: "white"
                                    anchors.left: optionLabel.right
                                    anchors.leftMargin: 20
                                    anchors.right: parent.right
                                    anchors.rightMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    wrapMode: Text.WordWrap
                                }
                                
                                // 点击选择答案
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (!answerPanel.visible) {
                                            var currentQuestion = currentQuestions[currentQuestionIndex];
                                            var questionId = currentQuestion.id;
                                            
                                            // 如果题目已经有答案，不允许再次作答
                                            if (userAnswers[questionId] && !userAnswers[questionId].isTemporary) {
                                                return;
                                            }
                                            
                                            if (optionsColumn.isMultiSelect) {
                                                // 多选题只改变选中状态
                                                toggleOption(index);
                                            } else {
                                                // 单选题直接提交答案
                                                submitAnswer(String.fromCharCode(65 + index));
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 当模型变化时强制刷新
                            onModelChanged: {
                                console.log("选项模型更新:", count, "个选项")
                            }
                        }
                        
                        // 多选题提交按钮
                        Button {
                            visible: optionsColumn.isMultiSelect && !answerPanel.visible
                            width: 120
                            height: 40
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            background: Rectangle {
                                color: "#0078d7"
                                radius: 5
                            }
                            contentItem: Text {
                                text: "提交答案"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (currentMultiSelections.length > 0) {
                                    submitMultiAnswer();
                                }
                            }
                        }
                    }
                    
                    // 填空题答案输入区域
                    Rectangle {
                        Layout.fillWidth: true
                        height: 120
                        color: "#55000000"
                        radius: 5
                        visible: false // 根据需求，不显示填空题区域
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                text: "请输入答案："
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "white"
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#33ffffff"
                                radius: 5
                                
                                TextArea {
                                    id: fillAnswerInput
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                }
                            }
                            
                            Button {
                                Layout.alignment: Qt.AlignRight
                                width: 100
                                height: 30
                                background: Rectangle {
                                    color: "#0078d7"
                                    radius: 5
                                }
                                contentItem: Text {
                                    text: "提交"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (!answerPanel.visible && fillAnswerInput.text.trim() !== "") {
                                        submitAnswer(fillAnswerInput.text.trim())
                                    }
                                }
                            }
                        }
                    }
                    
                    // 答案分析面板
                    Rectangle {
                        id: answerPanel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#55000000"
                        radius: 5
                        visible: false
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                id: answerResultText
                                Layout.fillWidth: true
                                text: "回答正确！"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 20
                                color: "#4CAF50"
                            }
                            
                            Text {
                                text: "解析："
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 18
                                color: "#AADDFF"
                            }
                            
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                
                                Text {
                                    id: answerAnalysisText
                                    width: parent.width
                                    text: "无解析"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }
            
            // 导航区域
            Rectangle {
                id: navigationArea
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 80
                color: "transparent"
                
                RowLayout {
                    anchors.centerIn: parent
                    width: parent.width * 0.7
                    spacing: 30
                    
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        enabled: currentQuestionIndex > 0
                        opacity: enabled ? 1.0 : 0.6
                        background: Rectangle {
                            color: parent.enabled ? "#2c70b7" : "#666666"
                            radius: 4
                        }
                        contentItem: Text {
                            text: "上一题"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            previousQuestion()
                        }
                    }
                    
                    Button {
                        id: nextButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        enabled: answerPanel.visible || currentQuestionIndex < currentQuestions.length - 1
                        opacity: enabled ? 1.0 : 0.6
                        background: Rectangle {
                            color: parent.enabled ? "#2c70b7" : "#666666"
                            radius: 4
                        }
                        contentItem: Text {
                            text: currentQuestionIndex < currentQuestions.length - 1 ? "下一题" : "完成"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            nextQuestion()
                        }
                    }
                }
            }
        }
    }
    
    // 确认对话框
    Dialog {
        id: confirmDialog
        width: 400
        height: 200
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        property string dialogTitle: "确认"
        property string dialogMessage: "确定要执行此操作吗？"
        property var confirmAction: function() {}
        
        background: Rectangle {
            color: "#333333"
            radius: 10
            border.color: "#555555"
            border.width: 1
        }
        
        header: Rectangle {
            color: "#444444"
            height: 40
            radius: 10
            
            Text {
                text: confirmDialog.dialogTitle
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                text: confirmDialog.dialogMessage
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "white"
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width - 40
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 60
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Button {
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: "#666666"
                        radius: 5
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
                
                Button {
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: "#0078d7"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "确定"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
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
    
    // 完成对话框
    Dialog {
        id: completionDialog
        width: 400
        height: 200
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape
        
        property string dialogMessage: "练习完成！"
        
        background: Rectangle {
            color: "#333333"
            radius: 10
            border.color: "#555555"
            border.width: 1
        }
        
        header: Rectangle {
            color: "#444444"
            height: 40
            radius: 10
            
            Text {
                text: "练习完成"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        contentItem: Rectangle {
            color: "transparent"
            
            Text {
                text: completionDialog.dialogMessage
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "white"
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width - 40
            }
        }
        
        footer: Rectangle {
            color: "transparent"
            height: 60
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Button {
                    width: 150
                    height: 40
                    background: Rectangle {
                        color: "#0078d7"
                        radius: 5
                    }
                    contentItem: Text {
                        text: "返回题库列表"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        completionDialog.close()
                        stackView.pop()
                    }
                }
            }
        }
    }
    
    // 答题卡面板
    Rectangle {
        id: answerCardPanel
        width: 220
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        color: "#44ffffff"
        radius: 10
        
        // 标题
        Rectangle {
            id: answerCardTitle
            width: parent.width
            height: 40
            anchors.top: parent.top
            color: "#33000000"
            radius: 10
            
            Text {
                text: "答题卡"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 18
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        // 答题统计
        Rectangle {
            id: answerStats
            width: parent.width
            height: 60
            anchors.top: answerCardTitle.bottom
            anchors.topMargin: 10
            color: "transparent"
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                // 已答题数
                Column {
                    spacing: 5
                    Text {
                        text: Object.keys(userAnswers).length
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "已答题"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "#cccccc"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                // 未答题数
                Column {
                    spacing: 5
                    Text {
                        text: currentQuestions.length - Object.keys(userAnswers).length
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "未答题"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "#cccccc"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        
        // 答题卡网格
        GridView {
            id: answerCardGrid
            anchors.top: answerStats.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            clip: true
            
            cellWidth: width / 4 // 每行4个
            cellHeight: 40
            model: currentQuestions.length
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                anchors.right: parent.right
                anchors.rightMargin: -8
            }
            
            delegate: Rectangle {
                width: answerCardGrid.cellWidth - 4
                height: 36
                radius: 5
                
                // 根据状态显示不同颜色
                color: {
                    var status = getQuestionStatus(index)
                    if (status === "correct") return "#4CAF50"  // 正确为绿色
                    else if (status === "wrong") return "#F44336"  // 错误为红色
                    else return "#55ffffff"  // 未答题为半透明白色
                }
                
                // 当前题目高亮边框
                border.width: currentQuestionIndex === index ? 2 : 0
                border.color: "#FFEB3B"  // 当前题目黄色边框
                
                // 题号
                Text {
                    text: (index + 1)
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "white"
                    anchors.centerIn: parent
                }
                
                // 点击导航到对应题目
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        navigateToQuestion(index)
                    }
                }
            }
        }
    }
} 