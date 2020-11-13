# DSFStepperView

A custom stepper text field.

<img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFStepperView/DSFStepperView.jpg?raw=true" alt="drawing" width="406"/>

![](https://img.shields.io/github/v/tag/dagronf/DSFStepperView) ![](https://img.shields.io/badge/macOS-10.12+-blue) ![](https://img.shields.io/badge/Swift-5.0-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

## Why?

I like the visual approach used with the SwiftUI settings pane, rather than having _really_ small hit targets via the conventional up/down stepper control.

## Features

* `IBDesignable` support so you can see and configure your stepper views in Interface Builder
* Increment decrement buttons with repeat (click and hold to continuously increment/decrement)
* Editable via keyboard
* Supports empty fields (useful for items that are 'default' or 'inherited' values)
* Set minimum/maximum and increment values. Support for float values (eg. increment by 0.01)
* Font name/size/color
* Optionally specify a NumberFormatter to display the value in the format you wish (for example, always showing 2 decimal places)
* Specify a delegate to receive value change updates, or bind to the field's value.
* Optional delegate to request tooltip strings depending on whether hovering over increment/decrement/text segments
* Fully auto-layout managed

## Usage

Add `DSFStepperView` to your project via Swift Package Manager, or copy the sources in the Sources/DSFStepperView directly to your project

### Via Interface Builder

Add a new `NSView` instance using Interface Builder, then change the class type to `DSFStepperView`

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

### Receiving value changes

There are two methods for dynamically receiving value updates.

#### Receiving value changes via a method on the delegate.

```swift
func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?)
```

#### Binding to `floatValue` on an instance of the control.

```swift
self.stepperObserver = self.observe(\.stepper.floatValue, options: [.new], changeHandler: { (_, value) in
   guard let val = value.newValue else { return }
   Swift.print("\(val)")
})
```

### Number Formatting

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

### Tooltips

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
* `initialValue` : The initial value to be displayed in the field (useful only for @IBDesignable support)
* `fontName` : The name of the font displaying the value (eg. Menlo). Defaults to the system font if the fontName cannot be resolved on the system. (`String`)
* `fontSize` : The size (in pts) of the font displaying the value (`CGFloat`)
* `foregroundColor` : The color of the font displaying the value (`NSColor`)
* `numberFormatter` : An optional number formatter for formatting/validating values in the view
* `isEnabled` : Enable or disable the control

## History

* `1.0.2`: Fixed Issue where 10.14 and earlier didn't display the value (NumberFormatter changes)
* `1.0.1`: Fixed Bug #1 regarding disappearing button labels on Big Sur
* `1.0.0`: Initial release

## License

```
MIT License

Copyright (c) 2020 Darren Ford

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
