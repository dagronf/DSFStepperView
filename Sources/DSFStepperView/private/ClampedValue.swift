//
//  File.swift
//  
//
//  Created by Darren Ford on 13/3/21.
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

