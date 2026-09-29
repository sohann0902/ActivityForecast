//
//  ScoreRating.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum ScoreRating: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    static func from(score: Double) -> ScoreRating {
        switch score {
        case 80...:
            return .excellent

        case 60..<80:
            return .good

        case 40..<60:
            return .fair

        default:
            return .poor
        }
    }
}
