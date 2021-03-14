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
import Combine

@IBDesignable
public class DSFStepperView: UIView {

	// The width of the hit target
	static let hitTargetWidth: CGFloat = 50

	static let borderStrokeDefault = UIColor.lightGray.withAlphaComponent(0.4)
	static let borderFillDefault = UIColor.lightGray.withAlphaComponent(0.2)

	static let defaultLabelColor = UIColor.label

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
			self.editField.placeholder = self.placeholder
		}
	}

	/// The color to draw the border
	///
	/// NOTE: If you set this value, you will need to handle accessibility changes yourself.
	@IBInspectable public var borderColor: UIColor? = nil {
		didSet {
			self.layer.borderColor = self.borderColor?.cgColor
		}
	}

	/// The color to draw the control background.
	///
	/// NOTE: If you set this value, you will need to handle accessibility changes yourself.
	@IBInspectable public var borderBackground: UIColor? = nil {
		didSet {
			self.layer.backgroundColor = self.borderBackground?.cgColor
		}
	}

	/// The color to draw the text
	@IBInspectable public var foregroundColor: UIColor? {
		didSet {
			self.editField.textColor = self.foregroundColor
			self.updateAvailability()
		}
	}

	/// The color to draw the indicator
	@IBInspectable public var indicatorColor: UIColor? = nil {
		didSet {
			self.indicatorLayer.backgroundColor = self.indicatorColor?.cgColor
		}
	}

	/// The minimum allowable value in the control
	@IBInspectable public var minimum: CGFloat = -CGFloat.greatestFiniteMagnitude {
		didSet {
			self.range = self.minimum ... self.maximum
		}
	}

	/// The maximum allowable value in the control
	@IBInspectable public var maximum: CGFloat = CGFloat.greatestFiniteMagnitude {
		didSet {
			self.range = self.minimum ... self.maximum
		}
	}

	/// The source of truth for the range of the control
	public var range: ClosedRange<CGFloat> = -CGFloat.greatestFiniteMagnitude ... CGFloat.greatestFiniteMagnitude {
		didSet {
			if let clampedValue = self._floatValue?.clampedValue(for: self.range) {
				if clampedValue.wasClamped {
					self.floatValue = clampedValue.value
				}
			}
		}
	}

	/// How much to increment/decrement the value when pressing the -/+ buttons
	@IBInspectable public var increment: CGFloat = 1

	/// The initial value to be displayed in the control
	@IBInspectable public var initialValue: CGFloat = 0 {
		didSet {
			if self.allowsEmpty, self.initialValue == DSFStepperView.OptionalIndicatorValue {
				self._floatValue = nil
			}
			else {
				self._floatValue = self.initialValue
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

	// MARK: - Control value

	// This is the SOURCE OF TRUTH value for the control.
	// This value is guaranteed to always be within the range of the control
	private var _floatValue: CGFloat? {
		didSet {

			// Must be guaranteed. If there's a value then it MUST be within the range
			assert(self._floatValue?.isContained(in: self.range) ?? true)

			let resultValue: NSNumber?
			if let value = _floatValue {
				resultValue = value.numberValue
				let str = self.numberFormatter.string(from: resultValue!)
				self.editField.text = str
			}
			else if self.allowsEmpty {
				self.editField.text = nil
				resultValue = nil
			}
			else {
				// Note that this can happen during the initialization time through IB
//				assert(false, "Shouldn't have an empty field when 'allowsEmpty' is false")
				resultValue = nil
			}

			self.updateAvailability()
			self.updatePublishedValue()
			self.updateIndicatorBar()

			self.willChangeValue(for: \.numberValue)
			self.didChangeValue(for: \.numberValue)

			// Notify the delegate of the change
			self.delegate?.stepperView(self, didChangeValueTo: resultValue)
		}
	}

	/// The control's public value
	public dynamic var floatValue: CGFloat? {
		get {
			// Always return the source of truth value
			return self._floatValue
		}
		set {
			let clampedVal = newValue?.clampedValue(for: self.range)
			self._floatValue = clampedVal?.value
		}
	}

	/// The control's value, wrapped in an NSNumber for @objc clients
	@objc public dynamic var numberValue: NSNumber? {
		get {
			return self.floatValue?.numberValue
		}
		set {
			self.floatValue = newValue?.cgFloatValue
		}
	}

	// When the value is being editing via the keyboard, the value before the change started
	private var _previousValue: CGFloat?

	/// The percentage value for the current value between the two bounds.
	@objc private(set) public var fractionalPosition: CGFloat = 0

	// MARK: - Formatter

	/// A number formatter for display and validation within the control (optional)
	public var numberFormatter: NumberFormatter = DSFStepperView.defaultFormatter {
		didSet {
			// Just re-trigger the update (which will use the new formatter)
			// Bit primitive, but in all honesty the numberFormatter won't change often
			let existingValue = self.floatValue
			self.floatValue = existingValue
		}
	}

	// A default formatter that deals only with decimal values (no float)
	private static let defaultFormatter: NumberFormatter = {
		let f = NumberFormatter()
		f.allowsFloats = false
		return f
	}()

	// MARK: - Combine publisher

	private var isSettingPublishedValue = false
	private var cancellable: AnyObject?
	public var _publishedValue = CurrentValueSubject<CGFloat?, Never>(nil)
	public var publishedValue: AnyPublisher<CGFloat?, Never> {
		return _publishedValue.eraseToAnyPublisher()
	}

	// Update the publisher value for combine.
	private func updatePublishedValue() {
		self._publishedValue.value = self._floatValue
	}

	// MARK: - Embedded controls

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

		let width = DSFStepperView.hitTargetWidth

		self.minusButton.frame = CGRect(x: rect.minX, y: rect.minY, width: width, height: rect.height)
		self.editField.frame = CGRect(x: rect.minX + width, y: rect.minY, width: rect.width - (2 * width), height: rect.height)
		self.plusButton.frame = CGRect(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height)

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.updateIndicatorBar()
		CATransaction.commit()
	}

	func setup() {

		// The top level has to be autolayout-capable
		self.translatesAutoresizingMaskIntoConstraints = false

		// It's easier (for this simple layout at least!) to just use autosizing masks. And it's far less problematic
		// when integrating into SwiftUI as well.

		let f = NumberFormatter()
		f.allowsFloats = false
		self.numberFormatter = f

		self.indicatorLayer.backgroundColor = self.indicatorColor?.cgColor
		self.layer.addSublayer(self.indicatorLayer)

		self.layer.masksToBounds = true

		self.layer.cornerRadius = 6
		self.layer.borderWidth = 0.5
		self.layer.borderColor = self.borderColor?.cgColor ?? DSFStepperView.borderStrokeDefault.cgColor
		self.layer.backgroundColor = self.borderBackground?.cgColor ?? DSFStepperView.borderFillDefault.cgColor

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
			self.floatValue = self.initialValue
		}

		self.updateAvailability()
		self.updateIndicatorBar()

		self.setNeedsLayout()
	}
}

// MARK: - Increment and decrement

private extension DSFStepperView {

	@objc func performIncrement() {
		if let val = self._floatValue {
			let newVal = val + self.increment
			self.floatValue = newVal	// floatValue.set() will truncate if necessary
		}
		else {
			self.floatValue = 0
		}
	}

	@objc func performDecrement() {
		if let val = self._floatValue {
			let newVal = val - self.increment
			self.floatValue = newVal	// floatValue.set() will truncate if necessary
		}
		else {
			self.floatValue = 0
		}
	}
}

// MARK: - Value change updates

private extension DSFStepperView {

	func updateIndicatorBar() {

		let lb = self.range.lowerBound
		let ub = self.range.upperBound

		guard lb > -CGFloat.greatestFiniteMagnitude,
				ub < CGFloat.greatestFiniteMagnitude else {
			self.fractionalPosition = 0
			self.indicatorLayer.frame = .zero
			return
		}

		if let val = self._floatValue {
			self.fractionalPosition = abs(val - lb) / abs(ub - lb)
		}
		else {
			self.fractionalPosition = 0
		}

		var newRect = self.bounds
		newRect.origin.y = self.bounds.height - 3.0
		newRect.size.height = 3.0
		self.indicatorLayer.frame = newRect.divided(atDistance: newRect.width * self.fractionalPosition, from: .minXEdge).slice
	}

	func updateAvailability() {
		let canIncrease: Bool
		let canDecrease: Bool

		if let val = self._floatValue {
			canIncrease = self.isEnabled ? val < self.range.upperBound : false
			canDecrease = self.isEnabled ? val > self.range.lowerBound : false
		}
		else {
			canIncrease = true
			canDecrease = true
		}

		let textColor = self.foregroundColor ?? DSFStepperView.defaultLabelColor
		self.editField.textColor = textColor.stateColor(self.isEnabled)

		self.plusButton.isEnabled = canIncrease
		self.plusButton.isHidden = !self.isEnabled
		self.plusButton.tintColor = textColor.stateColor(canIncrease)

		self.minusButton.isEnabled = canDecrease
		self.minusButton.isHidden = !self.isEnabled
		self.minusButton.tintColor = textColor.stateColor(canDecrease)

		self.editField.isEnabled = self.isEnabled

		// Fill color
		let fc = self.borderBackground ?? DSFStepperView.borderFillDefault
		self.layer.backgroundColor = fc.stateColor(self.isEnabled).cgColor

		// Border color
		let bc = self.borderColor ?? DSFStepperView.borderStrokeDefault
		self.layer.borderColor = bc.stateColor(self.isEnabled).cgColor

		// Indicator color
		self.indicatorLayer.backgroundColor = self.indicatorColor?.stateColor(self.isEnabled).cgColor ?? nil
	}
}



public extension DSFStepperView {
	override var accessibilityValue: String? {
		get {
			if let f = self._floatValue {
				return self.numberFormatter.string(from: f.numberValue)
			}
			else {
				return "empty"
			}
		}
		set {
			if let stringValue = newValue,
				let numberValue = self.numberFormatter.number(from: stringValue)
			{
				self.numberValue = numberValue
			}
			else {
				self.floatValue = 0
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
		self._previousValue = self._floatValue
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

	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var text = textField.text ?? ""

		guard let ran = Range(range, in: text) else {
			return false
		}

		text = text.replacingCharacters(in: ran, with: string)

		if self.allowsEmpty, text.isEmpty {
			return true
		}

		if let val = self.numberFormatter.number(from: text)?.cgFloatValue,
			self.range.contains(val)
		{
			return true
		}

		return false
	}

	public func textFieldDidEndEditing(_ textField: UITextField) {
		if self.allowsEmpty, textField.text?.isEmpty ?? true {
			self._floatValue = nil
			return
		}

		if let t = textField.text, let s = self.numberFormatter.number(from: t) {
			self.numberValue = s
		}
		else {
			textField.text = self.numberFormatter.string(for: self.numberValue)
		}
	}
}

// MARK: - State drawing helpers

fileprivate extension UIColor {
	func disabledColor() -> UIColor {
		return self.withAlphaComponent(self.cgColor.alpha / 2.2)
	}
	func stateColor(_ isEnabled: Bool) -> UIColor {
		return isEnabled ? self : self.disabledColor()
	}
}

#endif
