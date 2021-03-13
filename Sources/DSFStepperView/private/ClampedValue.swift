//
//  ClampedValue.swift
//
//  Created by Darren Ford on 13/3/20.
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

/// A clamping structure that clamps a value within a ClosedRange and indicating whether clamping took place
public struct ClampedValue<Bound> where Bound: Comparable {

	/// The type of clamping that occurred
	public enum ClampType {
		/// No clamping occurred - the value was within the specified range
		case none
		case lowerBound
		case upperBound
	}

	/// The clamped value
	public let value: Bound
	/// The clamping type that occurred during creation
	public let clampType: ClampType

	/// Was the input value clamped within the range?
	@inlinable public var wasClamped: Bool {
		return self.clampType != .none
	}

	/// Initializer
	public init(value: Bound, range: ClosedRange<Bound>) {
		if value < range.lowerBound {
			self.value = range.lowerBound
			self.clampType = .lowerBound
		}
		else if value > range.upperBound {
			self.value = range.upperBound
			self.clampType = .upperBound
		}
		else {
			self.value = value
			self.clampType = .none
		}
	}
}

public extension ClosedRange {
	/// Clamp 'value' within this range, and return the (potentially clamped) value and whether
	@inlinable func clamp(value: Bound) -> ClampedValue<Bound> {
		return ClampedValue(value: value, range: self)
	}

	/// Clamp 'value' within this range, and return the (potentially clamped) value and whether
	@inlinable func clamp(value: Bound) -> Bound {
		return Swift.min(self.upperBound, Swift.max(self.lowerBound, value))
	}
}

