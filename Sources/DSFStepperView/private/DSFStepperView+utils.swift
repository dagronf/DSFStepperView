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

#if canImport(AppKit) && os(macOS)

import AppKit

// MARK: - Dark Mode

internal extension NSAppearance {
	/// Is the appearance dark aqua?
	@inlinable var isDarkMode: Bool {
		if #available(macOS 10.14, *), self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
			return true
		}
		return false
	}
}

internal extension NSView {
	/// Is this view displaying in dark mode?
	///
	/// Note that just because the application is in dark mode doesn't mean that each view is displaying in dark mode.
	/// The 'effective appearance' of the view depends on many elements, such as the parent and any effect view(s) that
	/// contain it.
	@inlinable var isDarkMode: Bool {
		return self.effectiveAppearance.isDarkMode
	}
}

/// A global method to determine if the system is running in dark mode.
@inlinable func IsDarkMode() -> Bool {
	if #available(OSX 10.14, *) {
		if let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
			return style.lowercased().contains("dark")
		}
	}
	return false
}

// MARK: - Image scaling

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

// MARK: - Repeating button

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

// MARK: - Simple accessibility wrapper

@objc internal class Accessibility: NSObject {

	/// Get the current accessibility display option for reduce transparency. If this property's value is true, UI (mainly window) backgrounds should not be semi-transparent; they should be opaque.
	///
	/// You may listen for `DSFAccessibility.DidChange` to be notified when this changes.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`
	@inlinable @objc static var ReduceTransparency: Bool {
		if #available(OSX 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
		}
		else {
			return false
		}
	}

	/// Get the current accessibility display option for reduce motion. If this property's value is true, UI should avoid large animations, especially those that simulate the third dimension.
	///
	/// You may listen for `DSFAccessibility.DidChange` to be notified when this changes.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`.
	@inlinable @objc static var ReduceMotion: Bool {
		if #available(OSX 10.12, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
		}
		else {
			// Fallback on earlier versions
			return false
		}
	}

	/// Get the current accessibility display option for high-contrast UI.  If this is true, UI should be presented with high contrast such as utilizing a less subtle color palette or bolder lines.
	///
	/// You may listen for `DSFAccessibility.DidChange` to be notified when this changes.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast`.
	@inlinable @objc static var IncreaseContrast: Bool {
		if #available(OSX 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
		}
		else {
			return false
		}
	}
	/// Get the current accessibility display option for differentiate without color. If this is true, UI should not convey information using color alone and instead should use shapes or glyphs to convey information.
	///
	/// You may listen for `DSFAccessibility.DidChange` to be notified when this changes.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor`.
	@inlinable @objc static var DifferentiateWithoutColor: Bool {
		if #available(OSX 10.10, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor
		}
		else {
			return false
		}
	}

	/// Get the current accessibility display option for invert colors. If this property's value is true then the display will be inverted. In these cases it may be needed for UI drawing to be adjusted to in order to display optimally when inverted.
	///
	/// You may listen for `DSFAccessibility.DidChange` to be notified when this changes.
	///
	/// See: `NSWorkspace.shared.accessibilityDisplayShouldInvertColors`
	@inlinable @objc static var InvertColors: Bool {
		if #available(OSX 10.12, *) {
			return NSWorkspace.shared.accessibilityDisplayShouldInvertColors
		}
		else {
			return false
		}
	}
}

#endif
