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
//  Some value clamping utilities
//

import Foundation

/// A clamping structure that clamps a value within a ClosedRange and indicating whether clamping took place
public struct ClampedValue<Bound> where Bound: Comparable {
	/// The type of clamping that occurred
	public enum ClampType {
		/// No clamping occurred - the value was within the specified range
		case none
		/// The input value was lower than the specified range and was clamped to the lower bound
		case lowerBound
		/// The input value was higher than the specified range and was clamped to the upper bound
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

public extension Comparable {
	/// Clamp a comparable value to a closed range and return the ClampedValue
	@inlinable func clampedValue(for range: ClosedRange<Self>) -> ClampedValue<Self> {
		return ClampedValue(value: self, range: range)
	}

	/// Clamp a comparable value to a closed range and return the clamped value
	@inlinable func clamped(to range: ClosedRange<Self>) -> Self {
		return Swift.min(range.upperBound, Swift.max(range.lowerBound, self))
	}

	/// If this value contained in the specified closed range?
	@inlinable func isContained(in range: ClosedRange<Self>) -> Bool {
		return range.contains(self)
	}
}

public extension ClosedRange {
	/// Clamp 'value' within this range, and return the ClampedValue
	@inlinable func clampedValue(_ value: Bound) -> ClampedValue<Bound> {
		return ClampedValue(value: value, range: self)
	}

	/// Clamp 'value' within this range and return the (potentially clamped) value
	@inlinable func clamp(value: Bound) -> Bound {
		return Swift.min(self.upperBound, Swift.max(self.lowerBound, value))
	}
}
