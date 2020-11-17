//
//  ContentView.swift
//  DSFStepperView SwiftUI Demo
//
//  Created by Darren Ford on 13/11/20.
//

import SwiftUI

struct ContentView: View {
	@State private var currentValue: CGFloat? = 23
	@State private var isEnabled: Bool = true
	var demoConfig = DSFStepperView.SwiftUI.Configuration(
		minimum: 0, maximum: 100, increment: 1, initialValue: 23, numberFormatter: nil
	)

	/// A stepper [-10 ... 10] stepping by 0.5

	static let FloatFormatter: NumberFormatter = {
		let format = NumberFormatter()
		format.numberStyle = .decimal

		// Always display a single digit fractional value.
		format.allowsFloats = true
		format.minimumFractionDigits = 1
		format.maximumFractionDigits = 1
		return format
	}()

	@State private var currentValue2: CGFloat? = -3.5
	var demoConfig2 = DSFStepperView.SwiftUI.Configuration(
		minimum: -10, maximum: 10, increment: 0.5, initialValue: 23, numberFormatter: ContentView.FloatFormatter
	)

	var body: some View {
		VStack (spacing: 16) {
			Toggle("Enabled", isOn: $isEnabled)
			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: .constant(demoConfig),
								 floatValue: $currentValue,
								 isEnabled: $isEnabled,
								 font: .constant(nil))
					.frame(width: 120)
				TextField("", value: $currentValue, formatter: NumberFormatter())
					.frame(width: 120)
			}

			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: .constant(demoConfig2),
								 floatValue: $currentValue2,
								 isEnabled: .constant(true),
								 font: .constant(NSFont.systemFont(ofSize: 24)))
					.frame(width: 120)
				TextField("", value: $currentValue2, formatter: ContentView.FloatFormatter)
					.frame(width: 120)
			}

		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
