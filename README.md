# Overtime Tracker for iOS

A beautifully designed iOS app for postmen to track their daily overtime hours. Built with SwiftUI and featuring an Apple-inspired design.

## Features

- **Daily Overtime Tracking**: Record overtime hours worked before and after your contracted hours
- **Weekly Overview**: View all days of the current week (Monday-Sunday) with totals
- **Daily Totals**: See how much overtime you worked each day
- **Weekly Total**: Track your total overtime for the entire week
- **Apple-Inspired Design**: Clean, minimal interface matching Apple's design language
- **Persistent Storage**: All data is saved locally on your device using UserDefaults
- **Easy Time Input**: Use convenient picker wheels to input hours and minutes (in 15-minute increments)

## Screenshots

The app features:
- A large weekly total display at the top
- A clean list showing each day of the week (Monday-Sunday)
- Current day highlighted in blue
- Daily breakdown showing "before" and "after" contracted hours
- Tap any day to edit overtime hours
- Simple, intuitive time pickers for data entry

## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

### Building from Source

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Postman-app
   ```

2. **Open in Xcode**:
   ```bash
   open OvertimeTracker.xcodeproj
   ```

   Or simply double-click `OvertimeTracker.xcodeproj` in Finder

3. **Select your target device**:
   - In Xcode, select your iPhone from the device dropdown menu in the toolbar
   - Or choose an iOS Simulator

4. **Build and Run**:
   - Press `Cmd + R` or click the Play button in Xcode
   - The app will build and launch on your selected device/simulator

### Installing on Your iPhone

To install on a physical iPhone:

1. Connect your iPhone to your Mac via USB
2. In Xcode, select your iPhone from the device dropdown
3. Go to Signing & Capabilities tab
4. Select your Apple ID team for code signing
5. Press `Cmd + R` to build and install

**Note**: You may need to trust the developer certificate on your iPhone:
- Go to Settings > General > VPN & Device Management
- Tap your developer certificate and trust it

## How to Use

### Main Screen
- The main screen shows the current week (Monday-Sunday)
- The large number at the top is your total overtime for the week
- Each row represents one day with its overtime hours
- The current day is highlighted in blue
- Days with overtime show both "Before" and "After" hours

### Adding Overtime
1. Tap on any day in the list
2. A sheet will slide up with time pickers
3. Use the picker wheels to set:
   - **Before Contracted Hours**: Overtime worked before your regular shift
   - **After Contracted Hours**: Overtime worked after your regular shift
4. Watch the total update at the bottom
5. Tap **Save** to record your overtime
6. Tap **Cancel** to discard changes

### Time Increments
- Hours: 0-23
- Minutes: 0, 15, 30, 45 (15-minute increments)

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **UserDefaults**: Simple, persistent local storage
- **ObservableObject**: Reactive state management

### Project Structure
```
OvertimeTracker/
├── OvertimeTrackerApp.swift       # App entry point
├── Models/
│   └── OvertimeEntry.swift        # Data model for overtime entries
├── ViewModels/
│   └── OvertimeViewModel.swift    # Business logic and data management
├── Views/
│   ├── ContentView.swift          # Main weekly overview screen
│   └── DailyEntryView.swift       # Daily overtime entry form
└── Assets.xcassets/               # App assets and colors
```

### Data Model
Each overtime entry contains:
- Unique ID (UUID)
- Date
- Before contracted hours (Double)
- After contracted hours (Double)
- Computed total hours

### Week Calculation
- Weeks start on Monday and end on Sunday
- The app automatically displays the current week
- Empty days are created automatically for data entry

## Customization

### Changing Time Increments
To modify the minute increments (currently 15-minute intervals), edit `DailyEntryView.swift:71`:
```swift
ForEach([0, 15, 30, 45], id: \.self) { minute in
    Text("\(minute)").tag(minute)
}
```

### Changing the Accent Color
1. Open `Assets.xcassets/AccentColor.colorset`
2. Modify the color in Xcode's color picker
3. The app will automatically use the new accent color

## Future Enhancements

Potential features for future versions:
- Export overtime data to CSV or PDF
- Historical week viewing
- Monthly summaries
- Pay rate calculations
- Dark mode customization
- Widgets for quick overtime viewing
- Cloud sync between devices

## Support

For issues or questions, please open an issue on the GitHub repository.

## License

This project is created for personal use. Modify and use as needed.

## Credits

Designed and developed for postmen who need a simple, reliable way to track their overtime hours.

Built with SwiftUI and following Apple's Human Interface Guidelines for the best user experience.
