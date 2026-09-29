//
//  ForecastState.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum ForecastState {
    case idle
    case loading
    case loaded(WeatherForecast)
    case error(String)
}
