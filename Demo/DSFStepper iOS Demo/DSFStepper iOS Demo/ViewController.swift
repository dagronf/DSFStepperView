//
//  ViewController.swift
//  DSFStepper iOS Demo
//
//  Created by Darren Ford on 10/3/21.
//

import UIKit

import DSFStepperView

import Combine

class ViewController: UIViewController {

	@IBOutlet weak var s1: DSFStepperView!
	@IBOutlet weak var s2: DSFStepperView!

	@IBOutlet weak var combineListeningStepperView: DSFStepperView!

	var cancellable: AnyCancellable?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.


		let n = NumberFormatter()
		n.allowsFloats = true
		n.maximumFractionDigits = 2
		n.minimumFractionDigits = 2
		s2.numberFormatter = n

		let f = UIFont.monospacedSystemFont(ofSize: 22, weight: .bold)
		s2.font = f

		self.setupCombine()
	}

	func setupCombine() {
		self.cancellable = self.combineListeningStepperView.publishedValue.sink(receiveValue: { currentValue in
			if let c = currentValue {
				print("stepper is currently at \(c)")
			}
			else {
				print("stepper is currently empty")
			}
		})

	}


}

