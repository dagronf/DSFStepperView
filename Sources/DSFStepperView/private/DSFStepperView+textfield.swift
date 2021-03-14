//
//  DSFStepperView+textfield.swift
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

import AppKit

/// A stepper text field
internal class DSFStepperTextField: NSTextField {
	static let HitTargetWidth: CGFloat = 24

	fileprivate var isInCurrentUpdate: Bool = false

	@inlinable var parent: DSFStepperView? {
		return (self.superview as? DSFStepperView)
	}

	fileprivate var customCell: DSFStepperViewTextFieldCell {
		return self.cell as! DSFStepperViewTextFieldCell
	}

	override var isEnabled: Bool {
		get {
			return super.isEnabled
		}
		set {
			super.isEnabled = newValue
			self.updateForEnableDisable()
		}
	}

	/// The default number formatter (-∞ … ∞), no floating point
	private static let DefaultFormatter: NumberFormatter = {
		let format = NumberFormatter()
		format.numberStyle = .decimal
		format.minimumIntegerDigits = 1
		format.allowsFloats = false
		return format
	}()

	/// The value formatter for the field. If nil, provides a default formatter
	var valueFormatter: NumberFormatter? {
		get {
			return self.customCell.formatter as? NumberFormatter ?? DSFStepperTextField.DefaultFormatter
		}
		set {
			self.customCell.formatter = newValue ?? DSFStepperTextField.DefaultFormatter
			let v = self.current
			self.current = v
			//self.needsDisplay = true
		}
	}

	// Does the field support empty values?
	var allowsEmpty: Bool = true

	var allowsKeyboardInput: Bool = false {
		didSet {
			self.isEditable = self.allowsKeyboardInput
			//self.customCell.isEditable = self.allowsKeyboardInput
		}
	}

	// The value of the field BEFORE the edit started.  Allows for hitting 'esc' during edit to cancel the change
	private var beforeEditValue: CGFloat?

	var lastNonEmptyValue: CGFloat = 0

	/// The minimum value defined for the control
	var minimum: CGFloat = -CGFloat.greatestFiniteMagnitude {
		didSet {
			var currVal: CGFloat? = self.current
			if let curr = currVal, self.minimum > curr {
				currVal = self.minimum
			}
			self.current = currVal
		}
	}

	/// The maximum value defined for the control
	var maximum = CGFloat.greatestFiniteMagnitude {
		didSet {
			var currVal: CGFloat? = self.current
			if let curr = currVal, self.maximum < curr {
				currVal = self.maximum
			}
			self.current = currVal
		}
	}

	/// How much we increment/decrement the value for each button press
	var increment: CGFloat = 1

	/// The current value of the control
	var current: CGFloat? {
		didSet {
			if self.isInCurrentUpdate { return }
			self.isInCurrentUpdate = true
			defer { self.isInCurrentUpdate = false }

			guard let curr = current else {
				self.stringValue = ""
				self.parent?.floatValue = nil
				self.customCell.fractionalValue = -1
				return
			}

			let v = self.clamped(curr)
			let val = Float(v)
			self.stringValue = self.valueFormatter?.string(from: NSNumber(value: val)) ?? ""
			self.updateForEnableDisable()

			if let value = self.current,
				self.maximum != CGFloat.greatestFiniteMagnitude,
				self.minimum != -CGFloat.greatestFiniteMagnitude {
				self.customCell.fractionalValue = (value - self.minimum) / (self.maximum - self.minimum)
			}
			else {
				self.customCell.fractionalValue = -1
			}

			self.lastNonEmptyValue = v

			self.parent?.floatValue = CGFloat(val)
		}
	}

	private func clamped(_ value: CGFloat) -> CGFloat {
		return max(self.minimum, min(self.maximum, value))
	}

	// Set the foreground color for the text and buttons
	var foregroundColor: NSColor? {
		didSet {
			let labelColor = self.foregroundColor ?? DSFStepperView.defaultLabelColor
			self.textColor = labelColor
			self.customCell.textColor = labelColor
			if #available(OSX 10.14, *) {
				self.incrementButton.contentTintColor = labelColor
				self.decrementButton.contentTintColor = labelColor
			}
			self.needsDisplay = true
		}
	}

	// Set the foreground color for the text and buttons
	var indicatorColor: NSColor? {
		didSet {
			self.customCell.indicatorColor = self.indicatorColor
			self.needsDisplay = true
		}
	}

	// Set the foreground color for the text and buttons
	var borderColor: NSColor? {
		didSet {
			self.customCell.borderColor = self.borderColor
			self.needsDisplay = true
		}
	}

	// Set the foreground color for the text and buttons
	var borderBackground: NSColor? {
		didSet {
			self.customCell.borderBackground = self.borderBackground
			self.needsDisplay = true
		}
	}

	// MARK: - Decrement Button definition

	lazy var decrementImage: NSImage = {
		let i = NSImage(named: "NSRemoveTemplate")!.resizeImage(maxSize: NSSize(width: 12, height: 12))
		i.isTemplate = true
		return i
	}()

	lazy var decrementButton: NSButton = {
		let b = createButton()
		let im = self.decrementImage
		im.isTemplate = true
		b.image = im
		b.imagePosition = .imageOnly
		b.action = #selector(decrement(_:))
		return b
	}()

	@objc func decrement(_: Any) {
		let newValue: CGFloat = {
			if let current = self.current {
				return current
			}

			return self.lastNonEmptyValue
		}()

		self.current = self.clamped(newValue - self.increment)
	}

	// MARK: - Increment Button definition

	lazy var incrementImage: NSImage = {
		let i = NSImage(named: "NSAddTemplate")!.resizeImage(maxSize: NSSize(width: 12, height: 12))
		i.isTemplate = true
		return i
	}()

	lazy var incrementButton: NSButton = {
		let b = createButton()
		let im = self.incrementImage
		im.isTemplate = true
		b.image = im
		b.imagePosition = .imageOnly
		b.action = #selector(increment(_:))
		return b
	}()

	@objc func increment(_: Any) {
		let newValue: CGFloat = {
			if let current = self.current {
				return current
			}

			return self.lastNonEmptyValue
		}()

		self.current = self.clamped(newValue + self.increment)
	}
}

extension DSFStepperTextField {
	func setButtonLabelSize(sz: CGFloat) {
		let add = NSImage(named: "NSAddTemplate")!.resizeImage(maxSize: NSSize(width: sz, height: sz))
		add.isTemplate = true
		self.incrementButton.image = add

		let rem = NSImage(named: "NSRemoveTemplate")!.resizeImage(maxSize: NSSize(width: sz, height: sz))
		rem.isTemplate = true
		self.decrementButton.image = rem
	}
}


extension DSFStepperTextField {

	private func updateForEnableDisable() {
		if let _ = self.current {
			self.decrementButton.isEnabled = self.current != self.minimum && self.isEnabled
			self.incrementButton.isEnabled = self.current != self.maximum && self.isEnabled
		}
		else {
			self.decrementButton.isEnabled = true
			self.incrementButton.isEnabled = true
		}

		self.decrementButton.isHidden = !self.isEnabled
		self.incrementButton.isHidden = !self.isEnabled
	}

	override func drawFocusRingMask() {
		let b = NSBezierPath(roundedRect: self.bounds, xRadius: 4, yRadius: 4)
		b.fill()
	}

	override var intrinsicContentSize: NSSize {
		var s = super.intrinsicContentSize
		s.height += 4
		return s
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}

	override func layout() {
		super.layout()

		var decRec = self.bounds.insetBy(dx: 2, dy: 2)
		decRec.size.width = DSFStepperTextField.HitTargetWidth
		self.decrementButton.frame = decRec

		var incRec = self.bounds.insetBy(dx: 0, dy: 2)
		incRec.origin.x = self.bounds.maxX - DSFStepperTextField.HitTargetWidth - 2
		incRec.size.width = DSFStepperTextField.HitTargetWidth
		self.incrementButton.frame = incRec
	}
}

extension DSFStepperTextField {
	/// Build up the label
	func configure() {
		let newCell = DSFStepperViewTextFieldCell()
		let oldCell = self.cell as! NSTextFieldCell

		self.cell = newCell

		self.isSelectable = true
		newCell.isScrollable = false

		self.isContinuous = true
		self.alignment = .center

		self.font = oldCell.font
		self.formatter = oldCell.formatter
		self.placeholderString = oldCell.placeholderString

		self.isBordered = false
		self.isBezeled = false
		self.drawsBackground = false

		// Add the buttons.  Since these are not autolayout managed, we'll need to position them manually in layout()
		// (The reason for not making these autolayout is
		//   1. SwiftUI can be really tricky when it comes to autolayout and hosted views
		//   2. This view is quite simple so its easier to manage the layout ourselves
		self.addSubview(self.decrementButton)
		self.addSubview(self.incrementButton)

		self.delegate = self

		if let curr = self.current {
			self.stringValue = self.valueFormatter?.string(from: NSNumber(value: Float(curr))) ?? ""
		}
		else {
			self.stringValue = ""
		}

		self.updateForEnableDisable()

		/// Set the accessibility role to match that defined in Xcode
		self.setAccessibilityLabel(DSFStepperView.Localization.AccessibilityRole)
	}
}

private extension DSFStepperTextField {
	private func createButton() -> NSButton {
		let b = DSFDelayedRepeatingButton(frame: .zero)
		b.setButtonType(.momentaryChange)
		b.isBordered = false
		b.wantsLayer = true
		b.target = self
		return b
	}
}

extension DSFStepperTextField: NSTextFieldDelegate {
	override public func cancelOperation(_: Any?) {
		self.current = self.beforeEditValue
	}

	public func controlTextDidBeginEditing(_: Notification) {
		self.beforeEditValue = self.current
	}

	public func controlTextDidEndEditing(_: Notification) {
		self.beforeEditValue = nil

		if self.stringValue.isEmpty, self.allowsEmpty {
			self.current = nil
			return
		}

		if let v = self.valueFormatter?.number(from: self.stringValue)?.floatValue {
			self.current = self.clamped(CGFloat(v))
		}
	}

	public func control(_: NSControl, isValidObject _: Any?) -> Bool {
		if self.stringValue.isEmpty {
			return self.allowsEmpty
		}
		return self.valueFormatter?.number(from: self.stringValue) != nil
	}
}

private class DSFStepperViewTextFieldCell: NSTextFieldCell {

	fileprivate var indicatorColor: NSColor? = nil
	fileprivate var fractionalValue: CGFloat = -1
	fileprivate var borderColor: NSColor? = nil
	fileprivate var borderBackground: NSColor? = nil

	// Returns the color of the indicator if it has been set AND the control has a valid fractional value, else nil
	@inlinable var validatedIndicatorColor: NSColor? {
		if (0 ... 1).contains(self.fractionalValue),
			let indColor = self.indicatorColor {
			return indColor
		}
		return nil
	}

	private func tweak(_ theRect: CGRect) -> NSRect {
		// Get the parent's idea of where we should draw
		var newRect: NSRect = super.drawingRect(forBounds: theRect)

		// If the indicator is shown, move the text up a bit
		if self.validatedIndicatorColor != nil {
			newRect.size.height -= 2
		}

		// Get our ideal size for current text
		let textSize: NSSize = self.cellSize(forBounds: theRect)

		// Center in the proposed rect
		let heightDelta: CGFloat = newRect.size.height - textSize.height
		if heightDelta > 0 {
			newRect.size.height -= heightDelta
			newRect.origin.y += heightDelta / 2
		}

		// Bring in the edges so they don't overlap the increment/decrement buttons
		newRect.size.width -= (2 * DSFStepperTextField.HitTargetWidth) + 4
		newRect.origin.x += DSFStepperTextField.HitTargetWidth
		return newRect
	}

	override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
		super.select(withFrame: self.tweak(rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
	}

	override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
		super.edit(withFrame: self.tweak(rect), in: controlView, editor: textObj, delegate: delegate, event: event)
	}

	// Returns the color as represented by the 'isEnabled' state (well, according to us anyway)
	@inlinable func stateColor(_ color: NSColor) -> NSColor {
		return self.isEnabled ? color : color.withAlphaComponent(color.alphaComponent / 2.2)
	}

	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		let darkMode = controlView.isDarkMode
		
		let pth = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 1, dy: 1), xRadius: 4, yRadius: 4)
		pth.lineWidth = darkMode ? 1.0 : 1.5

		// Border

		do {
			let stroke: NSColor
			if let s = self.borderColor {
				stroke = s
			}
			else if Accessibility.IncreaseContrast {
				stroke = NSColor.textColor
			}
			else {
				stroke = NSColor.quaternaryLabelColor
			}
			stateColor(stroke).setStroke()
			pth.stroke()
		}

		// Fill

		do {
			let fill: NSColor
			if let f = self.borderBackground {
				fill = f
			}
			else if darkMode {
				fill = NSColor.textColor.withAlphaComponent(0.05)
			}
			else {
				fill = NSColor.white
			}
			stateColor(fill).setFill()
			pth.fill()
		}

		if let color = self.validatedIndicatorColor {
			let drawColor = stateColor(color)
			pth.setClip()
			drawColor.setFill()
			var bds = cellFrame
			bds.origin.y = bds.height - 3
			bds.size.height = 3
			bds.size.width *= self.fractionalValue
			bds.fill()
		}

		super.drawInterior(withFrame: self.tweak(cellFrame), in: controlView)
	}
}

#endif
