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

#if canImport(SwiftUI) && os(macOS)

import SwiftUI

@available(macOS 10.15, *)
public struct DSFStepperViewUI: NSViewRepresentable {

	public typealias NSViewType = DSFStepperView

	public struct Configuration {
		let minimum: CGFloat
		let maximum: CGFloat
		let increment: CGFloat

		let initialValue: CGFloat?
		var placeholderText: String?

		var numberFormatter: NumberFormatter?
	}

	/// The initial configuration for the stepper view
	@Binding public var configuration: Configuration

	/// The current value for the control
	@Binding public var floatValue: CGFloat?

	/// The enabled state for the control
	@Binding public var isEnabled: Bool

	@Binding public var font: NSFont?

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeNSView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		stepper.initialValue = configuration.initialValue ?? 0
		stepper.numberFormatter = configuration.numberFormatter

		stepper.isEnabled = self.isEnabled

		if let nsFont = font {
			stepper.font = nsFont
		}

		return stepper
	}

	public func updateNSView(_ nsView: DSFStepperView, context: Context) {

		nsView.delegate = context.coordinator

		if nsView.minimum != configuration.minimum {
			nsView.minimum = configuration.minimum
		}
		if nsView.maximum != configuration.maximum {
			nsView.maximum = configuration.maximum
		}
		if nsView.increment != configuration.increment {
			nsView.increment = configuration.increment
		}

		if nsView.placeholder != configuration.placeholderText {
			nsView.placeholder = configuration.placeholderText
		}

		if nsView.isEnabled != self.isEnabled {
			nsView.isEnabled = self.isEnabled
		}

		if nsView.numberFormatter !== configuration.numberFormatter {
			nsView.numberFormatter = configuration.numberFormatter
		}

		if let newFont = self.font {
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

	public class Coordinator: NSObject, DSFStepperViewDelegateProtocol {
		let parent: DSFStepperViewUI
		init(_ stepper: DSFStepperViewUI) {
			self.parent = stepper
		}

		public func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
			var newValue: CGFloat? = nil
			if let v = value?.floatValue {
				newValue = CGFloat(v)
			}

			DispatchQueue.main.async { [weak self] in
				self?.parent.floatValue = newValue
			}
		}
	}
}

#endif
