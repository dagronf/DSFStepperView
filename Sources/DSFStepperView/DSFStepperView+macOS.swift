//
//  DSFStepperView.swift
//
//  Created by Darren Ford on 10/11/20.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if canImport(AppKit) && os(macOS)

import Carbon.HIToolbox
import AppKit

import Combine

@IBDesignable
public class DSFStepperView: NSView {

	// The default color for the text
	static let defaultLabelColor: NSColor = NSColor.textColor

	// The indicator color (off by default)
	static let defaultIndicatorColor: NSColor? = nil

	// MARK: - Delegate

	/// The (optional) callback delegate
	@objc public var delegate: DSFStepperViewDelegateProtocol? {
		didSet {
			// Need to make sure the tooltip hit targets are created and checked
			self.needsLayout = true
		}
	}

	// MARK: Properties

	/// Enable or disable the control
	@objc public var isEnabled: Bool = true {
		didSet {
			self.editField.isEnabled = self.isEnabled
		}
	}

	/// Does this control allow an 'empty' value?
	@IBInspectable public var allowsEmpty: Bool = true {
		didSet {
			self.editField.allowsEmpty = self.allowsEmpty
		}
	}

	/// Allow the user to manually enter text
	@IBInspectable public var allowsKeyboardInput: Bool = true {
		didSet {
			self.editField.allowsKeyboardInput = self.allowsKeyboardInput
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
				self.floatValue = self.initialValue
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
	@IBInspectable public var foregroundColor: NSColor? {
		didSet {
			self.editField.foregroundColor = self.foregroundColor
		}
	}

	/// The color to draw the indicator. If not set, then no indicator is drawn
	@IBInspectable public var indicatorColor: NSColor? = nil {
		didSet {
			self.editField.indicatorColor = self.indicatorColor
		}
	}

	/// The color to draw the border
	///
	/// NOTE: If you set this value, you will need to handle accessibility changes yourself.
	@IBInspectable public var borderColor: NSColor? = nil {
		didSet {
			self.editField.borderColor = self.borderColor
		}
	}

	/// The color to draw the control background.
	///
	/// NOTE: If you set this value, you will need to handle accessibility changes yourself.
	@IBInspectable public var borderBackground: NSColor? = nil {
		didSet {
			self.editField.borderBackground = self.borderBackground
		}
	}

	/// The font for the control.
	public var font: NSFont? {
		get {
			return self.editField.font
		}
		set {
			self.editField.font = newValue
			self.editField.invalidateIntrinsicContentSize()
			self.editField.needsLayout = true
		}
	}

	// The current range definition
	public var range: ClosedRange<CGFloat> {
		return self.minimum ... self.maximum
	}

	// We only want to allow focus if 'allowsKeyboardInput' is true
	public override var acceptsFirstResponder: Bool {
		return self.allowsKeyboardInput == false
	}

	// MARK: - Formatter

	/// A number formatter for display and validation within the control (optional)
	@IBOutlet var numberFormatter: NumberFormatter? {
		didSet {
			self.editField.valueFormatter = self.numberFormatter
		}
	}

	// MARK: Value

	/// The value being displayed in the control.  nil represents an 'empty' value, so you can display 'inherited' or 'default' depending on your needs.
	public dynamic var floatValue: CGFloat? {
		didSet {
			// Update the displayed value in the control
			self.updateEditFieldValue()

			// Update the published value for Combine
			if !self.isSettingPublishedValue {
				self.isSettingPublishedValue = true
				self.updatePublishedValue()
				self.isSettingPublishedValue = false
			}

			self.willChangeValue(for: \.numberValue)
			self.didChangeValue(for: \.numberValue)

			// If there's a delegate set, call the change method
			self.delegate?.stepperView(self, didChangeValueTo: self.floatValue?.numberValue)
		}
	}

	/// The value being displayed in the control.  nil represents an 'empty' value, so you can display 'inherited' or 'default' depending on your needs.
	@objc public dynamic var numberValue: NSNumber? {
		get {
			return self.floatValue?.numberValue
		}
		set {
			self.floatValue = newValue?.cgFloatValue
		}
	}

	/// A CurrentValueSubject for the stepper.
	@available(OSX 10.15, *)
	public var publishedValue: CurrentValueSubject<CGFloat?, Never> {
		return self.observableCurrentObject as! CurrentValueSubject<CGFloat?, Never>
	}

	// Update the publisher value for combine. Does nothing for < 10.15
	private func updatePublishedValue() {
		if #available(OSX 10.15, *) {
			if let value = self.floatValue {
				self.publishedValue.value = value
			}
			else {
				self.publishedValue.value = nil
			}
		}
	}

	// MARK: - Embedded edit field

	// Custom edit field
	private let editField = DSFStepperTextField()

	// MARK: - Tooltip handling callback tags
	private var tooltipIncrementButton: NSView.ToolTipTag?
	private var tooltipDecrementButton: NSView.ToolTipTag?
	private var tooltipTextValue: NSView.ToolTipTag?

	// MARK: - Publisher handling for combine

	// Unfortunately, we don't have the ability in swift to use #available for stored properties.
	// So we have a hacky workaround - dynamically create the CurrentValueSubject and obscure the
	// type behind an AnyObject.

	private var isSettingPublishedValue = false
	private var cancellable: AnyObject?
	lazy private var observableCurrentObject: AnyObject? = {
		if #available(OSX 10.15, *) {
			return CurrentValueSubject<CGFloat?, Never>(nil)
		}
		return nil
	}()

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}


	// MARK: - Cleanup

	deinit {
		if #available(macOS 10.15, *) {
			if let cancel = self.cancellable as? AnyCancellable {
				cancel.cancel()
				self.cancellable = nil
			}
		}
		self.observableCurrentObject = nil
	}

}

// MARK: - Handle no-edit focus keyboard support

extension DSFStepperView {
	var drawnBorder: CGRect {
		return self.bounds.insetBy(dx: 0, dy: 2)
	}

	public override var focusRingMaskBounds: NSRect {
		return self.drawnBorder
	}

	public override func drawFocusRingMask() {
		let pth = NSBezierPath(roundedRect: self.drawnBorder, xRadius: 4, yRadius: 4)
		pth.fill()
	}

	public override func keyDown(with event: NSEvent) {
		if event.keyCode == kVK_UpArrow || event.keyCode == kVK_RightArrow {
			self.editField.increment(self)
		}
		else if event.keyCode == kVK_DownArrow || event.keyCode == kVK_LeftArrow {
			self.editField.decrement(self)
		}
		else {
			super.keyDown(with: event)
		}
	}
}

public extension DSFStepperView {
	override func prepareForInterfaceBuilder() {
		self.setup()
	}

	override var intrinsicContentSize: NSSize {
		var s = self.editField.intrinsicContentSize
		s.height += 4
		return s
	}

	override func layout() {
		super.layout()

		self.editField.frame = self.bounds

		self.updateTooltipHitTargets()
	}
}

private extension DSFStepperView {
	// The CGFloat value that indicates 'empty' for the control
	static let OptionalIndicatorValue = CGFloat.greatestFiniteMagnitude

	func setup() {

		self.translatesAutoresizingMaskIntoConstraints = false

		// Add and configure the edit field
		self.addSubview(self.editField)
		self.editField.configure()

		self.editField.placeholderString = self.placeholder
		self.editField.minimum = self.minimum
		self.editField.maximum = self.maximum
		self.editField.increment = self.increment

		self.editField.allowsKeyboardInput = self.allowsKeyboardInput
		self.editField.allowsEmpty = self.allowsEmpty

		// Push down the initial value
		self.updateEditFieldValue()

		if let f = self.numberFormatter {
			self.editField.valueFormatter = f
		}

		self.needsLayout = true

		self.configurePublisher()
	}

	func configurePublisher() {
		if #available(OSX 10.15, *) {
			self.cancellable = self.publishedValue.sink(receiveValue: { [weak self] currentValue in
				guard let `self` = self else { return }
				if !self.isSettingPublishedValue {
					self.isSettingPublishedValue = true

					if let value = currentValue {
						self.floatValue = value
					}
					else {
						self.floatValue = nil
					}
					self.isSettingPublishedValue = false
				}
			})
		}
	}


	func updateEditFieldValue() {
		if let value = self.floatValue {
			self.editField.current = value
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
