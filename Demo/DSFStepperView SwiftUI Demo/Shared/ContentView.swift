//
//  ContentView.swift
//  Shared
//
//  Created by Darren Ford on 10/3/21.
//

import SwiftUI
import DSFStepperView

struct ContentView: View {

	@State private var isEnabled: Bool = true
	@State private var currentValue: CGFloat? = 23
	let demoConfig = DSFStepperView.SwiftUI.DisplaySettings(
		range: 0 ... 100, increment: 1
	)

	@ObservedObject var style = DSFStepperView.SwiftUI.Style()

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
	@State private var foregroundColor: DSFColor = DSFColor.systemTeal

	let demoConfig2 = DSFStepperView.SwiftUI.DisplaySettings(
		range: -10 ... 10, increment: 0.5, initialValue: 23, numberFormatter: ContentView.FloatFormatter,
		font: DSFFont.monospacedSystemFont(ofSize: 18, weight: .regular)
	)


	@State private var currentValue3: CGFloat? = 5
	let demoConfig3 = DSFStepperView.SwiftUI.DisplaySettings(
		range: -10 ... 10, increment: 0.5,
		numberFormatter: FloatFormatter,
		font: DSFFont.systemFont(ofSize: 24, weight: .heavy)
	)


	var body: some View {
		VStack (spacing: 16) {
			Toggle("Enabled", isOn: $isEnabled)
			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: self.demoConfig,
											  isEnabled: self.isEnabled,
											  floatValue: self.$currentValue)
				TextField("", value: $currentValue, formatter: NumberFormatter())
					.padding(3)
					.border(Color.gray, width: 1)
			}
			.frame(height: 30)

			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(
					configuration: self.demoConfig2,
					isEnabled: self.isEnabled,
					foregroundColor: self.foregroundColor,
					indicatorColor: self.foregroundColor,
					floatValue: self.$currentValue2,
					onValueChange: { value in
						Swift.print("New value is \(String(describing: value))")
					})
				TextField("", value: $currentValue2, formatter: ContentView.FloatFormatter)
					.padding(3)
					.border(Color.gray, width: 1)
			}
			.frame(height: 30)

			DSFStepperView.SwiftUI(configuration: self.demoConfig3,
										  isEnabled: self.isEnabled,
										  floatValue: self.$currentValue3)
				.frame(height: 70)
		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
