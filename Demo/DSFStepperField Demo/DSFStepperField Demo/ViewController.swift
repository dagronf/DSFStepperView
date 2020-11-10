//
//  ViewController.swift
//  DSFStepperField Demo
//
//  Created by Darren Ford on 10/11/20.
//

import Cocoa

class ViewController: NSViewController {


	@IBOutlet weak var stepper1: DSFStepperView!
	@IBOutlet weak var stepper2: DSFStepperView!
	
	@IBOutlet weak var stepper3: DSFStepperView!
	@IBOutlet weak var ordinalStepper: DSFStepperView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		stepper3.delegate = self
		ordinalStepper.isEnabled = false
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func enabledDidChange(_ sender: NSButton) {
		self.ordinalStepper.isEnabled = (sender.state == .on)
	}

}

extension ViewController: DSFStepperViewDelegateProtocol {
	func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
		guard view === stepper3,
			  let updated = value?.floatValue else {
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
}
