//
//  ScoreReason.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


import SwiftUI

struct ScoreReason: Identifiable {
    let id = UUID()

    let type: ReasonType
    let message: String

    enum ReasonType {
        case positive
        case neutral
        case negative
    }
}
