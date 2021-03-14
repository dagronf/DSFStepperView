//
//  ContentView.swift
//  Shared
//
//  Created by Darren Ford on 10/3/21.
//

import SwiftUI
import DSFStepperView

extension DSFColor {
	static var random: DSFColor {
		let randomRed: CGFloat = CGFloat(drand48())
		let randomGreen: CGFloat = CGFloat(drand48())
		let randomBlue: CGFloat = CGFloat(drand48())
		return DSFColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
	}
}

struct ContentView: View {

	@State private var isEnabled: Bool = true
	@State private var currentValue: CGFloat? = 23
	let demoConfig = DSFStepperView.SwiftUI.DisplaySettings(
		range: 0 ... 100, increment: 1
	)

	@State var style = DSFStepperView.SwiftUI.Style(textColor: DSFColor.systemTeal, indicatorColor: DSFColor.systemBlue)
	@State var disabledStyle = DSFStepperView.SwiftUI.Style()

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

	// 2

	@State private var currentValue2: CGFloat? = -3.5
	let demoConfig2 = DSFStepperView.SwiftUI.DisplaySettings(
		range: -10 ... 10, increment: 0.5, initialValue: 23, numberFormatter: ContentView.FloatFormatter,
		font: DSFFont.monospacedSystemFont(ofSize: 18, weight: .regular)
	)

	// 3

	let demoConfig3 = DSFStepperView.SwiftUI.DisplaySettings(
		range: -10 ... 10, increment: 0.5,
		numberFormatter: FloatFormatter,
		font: DSFFont.systemFont(ofSize: 24, weight: .heavy)
	)
	@State private var currentValue3: CGFloat? = 5

	// 4

	@State var style4 = DSFStepperView.SwiftUI.Style(indicatorColor: DSFColor.systemGray)
	@State private var currentValue4: CGFloat? = 5
	let demoConfig4 = DSFStepperView.SwiftUI.DisplaySettings(
		range: 0 ... 10, increment: 1,
		initialValue: 5,
		placeholderText: "inh",
		allowsKeyboardInput: true, allowsEmptyValue: true
	)


	var body: some View {
		VStack (spacing: 16) {
			Toggle("Enabled", isOn: $isEnabled)
			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(configuration: self.demoConfig,
											  isEnabled: self.isEnabled,
											  floatValue: self.$currentValue)
				TextField("", value: $currentValue, formatter: NumberFormatter())
					.padding(4)
					.border(Color.gray)
			}
			.frame(height: 30)

			HStack(alignment: .center, spacing: 20) {
				DSFStepperView.SwiftUI(
					configuration: self.demoConfig2,
					style: self.style,
					isEnabled: self.isEnabled,
					floatValue: self.$currentValue2,
					onValueChange: { value in
						Swift.print("New value is \(String(describing: value))")
					})
				Button("🌈") {
					let cVal = DSFColor.random
					self.style.textColor = cVal
					self.style.strokeColor = cVal.withAlphaComponent(0.4)
					self.style.fillColor = cVal.withAlphaComponent(0.1)
					self.style.indicatorColor = cVal
				}
				TextField("", value: $currentValue2, formatter: ContentView.FloatFormatter)
					.padding(4)
					.border(Color.gray)
			}
			.frame(height: 30)

			DSFStepperView.SwiftUI(configuration: self.demoConfig3,
										  isEnabled: self.isEnabled,
										  floatValue: self.$currentValue3)
				.frame(height: 70)

			HStack(alignment: .center, spacing: 0) {
				DSFStepperView.SwiftUI(configuration: self.demoConfig4,
											  style: self.style4,
											  isEnabled: self.isEnabled,
											  floatValue: self.$currentValue4)
					.frame(width: 140, height: 30)
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
