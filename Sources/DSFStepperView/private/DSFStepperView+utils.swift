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

#endif
