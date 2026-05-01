import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property int tabCount: 1

    function focusActiveItem() {
        // No focusable content
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        // Kitty Theme Toggle Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: kittyThemeColumn.implicitHeight + 32
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1

            ColumnLayout {
                id: kittyThemeColumn
                anchors {
                    fill: parent
                    margins: 16
                }
                spacing: 12

                RowLayout {
                    spacing: 12

                    MaterialSymbol {
                        iconSize: 32
                        text: "terminal"
                        color: Appearance.colors.colOnLayer1
                    }

                    StyledText {
                        text: Translation.tr("Kitty Terminal Theme")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer1
                    }
                }

                ConfigSwitch {
                    Layout.fillWidth: true
                    buttonIcon: "palette"
                    text: Translation.tr("Use Dracula theme")
                    checked: Config.options.appearance.wallpaperTheming.kittyThemeMode === "dracula"
                    onCheckedChanged: {
                        const newMode = checked ? "dracula" : "auto";
                        if (Config.options.appearance.wallpaperTheming.kittyThemeMode !== newMode) {
                            Config.options.appearance.wallpaperTheming.kittyThemeMode = newMode;
                            // Delay script execution to allow Config to write to disk (50ms write delay)
                            applyThemeTimer.restart();
                        }
                    }

                    Timer {
                        id: applyThemeTimer
                        interval: 100 // Wait for Config.qml to write (readWriteDelay is 50ms)
                        repeat: false
                        onTriggered: {
                            Quickshell.execDetached([Directories.kittyThemeScriptPath, "apply"]);
                        }
                    }

                    StyledToolTip {
                        text: checked
                            ? Translation.tr("Using static Dracula colors (independent from wallpaper)")
                            : Translation.tr("Using wallpaper-generated colors")
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Config.options.appearance.wallpaperTheming.kittyThemeMode === "dracula"
                        ? Translation.tr("Kitty uses the Dracula color scheme, independent from wallpaper theming.")
                        : Translation.tr("Kitty colors are automatically generated from your wallpaper.")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Placeholder for more widgets
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    iconSize: 48
                    text: "widgets"
                    color: Appearance.colors.colOnLayer1
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Left sidebar")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Add your custom widgets here")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}