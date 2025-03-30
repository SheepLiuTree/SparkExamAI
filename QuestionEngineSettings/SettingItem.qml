import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 通用设置项组件
Rectangle {
    id: settingItem
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
    
    // 开关组件
    Component {
        id: switchComponent
        Switch {
            checked: settingData.checked
            onCheckedChanged: {
                settingData.checked = checked
            }
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
                
                onValueChanged: {
                    settingData.value = value
                }
                
                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth
                    height: 4
                    radius: 2
                    color: "#e0e0e0"
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        color: "#2c70b7"
                        radius: 2
                    }
                }
                
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: parent.pressed ? "#1e5b94" : "#2c70b7"
                    border.color: "#2c70b7"
                }
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
            
            onCurrentIndexChanged: {
                settingData.value = currentIndex
            }
            
            delegate: ItemDelegate {
                width: parent.width
                contentItem: Text {
                    text: modelData
                    color: "#333333"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
                highlighted: combobox.highlightedIndex === index
            }
            
            contentItem: Text {
                text: parent.displayText
                color: "#333333"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
            }
            
            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 40
                border.color: parent.pressed ? "#2c70b7" : "#d0d0d0"
                border.width: parent.pressed ? 2 : 1
                radius: 4
            }
        }
    }
    
    // 文本输入组件
    Component {
        id: textFieldComponent
        TextField {
            text: settingData.value
            font.pixelSize: 14
            
            onTextChanged: {
                settingData.value = text
            }
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                color: "white"
                border.color: parent.activeFocus ? "#2c70b7" : "#d0d0d0"
                border.width: parent.activeFocus ? 2 : 1
                radius: 4
            }
        }
    }
} 