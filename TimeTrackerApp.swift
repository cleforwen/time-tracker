import SwiftUI

@main
struct TimeTrackerApp: App {
    var body: some Scene {
        MenuBarExtra("Time Tracker", systemImage: "timer") {
            TimerView()
        }
        .menuBarExtraStyle(.window)
    }
}
