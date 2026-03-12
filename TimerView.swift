import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        VStack(spacing: 16) {
            headerSection
            configSection
            startTimeSection
            if timerManager.startTime != nil {
                breakTimeSection
            }
            timeRenderSection
            timeoutSection
            Divider()
            controlsSection
        }
        .padding()
        .frame(width: 320)
    }
    
    private var headerSection: some View {
        Text("Time Tracker")
            .font(.headline)
    }
    
    private var configSection: some View {
        HStack {
            Text("Working Time (hours):")
            Spacer()
            TextField("Hours", value: $timerManager.timeoutHours, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 50)
        }
    }
    
    @ViewBuilder
    private var startTimeSection: some View {
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
    }
    
    private var breakTimeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Break Time:")
                Spacer()
                
                Button(action: { timerManager.addManualBreak(minutes: -1) }) {
                    Text("-1m")
                        .font(.system(size: 11))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                }.buttonStyle(.bordered)
                
                Text(timerManager.totalPausedTime.formattedString())
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
    }
    
    private var timeRenderSection: some View {
        HStack {
            Text("Time Render:")
            Spacer()
            Text(timerManager.elapsed.formattedString())
                .font(.system(.body, design: .monospaced))
        }
    }
    
    private var timeoutSection: some View {
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
    }
    
    private var controlsSection: some View {
        HStack(spacing: 12) {
            Button(action: { timerManager.start() }) {
                Text(timerManager.isRunning ? "Running" : (timerManager.elapsed > 0 ? "Resume" : "Start"))
            }
            .disabled(timerManager.isRunning)
            
            Button("Pause") { timerManager.pause() }
            .disabled(!timerManager.isRunning)
            
            Button("Stop") { timerManager.stop() }
            .disabled(!timerManager.isRunning && timerManager.elapsed == 0)
            
            Spacer()
            
            Button("Quit") { NSApplication.shared.terminate(nil) }
            .foregroundColor(.red)
        }
    }
}
