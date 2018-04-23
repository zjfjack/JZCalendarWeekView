# JZCalendarWeekView

[![Build Status](https://travis-ci.org/zjfjack/JZCalendarWeekView.svg?branch=master)](https://travis-ci.org/zjfjack/JZCalendarWeekView)
[![CocoaPods](https://img.shields.io/cocoapods/v/JZCalendarWeekView.svg)](https://cocoapods.org/pods/JZCalendarWeekView)
[![Platform](https://img.shields.io/cocoapods/p/JZCalendarWeekView.svg?style=flat)](https://github.com/zjfjack/JZCalendarWeekView)
[![Swift 4.1](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/JZCalendarWeekView.svg)](http://opensource.org/licenses/MIT)

iOS Calendar Week/Day View in Swift

Inspired from WRCalendarView (https://github.com/wayfinders/WRCalendarView)

This is a new repository and it is my first time to write a library. <br />
If you have any questions and suggestions, feel free to contact me. Jeff Zhang: zekejeff@gmail.com

## Features

- [x] X-Day per Page (Day view: 1-day, 3-day view, weekview: 7-day)
- [x] Two Scroll types: One-Day scroll (scroll a section) or Page scroll
- [x] Events display on calendar view (supports events with conflict time and events cross few days)
- [x] Current time line display

<img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/numOfDays.gif" width="285"/> <img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/scrollType-page.gif" width="285"/> <img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/scrollType-section.gif" width="285"/>

## Usage

### ViewController

In your viewController, you only need do few things.

1. Setup your own custom calendarWeekView in 'viewDidLoad'
```swift
calendarWeekView.setupCalendar(numOfDays: 7,
                               setDate: Date(),
                               allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events),
                               scrollType: .pageScroll,
                               firstDayOfWeek: .Monday)
```
2. Setup your own custom flowLayout style in 'viewDidLoad' (optional)
```swift
calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourHeight: 50, rowHeaderWidth: 50, columnHeaderHeight: 50, hourGridDivision: JZHourGridDivision.noneDiv))
```

3. Override `viewWillTransition` to allow device rotation and iPad split view (Not support iPhone X Landscape yet)
```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    calendarWeekView.refreshWeekView()
}
```

### JZBaseWeekView

Create your own WeekView class inherit from `JZBaseWeekView`, and you should override the following functions.

- Register function: Register your own CollectionViewCell, SupplementaryView or  DecorationView here

```swift
override func registerViewClasses() {
    super.registerViewClasses()

    // Register CollectionViewCell
    self.collectionView.register(UINib(nibName: EventCell.className, bundle: nil), forCellWithReuseIdentifier: EventCell.className)

    // Register DecorationView: must provide corresponding JZDecorationViewKinds
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)

    // Register SupplementrayView: must override collectionView viewForSupplementaryElementOfKind
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
- CollectionView `cellForItemAt`: Use your custom collectionViewCell

```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let date = flowLayout.dateForColumnHeader(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.className, for: indexPath) as! EventCell
    cell.updateView(event: allEventsBySection[date]![indexPath.row] as! Event)
    return cell
}
```

### JZBaseEvent

In JZCalendarWeekView, the data model is using `[Date:Event]` dictionary because for each day (a section in collectionView), there are many events.<br />

A static function called `getIntraEventsByDate` provided in `JZWeekViewHelper` allow you to tranform your event list into `[Date:Event]` dictionary.
```swift 
open class func getIntraEventsByDate<T: JZBaseEvent>(originalEvents: [T]) -> [Date: [T]]
```
In order to call this function, you should create a subclass of `JZBaseEvent` and also implement the `NSCopying` protocol. <br />
For the `intraStartDate` and `intraEndDate` in `JZBaseEvent`, it means that if a event crosses two days, it should be devided into two events but with different intraStartDate and intraEndDate. <br />
eg. startDate = 180329 14:00, endDate = 180330 03:00, then two events should be generated: 1. 180329 14:00(IntraStart) - 23:59(IntraEnd) 2. 180330 00:00(IntraStart) - 03:00(IntraEnd)


For futher usage, you can also check the example project, some comments in code or just email me.<br />
I will improve the usage description as soon as possible.

## Requirements

- iOS 9.0+
- Xcode 9.3+
- Swift 4.1+

## Installation

### Cocoapods
JZCalendarWeekView can be added to your project by adding the following line to your `Podfile`:

```ruby
pod 'JZCalendarWeekView', '~> 0.1'
```

## Todo

- [ ] Gestures: Tap to select & Long press to drag
- [ ] Supports all devices including iPad and iPhone X and all orientations
- [ ] New scroll type: Infinite scroll
- [ ] Supports different types of events
- [ ] Supports Top custom decoration/supplementry view


## License

JZCalendarWeekView is available under the MIT license. See the [LICENSE](https://github.com/zjfjack/JZCalendarWeekView/blob/master/LICENSE)  for more info.



