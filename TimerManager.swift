import Foundation
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

extension TimeInterval {
    func formattedString() -> String {
        let isNegative = self < 0
        let absInterval = abs(self)
        let hours = Int(absInterval) / 3600
        let minutes = (Int(absInterval) % 3600) / 60
        let seconds = Int(absInterval) % 60
        let sign = isNegative ? "-" : ""
        return String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
    }
}
