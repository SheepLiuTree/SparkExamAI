import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    visibility: Window.Maximized
    title: qsTr("Hello World")

    Image {
        id: background
        anchors.fill: parent
        source: "qrc:/images/background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        id: headline_background
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/images/headline.png"
        Text {
            id: headline_text
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: "星火智考通·智能评测系统"
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 48
            color: "white"
        }
        Text {
            id: date_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            text: Qt.formatDateTime(new Date(), "yyyy年MM月dd日")
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"
        }
        Text {
            id: time_text
            anchors.bottom: headline_background.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            text: Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + getWeekDay()
            font.family: "阿里妈妈数黑体"
            font.pixelSize: 30
            color: "white"

            function getWeekDay() {
                var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
                var day = new Date().getDay();
                return weekDays[day];
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    time_text.text = Qt.formatDateTime(new Date(), "hh:mm:ss") + " " + time_text.getWeekDay();
                    date_text.text = Qt.formatDateTime(new Date(), "yyyy年MM月dd日");
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.top: headline_background.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        initialItem: mainPage
        clip: true
    }

    // 主页面
    Rectangle {
        id: mainPage
        color: "transparent"
        visible: false

        Image {
            id: function_menu_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: function_menu_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "功能菜单"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            Column {
                anchors.centerIn: parent
                spacing: 25

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火日课"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火日课 clicked")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火特训"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火特训 clicked")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "面容采集"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        stackView.push("FaceCollectionPage.qml")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "题集速录"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("题集速录 clicked")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "题策引擎"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("题策引擎 clicked")
                    }
                }

                Button {
                    width: 200
                    height: 70
                    background: Image {
                        source: "qrc:/images/button_bg.png"
                        fillMode: Image.Stretch
                    }
                    contentItem: Text {
                        text: "星火智能体"
                        font.family: "阿里妈妈数黑体"
                        font.pixelSize: 24
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("星火智能体 clicked")
                    }
                }
            }
        }

        Image {
            id: personal_page_background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.right
            anchors.horizontalCenterOffset: -parent.width/8
            anchors.bottom: parent.bottom
            source: "qrc:/images/menu.png"
            width: 250

            Text {
                id: personal_page_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: "个人主页"
                font.family: "阿里妈妈数黑体"
                font.pixelSize: 24
                color: "white"
            }

            ScrollView {
                id: personal_page_scroll_view
                anchors.top: personal_page_text.bottom
                anchors.topMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                ScrollBar.vertical.interactive: true

                Column {
                    id: personal_page_column
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Repeater {
                        model: ["杨柳", "王林浩", "邵海波", "董楠", "包君钰","薄小钰","陈兆琮","陈子豪","崔文博","丁子轩","董楠","冯子豪","高子豪","郭子豪","韩子豪","何子豪","胡子豪","贾子豪","康子豪","李子豪","刘子豪","马子豪","孟子豪","宁子豪","裴子豪","秦子豪","任子豪","邵子豪","孙子豪","唐子豪","王子豪","徐子豪","杨子豪","于子豪","张子豪","赵子豪","郑子豪","周子豪","朱子豪"]

                        Button {
                            width: 200
                            height: 70
                            background: Image {
                                source: "qrc:/images/personal_button_bg.png"
                                fillMode: Image.Stretch
                            }
                            contentItem: Text {
                                text: modelData
                                font.family: "阿里妈妈数黑体"
                                font.pixelSize: 30
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -8
                            }
                            onClicked: {
                                console.log(modelData + " clicked")
                            }
                        }
                    }
                }
            }
        }
    }
}
