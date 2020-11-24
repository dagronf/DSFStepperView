//
//  ContentView.swift
//  DSFStepperView SwiftUI Demo
//
//  Created by Darren Ford on 13/11/20.
//

import SwiftUI

struct ContentView: View {

	@State private var isEnabled: Bool = true
	@State private var currentValue: CGFloat? = 23
	let demoConfig = DSFStepperView.SwiftUI.DisplaySettings(
		minimum: 0, maximum: 100, increment: 1
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
	@State private var foregroundColor: NSColor = NSColor.systemTeal

	let demoConfig2 = DSFStepperView.SwiftUI.DisplaySettings(
		minimum: -10, maximum: 10, increment: 0.5, initialValue: 23, numberFormatter: ContentView.FloatFormatter,
		font: NSFont.systemFont(ofSize: 24)
	)

	var body: some View {
		VStack (spacing: 16) {
			Toggle("Enabled", isOn: $isEnabled)
			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: self.demoConfig,
									   isEnabled: self.isEnabled,
									   floatValue: self.$currentValue)
					.frame(width: 120)
				TextField("", value: $currentValue, formatter: NumberFormatter())
					.frame(width: 120)
			}

			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: self.demoConfig2,
									   foregroundColor: self.foregroundColor,
									   floatValue: self.$currentValue2,
									   onValueChange: { value in
										Swift.print("New value is \(String(describing: value))")
									   })

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
