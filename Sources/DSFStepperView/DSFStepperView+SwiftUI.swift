//
//  DSFStepperView+SwiftUI.swift
//
//  Created by Darren Ford on 13/11/20.
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

#if canImport(SwiftUI) && canImport(AppKit) && os(macOS)

import SwiftUI

@available(macOS 10.15, *)
extension DSFStepperView {
	public struct SwiftUI: NSViewRepresentable {
		public typealias NSViewType = DSFStepperView

		public typealias OnValueChangeType = ((CGFloat?) -> Void)

		public struct DisplaySettings {
			let minimum: CGFloat
			let maximum: CGFloat
			let increment: CGFloat

			let initialValue: CGFloat?
			var placeholderText: String?

			var numberFormatter: NumberFormatter?

			var allowsKeyboardInput = true

			let font: NSFont?

			public init(
				minimum: CGFloat = -CGFloat.greatestFiniteMagnitude,
				maximum: CGFloat = CGFloat.greatestFiniteMagnitude,
				increment: CGFloat = 1,
				initialValue: CGFloat = 0,
				placeholderText: String? = nil,
				numberFormatter: NumberFormatter? = nil,
				allowsKeyboardInput: Bool = true,
				font: NSFont? = nil
			) {
				self.minimum = minimum
				self.maximum = maximum
				self.increment = increment
				self.initialValue = initialValue
				self.placeholderText = placeholderText
				self.numberFormatter = numberFormatter
				self.allowsKeyboardInput = allowsKeyboardInput
				self.font = font
			}
		}

		/// The configuration for the stepper view
		public let configuration: DisplaySettings

		/// The enabled state for the control
		public var isEnabled: Bool = true

		/// The color to draw the central value
		public var foregroundColor: NSColor? = nil

		/// The current value for the control
		@Binding public var floatValue: CGFloat?

		/// An optional change value callback
		public var onValueChange: OnValueChangeType? = nil

		/// Initializer
		public init(configuration: DisplaySettings,
					isEnabled: Bool = true,
					foregroundColor: NSColor? = nil,
					floatValue: Binding<CGFloat?> = .constant(0),
					onValueChange: OnValueChangeType? = nil) {

			self.configuration = configuration
			self.isEnabled = isEnabled
			self.foregroundColor = foregroundColor
			self._floatValue = floatValue
			self.onValueChange = onValueChange
		}
	}
}

// MARK: - View Representable

@inlinable internal func updateIfNotEqual<T>(result: inout T, val: T) where T: Equatable {
	if result != val {
		result = val
	}
}

@available(macOS 10.15, *)
extension DSFStepperView.SwiftUI {
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeNSView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		stepper.initialValue = configuration.initialValue ?? 0
		stepper.numberFormatter = configuration.numberFormatter

		stepper.isEnabled = self.isEnabled

		if let nsFont = configuration.font {
			stepper.font = nsFont
		}

		return stepper
	}

	public func updateNSView(_ nsView: DSFStepperView, context: Context) {

		nsView.delegate = context.coordinator

		updateIfNotEqual(result: &nsView.minimum, val: configuration.minimum)
		updateIfNotEqual(result: &nsView.maximum, val: configuration.maximum)
		updateIfNotEqual(result: &nsView.increment, val: configuration.increment)
		updateIfNotEqual(result: &nsView.placeholder, val: configuration.placeholderText)
		updateIfNotEqual(result: &nsView.isEnabled, val: self.isEnabled)
		updateIfNotEqual(result: &nsView.allowsKeyboardInput, val: configuration.allowsKeyboardInput)
		updateIfNotEqual(result: &nsView.foregroundColor, val: self.foregroundColor)

		if nsView.numberFormatter !== configuration.numberFormatter {
			nsView.numberFormatter = configuration.numberFormatter
		}

		if let newFont = configuration.font {
			nsView.font = newFont
		}
		else {
			nsView.font = nil
		}

		let newNSNumber = self.floatValue == nil ? nil : NSNumber(value: Float(self.floatValue!))
		if !(newNSNumber?.isEqual(to: nsView.floatValue) ?? true) {
			nsView.floatValue = newNSNumber
		}
	}

}

// MARK: - Coordinator

@available(macOS 10.15, *)
extension DSFStepperView.SwiftUI {
	public class Coordinator: NSObject, DSFStepperViewDelegateProtocol {
		let parent: DSFStepperView.SwiftUI

		var previousValue: CGFloat? = nil

		init(_ stepper: DSFStepperView.SwiftUI) {
			self.parent = stepper
		}

		public func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
			var newValue: CGFloat? = nil

			if let v = value?.floatValue {
				newValue = CGFloat(v)
			}

			if self.previousValue == newValue {
				return
			}
			self.previousValue = newValue

			DispatchQueue.main.async { [weak self] in
				if let parent = self?.parent {
					parent.floatValue = newValue
					parent.onValueChange?(newValue)
				}
			}
		}
	}
}

#endif
