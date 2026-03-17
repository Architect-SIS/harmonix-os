import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// ═══════════════════════════════════════════════════════════════
// Harmonix Agent Factory — Desktop Wallpaper Shell
// ═══════════════════════════════════════════════════════════════
// Rendered as wallpaper via Hyprwinwrap. Always visible through
// window gaps. Click into to interact, click out to return to
// tiled workflow. Layout based on Paperclip Empire dashboard.
// ΣΔ → 0

ShellRoot {
    id: root

    // ─── Harmonix Theme ──────────────────────────────────────
    readonly property color voidBlack: "#0A0A0B"
    readonly property color deltaBlue: "#0066FF"
    readonly property color resonanceWhite: "#F0F0F2"
    readonly property color cardBg: "#111113"
    readonly property color cardBorder: "#1A1A1E"
    readonly property color mutedText: "#6B6B76"
    readonly property color accentPurple: "#7C3AED"
    readonly property color successGreen: "#00CC66"
    readonly property color errorRed: "#FF4444"
    readonly property color warningAmber: "#FFB800"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: factoryWindow
            property var modelData
            screen: modelData

            // Hyprwinwrap class — must match plugin config
            // This makes the window render as wallpaper
            windowClass: "harmonix-factory"

            anchors.fill: true
            color: root.voidBlack

            // ─── Main Layout ─────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: root.voidBlack

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 20

                    // ─── Header ──────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48

                        Text {
                            text: "◆ HARMONIX AGENT FACTORY"
                            color: root.deltaBlue
                            font.pixelSize: 18
                            font.family: "Inter"
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "ΣΔ → 0"
                            color: root.mutedText
                            font.pixelSize: 14
                            font.family: "JetBrains Mono"
                        }

                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: root.successGreen
                            // Pulse animation
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 1500; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            text: "ONLINE"
                            color: root.successGreen
                            font.pixelSize: 12
                            font.family: "JetBrains Mono"
                        }
                    }

                    // ─── Metric Cards Row ────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        spacing: 12

                        Repeater {
                            model: [
                                { title: "AGENTS", value: "0", sub: "0 running, 0 idle", icon: "🤖", accent: "#0066FF" },
                                { title: "TASKS", value: "0", sub: "0 open, 0 blocked", icon: "◉", accent: "#7C3AED" },
                                { title: "SPEND", value: "$0", sub: "No budget set", icon: "◈", accent: "#00CC66" },
                                { title: "APPROVALS", value: "0", sub: "None pending", icon: "◇", accent: "#FFB800" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: root.cardBg
                                border.color: root.cardBorder
                                border.width: 1
                                radius: 8

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 4

                                    RowLayout {
                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 16
                                        }
                                        Text {
                                            text: modelData.title
                                            color: root.mutedText
                                            font.pixelSize: 11
                                            font.family: "Inter"
                                            font.weight: Font.DemiBold
                                            font.letterSpacing: 1.5
                                        }
                                    }

                                    Text {
                                        text: modelData.value
                                        color: root.resonanceWhite
                                        font.pixelSize: 28
                                        font.family: "Inter"
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: modelData.sub
                                        color: root.mutedText
                                        font.pixelSize: 11
                                        font.family: "Inter"
                                    }
                                }
                            }
                        }
                    }

                    // ─── Charts Row ──────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        spacing: 12

                        Repeater {
                            model: ["RUN ACTIVITY", "PRIORITY", "STATUS", "SUCCESS RATE"]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: root.cardBg
                                border.color: root.cardBorder
                                border.width: 1
                                radius: 8

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: modelData
                                        color: root.mutedText
                                        font.pixelSize: 11
                                        font.family: "Inter"
                                        font.weight: Font.DemiBold
                                        font.letterSpacing: 1.5
                                    }

                                    Text {
                                        text: "Last 14 days"
                                        color: Qt.darker(root.mutedText, 1.3)
                                        font.pixelSize: 10
                                        font.family: "Inter"
                                    }

                                    // Placeholder chart bars
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Row {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            spacing: 3

                                            Repeater {
                                                model: 14
                                                Rectangle {
                                                    width: (parent.width - 13 * 3) / 14
                                                    height: Math.random() * parent.height * 0.8 + parent.height * 0.1
                                                    anchors.bottom: parent.bottom
                                                    color: root.deltaBlue
                                                    opacity: 0.3 + Math.random() * 0.5
                                                    radius: 2
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ─── Activity + Tasks Split ──────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        // Recent Activity
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.cardBg
                            border.color: root.cardBorder
                            border.width: 1
                            radius: 8

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                Text {
                                    text: "RECENT ACTIVITY"
                                    color: root.mutedText
                                    font.pixelSize: 11
                                    font.family: "Inter"
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 1.5
                                }

                                Repeater {
                                    model: [
                                        "Waiting for agents...",
                                        "No activity yet",
                                        "Deploy agents to begin"
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        color: "transparent"
                                        border.color: root.cardBorder
                                        border.width: 0

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 4
                                            spacing: 8

                                            Rectangle {
                                                width: 6; height: 6; radius: 3
                                                color: root.mutedText
                                                opacity: 0.4
                                            }

                                            Text {
                                                text: modelData
                                                color: Qt.darker(root.mutedText, 1.1)
                                                font.pixelSize: 13
                                                font.family: "Inter"
                                                font.italic: true
                                            }
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        // Recent Tasks
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.cardBg
                            border.color: root.cardBorder
                            border.width: 1
                            radius: 8

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                Text {
                                    text: "RECENT TASKS"
                                    color: root.mutedText
                                    font.pixelSize: 11
                                    font.family: "Inter"
                                    font.weight: Font.DemiBold
                                    font.letterSpacing: 1.5
                                }

                                Repeater {
                                    model: [
                                        "No tasks assigned",
                                        "Create agents first",
                                        "Then assign work"
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        color: "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 4
                                            spacing: 8

                                            Rectangle {
                                                width: 6; height: 6; radius: 3
                                                color: root.mutedText
                                                opacity: 0.4
                                            }

                                            Text {
                                                text: modelData
                                                color: Qt.darker(root.mutedText, 1.1)
                                                font.pixelSize: 13
                                                font.family: "Inter"
                                                font.italic: true
                                            }
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }
                    }

                    // ─── Footer ──────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24

                        Text {
                            text: "HARMONIX OS v26.05 · NixOS Yarara · Hyprland 0.53"
                            color: Qt.darker(root.mutedText, 1.5)
                            font.pixelSize: 10
                            font.family: "JetBrains Mono"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "◆ The Architect"
                            color: Qt.darker(root.mutedText, 1.3)
                            font.pixelSize: 10
                            font.family: "Inter"
                        }
                    }
                }
            }
        }
    }
}
