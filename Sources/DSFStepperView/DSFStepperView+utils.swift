//
//  DSFStepperView+utils.swift
//
//  Created by Darren Ford on 11/11/20.
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

#if os(macOS)

import AppKit

internal extension NSAppearance {
	/// Is the app running in dark mode?
	@inlinable var isDarkMode: Bool {
		if #available(macOS 10.14, *),
		   self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
		{
			return true
		}
		return false
	}
}

internal extension NSImage {
	/// Scale the image proportionally to fit to the target size, returning a new image
	func resizeImage(maxSize: NSSize) -> NSImage {
		var ratio: Float = 0.0
		let imageWidth = Float(self.size.width)
		let imageHeight = Float(self.size.height)
		let maxWidth = Float(maxSize.width)
		let maxHeight = Float(maxSize.height)

		// Get ratio (landscape or portrait)
		if imageWidth > imageHeight {
			// Landscape
			ratio = maxWidth / imageWidth
		}
		else {
			// Portrait
			ratio = maxHeight / imageHeight
		}

		// Calculate new size based on the ratio
		let newWidth = imageWidth * ratio
		let newHeight = imageHeight * ratio

		// Create a new NSSize object with the newly calculated size
		let newSize = NSSize(width: Int(newWidth), height: Int(newHeight))

		// Cast the NSImage to a CGImage
		var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		let imageRef = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)

		// Create NSImage from the CGImage using the new size
		let imageWithNewSize = NSImage(cgImage: imageRef!, size: newSize)

		// Return the new image
		return imageWithNewSize
	}
}

// A simple NSButton that supports a delayed button repeat if the user clicks and holds the button
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

	override func resetCursorRects() {
		// Add the hand cursor when we're over the button
		self.addCursorRect(bounds, cursor: .pointingHand)
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

	// MARK: - Mouse Tracking

	private func createBaseFadeAnimation() -> CABasicAnimation {
		let b = CABasicAnimation(keyPath: "backgroundColor")
		b.autoreverses = false
		b.duration = 0.2
		b.isRemovedOnCompletion = false
		b.fillMode = .forwards
		return b
	}

	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		if !self.isEnabled  { return }
		let anim = self.createBaseFadeAnimation()
		anim.toValue = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
			? NSColor.gridColor.cgColor
			: CGColor(gray: 0.5, alpha: 0.15)

		self.layer?.add(anim, forKey: "fadecolor")
	}

	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		let anim = self.createBaseFadeAnimation()
		anim.toValue = nil
		self.layer?.add(anim, forKey: "fadecolor")
	}
}

#endif
