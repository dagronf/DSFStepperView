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
	/// Called when the value in the stepper changes
	/// - Parameters:
	///   - view: the stepper view that changed value
	///   - value: the new value, or nil if the value is empty
	@objc func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?)

	/// Called to retrieve the tooltip text for the control (optional)
	/// - Parameters:
	///   - view: the stepper view
	///   - segment: the segment of the control to retreive tooltip text for
	/// - Returns the string to display for the control segment, or nil if no tooltip should be displayed
	@objc optional func stepperView(_ view: DSFStepperView, wantsTooltipTextforSegment segment: DSFStepperView.ToolTipSegment) -> String?
}

@IBDesignable
public class DSFStepperView: NSView {
	// MARK: - Delegate

	/// The (optional) callback delegate
	public var delegate: DSFStepperViewDelegateProtocol? {
		didSet {
			// Need to make sure the tooltip hit targets are created and checked
			self.needsLayout = true
		}
	}

	// MARK: Properties

	/// Enable or disable the control
	@objc public var isEnabled: Bool = true {
		didSet {
			self.editField.fieldEnabled = self.isEnabled
		}
	}

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

	// MARK: - Formatter

	/// A number formatter for display and validation within the control (optional)
	@IBOutlet var numberFormatter: NumberFormatter! {
		didSet {
			self.editField.valueFormatter = self.numberFormatter
		}
	}

	// MARK: Value

	/// The value being displayed in the control.  nil represents an 'empty' value, so you can display 'inherited' or 'default' depending on your needs.
	@objc public dynamic var floatValue: NSNumber? {
		didSet {
			self.pushFloatValue()
			self.delegate?.stepperView(self, didChangeValueTo: self.floatValue)
		}
	}

	// MARK: Private

	// Custom edit field
	private lazy var editField: DSFStepperTextField = {
		let e = DSFStepperTextField()
		e.translatesAutoresizingMaskIntoConstraints = false
		return e
	}()

	// Tooltip handling callback tags
	private var tooltipIncrementButton: NSView.ToolTipTag?
	private var tooltipDecrementButton: NSView.ToolTipTag?
	private var tooltipTextValue: NSView.ToolTipTag?
}

public extension DSFStepperView {
	override func prepareForInterfaceBuilder() {
		self.setup()
		self.editField.setup()
	}

	override func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		if let _ = newWindow {
			self.setup()
		}
	}

	override var intrinsicContentSize: NSSize {
		var s = self.editField.intrinsicContentSize
		s.height += 4
		return s
	}

	override func layout() {
		super.layout()
		self.updateTooltipHitTargets()
	}
}

private extension DSFStepperView {
	// The CGFloat value that indicates 'empty' for the control
	static let OptionalIndicatorValue = CGFloat.greatestFiniteMagnitude

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

// MARK: - Tooltip callback

extension DSFStepperView: NSViewToolTipOwner {
	/// The tooltip string types
	@objc public enum ToolTipSegment: Int {
		/// The tooltip for the decrement button
		case decrementButton = 0
		/// The tooltip for the 'value' (the text part of the button)
		case value = 1
		/// The tooltip for the increment button
		case incrementButton = 2
	}

	private func updateTooltipHitTargets() {
		// We always need to remove the hit targets on an update, even when removing the delegate

		if let t = self.tooltipDecrementButton {
			self.removeToolTip(t)
			self.tooltipDecrementButton = nil
		}

		if let t = self.tooltipTextValue {
			self.removeToolTip(t)
			self.tooltipTextValue = nil
		}

		if let t = self.tooltipIncrementButton {
			self.removeToolTip(t)
			self.tooltipIncrementButton = nil
		}

		// If we don't have a delegate, we're done
		guard let _ = self.delegate else {
			return
		}

		// Decrement hit target
		let decr = self.bounds.divided(atDistance: DSFStepperTextField.HitTargetWidth, from: .minXEdge).slice
		self.tooltipDecrementButton = self.addToolTip(decr, owner: self, userData: nil)

		// Value hit target
		var valueRect: CGRect = self.bounds
		valueRect.origin.x += DSFStepperTextField.HitTargetWidth
		valueRect.size.width -= 2 * DSFStepperTextField.HitTargetWidth
		self.tooltipTextValue = self.addToolTip(valueRect, owner: self, userData: nil)

		// Increment hit target
		let incr = self.bounds.divided(atDistance: DSFStepperTextField.HitTargetWidth, from: .maxXEdge).slice
		self.tooltipIncrementButton = self.addToolTip(incr, owner: self, userData: nil)
	}

	public func view(_: NSView, stringForToolTip tag: NSView.ToolTipTag, point _: NSPoint, userData _: UnsafeMutableRawPointer?) -> String {
		guard let delegate = self.delegate else {
			// No delegate, no tooltip request
			return ""
		}

		let segment: DSFStepperView.ToolTipSegment
		if tag == self.tooltipDecrementButton {
			segment = .decrementButton
		}
		else if tag == self.tooltipTextValue {
			segment = .value
		}
		else {
			segment = .incrementButton
		}
		return delegate.stepperView?(self, wantsTooltipTextforSegment: segment) ?? ""
	}
}

#endif
