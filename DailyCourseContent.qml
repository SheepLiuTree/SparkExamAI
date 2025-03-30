import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: "transparent"
    
    property var userData
    
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
            stackView.pop()
        }
    }
    
    Text {
        id: welcomeText
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        text: "欢迎, " + (userData ? userData.name : "用户") + "!"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 36
        color: "white"
    }
    
    Text {
        id: courseTitle
        anchors.top: welcomeText.bottom
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: "今日课程内容"
        font.family: "阿里妈妈数黑体"
        font.pixelSize: 28
        color: "white"
    }
    
    Rectangle {
        anchors.top: courseTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.8
        height: parent.height - 250
        color: "#44ffffff"
        radius: 10
        
        ListView {
            id: courseListView
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            clip: true
            model: ListModel {
                ListElement {
                    title: "数学 - 函数与导数"
                    description: "学习函数的基本概念和导数的应用，重点解决实际问题。"
                    duration: "45分钟"
                }
                ListElement {
                    title: "语文 - 现代文阅读"
                    description: "提高文言文阅读理解能力，掌握重点字词解释和断句技巧。"
                    duration: "40分钟"
                }
                ListElement {
                    title: "英语 - 完形填空训练"
                    description: "针对高考完形填空题型进行专项训练，提升语感和词汇应用能力。"
                    duration: "35分钟"
                }
                ListElement {
                    title: "物理 - 电磁感应"
                    description: "理解电磁感应现象及其应用，掌握楞次定律和法拉第电磁感应定律。"
                    duration: "50分钟"
                }
                ListElement {
                    title: "化学 - 有机化学基础"
                    description: "学习有机物的命名规则和基本反应类型，掌握典型有机物的性质。"
                    duration: "45分钟"
                }
            }
            
            delegate: Rectangle {
                width: courseListView.width
                height: 100
                color: "#33ffffff"
                radius: 8
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5
                    
                    Text {
                        text: title
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 20
                        color: "white"
                        font.bold: true
                    }
                    
                    Text {
                        text: description
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 16
                        color: "white"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Text {
                        text: "课程时长: " + duration
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 14
                        color: "white"
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Selected course: " + title)
                    }
                }
            }
        }
    }
} 