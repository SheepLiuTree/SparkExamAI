import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: thisPage
    color: "transparent"
    
    property var userData
    property var selectedQuestionBank: null
    property bool wrongQuestionsMode: false
    
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
                    return title || "未分类";
                }
            }
            return "未分类";
        } catch (e) {
            console.error("获取题库分类失败:", e);
            return "未分类";
        }
    }
    
    // 获取所有题库
    function loadQuestionBanks() {
        var banks = dbManager.getAllQuestionBanks()
        questionBankModel.clear()
        
        for (var i = 0; i < banks.length; i++) {
            var bank = banks[i]
            var category = getBankCategory(bank.id)
            
            // 获取错题数量（如果用户已登录）
            var wrongCount = 0
            if (userData && userData.workId) {
                var wrongQuestionIds = dbManager.getUserWrongQuestionIds(userData.workId, bank.id)
                wrongCount = wrongQuestionIds.length
            }
            
            questionBankModel.append({
                id: bank.id,
                name: bank.name,
                questionCount: bank.count,
                wrongCount: wrongCount,
                category: category
            })
        }
        
        console.log("加载题库完成，共", questionBankModel.count, "个题库")
    }
    
    // 添加一个单独的计时器组件用于页面返回刷新
    Timer {
        id: refreshTimer
        interval: 200
        repeat: false
        onTriggered: {
            console.log("定时器触发，刷新题库列表")
            loadQuestionBanks()
        }
    }
    
    // 当页面可见性变化时触发刷新
    onVisibleChanged: {
        if (visible) {
            console.log("页面变为可见，刷新题库列表")
            refreshTimer.start()
        }
    }
    
    // 开始顺序刷题
    function startSequentialPractice(bankId, bankName) {
        selectedQuestionBank = {
            id: bankId,
            name: bankName
        }
        wrongQuestionsMode = false
        
        // 打开练习页面
        var properties = {
            userData: userData,
            questionBankId: bankId,
            questionBankName: bankName,
            wrongQuestionsMode: false
        }
        
        stackView.push("QuestionPracticePage.qml", properties)
    }
    
    // 开始错题刷题
    function startWrongQuestionsPractice(bankId, bankName) {
        selectedQuestionBank = {
            id: bankId,
            name: bankName
        }
        wrongQuestionsMode = true
        
        // 打开练习页面
        var properties = {
            userData: userData,
            questionBankId: bankId,
            questionBankName: bankName,
            wrongQuestionsMode: true
        }
        
        stackView.push("QuestionPracticePage.qml", properties)
    }
    
    Component.onCompleted: {
        loadQuestionBanks()
    }
    
    // 当用户数据变化时，重新加载题库以更新错题数量
    onUserDataChanged: {
        loadQuestionBanks()
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
                confirmDialog.dialogMessage = "确定要返回上一页吗？"
                confirmDialog.confirmAction = function() {
                    // 如果当前有用户数据，尝试更新用户的练习数据
                    if (userData && userData.workId) {
                        try {
                            // 尝试直接通过根对象调用全局函数
                            var root = stackView.parent
                            var updateSuccess = false
                            
                            if (root && typeof root.updateUserData === "function") {
                                // 尝试使用全局函数
                                updateSuccess = root.updateUserData(userData.workId)
                                console.log("使用根对象全局函数更新用户数据: " + updateSuccess)
                            }
                            
                            // 如果全局函数调用失败，尝试直接访问mainPage
                            if (!updateSuccess) {
                                var mainPageItem = findMainPage(stackView)
                                if (mainPageItem) {
                                    console.log("找到mainPage，尝试直接访问user_practice_data")
                                    var practiceDataItem = mainPageItem.user_practice_data
                                    
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
                    
                    // 确保返回时显示中间列，隐藏个人数据页面
                    var mainPage = stackView.get(0)
                    if (mainPage) {
                        console.log("确保返回时显示中间列，隐藏个人数据页面");
                        if (mainPage.middle_column) {
                            mainPage.middle_column.visible = true;
                        }
                        if (mainPage.user_practice_data) {
                            mainPage.user_practice_data.visible = false;
                        }
                    }
                    
                    stackView.pop()
                }
                confirmDialog.open()
            }
        }
        
        // 标题文本，放在中央
        Text {
            text: "星火特训 - " + (userData ? userData.name : "用户")
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
        
        // 标题区域
        Rectangle {
            id: titleArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            color: "transparent"
            
            Image {
                id: titleBackground
                source: "qrc:/images/title_bg.png"
                fillMode: Image.PreserveAspectFit
                width: 400
                height: 150
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -20
                
                Text {
                    text: "题库列表"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 26
                    color: "white"
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        // 题库列表区域
        Rectangle {
            id: questionBankArea
            anchors.top: titleArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            color: "transparent"
            
            // 题库模型
            ListModel {
                id: questionBankModel
            }
            
            // 题库列表视图
            GridView {
                id: questionBankGridView
                anchors.fill: parent
                anchors.margins: 10
                cellWidth: 300
                cellHeight: 200
                model: questionBankModel
                clip: true
                
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                
                delegate: Rectangle {
                    width: 280
                    height: 180
                    color: "#66000000"
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            text: model.name
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 20
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "分类: " + model.category
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "#A5D6FF"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Text {
                                text: "题目数量: " + model.questionCount
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "#cccccc"
                            }
                            
                            Text {
                                text: "错题数量: " + model.wrongCount
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 16
                                color: "#FFB6C1"
                            }
                        }
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Button {
                                width: 120
                                height: 40
                                background: Image {
                                    source: "qrc:/images/button_bg.png"
                                    fillMode: Image.Stretch
                                }
                                contentItem: Text {
                                    text: "顺序刷题"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    startSequentialPractice(model.id, model.name)
                                }
                            }
                            
                            Button {
                                width: 120
                                height: 40
                                background: Image {
                                    source: "qrc:/images/button_bg.png"
                                    fillMode: Image.Stretch
                                }
                                contentItem: Text {
                                    text: "错题刷题"
                                    font.family: "阿里妈妈数黑体"
                                    font.pixelSize: 16
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    startWrongQuestionsPractice(model.id, model.name)
                                }
                            }
                        }
                    }
                }
            }
            
            // 空状态显示
            Text {
                visible: questionBankModel.count === 0
                text: "暂无题库，请先添加题库"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 20
                color: "white"
                anchors.centerIn: parent
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
} 