import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: generalSettingsPage
    color: "transparent"
    
    property var settings: [
        { type: "switch", name: "启用自动出题", checked: true, description: "开启后系统将根据设定的策略自动出题" },
        { type: "slider", name: "难度系数", value: 3, minValue: 1, maxValue: 5, description: "调整题目的整体难度系数" },
        { type: "combobox", name: "默认题型", value: 0, options: ["选择题", "填空题", "简答题", "综合题"], description: "设置优先出题的题型" },
        { type: "switch", name: "允许重复题目", checked: false, description: "是否允许在短期内出现相同的题目" },
        { type: "text", name: "每日题量", value: "10", description: "设置每日推送的题目数量" }
    ]
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "通用设置"
            font.pixelSize: 20
            font.bold: true
            color: "#333333"
            Layout.bottomMargin: 10
        }
        
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: settingsColumn.height
            clip: true
            
            ColumnLayout {
                id: settingsColumn
                width: parent.width
                spacing: 25
                
                Repeater {
                    model: settings
                    delegate: SettingItem {
                        Layout.fillWidth: true
                        settingData: modelData
                    }
                }
                
                Item {
                    Layout.fillHeight: true
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 15
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "恢复默认"
                implicitWidth: 100
                implicitHeight: 40
                
                background: Rectangle {
                    color: "#f0f0f0"
                    border.color: "#d0d0d0"
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "#444444"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "保存设置"
                implicitWidth: 100
                implicitHeight: 40
                
                background: Rectangle {
                    color: "#2c70b7"
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    
    // 设置项组件
    Component {
        id: settingItemComponent
        Rectangle {
            width: parent.width
            height: 50
            color: "transparent"
            
            property var settingData
            
            RowLayout {
                anchors.fill: parent
                spacing: 10
                
                Text {
                    text: settingData.name
                    font.pixelSize: 16
                    color: "#333333"
                    Layout.preferredWidth: parent.width * 0.3
                }
                
                Loader {
                    id: controlLoader
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.fillHeight: true
                    sourceComponent: {
                        switch(settingData.type) {
                        case "switch":
                            return switchComponent
                        case "slider":
                            return sliderComponent
                        case "combobox":
                            return comboboxComponent
                        case "text":
                            return textFieldComponent
                        default:
                            return null
                        }
                    }
                }
                
                Text {
                    text: settingData.description
                    font.pixelSize: 14
                    color: "#666666"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    // 开关组件
    Component {
        id: switchComponent
        Switch {
            checked: settingData.checked
        }
    }
    
    // 滑块组件
    Component {
        id: sliderComponent
        RowLayout {
            spacing: 10
            
            Slider {
                from: settingData.minValue
                to: settingData.maxValue
                value: settingData.value
                stepSize: 1
                Layout.fillWidth: true
            }
            
            Text {
                text: settingData.value
                font.pixelSize: 14
                color: "#333333"
            }
        }
    }
    
    // 下拉框组件
    Component {
        id: comboboxComponent
        ComboBox {
            model: settingData.options
            currentIndex: settingData.value
        }
    }
    
    // 文本输入组件
    Component {
        id: textFieldComponent
        TextField {
            text: settingData.value
            font.pixelSize: 14
        }
    }
} 