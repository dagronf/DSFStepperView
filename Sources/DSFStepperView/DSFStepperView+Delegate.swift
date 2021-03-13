//
//  DSFStepperView+Delegate.swift
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

import Foundation

@objc public protocol DSFStepperViewDelegateProtocol {
	/// Called when the value in the stepper changes
	/// - Parameters:
	///   - view: the stepper view that changed value
	///   - value: the new value, or nil if the value is empty
	@objc func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?)

	#if os(macOS)
	/// Called to retrieve the tooltip text for the control (optional)
	/// - Parameters:
	///   - view: the stepper view
	///   - segment: the segment of the control to retreive tooltip text for
	/// - Returns the string to display for the control segment, or nil if no tooltip should be displayed
	@objc optional func stepperView(_ view: DSFStepperView, wantsTooltipTextforSegment segment: DSFStepperView.ToolTipSegment) -> String?
	#endif
}
