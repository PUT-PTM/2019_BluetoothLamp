# TactileSlider

[![CI Status](https://img.shields.io/travis/daprice/iOS-Tactile-Slider.svg?style=flat)](https://travis-ci.org/daprice/iOS-Tactile-Slider)
[![Version](https://img.shields.io/cocoapods/v/TactileSlider.svg?style=flat)](https://cocoapods.org/pods/TactileSlider)
[![License](https://img.shields.io/cocoapods/l/TactileSlider.svg?style=flat)](https://cocoapods.org/pods/TactileSlider)
[![Platform](https://img.shields.io/cocoapods/p/TactileSlider.svg?style=flat)](https://cocoapods.org/pods/TactileSlider)

A slider control designed to be easy to grab and use because it can be dragged or tapped from anywhere along its track, similar to the sliders in Control Center and HomeKit.

![Animated gif of TactileSliders animating to values](Screenshots/animated.gif)

## Features

- Can be dragged or (optionally) tapped to set a value
- Supports horizontal and vertical orientation in either direction
- IBDesignable – colors, values, rounded corners, and behavior can be customized in Interface Builder or programatically
- Adjustable haptic feedback (iOS 10+)
- VoiceOver support

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0+ (iOS 10.0+ required for haptic feedback)

## Installation

TactileSlider is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TactileSlider'
```

## Usage

```swift
let slider = TactileSlider(frame: someRect)

slider.minimumValue = 1
slider.maximumValue = 10

slider.setValue(3.8, animated: true)
```

### Setting orientation and direction

```swift
slider.vertical = true
slider.reverseValueAxis = true
```

### Adjusting behavior

```swift
slider.isContinuous = false
slider.enableTapping = false // allow or disallow tapping anywhere on the slider track to instantly set a value
slider.scaleUpWhenInUse = true // make the slider puff up slightly while being dragged
```

### Changing colors and appearance

```swift
slider.trackBackground = UIColor.black.withAlpha(0.8)
slider.thumbTint = UIColor.blue
slider.cornerRadius = 12
```

### Interface Builder

![screenshot of Xcode Interface Builder demonstrating a TactileSlider being customized using the graphical interface](Screenshots/IBDesignable.png)

## Author

Dale Price ([@dale_price@mastodon.technology](https://mastodon.technology/@dale_price))

## License

TactileSlider is available under the MIT license. See the LICENSE file for more info.
