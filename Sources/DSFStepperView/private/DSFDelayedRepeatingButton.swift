//
//  DSFDelayedRepeatingButton.swift
//
//  Created by Darren Ford on 10/11/20.
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

#if canImport(AppKit) && os(macOS)

import AppKit

/// A simple NSButton that supports a delayed button repeat if the user clicks and holds the button
internal class DSFDelayedRepeatingButton: NSButton {
	override var acceptsFirstResponder: Bool {
		// For the purposes of this stepper view, we don't want to allow focus on the button
		return false
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.wantsLayer = true
		self.layer?.cornerRadius = 3
	}

	override var isEnabled: Bool {
		get {
			return super.isEnabled
		}
		set {
			super.isEnabled = newValue
			self.window?.invalidateCursorRects(for: self)
		}
	}

	override func resetCursorRects() {
		// Add the hand cursor when we're over the button
		if self.isEnabled {
			self.addCursorRect(bounds, cursor: .pointingHand)
		}
	}

	var mouseOverTrack: NSTrackingArea?
	override func layout() {
		super.layout()

		if let t = self.mouseOverTrack {
			self.removeTrackingArea(t)
		}

		self.mouseOverTrack = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
		self.addTrackingArea(self.mouseOverTrack!)
	}

	deinit {
		self.eventTimer?.invalidate()
		self.eventTimer = nil
	}

	private var eventTimer: Timer?

	override func mouseDown(with _: NSEvent) {
		guard let w = self.window else {
			return
		}

		self.performClick(self)

		self.eventTimer = Timer.scheduledTimer(
			timeInterval: NSEvent.keyRepeatDelay,
			target: self,
			selector: #selector(self.initialTimerCallback),
			userInfo: "initial",
			repeats: false
		)

		RunLoop.current.add(self.eventTimer!, forMode: .eventTracking)

		var keepGoing = true
		while keepGoing {
			guard let theEvent = w.nextEvent(matching: [.leftMouseUp]) else {
				keepGoing = false
				break
			}

			switch theEvent.type {
			case .leftMouseUp:
				self.eventTimer?.invalidate()
				keepGoing = false
			default:
				break
			}
		}

		self.eventTimer?.invalidate()
		self.eventTimer = nil

		self.needsDisplay = true
	}

	@objc func initialTimerCallback(_ timer: Timer) {
		guard let which = timer.userInfo as? String else {
			return
		}

		if which == "initial" {
			// Remove the old timer first
			self.eventTimer?.invalidate()
			self.eventTimer = nil

			self.eventTimer = Timer.scheduledTimer(
				timeInterval: NSEvent.keyRepeatInterval,
				target: self,
				selector: #selector(self.initialTimerCallback),
				userInfo: "repeat",
				repeats: true
			)
			RunLoop.current.add(self.eventTimer!, forMode: .eventTracking)
		}

		self.sendAction(self.action, to: self.target)
	}

	// MARK: Mouse Tracking

	@inlinable internal var mouseOverColor: CGColor {
		let alpha: CGFloat = Accessibility.ReduceTransparency ? 0.3 : 0.1
		return CGColor(gray: 0.5, alpha: alpha)
	}

	private func createBaseFadeAnimation() -> CABasicAnimation {
		let b = CABasicAnimation(keyPath: "backgroundColor")
		b.autoreverses = false
		b.duration = Accessibility.ReduceMotion ? 0.01 : 0.1
		b.isRemovedOnCompletion = false
		b.fillMode = .forwards
		return b
	}

	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		if !self.isEnabled { return }
		let anim = self.createBaseFadeAnimation()
		anim.toValue = self.mouseOverColor
		self.layer?.add(anim, forKey: "fadecolor")
	}

	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		let anim = self.createBaseFadeAnimation()
		anim.toValue = nil
		self.layer?.add(anim, forKey: "fadecolor")
	}
}

#else

import UIKit

internal class DSFDelayedRepeatingButton: UIButton {

	private var timer: Timer?

	var actionBlock: (() -> Void)?

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.addTarget(self, action: #selector(startPress), for: .touchDown)
		self.addTarget(self, action: #selector(endPress), for: [.touchUpOutside, .touchUpInside])
	}

	@objc func startPress(_ sender: Any?) {
		self.performAction()
	}

	@objc func endPress(_ sender: Any?) {
		self.timer?.invalidate()
	}

	func doAction() {
		DispatchQueue.main.async { [weak self] in
			self?.actionBlock?()
		}
	}

	func performAction() {
		// Trigger the action first
		self.doAction()

		self.timer = Timer.scheduledTimer(
			timeInterval: 0.5,
			target: self,
			selector: #selector(self.initialDelay),
			userInfo: nil,
			repeats: false)
	}

	@objc func initialDelay(_ timer: Timer?) {
		self.timer?.invalidate()
		self.timer = nil

		// Trigger the action...
		self.doAction()

		// ... then repeat at a faster interval
		self.timer = Timer.scheduledTimer(
			timeInterval: 0.1,
			target: self,
			selector: #selector(self.repeatAction),
			userInfo: nil,
			repeats: true)
	}

	@objc func repeatAction(_ timer: Timer?) {
		self.doAction()
	}
}



#endif
