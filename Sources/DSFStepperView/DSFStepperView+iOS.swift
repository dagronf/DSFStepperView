//
//  DSFStepperView+iOS.swift
//
//  Created by Darren Ford on 10/3/21.
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

#if canImport(UIKit)

import UIKit

@IBDesignable
public class DSFStepperView: UIView {
	static let borderStrokeDefault = UIColor.lightGray.withAlphaComponent(0.4)
	static let borderFillDefault = UIColor.lightGray.withAlphaComponent(0.2)

	// The CGFloat value that indicates 'empty' for the control
	static let OptionalIndicatorValue = CGFloat.greatestFiniteMagnitude

	/// The (optional) callback delegate
	@objc public var delegate: DSFStepperViewDelegateProtocol? {
		didSet {
			// Need to make sure the tooltip hit targets are created and checked
			self.setNeedsLayout()
		}
	}

	/// Enable/Disable the entire control
	@IBInspectable public var isEnabled: Bool = true {
		didSet {
			self.updateAvailability()
		}
	}

	/// Does this control allow an 'empty' value?
	@IBInspectable public var allowsEmpty: Bool = false

	/// Allow the user to manually enter text
	@IBInspectable public var allowsKeyboardInput: Bool = false

	/// Placeholder text to display if the field is empty
	@IBInspectable public var placeholder: String? = "Inherited" {
		didSet {
			if self.allowsEmpty {
				self.editField.placeholder = self.placeholder
			}
		}
	}

	/// The color to draw the border
	@IBInspectable public var borderColor: UIColor = DSFStepperView.borderStrokeDefault {
		didSet {
			self.layer.borderColor = self.borderColor.cgColor
		}
	}

	/// The color to draw the background
	@IBInspectable public var borderBackground: UIColor = DSFStepperView.borderFillDefault {
		didSet {
			self.layer.backgroundColor = self.borderBackground.cgColor
		}
	}

	/// The color to draw the text
	@IBInspectable public var foregroundColor = UIColor.label {
		didSet {
			self.editField.textColor = self.foregroundColor
			self.updateAvailability()
		}
	}

	/// The color to draw the indicator
	@IBInspectable public var indicatorColor = UIColor.systemBlue {
		didSet {
			self.indicatorLayer.backgroundColor = self.indicatorColor.cgColor
		}
	}

	/// The minimum allowable value in the control
	@IBInspectable public var minimum: CGFloat = -CGFloat.greatestFiniteMagnitude {
		didSet {
			if let val = self.cgFloatValue,
				val < self.minimum
			{
				self.floatValue = self.minimum.numberValue
			}
			self.floatValueUpdated()
		}
	}

	/// The maximum allowable value in the control
	@IBInspectable public var maximum: CGFloat = CGFloat.greatestFiniteMagnitude {
		didSet {
			if let val = self.cgFloatValue,
				val > self.maximum
			{
				self.floatValue = self.maximum.numberValue
			}
			self.floatValueUpdated()
		}
	}

	/// How much to increment/decrement the value when pressing the -/+ buttons
	@IBInspectable public var increment: CGFloat = 1

	/// The initial value to be displayed in the control
	@IBInspectable public var initialValue: CGFloat = 0 {
		didSet {
			if self.allowsEmpty, self.initialValue == DSFStepperView.OptionalIndicatorValue {
				self.floatValue = nil
			}
			else {
				self.floatValue = self.initialValue.numberValue
			}
		}
	}

	// MARK: - Font

	/// The font for the control.
	public var font: UIFont? {
		get {
			return self.editField.font
		}
		set {
			self.editField.font = newValue
			self.editField.invalidateIntrinsicContentSize()
			self.editField.setNeedsLayout()
		}
	}

	private var fractionalPosition: CGFloat = 0
	private var _previousValue: NSNumber?

	fileprivate var cgFloatValue: CGFloat? {
		return self.floatValue?.cgFloatValue
	}

	@objc public dynamic var floatValue: NSNumber? {
		didSet {
			self.floatValueUpdated()
		}
	}

	private func floatValueUpdated() {
		guard let cgv = self.floatValue?.cgFloatValue else {
			if self.allowsEmpty {
				self.editField.text = nil
				return
			}
			//			fatalError("Cannot set nil value when 'allowsEmpty' is false")
			return
		}

		let nv = min(self.maximum, max(self.minimum, cgv)).numberValue
		if let str = self.numberFormatter.string(from: nv) {
			self.editField.text = str
		}
		else {
			// fatalError("Cannot set value for numberformatter")
		}

		self.updateAvailability()
		self.updateIndicatorBar()

		// Notify the delegate of the change
		self.delegate?.stepperView(self, didChangeValueTo: self.floatValue)
	}

	private func updateAvailability() {
		let canIncrease: Bool
		let canDecrease: Bool

		if let val = self.cgFloatValue {
			canIncrease = self.isEnabled ? val < self.maximum : false
			canDecrease = self.isEnabled ? val > self.minimum : false
		}
		else {
			canIncrease = false
			canDecrease = false
		}

		self.plusButton.isEnabled = canIncrease
		self.plusButton.tintColor = canIncrease ? self.editField.textColor : .lightGray

		self.minusButton.isEnabled = canDecrease
		self.minusButton.tintColor = canDecrease ? self.editField.textColor : .lightGray

		self.editField.isEnabled = self.isEnabled

		self.editField.textColor = self.isEnabled ? self.foregroundColor : .lightGray
	}

	// Is 'value' contained within the min and max ranges?
	private func contains(_ value: CGFloat) -> Bool {
		return value >= self.minimum && value <= self.maximum
	}

	// A default formatter that deals only with decimal values (no float)
	private static let defaultFormatter: NumberFormatter = {
		let f = NumberFormatter()
		f.allowsFloats = false
		return f
	}()

	// MARK: - Formatter

	/// A number formatter for display and validation within the control (optional)
	public var numberFormatter: NumberFormatter = DSFStepperView.defaultFormatter {
		didSet {
			self.floatValueUpdated()
		}
	}

	//	let stack: UIStackView = {
	//		let stack = UIStackView(frame: .zero)
	//		stack.axis = .horizontal
	//		stack.distribution = .fillProportionally
	//		return stack
	//	}()

	let editField = UITextField(frame: .zero)

	let plusButton = DSFDelayedRepeatingButton(frame: .zero)
	let minusButton = DSFDelayedRepeatingButton(frame: .zero)

	let indicatorLayer = CALayer()

	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	override public func layoutSubviews() {
		super.layoutSubviews()

		let rect = self.bounds
		self.minusButton.frame = CGRect(x: rect.minX, y: rect.minY, width: 50, height: rect.height)
		self.editField.frame = CGRect(x: rect.minX + 50, y: rect.minY, width: rect.width - 100, height: rect.height)
		self.plusButton.frame = CGRect(x: rect.maxX - 50, y: rect.minY, width: 50, height: rect.height)

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.updateIndicatorBar()
		CATransaction.commit()
	}

	func updateIndicatorBar() {
		guard self.minimum > -CGFloat.greatestFiniteMagnitude || self.maximum < CGFloat.greatestFiniteMagnitude else {
			self.fractionalPosition = 0
			self.indicatorLayer.frame = .zero
			return
		}

		if let val = self.cgFloatValue {
			self.fractionalPosition = abs(val - self.minimum) / abs(self.maximum - self.minimum)
		}
		else {
			self.fractionalPosition = 0
		}

		var newRect = self.bounds
		newRect.origin.y = self.bounds.height - 2.5
		newRect.size.height = 2.5
		self.indicatorLayer.frame = newRect.divided(atDistance: newRect.width * self.fractionalPosition, from: .minXEdge).slice
	}

	private static let SuperLow = UILayoutPriority(10)

	func setup() {

		// The top level has to be autolayout-capable
		self.translatesAutoresizingMaskIntoConstraints = false

		// It's easier, for this simple layout, to just use autosizing masks.  And it's far less problematic
		// when integrating into SwiftUI as well!

		let f = NumberFormatter()
		f.allowsFloats = false
		self.numberFormatter = f

		self.indicatorLayer.backgroundColor = self.indicatorColor.cgColor
		self.layer.addSublayer(self.indicatorLayer)

		self.layer.masksToBounds = true

		self.layer.cornerRadius = 6
		self.layer.borderWidth = 0.5
		self.layer.borderColor = self.borderColor.cgColor
		self.layer.backgroundColor = self.borderBackground.cgColor

		self.minusButton.isAccessibilityElement = true
		self.minusButton.accessibilityLabel = "Decrement stepper"
		self.minusButton.setImage(UIImage(systemName: "minus"), for: .normal)
		self.minusButton.tintColor = self.editField.textColor
		self.minusButton.actionBlock = { [weak self] in
			self?.performDecrement()
		}

		self.editField.textAlignment = .center
		self.editField.delegate = self

		self.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
		self.plusButton.isAccessibilityElement = true
		self.plusButton.accessibilityLabel = "Increment stepper"
		self.plusButton.tintColor = self.editField.textColor

		self.plusButton.actionBlock = { [weak self] in
			self?.performIncrement()
		}

		self.addSubview(self.minusButton)
		self.addSubview(self.editField)
		self.addSubview(self.plusButton)

		self.setupAccessibility()

		if self.allowsEmpty, self.initialValue == DSFStepperView.OptionalIndicatorValue {
			self.floatValue = nil
		}
		else {
			self.floatValue = self.initialValue.numberValue
		}

		self.updateAvailability()
		self.updateIndicatorBar()

		self.setNeedsLayout()
	}

	@objc func performIncrement() {
		if let val = self.cgFloatValue {
			let newVal = val + self.increment
			self.floatValue = max(self.minimum, min(self.maximum, newVal)).numberValue
		}
	}

	@objc func performDecrement() {
		if let val = self.cgFloatValue {
			let newVal = val - self.increment
			self.floatValue = max(self.minimum, min(self.maximum, newVal)).numberValue
		}
	}
}

public extension DSFStepperView {
	override var accessibilityValue: String? {
		get {
			if let f = self.floatValue {
				return self.numberFormatter.string(from: f)
			}
			else {
				return "empty"
			}
		}
		set {
			if let n = newValue,
				let cg = self.numberFormatter.number(from: n)
			{
				self.floatValue = cg
			}
			else {
				self.floatValue = NSNumber(value: 0)
			}
		}
	}

	internal func setupAccessibility() {
		self.isAccessibilityElement = true
		self.accessibilityLabel = "Stepper"
	}

	override func accessibilityIncrement() {
		self.performIncrement()
	}

	override func accessibilityDecrement() {
		self.performDecrement()
	}
}

extension DSFStepperView: UITextFieldDelegate {
	public func textFieldShouldBeginEditing(_: UITextField) -> Bool {
		return self.allowsKeyboardInput
	}

	public func textFieldDidBeginEditing(_: UITextField) {
		self._previousValue = self.floatValue
	}

	public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if self.allowsEmpty, textField.text?.isEmpty ?? false {
			return true
		}

		if let t = textField.text,
			let _ = self.numberFormatter.number(from: t)
		{
			return true
		}

		return false
	}

	public func textFieldDidEndEditing(_ textField: UITextField) {
		if self.allowsEmpty, textField.text?.isEmpty ?? true {
			self.floatValue = nil
			return
		}

		if let t = textField.text, let s = self.numberFormatter.number(from: t) {
			self.floatValue = s
		}
		else {
			textField.text = self.numberFormatter.string(for: self.floatValue)
		}
	}

	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var text = textField.text ?? ""

		guard let ran = Range(range, in: text) else {
			return false
		}

		text = text.replacingCharacters(in: ran, with: string)

		if self.allowsEmpty, text.isEmpty {
			return true
		}

		if let val = self.numberFormatter.number(from: text),
			self.contains(val.cgFloatValue)
		{
			return true
		}

		return false
	}
}

#endif
