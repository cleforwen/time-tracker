import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var startTime: Date?
    @Published var accumulatedTime: TimeInterval = 0
    @Published var timeoutHours: Double = 7.0
    
    @Published var currentTime: Date = Date()
    @Published var accumulatedPausedTime: TimeInterval = 0
    @Published var pauseStartTime: Date?
    
    private var timerCancellable: AnyCancellable?
    
    init() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time
        }
    }
    
    var elapsed: TimeInterval {
        if isRunning, let start = startTime {
            return accumulatedTime + currentTime.timeIntervalSince(start)
        }
        return accumulatedTime
    }
    
    var timeoutDuration: TimeInterval {
        return timeoutHours * 3600
    }
    
    var timeRemaining: TimeInterval {
        return max(0, timeoutDuration - elapsed)
    }
    
    var projectedTimeoutTime: Date {
        if isRunning {
            return currentTime.addingTimeInterval(timeRemaining)
        } else {
            // When paused or stopped, projected time would be now + timeRemaining
            return Date().addingTimeInterval(timeRemaining)
        }
    }
    
    func start() {
        if !isRunning {
            if startTime == nil {
                startTime = Date()
            }
            if let pStart = pauseStartTime {
                accumulatedPausedTime += Date().timeIntervalSince(pStart)
                pauseStartTime = nil
            }
            isRunning = true
            currentTime = Date()
        }
    }
    
    func pause() {
        if isRunning {
            if let start = startTime {
                accumulatedTime += Date().timeIntervalSince(start)
                // Note: startTime is kept so we know when the whole session started
                startTime = Date() // Reset start time for the next slice of running time
            }
            isRunning = false
            pauseStartTime = Date()
        }
    }
    
    func stop() {
        isRunning = false
        startTime = nil
        accumulatedTime = 0
        pauseStartTime = nil
        accumulatedPausedTime = 0
    }
    
    var totalPausedTime: TimeInterval {
        if !isRunning, let pStart = pauseStartTime {
            return accumulatedPausedTime + currentTime.timeIntervalSince(pStart)
        }
        return accumulatedPausedTime
    }
}

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Time Tracker")
                .font(.headline)
            
            // Timeout Config
            HStack {
                Text("Time to render(hours):")
                Spacer()
                TextField("Hours", value: $timerManager.timeoutHours, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
            }
            
            // Time Started
            if timerManager.startTime != nil {
                DatePicker("Time Started:", selection: Binding(
                    get: { timerManager.startTime ?? Date() },
                    set: { timerManager.startTime = $0 }
                ), displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
            } else {
                HStack {
                    Text("Time Started:")
                    Spacer()
                    Text("Not Started")
                        .foregroundColor(.secondary)
                }
            }
            
            // Paused Time (Break Time)
            if timerManager.totalPausedTime > 0 {
                HStack {
                    Text("Break Time:")
                    Spacer()
                    Text(formatTime(timerManager.totalPausedTime))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(timerManager.isRunning ? "Running" : "Break")
                        .foregroundColor(timerManager.isRunning ? .green : .orange)
                }
            }
            
            // Elapsed Time (Time Render)
            HStack {
                Text("Time Render:")
                Spacer()
                Text(formatTime(timerManager.elapsed))
                    .font(.system(.body, design: .monospaced))
            }
            
            // Time Remaining
            HStack {
                Text("Time To Timeout:")
                Spacer()
                if timerManager.timeRemaining <= 0 {
                    Text("Timeout Reached")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.red)
                } else {
                    Text(timerManager.projectedTimeoutTime, style: .time)
                        .font(.system(.body, design: .monospaced))
                }
            }
            
            Divider()
            
            // Controls
            HStack(spacing: 12) {
                Button(action: {
                    timerManager.start()
                }) {
                    Text(timerManager.isRunning ? "Running" : (timerManager.elapsed > 0 ? "Resume" : "Start"))
                }
                .disabled(timerManager.isRunning)
                
                Button("Pause") {
                    timerManager.pause()
                }
                .disabled(!timerManager.isRunning)
                
                Button("Stop") {
                    timerManager.stop()
                }
                .disabled(!timerManager.isRunning && timerManager.elapsed == 0)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 320)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let isNegative = interval < 0
        let absInterval = abs(interval)
        let hours = Int(absInterval) / 3600
        let minutes = (Int(absInterval) % 3600) / 60
        let seconds = Int(absInterval) % 60
        let sign = isNegative ? "-" : ""
        return String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
    }
}

@main
struct TimeTrackerApp: App {
    var body: some Scene {
        MenuBarExtra("Time Tracker", systemImage: "timer") {
            TimerView()
        }
        .menuBarExtraStyle(.window)
    }
}
