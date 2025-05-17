import QtQuick 2.15
import QtQuick.VirtualKeyboard 2.15

Item {
    id: virtualKeyboardWrapper
    width: parent.width
    height: inputPanel.height
    anchors.bottom: parent.bottom

    // 虚拟键盘的输入面板
    InputPanel {
        id: inputPanel
        width: parent.width
        anchors.bottom: parent.bottom
        visible: Qt.inputMethod.visible
        
        // 当输入面板的高度或可见性变化时更新虚拟键盘高度
        onHeightChanged: {
            virtualKeyboardWrapper.height = inputPanel.height
        }
        
        // 设置主题
        externalLanguageSwitchEnabled: true
        
        // 当键盘可见性变化时发出信号
        onVisibleChanged: {
            if (visible) {
                console.log("虚拟键盘显示，高度:", height)
            } else {
                console.log("虚拟键盘隐藏")
            }
        }
    }
} 