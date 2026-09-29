//
//  WeatherCondition.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

enum WeatherCondition : String {
    case clear
    case mainlyClear
    case partlyCloudy
    case overcast

    case fog
    case rimeFog

    case drizzle
    case freezingDrizzle

    case rain
    case freezingRain

    case snow
    case rainShowers
    case snowShowers

    case thunderstorm
    case thunderstormWithHail

    case unknown
}

extension WeatherCondition {

	static func from(code: Int) -> WeatherCondition {
		switch code {
		case 0:
			return .clear

		case 1:
			return .mainlyClear

		case 2:
			return .partlyCloudy

		case 3:
			return .overcast

		case 45:
			return .fog

		case 48:
			return .rimeFog

		case 51, 53, 55:
			return .drizzle

		case 56, 57:
			return .freezingDrizzle

		case 61, 63, 65:
			return .rain

		case 66, 67:
			return .freezingRain

		case 71, 73, 75, 77:
			return .snow

		case 80, 81, 82:
			return .rainShowers

		case 85, 86:
			return .snowShowers

		case 95, 97:
			return .thunderstorm

		case 96, 99:
			return .thunderstormWithHail

		default:
			return .unknown
		}
	}
}
