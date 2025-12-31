pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    id: root
	property real memoryTotal: 1
	property real memoryFree: 0
	property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
	property real swapFree: 0
	property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property real cpuTemp: 0  // CPU temperature in Celsius
    property var previousCpuStats

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()
            fileCpuTemp.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000

            // Trigger CPU temperature reading
            cpuTempProc.running = true
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }

    // CPU Temperature reading via hwmon (more universal than thermal_zone)
    Process {
        id: cpuTempProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        // Try hwmon first (works on most systems), fallback to sensors command
        command: ["bash", "-c", `
            # Try to find CPU temp from hwmon (coretemp, k10temp, zenpower, etc.)
            for hwmon in /sys/class/hwmon/hwmon*; do
                name=$(cat "$hwmon/name" 2>/dev/null)
                case "$name" in
                    coretemp|k10temp|zenpower|amdgpu|cpu_thermal|acpitz)
                        # Read first available temp input (usually package/die temp)
                        for temp in "$hwmon"/temp*_input; do
                            if [ -f "$temp" ]; then
                                cat "$temp"
                                exit 0
                            fi
                        done
                        ;;
                esac
            done
            # Fallback: try any temp1_input
            for hwmon in /sys/class/hwmon/hwmon*; do
                if [ -f "$hwmon/temp1_input" ]; then
                    cat "$hwmon/temp1_input"
                    exit 0
                fi
            done
            echo "0"
        `]
        stdout: SplitParser {
            onRead: data => {
                const temp = parseInt(data.trim())
                if (temp > 0) {
                    root.cpuTemp = temp / 1000  // Convert millidegrees to degrees
                }
            }
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
