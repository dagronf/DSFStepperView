//
//  DSFStepperView+utils.swift
//
//  Created by Darren Ford on 11/11/20.
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

import Foundation
import CoreGraphics

#if os(macOS)
import Cocoa
public typealias DSFColor = NSColor
public typealias DSFView = NSView
public typealias DSFFont = NSFont
#else
import UIKit
public typealias DSFColor = UIColor
public typealias DSFView = UIView
public typealias DSFFont = UIFont
#endif

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS)
@available(macOS 10.15, *)
typealias DSFViewRepresentable = NSViewRepresentable
#else
@available(iOS 13.0, tvOS 13.0, *)
typealias DSFViewRepresentable = UIViewRepresentable
#endif
#endif

#if canImport(Combine)
import Combine
@available(macOS 10.15, *)
extension Publisher {
	 var erased: AnyPublisher<Output, Failure> { eraseToAnyPublisher() }
}
#endif

extension CGFloat {
	/// Returns an NSNumber representation of this value
	@inlinable var numberValue: NSNumber {
		return NSNumber(value: Double(self))
	}
}

extension NSNumber {
	/// Returns a CGFloat representation of this value
	@inlinable var cgFloatValue: CGFloat {
		return CGFloat(self.doubleValue)
	}
}

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
