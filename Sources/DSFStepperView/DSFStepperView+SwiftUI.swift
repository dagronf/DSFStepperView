//
//  DSFStepperView+SwiftUI.swift
//
//  Created by Darren Ford on 13/11/20.
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

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DSFStepperView {
	public struct SwiftUI: DSFViewRepresentable {
		#if os(macOS)
		public typealias NSViewType = DSFStepperView
		#else
		public typealias UIViewType = DSFStepperView
		#endif

		public typealias OnValueChangeType = ((CGFloat?) -> Void)

		/// A style object to define the look and feel of a DSFStepperView.SwiftUI control
		public struct Style {
			/// The color to draw the central value
			public var textColor: DSFColor?
			/// The font to use.
			public let font: DSFFont?
			/// The fill color
			public var fillColor: DSFColor?
			/// The border color
			public var strokeColor: DSFColor?
			/// The color to draw the indicator
			public var indicatorColor: DSFColor?

			/// A style object
			/// - Parameters:
			///   - textColor: The color to draw the text. If nil, uses the default label color
			///   - font: The font to use when drawing the value
			///   - fillColor: The background fill color for the control. If nil, uses the default color
			///   - strokeColor: The border color for the control. If nil, uses the default color
			///   - indicatorColor: The indicator color for the control. If nil, no indicator is drawn
			public init(textColor: DSFColor? = nil,
							font: DSFFont? = nil,
							fillColor: DSFColor? = nil,
							strokeColor: DSFColor? = nil,
							indicatorColor: DSFColor? = nil) {
				self.textColor = textColor
				self.font = font
				self.fillColor = fillColor
				self.strokeColor = strokeColor
				self.indicatorColor = indicatorColor
			}
		}

		/// A style object to define the look and feel of a DSFStepperView.SwiftUI control
		public struct DisplaySettings {
			/// The allowable range of values
			let range: ClosedRange<CGFloat>
			/// How much to increment/decrement
			let increment: CGFloat
			/// The initial value to display in the control
			let initialValue: CGFloat?
			/// If the control allows 'empty' values, the placeholder text to display
			var placeholderText: String?
			/// The formatter to use when displaying/validating values
			var numberFormatter: NumberFormatter?
			/// Can the control be 'empty'?
			var allowsEmptyValue: Bool
			/// If true, allows the user to manually enter (type) a value into the control
			var allowsKeyboardInput: Bool


			public init(
				range: ClosedRange<CGFloat> = -CGFloat.greatestFiniteMagnitude ... CGFloat.greatestFiniteMagnitude,
				increment: CGFloat = 1,
				initialValue: CGFloat = 0,
				placeholderText: String? = nil,
				numberFormatter: NumberFormatter? = nil,
				allowsKeyboardInput: Bool = false,
				allowsEmptyValue: Bool = false
			) {
				self.range = range
				self.increment = increment
				self.initialValue = initialValue
				self.placeholderText = placeholderText
				self.numberFormatter = numberFormatter
				self.allowsKeyboardInput = allowsKeyboardInput
				self.allowsEmptyValue = allowsEmptyValue
			}
		}

		/// The configuration for the stepper view
		public let configuration: DisplaySettings

		/// The style to draw the controls
		public let style: Style

		/// The enabled state for the control
		public var isEnabled: Bool = true

		/// The current value for the control
		@Binding public var floatValue: CGFloat?

		/// An optional change value callback
		public var onValueChange: OnValueChangeType? = nil

		/// Initializer
		public init(configuration: DisplaySettings,
						style: Style = Style(),
						isEnabled: Bool = true,
						floatValue: Binding<CGFloat?> = .constant(nil),
						onValueChange: OnValueChangeType? = nil) {

			self.configuration = configuration
			self.style = style
			self.isEnabled = isEnabled
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

@available(OSX 10.15, iOS 13, tvOS 13, macCatalyst 13.1.0, *)
extension DSFStepperView.SwiftUI {
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}

@available(iOS 13, tvOS 13, macOS 9999, *)
extension DSFStepperView.SwiftUI {

	public func makeUIView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		stepper.setContentHuggingPriority(.defaultLow, for: .horizontal)
		stepper.setContentHuggingPriority(.defaultLow, for: .vertical)

		self.updateView(stepper)

		return stepper
	}

	public func updateUIView(_ uiView: DSFStepperView, context: Context) {
		uiView.delegate = context.coordinator
		self.updateView(uiView)
	}
}

@available(macOS 10.15, iOS 9999, tvOS 9999, *)
extension DSFStepperView.SwiftUI {
	public func makeNSView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		stepper.setContentHuggingPriority(.defaultLow, for: .horizontal)
		stepper.setContentHuggingPriority(.defaultLow, for: .vertical)

		self.updateView(stepper)

		return stepper
	}

	public func updateNSView(_ nsView: DSFStepperView, context: Context) {
		nsView.delegate = context.coordinator
		self.updateView(nsView)
	}
}

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, *)
extension DSFStepperView.SwiftUI {
	func updateView(_ view: DSFStepperView) {

		if configuration.range != view.range {
			view.minimum = configuration.range.lowerBound
			view.maximum = configuration.range.upperBound
		}

		if view.increment != configuration.increment { view.increment = configuration.increment }
		if view.placeholder != configuration.placeholderText { view.placeholder = configuration.placeholderText }
		if view.isEnabled != self.isEnabled { view.isEnabled = self.isEnabled }
		if view.allowsKeyboardInput != configuration.allowsKeyboardInput { view.allowsKeyboardInput = configuration.allowsKeyboardInput }
		if view.allowsEmpty != configuration.allowsEmptyValue { view.allowsEmpty = configuration.allowsEmptyValue }

		let fc = self.style.textColor ?? DSFStepperView.defaultLabelColor
		if !fc.isEqual(view.foregroundColor) {
			view.foregroundColor = fc
		}

		// Indicator color

		if let ic = self.style.indicatorColor {
			if !ic.isEqual(view.indicatorColor) {
				view.indicatorColor = ic
			}
		}
		else if view.indicatorColor != nil {
			view.indicatorColor = nil
		}

		// stroke color

		if let sc = self.style.strokeColor {
			if !sc.isEqual(view.borderColor) {
				view.borderColor = sc
			}
		}
		else if view.borderColor != nil {
			view.borderColor = nil
		}

		if let fc = self.style.fillColor {
			if !fc.isEqual(view.borderBackground) {
				view.borderBackground = fc
			}
		}
		else if view.borderBackground != nil {
			view.borderBackground = nil
		}

		if view.numberFormatter !== configuration.numberFormatter {
			if let f = configuration.numberFormatter {
				view.numberFormatter = f
			}
		}

		if let newFont = style.font {
			view.font = newFont
		}

		if view.floatValue != self.floatValue {
			view.floatValue = self.floatValue
		}
	}
}

// MARK: - Coordinator

@available(macOS 10.15, macCatalyst 13.1.0, *)
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
