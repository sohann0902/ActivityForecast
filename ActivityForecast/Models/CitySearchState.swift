//
//  CitySearchState.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import Foundation

enum CitySearchState: Equatable {
    case idle
    case loading
    case loaded([City])
    case empty
    case error(String)
}
