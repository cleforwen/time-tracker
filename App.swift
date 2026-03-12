import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var startTime: Date?
    @Published var timeoutHours: Double = 7.0
    
    @Published var currentTime: Date = Date()
    @Published var accumulatedPausedTime: TimeInterval = 0
    @Published var manualPausedTime: TimeInterval = 0
    @Published var pauseStartTime: Date?
    
    private var timerCancellable: AnyCancellable?
    
    init() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time
        }
    }
    
    var totalPausedTime: TimeInterval {
        var time = accumulatedPausedTime + manualPausedTime
        if !isRunning, let pStart = pauseStartTime {
            time += currentTime.timeIntervalSince(pStart)
        }
        return max(0, time)
    }
    
    var elapsed: TimeInterval {
        guard let start = startTime else { return 0 }
        let grossElapsed = currentTime.timeIntervalSince(start)
        return max(0, grossElapsed - totalPausedTime)
    }
    
    var timeoutDuration: TimeInterval {
        return timeoutHours * 3600
    }
    
    var timeRemaining: TimeInterval {
        return max(0, timeoutDuration - elapsed)
    }
    
    var projectedTimeoutTime: Date? {
        guard let start = startTime else { return nil }
        return start.addingTimeInterval(timeoutDuration + totalPausedTime)
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
            isRunning = false
            pauseStartTime = Date()
        }
    }
    
    func stop() {
        isRunning = false
        startTime = nil
        accumulatedPausedTime = 0
        manualPausedTime = 0
        pauseStartTime = nil
    }
    
    func addManualBreak(minutes: Double) {
        manualPausedTime += minutes * 60
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
                Text("Working Time (hours):")
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
            if timerManager.startTime != nil {
                HStack {
                    Text("Break Time:")
                    Spacer()
                    
                    Button(action: { timerManager.addManualBreak(minutes: -1) }) {
                        Text("-1m")
                            .font(.system(size: 11))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                    }.buttonStyle(.bordered)
                    
                    Text(formatTime(timerManager.totalPausedTime))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.orange)
                        .frame(width: 85, alignment: .trailing)
                    
                    Button(action: { timerManager.addManualBreak(minutes: 1) }) {
                        Text("+1m")
                            .font(.system(size: 11))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                    }.buttonStyle(.bordered)
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
                } else if let projected = timerManager.projectedTimeoutTime {
                    Text(projected, style: .time)
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
