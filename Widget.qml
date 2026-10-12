import QtQuick

// Invisible bar widget: on load it places a starfield shader at the bottom of
// the bar window's content, under every section. The bar's own background
// colour still paints behind it.
Item {
  id: root

  property var shell: null

  implicitWidth: 0
  implicitHeight: 0

  property Item effect: null

  function attach() {
    if (effect) return
    var top = root
    while (top.parent) top = top.parent
    if (top === root) return
    effect = starfieldComponent.createObject(top, { z: -1 })
  }

  Component.onCompleted: Qt.callLater(attach)
  onParentChanged: Qt.callLater(attach)
  Component.onDestruction: if (effect) effect.destroy()

  Component {
    id: starfieldComponent

    ShaderEffect {
      id: sf
      anchors.fill: parent
      fragmentShader: Qt.resolvedUrl("shaders/starfield.frag.qsb")

      readonly property string position: root.shell && root.shell.bar && root.shell.bar.position ? root.shell.bar.position : "top"
      readonly property var scr: sf.Window.window ? sf.Window.window.screen : null

      property real iTime: 0
      property size itemSize: Qt.size(width, height)
      property real refHeight: scr ? scr.height : 1440
      property point offset: Qt.point(
        position === "right" && scr ? scr.width - width : 0,
        position === "bottom" && scr ? scr.height - height : 0)

      FrameAnimation {
        running: sf.visible && sf.Window.window !== null && sf.Window.window.visible
        onTriggered: sf.iTime = elapsedTime % 32000 // wrap: see PERIOD in shader
      }
    }
  }
}
