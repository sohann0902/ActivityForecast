//
//  Activity.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum Activity: Hashable {
	case outdoorSightseeing
	case indoorSightseeing
	case skiing
	case surfing

	var background: Color {
		switch self {
		case .outdoorSightseeing:
			return .green.opacity(0.2)

		case .indoorSightseeing:
			return .brown.opacity(0.2)

		case .skiing:
			return .blue.opacity(0.15)

		case .surfing:
			return .blue.opacity(0.4)
		}
	}
	
	var imageName: String {
		switch self {
		case .outdoorSightseeing:
			return "outdoor"

		case .indoorSightseeing:
			return "indoor"

		case .skiing:
			return "skii"

		case .surfing:
			return "surf"
		}
	}
}

extension Activity {
    var title: String {
        switch self {
        case .skiing: return "Skiing"
        case .surfing: return "Surfing"
        case .outdoorSightseeing: return "Outdoor sightseeing"
        case .indoorSightseeing: return "Indoor sightseeing"
        }
    }
}
