//
//  ForecastState.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum ForecastState: Equatable {
    case idle
    case loading
    case loaded([DailyActivityRanking])
    case error(String)
}
