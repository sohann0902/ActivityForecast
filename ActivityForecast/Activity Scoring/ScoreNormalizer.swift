//
//  ScoreNormalizer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum ScoreNormalizer {

    static func idealRange(
        value: Double,
        minimum: Double,
        idealMinimum: Double,
        idealMaximum: Double,
        maximum: Double
    ) -> Double {
		if value <= minimum || value >= maximum {
			return 0
		}
		
		if value >= idealMinimum && value <= idealMaximum {
			return 1
		}
		
		if value < idealMinimum {
			return (value - minimum) / (idealMinimum - minimum)
		}
		
		let normalized = (maximum - value) / (maximum - idealMaximum)
		
		return clamp(normalized)
    }
	
	static func lowerIsBetter(
			value: Double,
			idealMaximum: Double,
			worstValue: Double
		) -> Double {
			if value <= idealMaximum {
				return 1
			}

			if value >= worstValue {
				return 0
			}

			let normalized = 1 - (
				(value - idealMaximum) /
				(worstValue - idealMaximum)
			)
			
			return clamp(normalized)
		}
	
	static func higherIsBetter(
		value: Double,
		minimumUseful: Double,
		idealMinimum: Double
	) -> Double {
		if value <= minimumUseful {
			return 0
		}

		if value >= idealMinimum {
			return 1
		}

		let normalized =
			(value - minimumUseful) /
			(idealMinimum - minimumUseful)

		return clamp(normalized)
	}
	
	private static func clamp(_ value: Double) -> Double {
		min(max(value, 0), 1)
	}
}
