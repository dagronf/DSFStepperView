//
//  ViewController.swift
//  DSFStepperField Demo
//
//  Created by Darren Ford on 10/11/20.
//

import Cocoa
import Combine

import DSFStepperView

class ViewController: NSViewController {
	@IBOutlet var stepper1: DSFStepperView!
	@IBOutlet var stepper2: DSFStepperView!

	@IBOutlet var stepper3: DSFStepperView!
	@IBOutlet var ordinalStepper: DSFStepperView!

	@IBOutlet var noEditStepper: DSFStepperView!

	var stepper2Observer: NSKeyValueObservation?

	var cancellableWrapped: AnyObject?

	@available(macOS 10.15, *)
	var cancellable: AnyCancellable? {
		return cancellableWrapped as? AnyCancellable
	}


	override func viewDidLoad() {
		super.viewDidLoad()

		self.stepper3.delegate = self
		self.ordinalStepper.isEnabled = false

		self.noEditStepper.font = NSFont.boldSystemFont(ofSize: 50)

		if #available(macOS 10.15, *) {
			// Hook in the first stepper using Combine
			self.cancellableWrapped = self.stepper1.publishedValue.sink(receiveValue: { currentValue in
				if let c = currentValue {
					print("stepper is currently at \(c)")
				}
				else {
					print("stepper is currently empty")
				}
			})
		}

		// Bind to the second stepper to receive change notifications
		self.stepper2Observer = self.observe(\.stepper2.floatValue, options: [.old, .new], changeHandler: { _, value in
			guard let val = value.newValue??.floatValue else { return }
			guard let oldVal = value.oldValue??.floatValue else { return }
			guard val != oldVal else { return }
			Swift.print("\(val)")
		})
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	@IBAction func enabledDidChange(_ sender: NSButton) {
		self.ordinalStepper.isEnabled = (sender.state == .on)
	}

	@IBAction func resetValue(_: Any) {
		if #available(macOS 10.15, *) {
			self.stepper1.publishedValue.send(44.5)
		}
	}
}

extension ViewController: DSFStepperViewDelegateProtocol {
	func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
		guard view === self.stepper3,
		      let updated = value?.floatValue else
		{
			return
		}

		if abs(updated) < 30 {
			view.foregroundColor = .systemGreen
		}
		else if abs(updated) < 40 {
			view.foregroundColor = .systemOrange
		}
		else {
			view.foregroundColor = .systemRed
		}
	}

	func stepperView(_: DSFStepperView, wantsTooltipTextforSegment segment: DSFStepperView.ToolTipSegment) -> String? {
		switch segment {
		case .decrementButton: return "Decrement the value"
		case .incrementButton: return "Increment the value"
		case .value: return "The amount of the value"
		}
	}
}
