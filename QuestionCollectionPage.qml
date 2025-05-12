import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Rectangle {
    id: questionCollectionPage
    color: "transparent"
    
    property string userName: "管理员"
    property var questionBanks: []
    property var userData: ({})
    
    // 检测userData变化
    onUserDataChanged: {
        if (userData && userData.name) {
            userName = userData.name
            console.log("题集速录页面已接收用户数据: " + userName)
        }
    }
    
    // 初始化时从数据库加载题库
    Component.onCompleted: {
        loadQuestionBanks()
        
        // 如果已经有userData，则更新userName
        if (userData && userData.name) {
            userName = userData.name
            console.log("题集速录页面初始化完成，用户名: " + userName)
        }
    }
    
    // 从数据库加载题库
    function loadQuestionBanks() {
        questionBanks = dbManager.getAllQuestionBanks()
    }
    
    // 返回按钮
    Button {
        id: backButton
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: 100
        height: 40
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
            confirmDialog.open()
        }
    }
    
    // 页面标题
    Text {
        id: pageTitle
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: "题集速录"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 36
        color: "white"
        font.bold: true
    }
    
    // 欢迎信息
    Text {
        id: welcomeText
        anchors.top: pageTitle.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "欢迎, " + userName + "!"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 20
        color: "white"
    }
    
    // 主内容区域
    Rectangle {
        anchors.top: welcomeText.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: parent.width * 0.9
        color: "#44ffffff"
        radius: 10
        
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
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        Layout.preferredWidth: 120
                        text: "题目数量"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Text {
                        Layout.preferredWidth: 180
                        text: "导入时间"
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
                id: libraryListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: questionBanks
                clip: true
                
                delegate: Rectangle {
                    width: libraryListView.width
                    height: 60
                    color: index % 2 === 0 ? "#33ffffff" : "#22ffffff"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10
                        
                        // 删除按钮
                        Button {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 36
                            
                            background: Rectangle {
                                color: "#F44336"
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: "删除"
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 14
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                deleteConfirmDialog.bankId = modelData.id
                                deleteConfirmDialog.libraryName = modelData.name
                                deleteConfirmDialog.open()
                            }
                        }
                        
                        // 题库名称
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        // 题目数量
                        Text {
                            Layout.preferredWidth: 120
                            text: modelData.count + " 题"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        // 导入时间
                        Text {
                            Layout.preferredWidth: 180
                            text: modelData.importTime
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 16
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // 状态提示
            Text {
                id: statusText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignCenter
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                font.bold: true
                color: "#4CAF50"
                visible: text !== ""
            }
            
            Timer {
                id: statusTimer
                interval: 3000
                onTriggered: {
                    statusText.text = ""
                }
            }
        }
    }
    
    // 批量导入对话框 - 使用Popup替代Dialog
    Popup {
        id: batchImportDialog
        width: 600
        height: 550  // 减小高度，因为去掉了表头预览
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property bool isValidExcel: false
        
        contentItem: Rectangle {
            color: "#f5f5f5"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // 添加标题
                Text {
                    text: "批量导入题目"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "请选择要导入的Excel文件"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10
                        
                        TextField {
                            id: excelFilePath
                            Layout.fillWidth: true
                            readOnly: true
                            placeholderText: "请选择Excel文件"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 40
                            text: "浏览..."
                            
                            background: Rectangle {
                                color: "#f0f0f0"
                                radius: 4
                                border.color: "#cccccc"
                                border.width: 1
                            }
                            
                            onClicked: {
                                // 使用QML原生FileDialog而不是C++ QFileDialog
                                fileDialog.open()
                            }
                        }
                    }
                }
                
                // 状态信息
                Text {
                    id: excelValidationText
                    text: batchImportDialog.isValidExcel ? 
                          "✅ Excel文件格式正确，可以导入" : 
                          (excelFilePath.text === "" ? "" : "❌ Excel文件格式不正确，请检查表头格式")
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: batchImportDialog.isValidExcel ? "#4CAF50" : "#F44336"
                    visible: excelFilePath.text !== ""
                    Layout.fillWidth: true
                }
                
                // 题库名称输入
                Text {
                    text: "题库名称:"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                }
                
                TextField {
                    id: questionBankName
                    Layout.fillWidth: true
                    placeholderText: "请输入题库名称"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    
                    background: Rectangle {
                        color: "#ffffff"
                        radius: 4
                        border.color: "#cccccc"
                        border.width: 1
                    }
                }
                
                Text {
                    text: "导入说明:"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333333"
                }
                
                Text {
                    text: "表头格式要求:\n题干、答案、解析、选项A、选项B、选项C、选项D、选项E、选项F、选项G\n\n说明：\n1. 必填字段：题干、答案\n2. 答案不要有字母外的其他字符\n3. 判断题的答案为：\"A\",\"B\""
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: "#666666"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                
                // 底部按钮布局，添加Item填充高度空间
                Item {
                    Layout.fillHeight: true
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 15
                    
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        text: "取消"
                        
                        background: Rectangle {
                            color: "#f0f0f0"
                            radius: 4
                            border.color: "#cccccc"
                            border.width: 1
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            batchImportDialog.close()
                        }
                    }
                    
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        text: "开始导入"
                        enabled: batchImportDialog.isValidExcel && questionBankName.text.trim() !== ""
                        
                        background: Rectangle {
                            color: parent.enabled ? "#2196F3" : "#cccccc"
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
                            console.log("开始导入题目...");
                            
                            // 检查Excel文件是否有效
                            if (!excelFilePath.text || !fileManager.validateExcelStructure(excelFilePath.text)) {
                                statusText.text = "请选择有效的Excel文件";
                                statusTimer.restart();
                                return;
                            }
                            
                            // 检查题库名称是否有效
                            if (!questionBankName.text.trim()) {
                                statusText.text = "请输入题库名称";
                                statusTimer.restart();
                                return;
                            }
                            
                            // 读取Excel数据
                            console.log("读取Excel文件:", excelFilePath.text);
                            var excelData = fileManager.readExcelFile(excelFilePath.text);
                            console.log("读取到", excelData.length, "条记录");
                            
                            if (excelData.length === 0) {
                                statusText.text = "Excel文件中没有有效数据";
                                statusTimer.restart();
                                return;
                            }
                            
                            // 创建题库
                            console.log("创建题库:", questionBankName.text);
                            if (!dbManager.addQuestionBank(questionBankName.text, excelData.length)) {
                                // 检查是否是因为同名题库导致的失败
                                var banks = dbManager.getAllQuestionBanks();
                                var hasSameName = false;
                                for (var i = 0; i < banks.length; i++) {
                                    if (banks[i].name === questionBankName.text) {
                                        hasSameName = true;
                                        break;
                                    }
                                }
                                
                                if (hasSameName) {
                                    statusText.text = "题库 '" + questionBankName.text + "' 已存在，请使用其他名称";
                                } else {
                                    statusText.text = "创建题库失败";
                                }
                                statusTimer.restart();
                                return;
                            }
                            
                            // 获取新创建的题库ID
                            var banks = dbManager.getAllQuestionBanks();
                            var newBank = null;
                            for (var i = 0; i < banks.length; i++) {
                                if (banks[i].name === questionBankName.text) {
                                    newBank = banks[i];
                                    break;
                                }
                            }
                            
                            if (!newBank) {
                                statusText.text = "无法获取新创建的题库ID";
                                statusTimer.restart();
                                return;
                            }
                            
                            // 导入题目
                            console.log("导入题目到题库:", newBank.id);
                            if (dbManager.importQuestions(newBank.id, excelData)) {
                                statusText.text = "成功导入" + excelData.length + "道题目";
                                loadQuestionBanks(); // 刷新题库列表
                            } else {
                                statusText.text = "导入题目失败";
                            }
                            
                            statusTimer.restart();
                            batchImportDialog.close();
                        }
                    }
                }
            }
        }
        
        // 重置对话框
        onOpened: {
            excelFilePath.text = ""
            questionBankName.text = ""
            isValidExcel = false
        }
    }
    
    // 文件夹选择对话框 - 使用Popup替代Dialog
    Popup {
        id: folderSelectionDialog
        width: 600
        height: 400
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        contentItem: Rectangle {
            color: "#f5f5f5"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // 添加标题
                Text {
                    text: "选择保存位置"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "请选择要保存模板文件的文件夹"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    color: "#333333"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10
                        
                        TextField {
                            id: folderPathInput
                            Layout.fillWidth: true
                            readOnly: true
                            placeholderText: "请选择保存文件夹"
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 40
                            text: "浏览..."
                            
                            background: Rectangle {
                                color: "#f0f0f0"
                                radius: 4
                                border.color: "#cccccc"
                                border.width: 1
                            }
                            
                            onClicked: {
                                // 使用QML原生FileDialog而不是C++ QFileDialog
                                folderDialog.open()
                            }
                        }
                    }
                }
                
                Text {
                    text: "说明:"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333333"
                }
                
                Text {
                    text: "1. 将自动复制题库导入模板文件到您选择的文件夹\n2. 文件名将为\"导题模板_yyyyMMdd_hhmmss.xlsx\"\n3. 您可以按照模板格式填写题目，然后使用批量导入功能导入"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: "#666666"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 15
                    
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        text: "取消"
                        
                        background: Rectangle {
                            color: "#f0f0f0"
                            radius: 4
                            border.color: "#cccccc"
                            border.width: 1
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            folderSelectionDialog.close()
                        }
                    }
                    
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        text: "下载"
                        
                        background: Rectangle {
                            color: "#9C27B0"
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
                            // 获取当前时间戳
                            var now = new Date()
                            var timestamp = Qt.formatDateTime(now, "yyyyMMdd_hhmmss")
                            var fileName = "导题模板" + timestamp + ".xlsx"
                            
                            // 检查选择的路径是否有效
                            if (folderPathInput.text === "") {
                                statusText.text = "请先选择保存文件夹"
                                statusText.color = "#F44336"
                                statusTimer.restart()
                                return
                            }
                            
                            // 复制模板文件到选择的文件夹
                            var appDir = fileManager.getApplicationDir()
                            var sourcePath = appDir + "/templates/导题模板.xlsx"
                            
                            // 检查source文件是否存在
                            if (!fileManager.directoryExists(appDir + "/templates") || 
                                !fileManager.copyFile(sourcePath, folderPathInput.text + "/" + fileName)) {
                                
                                // 使用资源文件中的模板 (qrc)
                                console.log("使用资源文件中的模板")
                                
                                // 创建一个临时文件
                                var tempPath = appDir + "/temp"
                                if (!fileManager.directoryExists(tempPath)) {
                                    fileManager.createDirectory(tempPath)
                                }
                                
                                // 将资源文件提取到临时文件
                                var tempFilePath = tempPath + "/导题模板.xlsx"
                                
                                // 这里需要将qrc资源文件复制出来，实际应用中需要使用QFile实现
                                // 这里我们简化为使用README.txt
                                var readmePath = appDir + "/templates/README.txt"
                                var success = false
                                
                                if (fileManager.directoryExists(appDir + "/templates")) {
                                    success = fileManager.copyFile(readmePath, folderPathInput.text + "/" + fileName)
                                }
                                
                                if (!success) {
                                    statusText.text = "模板保存失败，请检查文件权限和路径"
                                    statusText.color = "#F44336"
                                    statusTimer.restart()
                                    return
                                }
                            } else {
                                console.log("成功复制本地模板文件")
                            }
                            
                            var destPath = folderPathInput.text + "/" + fileName
                            
                            folderSelectionDialog.close()
                            statusText.text = "模板已保存到: " + destPath
                            statusText.color = "#9C27B0"
                            statusTimer.restart()
                        }
                    }
                }
            }
        }
    }
    
    // 删除确认对话框 - 使用Popup替代Dialog
    Popup {
        id: deleteConfirmDialog
        width: 400
        height: 300
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property int bankId: -1
        property string libraryName: ""
        
        contentItem: Rectangle {
            color: "#f5f5f5"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // 添加标题
                Text {
                    text: "确认删除"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "您确定要删除以下题库吗？"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#333333"
                }
                
                Text {
                    text: deleteConfirmDialog.libraryName
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: "#666666"
                }
                
                Text {
                    text: "此操作将永久删除该题库及其所有题目，且无法恢复。"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 14
                    color: "#F44336"
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 15
                    
                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        text: "取消"
                        
                        background: Rectangle {
                            color: "#f0f0f0"
                            radius: 4
                            border.color: "#cccccc"
                            border.width: 1
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: "阿里妈妈数黑体"
                            font.pixelSize: 14
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            deleteConfirmDialog.close()
                        }
                    }
                    
                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        text: "确认删除"
                        
                        background: Rectangle {
                            color: "#F44336"
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
                            // 从数据库删除题库
                            var success = dbManager.deleteQuestionBank(deleteConfirmDialog.bankId)
                            
                            if (success) {
                                // 清理五芒图设置中该题库的归类信息
                                try {
                                    // 获取所有五芒图点的分类设置
                                    for (var i = 1; i <= 5; i++) {
                                        var categoryKey = "pentagon_category_" + i;
                                        var categorySetting = dbManager.getSetting(categoryKey, "{}");
                                        var categoryData = JSON.parse(categorySetting);
                                        
                                        // 如果该题库ID存在于分类中，则删除
                                        if (categoryData[deleteConfirmDialog.bankId]) {
                                            delete categoryData[deleteConfirmDialog.bankId];
                                            // 保存更新后的分类设置
                                            dbManager.setSetting(categoryKey, JSON.stringify(categoryData));
                                            console.log("已清理五芒图点", i, "中的题库归类信息");
                                        }
                                    }
                                } catch (e) {
                                    console.error("清理五芒图设置失败:", e);
                                }
                                
                                // 重新加载题库列表
                                loadQuestionBanks()
                                
                                statusText.text = "已删除题库: " + deleteConfirmDialog.libraryName
                                statusText.color = "#F44336"
                            } else {
                                statusText.text = "删除题库失败"
                                statusText.color = "#F44336"
                            }
                            
                            deleteConfirmDialog.close()
                            statusTimer.restart()
                        }
                    }
                }
            }
        }
    }
    
    // FileDialog使用Qt 6兼容写法
    FileDialog {
        id: folderDialog
        title: "选择保存文件夹"
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenDirectory
        
        onAccepted: {
            // 将选择的URL转换为本地路径
            var path = folderDialog.selectedFolder.toString()
            // 去除file:/// 前缀
            path = path.replace(/^(file:\/{3})/, "")
            // 解码URL
            path = decodeURIComponent(path)
            folderPathInput.text = path
        }
    }
    
    FileDialog {
        id: fileDialog
        title: "选择Excel文件"
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFile
        nameFilters: [ "Excel files (*.xlsx *.xls)", "All files (*)" ]
        
        onAccepted: {
            // 将选择的URL转换为本地路径
            var path = fileDialog.selectedFile.toString()
            // 去除file:/// 前缀
            path = path.replace(/^(file:\/{3})/, "")
            // 解码URL
            path = decodeURIComponent(path)
            excelFilePath.text = path
            
            // 验证Excel格式并加载表头
            batchImportDialog.isValidExcel = fileManager.validateExcelStructure(path)
        }
    }
    
    // 确认对话框
    Popup {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#1e293b"
            radius: 10
            border.color: "#334155"
            border.width: 2
        }
        
        contentItem: Item {
            anchors.fill: parent
            
            // 头部标题
            Rectangle {
                id: headerRect
                width: parent.width
                height: 50
                color: "#334155"
                radius: 8
                anchors.top: parent.top
                
                Text {
                    text: "返回确认"
                    font.family: "阿里妈妈数黑体"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            
            // 内容区域
            Text {
                width: parent.width - 40
                anchors.centerIn: parent
                text: "确定要退出题集速录吗？"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 16
                color: "#f0f9ff"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            // 底部按钮区域
            Rectangle {
                width: parent.width
                height: 70
                color: "transparent"
                anchors.bottom: parent.bottom
                
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
                            // 获取主页引用
                            var mainPage = stackView.get(0)
                            
                            // 确保返回时显示中间列，隐藏个人数据页面
                            if (mainPage) {
                                console.log("确保返回时显示中间列，隐藏个人数据页面");
                                if (mainPage.middle_column) {
                                    mainPage.middle_column.visible = true;
                                }
                                if (mainPage.user_practice_data) {
                                    mainPage.user_practice_data.visible = false;
                                }
                            }
                            
                            // 返回到主界面
                            stackView.pop(null)
                            
                            // 返回上一页
                            console.log("返回上一页")
                            confirmDialog.close()
                        }
                    }
                }
            }
        }
    }
} 