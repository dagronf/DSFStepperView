# DSFStepperView

A custom stepper text field for macOS and iOS (Swift/SwiftUI/Objective-C/Catalyst).

<p align="center">
  <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFStepperView/DSFStepperView.jpg?raw=true" alt="drawing" width="406"/>
  <br/><br/>
  <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFStepperView/indicators.png?raw=true" alt="drawing" width="406"/>
  <br/><br/>
<img src="https://img.shields.io/github/v/tag/dagronf/DSFStepperView"/>
<img src="https://img.shields.io/badge/macOS-10.13+-red"/>
<img src="https://img.shields.io/badge/iOS-13+-blue"/>
<img src="https://img.shields.io/badge/Swift-5.4-orange.svg"/>
<img src="https://img.shields.io/badge/SwiftUI-2.0+-green"/>
<img src="https://img.shields.io/badge/macCatalyst-13.0+-purple"/>
<img src="https://img.shields.io/badge/License-MIT-lightgrey"/>
<a href="https://swift.org/package-manager">
   <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)"/>
</a>
</p>

## Why?

I like the visual approach used with the SwiftUI settings pane, rather than having _really_ small hit targets via the conventional up/down stepper control on macOS.

## Features

* Support for macOS and iOS.
* Cross-platform SwiftUI and Catalyst support for a consistent look.
* `IBDesignable` support so you can see and configure your stepper views in Interface Builder.
* Increment decrement buttons with repeat (click/press and hold to continuously increment/decrement)
* Indicator bar to indicate the current fractional value of the control *(optional)*
* Editable via keyboard *(optional)*
* Empty field support (useful for items that are 'default' or 'inherited' values) *(optional)*
* Set minimum/maximum and increment values. Support for float values (eg. increment by 0.01)
* Font name/size/color
* NumberFormatter support to display the value in the format you wish (for example, always showing 2 decimal places) *(optional)*
* Specify a delegate to receive value change updates, or bind to the field's value.
* Optional delegate to request tooltip strings depending on whether hovering over increment/decrement/text segments
* Support for Combine publishing

## Usage

Add `DSFStepperView` to your project via Swift Package Manager, or copy the sources in the Sources/DSFStepperView directly to your project

Demos are available in the `Demo/` subfolder.

### Via Interface Builder

Add a new `NSView` or `UIView` instance using Interface Builder, then change the class type to `DSFStepperView`

### Programatically

```swift
let stepperView = DSFStepperView(frame: .zero)
stepperView.minimum = -1.0
stepperView.maximum = 1.0
stepperView.allowsEmpty = true
...
// Set the control's value to 0.5
stepperView.floatValue = 0.5

// Clear the control's value
stepperView.floatValue = nil
```

## Receiving value changes

There are four methods for dynamically receiving value updates.

### Receiving value changes via a delegate.

Implement the protocol `DSFStepperViewDelegateProtocol` on an object and set it as the delegate for an instance of `DSFStepperView`. Updates to the value will be received via the

```swift
func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?)
```

interface.

### Providing a change value block

You can provide a block to call via the `onValueChange` property on the stepper view.

```swift
self.stepper.onValueChange = { [weak self] newValue in
   Swift.print("Ordinal value did change to \(String(describing: newValue)) ")
}
```

### Using the Combine framework on macOS 10.15, iOS 13 and later

You can use the Combine framework to subscribe to changes in the control.  On 10.15 and later the control exposes the publisher `publishedValue` from which you can subscribe to value changes.

```swift
self.cancellable = myStepper.publishedValue.sink(receiveValue: { currentValue in
   if let c = currentValue {
      print("stepper is currently at \(c)")
   }
   else {
      print("stepper is currently empty")
   }
})
```

### Binding to `numberValue` on an instance of the control.

You can use bindings to observe the `numberValue` member variable.

```swift
self.stepperObserver = self.observe(\.stepper.numberValue, options: [.new], changeHandler: { (_, value) in
   guard let val = value.newValue else { return }
   Swift.print("\(val)")
})
```

## Value Display Formatting

If you want to allow non-integer values (such as 0.5), you will need to provide a `NumberFormatter` instance to format and validate the value in the field. `DSFStepperView` provides a default NumberFormatter which provides integer only values in the range  (-∞ ... ∞) which you can override.

Using a number formatter also allows you to have a stepper that supports (for example) 1st, 2nd, 3rd, 4th when displaying.

```swift
let format = NumberFormatter()
format.numberStyle = .decimal

// Always display a single digit fractional value.
format.allowsFloats = true
format.minimumFractionDigits = 1
format.maximumFractionDigits = 1

stepperView.numberFormatter = format
```

In Interface Builder you can hook your instance's `numberFormatter` outlet to an instance of NumberFormatter in xib or storyboard.


## Tooltips (macOS only)

You can specify a tooltip for the entire control the usual way using Interface Builder or programatically via 

```swift
myStepperInstance.toolTip = "groovy!"
```

You can also provide individual tooltips for the components of the stepper via an optional function on the delegate.

```swift
@objc optional func stepperView(_ view: DSFStepperView, wantsTooltipTextforSegment segment: DSFStepperView.ToolTipSegment) -> String?
```

Using this method you can provide custom tooltips for the following stepper sections

* The decrement button
* The increment button
* The value text field

## Customizations

### Properties

These properties can all be configured via Interface Builder or programatically.

* `allowsEmpty` : Allow the field to be empty.  Useful if you want to display (for example) an 'inherited' or 'default' label (`Bool`)
* `placeholder` : The placeholder string to use when the field is empty (`String`)
* `minimum` : The minimum value to be allowed in the view (`CGFloat`)
* `maximum` : The maximum value to be allowed in the view (`CGFloat`)
* `increment` : The amount to increment or decrement the count when using the buttons (`CGFloat`)
* `initialValue` : The initial value to be displayed in the field (useful only for @IBDesignable support) (`CGFloat`)
* `fontName` : The name of the font displaying the value (eg. Menlo). Defaults to the system font if the fontName cannot be resolved on the system. (`String`)
* `fontSize` : The size (in pts) of the font displaying the value (`CGFloat`)
* `foregroundColor` : The color of the font displaying the value (`NSColor`/`UIColor`)
* `indicatorColor` : The color to draw the fractional value bar at the bottom of the control (`NSColor`/`UIColor`)
* `numberFormatter` : An optional number formatter for formatting/validating values in the view
* `isEnabled` : Enable or disable the control
* `font` : The font for the text field

## SwiftUI

A SwiftUI wrapper is available, supporting both iOS and macOS.  There is a demo project for iOS and macOS in the `Demo` subfolder.

<details>
<summary>Example</summary>

```swift
struct ContentView: View {

   @State private var currentValue: CGFloat? = 23
   @State private var isEnabled: Bool = true
   
   let configuration = DSFStepperView.SwiftUI.DisplaySettings(
      minimum: 0, maximum: 100, increment: 1
   )
   let style = DSFStepperView.SwiftUI.Style(
      font: DSFFont.systemFont(ofSize: 24, weight: .heavy),
      indicatorColor: DSFColor.systemBlue)

   var body: some View {
      DSFStepperView.SwiftUI(
         configuration: self.configuration,
         style: self.style,
         isEnabled: self.isEnabled,
         floatValue: self.$currentValue,
         onValueChange: { value in
            Swift.print("New value is \(String(describing: value))")
         }
      )
   }
}
```

</details>

## History

* `4.0.0`:
  - Move to minimum macOS 10.13 target, Swift 5.4.
  - Added inline SwiftUI previews for swiftui source.
* `3.0.0`: Explicitly define both static and dynamic libraries in the package.
* `2.0.1`: Fixed [issue 4](https://github.com/dagronf/DSFStepperView/issues/4) 
* `2.0.0`:
  - Added iOS implementation for cross-platform compatibility (both SwiftUI and Catalyst support)
  - Separated `floatValue` into `floatValue` (Swift only) and `numberValue` (an NSNumber for objc). If you have used bindings in your XIB that previously observed `floatValue` you will need to update them to use `numberValue` instead.
  - Removed the ability to *set* the value via the publisher in Combine (was a dumb idea).
* `1.1.4`: Added Objc demo, fixed delegate visibility
* `1.1.3`: Fixed issue with default SwiftUI initializer not exported.
* `1.1.2`: Some updates for accessibility
* `1.1.1`: Fixed issue with Combine not available before 10.15
* `1.1.0`: Added mouseover highlight for buttons, Combine publisher (10.15+), SwiftUI wrapper (10.15+).
* `1.0.2`: Fixed Issue where 10.14 and earlier didn't display the value (NumberFormatter changes)
* `1.0.1`: Fixed Bug #1 regarding disappearing button labels on Big Sur
* `1.0.0`: Initial release

## License

MIT. Use it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
