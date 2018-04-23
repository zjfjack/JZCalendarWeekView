# JZCalendarWeekView

[![Build Status](https://travis-ci.org/zjfjack/JZCalendarWeekView.svg?branch=master)](https://travis-ci.org/zjfjack/JZCalendarWeekView)
[![CocoaPods](https://img.shields.io/cocoapods/v/JZCalendarWeekView.svg)](https://cocoapods.org/pods/JZCalendarWeekView)
[![Platform](https://img.shields.io/cocoapods/p/JZCalendarWeekView.svg?style=flat)](https://github.com/zjfjack/JZCalendarWeekView)

iOS Calendar Week/Day View in Swift

Inspired from WRCalendarView (https://github.com/wayfinders/WRCalendarView)

This is a new repository and it is my first time to write a library. If you have any question and suggestion, feel free to contact me. Jeff Zhang: zekejeff@gmail.com

## Features

- [x] X-Day per Page (Day view: 1-day, 3-day view, weekview: 7-day)
- [x] Two Scroll types: One-Day scroll (scroll a section) or Page scroll
- [x] Events display on calendar view (supports events with conflict time and events cross few days)
- [x] Current time line display

## Usage

### ViewController

In your viewController, you only need do two things.

1. Override viewWillTransition to allow device rotation and iPad split view (Not support iPhone X Landscape yet)

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    calendarWeekView.refreshWeekView()
}
```
2. Setup your costom calendarWeekView
```swift
calendarWeekView.setupCalendar(numOfDays: 7,
                               setDate: Date(),
                               allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events),
                               scrollType: .pageScroll,
                               firstDayOfWeek: .Monday)
```

### JZBaseWeekView

Create your own WeekView class inherit from JZBaseWeekView, and you should override the following functions.

- Register function: Register your own CollectionViewCell, SupplementaryView or  DecorationView here

```swift
override func registerViewClasses() {
    super.registerViewClasses()
    
    // Register CollectionViewCell
    self.collectionView.register(UINib(nibName: EventCell.className, bundle: nil), forCellWithReuseIdentifier: EventCell.className)
    
    // Register DecorationView: must provide corresponding JZDecorationViewKinds
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
    
    // Register SupplementrayView: must override
    collectionView.register(RowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: "RowHeader")
}
```
If you want to use your own supplementryView, you should register it and override the following function

```swift
override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == JZSupplementaryViewKinds.rowHeader {
        let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HourRowHeader.className, for: indexPath) as! HourRowHeader
        rowHeader.updateView(date: flowLayout.dateForTimeRowHeader(at: indexPath))
        return rowHeader
    }
    return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
}
```
- CollectionView cellForItemAt: Use your custom collectionViewCell

```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let date = flowLayout.dateForColumnHeader(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.className, for: indexPath) as! EventCell
    cell.updateView(event: allEventsBySection[date]![indexPath.row] as! Event)
    return cell
}
```

### JZBaseEvent

You must create your own Event model by inheriting from JZBaseEvent to allow cross-days. Also, NSCopying should be implemented.

```swift
open class JZBaseEvent: NSObject, NSCopying {

    open var startDate: Date
    open var endDate: Date

    // If a event crosses two days, it should be devided into two events but with different intraStartDate and intraEndDate
    // eg. startDate = 2018.03.29 14:00 endDate = 2018.03.30 03:00, then two events should be generated: 1. 0329 14:00 - 23:59(IntraEnd) 2. 0330 00:00(IntraStart) - 03:00
    open var intraStartDate: Date
    open var intraEndDate: Date

    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.intraStartDate = startDate
        self.intraEndDate = endDate
    }

    //Must be overrided
    open func copy(with zone: NSZone? = nil) -> Any {
        return JZBaseEvent(startDate: startDate, endDate: endDate)
    }
}
```
After this, you can use the funciton 'getIntraEventsByDate' in JZWeekViewHelper to tranform your event list to JZCalendarWeekView needed Date & Event dictionary

```swift
open class func getIntraEventsByDate<T: JZBaseEvent>(originalEvents: [T]) -> [Date: [T]]
```

For futher usage, you can also check the example project, some comments in code or just email me.

I will improve the usage description as soon as possible.

## Requirements

- iOS 9.0+
- Xcode 9.3+
- Swift 4.1+

## Installation

### Cocoapods
JZCalendarWeekView can be added to your project by adding the following line to your `Podfile`:

```ruby
pod 'JZCalendarWeekView', '~> 0.0'
```

## Todo

- [ ] Gestures: Tap to select & Long press to drag
- [ ] Supports all devices including iPad and iPhone X and all orientations
- [ ] New scroll type: Infinite scroll
- [ ] Supports different types of events
- [ ] Supports Top custom decoration/supplementry view


## License

JZCalendarWeekView is available under the MIT license. See the [LICENSE](https://github.com/zjfjack/JZCalendarWeekView/blob/master/LICENSE)  for more info.



