# Time Tracker

A simple, native macOS menu bar application built with SwiftUI that helps you track your focus time and manage your breaks.

## Features

- **Menu Bar Native:** Lives entirely in your macOS menu bar for quick access without cluttering your dock or windows.
- **Time Rendering:** Real-time digital clock displaying your currently elapsed focus time.
- **Timeout Configuration:** Customize your "Time to Render (hours)" to automatically calculate when your focus block should be completed.
- **Projected Timeout Time:** Displays the exact dynamically calculated wall-clock time when you will hit your timeout limit based on the work you've already accumulated.
- **Break Time Tracking:** Pausing the timer automatically logs and tracks your break duration, updating your state to "Break".
- **Accumulated Timers:** Support for pausing and resuming, carrying over previously accumulated work time.

## Requirements

- macOS 13.0+
- Swift 5+ 

## Build & Run

1. Clone or download the repository.
2. Ensure you have the Swift tools installed (typically alongside Xcode).
3. To compile the application, you can use the provided build script:
    ```bash
    chmod +x build.sh
    ./build.sh
    ```
4. Run the application from the terminal:
    ```bash
    open TimeTracker.app
    ```

## Usage

Once opened, look for the Timer icon in the top right menu bar of your screen. 
- Click **Start** to begin tracking time.
- Click **Pause** to go on break (the menu will clearly show the break state).
- Click **Resume** to continue your focus session.
- Keep track of your **Time To Timeout** field to understand exactly when you'll be done! 

## Author
Generated with AI.
