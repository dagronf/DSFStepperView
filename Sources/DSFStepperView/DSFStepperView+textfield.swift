//
//  DSFStepperView+textfield.swift
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

import Cocoa

/// A stepper text field
internal class DSFStepperTextField: NSTextField {
	static let HitTargetWidth: CGFloat = 20

	fileprivate var isInCurrentUpdate: Bool = false

	fileprivate var customCell: DSFStepperViewTextFieldCell? {
		return self.cell as? DSFStepperViewTextFieldCell
	}

	var fieldEnabled: Bool {
		get {
			return super.isEnabled
		}
		set {
			super.isEnabled = newValue
			self.decrementButton.isEnabled = newValue
			self.incrementButton.isEnabled = newValue
		}
	}

	/// Returns true if the setup() function has been called
	var isReady: Bool {
		return self.customCell != nil
	}

	lazy var valueFormatter: NumberFormatter = {
		let format = NumberFormatter()
		format.numberStyle = .decimal
		format.maximumIntegerDigits = Int.max
		format.minimumIntegerDigits = 1
		format.allowsFloats = false
		return format
	}() {
		didSet {
			self.cell?.formatter = self.valueFormatter
		}
	}

	var allowsEmpty: Bool = true {
		didSet {}
	}

	private var beforeEditValue: CGFloat?

	var lastNonEmptyValue: CGFloat = 0

	/// The minimum value defined for the control
	var minimum: CGFloat = -CGFloat.greatestFiniteMagnitude {
		didSet {
			if let curr = self.current, self.minimum > curr {
				self.current = self.minimum
			}
		}
	}

	/// The maximum value defined for the control
	var maximum = CGFloat.greatestFiniteMagnitude {
		didSet {
			if let curr = self.current, self.maximum < curr {
				self.current = self.maximum
			}
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
				return
			}

			let v = self.clamped(curr)
			let val = Float(v)
			self.stringValue = self.valueFormatter.string(from: NSNumber(value: val)) ?? ""
			self.enableDisable()

			self.lastNonEmptyValue = v

			(superview as? DSFStepperView)?.floatValue = NSNumber(value: val)
		}
	}

	var foregroundColor: NSColor? {
		didSet {
			self.customCell?.textColor = self.foregroundColor
		}
	}

	// MARK: - Decrement Button definition

	lazy var decrementImage: NSImage = {
		let i = NSImage(named: "NSRemoveTemplate")!.resizeImage(maxSize: NSSize(width: 8, height: 8))
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
		let i = NSImage(named: "NSAddTemplate")!.resizeImage(maxSize: NSSize(width: 8, height: 8))
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
	private func enableDisable() {
		self.decrementButton.isEnabled = self.current != self.minimum && self.isEnabled
		self.incrementButton.isEnabled = self.current != self.maximum && self.isEnabled
	}

	private func clamped(_ value: CGFloat) -> CGFloat {
		return max(self.minimum, min(self.maximum, value))
	}

	override func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		self.setup()
	}

	override var isEnabled: Bool {
		didSet {
			super.isEnabled = self.isEnabled
			self.decrementButton.isEnabled = self.isEnabled
			self.incrementButton.isEnabled = self.isEnabled
		}
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
}

extension DSFStepperTextField {
	/// Build up the label
	func setup() {
		let oldCell = self.cell as! NSTextFieldCell
		let newCell = DSFStepperViewTextFieldCell()

		newCell.isEnabled = oldCell.isEnabled
		newCell.isEditable = oldCell.isEditable
		newCell.isSelectable = true
		newCell.isScrollable = true

		newCell.placeholderString = oldCell.placeholderString
		newCell.isScrollable = false
		newCell.isContinuous = oldCell.isContinuous
		newCell.font = oldCell.font
		newCell.alignment = .center
		newCell.textColor = oldCell.textColor

		self.isBordered = false
		self.isBezeled = false
		self.drawsBackground = false

		self.cell = newCell

		// Left (decrement) button constraints

		self.addSubview(self.decrementButton)
		self.addConstraint(NSLayoutConstraint(item: self.decrementButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.decrementButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 3))
		self.addConstraint(NSLayoutConstraint(item: self.decrementButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -3))
		self.decrementButton.addConstraint(NSLayoutConstraint(item: self.decrementButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DSFStepperTextField.HitTargetWidth))

		// Right (increment) button constraints

		self.addSubview(self.incrementButton)
		self.addConstraint(NSLayoutConstraint(item: self.incrementButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.incrementButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 3))
		self.addConstraint(NSLayoutConstraint(item: self.incrementButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -3))
		self.incrementButton.addConstraint(NSLayoutConstraint(item: self.incrementButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DSFStepperTextField.HitTargetWidth))

		self.delegate = self

		if let curr = self.current {
			self.stringValue = self.valueFormatter.string(from: NSNumber(value: Float(curr))) ?? ""
		}
		else {
			self.stringValue = ""
		}

		self.enableDisable()

		if let fn = self.font?.fontDescriptor,
		   let sz = self.font?.fontDescriptor.pointSize
		{
			self.decrementButton.font = NSFont(descriptor: fn, size: sz - 2)
			self.incrementButton.font = NSFont(descriptor: fn, size: sz - 2)
		}

		/// Set the accessibility role to match that defined in Xcode
		self.setAccessibilityLabel(DSFStepperView.Localization.AccessibilityRole)
	}
}

private extension DSFStepperTextField {
	private func createButton() -> NSButton {
		let b = DSFDelayedRepeatingButton(frame: .zero)
		b.translatesAutoresizingMaskIntoConstraints = false
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

		if let v = self.valueFormatter.number(from: self.stringValue)?.floatValue {
			self.current = self.clamped(CGFloat(v))
		}
	}

	public func control(_: NSControl, isValidObject _: Any?) -> Bool {
		if self.stringValue.isEmpty {
			return self.allowsEmpty
		}
		return self.valueFormatter.number(from: self.stringValue) != nil
	}
}

private class DSFStepperViewTextFieldCell: NSTextFieldCell {
	private func tweak(_ theRect: CGRect) -> NSRect {
		// Get the parent's idea of where we should draw
		var newRect: NSRect = super.drawingRect(forBounds: theRect)

		// Get our ideal size for current text
		let textSize: NSSize = self.cellSize(forBounds: theRect)

		// Center in the proposed rect
		let heightDelta: CGFloat = newRect.size.height - textSize.height
		if heightDelta > 0 {
			newRect.size.height -= heightDelta
			newRect.origin.y += heightDelta / 2
		}

		// Bring in the edges so they don't overlap the increment/decrement buttons
		newRect.size.width -= (2 * DSFStepperTextField.HitTargetWidth)
		newRect.origin.x += DSFStepperTextField.HitTargetWidth
		return newRect
	}

	override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
		super.select(withFrame: self.tweak(rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
	}

	override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
		super.edit(withFrame: self.tweak(rect), in: controlView, editor: textObj, delegate: delegate, event: event)
	}

	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		// Drawing code here.
		let pth = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 1, dy: 1), xRadius: 4, yRadius: 4)
		NSColor.quaternaryLabelColor.setStroke()
		pth.stroke()

		if NSAppearance.current?.isDarkMode ?? false {
			NSColor.textColor.withAlphaComponent(0.05).setFill()
		}
		else {
			NSColor.white.setFill()
		}

		pth.fill()

		super.drawInterior(withFrame: self.tweak(cellFrame), in: controlView)
	}
}

#endif
