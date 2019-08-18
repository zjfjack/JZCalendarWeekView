<img src="https://github.com/zjfjack/JZCalendarWeekView/blob/master/Screenshots/logotype.png"/> <br /> <br />

[![Build Status](https://travis-ci.org/zjfjack/JZCalendarWeekView.svg?branch=master)](https://travis-ci.org/zjfjack/JZCalendarWeekView)
[![CocoaPods](https://img.shields.io/cocoapods/v/JZCalendarWeekView.svg)](https://cocoapods.org/pods/JZCalendarWeekView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JZCalendarWeekView.svg?style=flat)](https://github.com/zjfjack/JZCalendarWeekView)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/JZCalendarWeekView.svg)](http://opensource.org/licenses/MIT)

iOS Calendar Week/Day View in Swift

Inspired from [WRCalendarView](https://github.com/wayfinders/WRCalendarView)

## Features

- [x] X-Day per Page (Day view: 1-day, 3-day view, weekview: 7-day)
- [x] Two Scroll types: One-Day scroll (scroll a section) or Page scroll
- [x] Two Types of Long Press Gestures: Add a new event & Move an existing event
- [x] Events display on calendar view (supports events with conflict time and events crossing few days)
- [x] Set horizontal scrollable range dates
- [x] Support all device orientations (including iPhone X Landscape) and iPad (Slide Over and Split View)
- [x] Customise your own current timeline
- [x] All-Day Events

<img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/numOfDays.gif" width="210"/> <img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/longPress.gif" width="210"/> <img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/scrollType.gif" width="210"/> <img src="https://raw.githubusercontent.com/zjfjack/JZCalendarWeekView/master/Screenshots/all-day.gif" width="210"/>

## Usage

### ViewController

In your viewController, you only need do few things.

1. Setup your own custom calendarWeekView in `viewDidLoad`
```swift
calendarWeekView.setupCalendar(numOfDays: 7,
                               setDate: Date(),
                               allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events),
                               scrollType: .pageScroll,
                               firstDayOfWeek: .Monday)
```
2. Override `viewWillTransition` and call `viewTransitionHandler` in `JZWeekViewHelper` to support all device orientations
```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
}
```
3. Setup your own custom flowLayout style in `viewDidLoad` (optional)
```swift
calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourHeight: 50, rowHeaderWidth: 50, columnHeaderHeight: 50, hourGridDivision: JZHourGridDivision.noneDiv))
```

### JZBaseWeekView

Create your own WeekView class inheriting from `JZBaseWeekView`, and you should override the following functions.

1. Register function: Register your own  `UICollectionReusableView` here. (CollectionViewCell, SupplementaryView or  DecorationView)

```swift
override func registerViewClasses() {
    super.registerViewClasses()

    // Register CollectionViewCell
    self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: "EventCell")

    // Register DecorationView: must provide corresponding JZDecorationViewKinds
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
    self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)

    // Register SupplementrayView: must override collectionView viewForSupplementaryElementOfKind
    collectionView.register(RowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: "RowHeader")
}
```
If you want to use your own supplementryView (including your current timeline), you should register it and override the following function

```swift
override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
```
2. CollectionView `cellForItemAt`: Use your custom collectionViewCell

```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let date = flowLayout.dateForColumnHeader(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.className, for: indexPath) as! EventCell
    cell.updateView(event: allEventsBySection[date]![indexPath.row] as! Event)
    return cell
}
```

### JZLongPressView

This view is inheriated from `JZBaseWeekView` and implements the long press gestures. You can simply follow the setup rules of `JZBaseWeekView`. <br />
In order to achieve the long press gestures, you should implement the `JZLongPressViewDelegate` and `JZLongPressViewDataSource` in your ViewController.

```swift
public protocol JZLongPressViewDelegate: class {
    /// When addNew long press gesture ends, this function will be called.
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date)
    /// When Move long press gesture ends, this function will be called.
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date)
    /// Sometimes the longPress will be cancelled because some curtain reason.
    func weekView(_ weekView: JZLongPressWeekView, longPressType: JZLongPressWeekView.LongPressType, didCancelLongPressAt startDate: Date)
}

public protocol JZLongPressViewDataSource: class {
    /// Implement this function to customise your own AddNew longPressView
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView
    /// Implement this function to customise your own Move longPressView
    func weekView(_ weekView: JZLongPressWeekView, movingCell: UICollectionViewCell, viewForMoveLongPressAt startDate: Date) -> UIView
}
```
Also, you should provide the long press types and there are some other properties you can change.

```swift 
calendarWeekView.longPressDelegate = self
calendarWeekView.longPressDataSource = self
calendarWeekView.longPressTypes = [.addNew, .move]

// Optional
calendarWeekView.addNewDurationMins = 120
calendarWeekView.moveTimeMinInterval = 15
```
If you want to use the `move` type long press, you have to inherit your `UICollectionViewCell` from `JZLongPressEventCell` to allow retrieving editing `JZBaseEvent` because of `UICollectionView` reuse problem. Also, remember to set your cell `backgroundColor` in cell `contentView`.

### JZBaseEvent

In JZCalendarWeekView, the data model is using `[Date: [Event]]` dictionary because for each day (a section in collectionView), there might be some events. <br />

A static function called `getIntraEventsByDate` provided in `JZWeekViewHelper` allow you to tranform your events list into `[Date: [Event]]` dictionary.
```swift 
open class func getIntraEventsByDate<T: JZBaseEvent>(originalEvents: [T]) -> [Date: [T]]
```
In order to call this function, you should create a subclass of `JZBaseEvent` and also implement the `NSCopying` protocol. <br />
For the `intraStartDate` and `intraEndDate` in `JZBaseEvent`, it means that if a event crosses two days, it should be divided into two events but with different intraStartDate and intraEndDate. <br />
eg. startDate = 180329 14:00, endDate = 180330 03:00, then two events should be generated: 1. 180329 14:00(IntraStart) - 23:59(IntraEnd) 2. 180330 00:00(IntraStart) - 03:00(IntraEnd)


### All-Day Events

All-Day feature is aimed to display all-day events separately, but only events tagged `isAllDay` true can be shown. For those events crossing few days would better keep them `isAllDay` false. (Refer to Apple Calendar & Google Calendar)<br />
In order to active all-day feature, there are only two things you need to do.

1. Inherit your Event class from `JZAllDayEvent` to ensure the `isAllDay` variable added.
2. In your customised CalendarViewWeekView, override the `viewForSupplementaryElementOfKind` and use `updateView` in `AllDayHeader` to update your all-day view with your own views. [Example](Example/JZCalendarWeekViewExample/Source/LongPressViews/LongPressWeekView.swift)


### Horizontal Scrollable Range

Horizontal scrollable range dates allow you to set your preferred scrollable range. CalendarWeekView can only be horizontal scrollable between `startDate`(including) and `endDate`(including). `nil` means no limit.

1. You can set `scrollableRange` when you call `setupCalendar()` or simply change this variable.
2. If you change `scrollType` without calling `forceReload()`, you should call `setHorizontalEdgesOffsetX()` to reset the edges, because for different scroll types, the edges are different.

#### For futher usage, you can also check the example project, some comments in code or just email me.<br />

## Requirements

- iOS 9.0+
- Xcode 10+
- Swift 4.2

## Installation

### Cocoapods
JZCalendarWeekView can be added to your project by adding the following line to your `Podfile`:

```ruby
# Latest release in CocoaPods (recommend to use latest version before v1.0.0 release, optional: provide version number)
pod 'JZCalendarWeekView'
```

### Carthage
JZCalendarWeekView can be added to your project by adding the following line to your `Cartfile`:

```ruby
# Latest release on Carthage (recommend to use latest version before v1.0.0 release, optional: provide version number)
github "zjfjack/JZCalendarWeekView"
```

## Todo

- [ ] DecorationView for different background views (refer to #12)
- [ ] Limited date range: start time and end Time (vertical) in CalendarView
- [ ] Theme implementation
- [ ] New scroll type: Infinite scroll
- [ ] Support different types of event arrangment rules

## Author

Jeff Zhang, zekejeff@gmail.com </br>
If you have any questions and suggestions, feel free to contact me.

## License

JZCalendarWeekView is available under the MIT license. See the [LICENSE](https://github.com/zjfjack/JZCalendarWeekView/blob/master/LICENSE)  for more info.



