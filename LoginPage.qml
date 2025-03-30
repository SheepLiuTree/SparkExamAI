import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: loginPage
    color: "transparent"
    
    property var stackView

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/images/background.png"
        fillMode: Image.PreserveAspectCrop
    }
    
    // Logo和标题区域
    Item {
        id: logoSection
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        width: parent.width * 0.8
        height: parent.height * 0.2
        
        Image {
            id: logoImage
            source: "qrc:/images/sparklogo.png"
            width: 80
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                visible: parent.status !== Image.Ready
                text: "星火"
                font.pixelSize: 36
                color: "white"
                anchors.centerIn: parent
            }
        }
        
        Text {
            text: "星火学习平台"
            font.pixelSize: 32
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logoImage.bottom
            anchors.topMargin: 20
        }
    }
    
    // 登录表单区域
    Rectangle {
        id: loginForm
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logoSection.bottom
        anchors.topMargin: 30
        width: parent.width * 0.8
        height: parent.height * 0.5
        radius: 10
        color: "#80FFFFFF"
        
        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.8
            spacing: 20
            
            Text {
                text: "用户登录"
                font.pixelSize: 24
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: 5
                color: "white"
                
                TextField {
                    id: usernameField
                    anchors.fill: parent
                    anchors.margins: 2
                    placeholderText: "用户名"
                    font.pixelSize: 16
                    leftPadding: 10
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: 5
                color: "white"
                
                TextField {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 2
                    placeholderText: "密码"
                    echoMode: TextInput.Password
                    font.pixelSize: 16
                    leftPadding: 10
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: 25
                color: "#2c70b7"
                
                Text {
                    text: "登录"
                    color: "white"
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 登录逻辑
                        if (usernameField.text.length > 0 && passwordField.text.length > 0) {
                            let userData = {
                                name: usernameField.text,
                                avatarPath: ""
                            };
                            stackView.push("MainPage.qml", { userData: userData });
                        } else {
                            loginErrorText.visible = true;
                        }
                    }
                }
            }
            
            Text {
                id: loginErrorText
                text: "请输入用户名和密码"
                color: "red"
                font.pixelSize: 14
                visible: false
                Layout.alignment: Qt.AlignHCenter
            }
            
            Item {
                Layout.fillWidth: true
                height: 20
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                CheckBox {
                    text: "记住我"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignLeft
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "忘记密码?"
                    font.pixelSize: 14
                    color: "#2c70b7"
                    Layout.alignment: Qt.AlignRight
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("忘记密码流程")
                        }
                    }
                }
            }
        }
    }
    
    // 人脸识别登录区域
    Rectangle {
        id: faceLoginSection
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginForm.bottom
        anchors.topMargin: 20
        width: 200
        height: 50
        radius: 25
        color: "#80FFFFFF"
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 10
            
            Image {
                source: "qrc:/images/face_icon.png"
                width: 24
                height: 24
                Layout.alignment: Qt.AlignVCenter
                
                Text {
                    visible: parent.status !== Image.Ready
                    text: "👤"
                    font.pixelSize: 20
                    anchors.centerIn: parent
                }
            }
            
            Text {
                text: "人脸识别登录"
                font.pixelSize: 16
                color: "#333333"
                Layout.alignment: Qt.AlignVCenter
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 打开人脸识别登录
                console.log("人脸识别登录")
            }
        }
    }
    
    // 页脚区域
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: "© 2023 星火学习平台 版权所有"
        font.pixelSize: 12
        color: "white"
    }
} 