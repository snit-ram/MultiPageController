# MultiPageController

[![Version](https://img.shields.io/cocoapods/v/MultiPageController.svg?style=flat)](http://cocoapods.org/pods/MultiPageController)
[![License](https://img.shields.io/cocoapods/l/MultiPageController.svg?style=flat)](http://cocoapods.org/pods/MultiPageController)
[![Platform](https://img.shields.io/cocoapods/p/MultiPageController.svg?style=flat)](http://cocoapods.org/pods/MultiPageController)

Component inspired by UIPageController that allows fast navigation by scrolling to switch to a different ViewController.
ViewControllers are lazily instantiated the first time it gets activated.

An item gets automatically selected if the user stop scrolling, or the user can tap an element o select it.

![MultiPageViewController Image](http://i.makeagif.com/media/11-08-2016/_mrVVK.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS >= 9.0
* Swift 3.0

## Installation

MultiPageController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MultiPageController"
```

## Usage
Set the MultipageController's datasource and reload it's data:
```swift
let multipageController = MultipageController()
multipageController.dataSource = self
multipageController.reloadData()
```

### MultiPageControllerDataSource Methods

```swift
/*
* Returns the number of items to be presented when scrolling
*/
func numberOfItems(in: MultiPageController) -> Int

/*
* Returns a view to be used as preview of the item the user can select. 
* This is called only once per element.
*/
func multiPageController(_ multiPageController: MultiPageController, viewControllerAt index: Int) -> UIViewController

/* 
* Returns the view controller to be presented when the user taps selects an element. 
* This is called once the user first selects the element at the specified index
*/
func multiPageController(_ multiPageController: MultiPageController, previewViewAt index: Int) -> UIView
```

## Author

Rafael Martins, snit.ram@gmail.com

## License

MultiPageController is available under the MIT license. See the LICENSE file for more info.
