# DSFStepperView

A custom stepper text field ala Xcode SwiftUI options

<img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFStepperView/DSFStepperView.jpg?raw=true" alt="drawing" width="406"/>

## Why?

I like the visual approach used with the SwiftUI settings pane, rather than having _really_ small hit targets via the conventional up/down stepper control.

## Features

* Fully auto-layout managed
* Increment decrement buttons with repeat (click and hold to continuously increment/decrement)
* Editable via keyboard
* Supports 'empty' fields (useful for items that are 'default' or 'inherited' values)
* Set minimum/maximum and increment values. Support for float values (eg. increment by 0.01)
* Font name/size/color
* Optionally specify a NumberFormatter to display the value in the format you wish (for example, always showing 2 decimal places)
* Specify a delegate to receive value change updates, or bind to the field's value.
