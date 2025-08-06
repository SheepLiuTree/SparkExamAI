import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: passwordDialog
    
    property string titleText: "密码验证"
    property string passwordLabel: "密码："
    property string nameLabel: "姓名："
    property string workIdLabel: "工号："
    property string defaultPassword: "123456"
    property bool requireName: false
    property bool requireWorkId: false
    
    // 支持多种验证模式
    property string mode: "password"  // "password", "name_password", "workid_password", "name_workid_password"
    
    property string enteredName: ""
    property string enteredWorkId: ""
    property string enteredPassword: ""
    
    signal accepted(string name, string workId, string password)
    signal rejected()
    
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    width: 400
    height: {
        if (mode === "name_workid_password") return 320
        else if (requireName || requireWorkId) return 280
        else return 180
    }
    padding: 20
    
    anchors.centerIn: parent
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        
        Label {
            Layout.fillWidth: true
            text: passwordDialog.titleText
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        
        // 姓名字段
        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: passwordDialog.nameLabel
            visible: mode === "name_workid_password" || requireName
            text: passwordDialog.enteredName
            onTextChanged: passwordDialog.enteredName = text
        }
        
        // 工号字段
        TextField {
            id: workIdField
            Layout.fillWidth: true
            placeholderText: passwordDialog.workIdLabel
            visible: mode === "name_workid_password" || requireWorkId
            text: passwordDialog.enteredWorkId
            onTextChanged: passwordDialog.enteredWorkId = text
        }
        
        // 密码字段
        TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: passwordDialog.passwordLabel
            echoMode: TextInput.Password
            text: passwordDialog.enteredPassword
            onTextChanged: passwordDialog.enteredPassword = text
            onAccepted: {
                if (validateInput()) {
                    passwordDialog.accepted(passwordDialog.enteredName,
                                          passwordDialog.enteredWorkId,
                                          passwordDialog.enteredPassword)
                    passwordDialog.close()
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            
            Button {
                text: "取消"
                onClicked: {
                    passwordDialog.reject()
                    passwordDialog.rejected()
                }
            }
            
            Button {
                text: "确认"
                highlighted: true
                onClicked: {
                    if (validateInput()) {
                        passwordDialog.accepted(passwordDialog.enteredName,
                                              passwordDialog.enteredWorkId,
                                              passwordDialog.enteredPassword)
                        passwordDialog.close()
                    }
                }
            }
        }
        
        Label {
            id: errorLabel
            Layout.fillWidth: true
            text: ""
            color: "red"
            font.pixelSize: 12
            visible: false
            wrapMode: Text.WordWrap
        }
    }
    
    function validateInput() {
        if (mode === "name_workid_password" || requireName) {
            if (enteredName.trim() === "") {
                showError("请输入姓名")
                return false
            }
        }
        
        if (mode === "name_workid_password" || requireWorkId) {
            if (enteredWorkId.trim() === "") {
                showError("请输入工号")
                return false
            }
        }
        
        if (enteredPassword.trim() === "") {
            showError("请输入密码")
            return false
        }
        
        return true
    }
    
    function showError(message) {
        errorLabel.text = message
        errorLabel.visible = true
    }
    
    function clear() {
        nameField.text = ""
        workIdField.text = ""
        passwordField.text = ""
        enteredName = ""
        enteredWorkId = ""
        enteredPassword = ""
        errorLabel.visible = false
    }
    
    onOpened: {
        clear()
        if (mode === "name_workid_password") {
            nameField.forceActiveFocus()
        } else if (requireName) {
            nameField.forceActiveFocus()
        } else if (requireWorkId) {
            workIdField.forceActiveFocus()
        } else {
            passwordField.forceActiveFocus()
        }
    }
    
    onClosed: {
        clear()
    }
}
