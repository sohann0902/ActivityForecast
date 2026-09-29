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
