//
//  Comparable+Exxt.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 01/10/26.
//


extension Comparable {

	func clamped(
		to range: ClosedRange<Self>
	) -> Self {

		min(
			max(self, range.lowerBound),
			range.upperBound
		)
	}
}
