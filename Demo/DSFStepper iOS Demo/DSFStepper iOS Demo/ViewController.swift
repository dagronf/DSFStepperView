//
//  ViewController.swift
//  DSFStepper iOS Demo
//
//  Created by Darren Ford on 10/3/21.
//

import UIKit

import DSFStepperView

class ViewController: UIViewController {

	@IBOutlet weak var s1: DSFStepperView!
	@IBOutlet weak var s2: DSFStepperView!

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

	}


}

