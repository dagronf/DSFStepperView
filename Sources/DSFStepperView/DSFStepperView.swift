//
//  DSFStepperView.swift
//
//  Created by Darren Ford on 10/11/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//
//	MIT License
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//

#if os(macOS)

import AppKit

@objc public protocol DSFStepperViewDelegateProtocol {
	@objc func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?)
}

@IBDesignable
public class DSFStepperView: NSView {
	public var delegate: DSFStepperViewDelegateProtocol? = nil

	// The CGFloat value that indicates 'empty' for the control
	static let OptionalIndicatorValue = CGFloat.greatestFiniteMagnitude

	// Custom edit field
	private lazy var editField: DSFStepperTextField = {
		let e = DSFStepperTextField()
		e.translatesAutoresizingMaskIntoConstraints = false
		return e
	}()

	/// Does this control allow an 'empty' value?
	@IBInspectable public var allowsEmpty: Bool = true {
		didSet {
			self.editField.allowsEmpty = self.allowsEmpty
		}
	}

	/// Placeholder text to display if the field is empty
	@IBInspectable public var placeholder: String? {
		didSet {
			if self.allowsEmpty {
				self.editField.placeholderString = self.placeholder
			}
		}
	}

	/// The minimum allowable value in the control
	@IBInspectable public var minimum: CGFloat = -CGFloat.greatestFiniteMagnitude {
		didSet {
			self.editField.minimum = self.minimum
		}
	}

	/// The maximum allowable value in the control
	@IBInspectable public var maximum: CGFloat = CGFloat.greatestFiniteMagnitude {
		didSet {
			self.editField.maximum = self.maximum
		}
	}

	/// How much to increment/decrement the value when pressing the -/+ buttons
	@IBInspectable public var increment: CGFloat = 1 {
		didSet {
			self.editField.increment = self.increment
		}
	}

	/// The initial value to be displayed in the control
	@IBInspectable public var initialValue: CGFloat = DSFStepperView.OptionalIndicatorValue {
		didSet {
			if self.initialValue == DSFStepperView.OptionalIndicatorValue {
				self.floatValue = nil
			}
			else {
				self.floatValue = NSNumber(value: Float(self.initialValue))
			}
		}
	}

	/// The name of the font to be used in the control
	@IBInspectable public var fontName: String = NSFont.systemFont(ofSize: 2).fontName {
		didSet {
			self.editField.font = NSFont(name: self.fontName, size: self.fontSize)
		}
	}

	/// The size of the font to be used in the control
	@IBInspectable public var fontSize: CGFloat = NSFont.systemFontSize {
		didSet {
			self.editField.font = NSFont(name: self.fontName, size: self.fontSize)
		}
	}

	/// The font color (default is the standard text color)
	@IBInspectable public var foregroundColor: NSColor? = nil {
		didSet {
			self.editField.textColor = self.foregroundColor
		}
	}

	/// A number formatter for display and validation within the control (optional)
	@IBOutlet var numberFormatter: NumberFormatter! {
		didSet {
			self.editField.valueFormatter = self.numberFormatter
		}
	}

	// MARK: - Value

	/// The value being displayed in the control.  nil represents an 'empty' value, so you can display 'inherited' or 'default' depending on your needs.
	@objc public dynamic var floatValue: NSNumber? {
		didSet {
			self.pushFloatValue()
			self.delegate?.stepperView(self, didChangeValueTo: self.floatValue)
		}
	}
}

extension DSFStepperView {
	override public func prepareForInterfaceBuilder() {
		self.setup()
		self.editField.setup()
	}

	override public func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		if let _ = newWindow {
			self.setup()
		}
	}

	override public var intrinsicContentSize: NSSize {
		var s = self.editField.intrinsicContentSize
		//s.height += 4
		return s
	}
}

private extension DSFStepperView {
	func setup() {

		if self.editField.isReady {
			return
		}

		self.addSubview(self.editField)
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[item]-2-|", options: .alignAllCenterY, metrics: [:], views: ["item": self.editField]))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[item]-2-|", options: .alignAllCenterX, metrics: [:], views: ["item": self.editField]))

		self.editField.placeholderString = self.placeholder
		self.editField.minimum = self.minimum
		self.editField.maximum = self.maximum
		self.editField.increment = self.increment

		// Push down the initial value
		self.pushFloatValue()

		if let f = self.numberFormatter {
			self.editField.valueFormatter = f
		}

		self.needsUpdateConstraints = true
		self.needsLayout = true
	}

	func pushFloatValue() {
		if let val = self.floatValue {
			self.editField.current = CGFloat(truncating: val)
		}
		else {
			self.editField.current = nil
		}
	}
}

#endif
