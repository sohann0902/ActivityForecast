//
//  OutdoorScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct OutdoorScorer {

	static func score(for weather: DailyWeather) -> Double {

		let temperature = temperatureScore(for: weather) // max 45
		let wind = windScore(for: weather)               // max 35
		let sunshine = sunshineScore(for: weather)       // max 20

		let precipitation = precipitationPenalty(for: weather)
		let gusts = gustPenalty(for: weather)
		let uv = uvPenalty(for: weather)
		let severity = weatherSeverityPenalty(for: weather)

		let finalScore =
			temperature +
			wind +
			sunshine -
			precipitation -
			gusts -
			uv -
			severity

		return finalScore.clamped(to: 0...100)
	}


	// MARK: - Temperature

	private static func temperatureScore(
		for weather: DailyWeather
	) -> Double {

		let apparentTemperature =
			(
				weather.apparentTemperatureMax +
				weather.apparentTemperatureMin
			) / 2

		switch apparentTemperature {

		case 18...26:
			return 45

		case 12..<18:
			return 35

		case 26..<32:
			return 35

		case 5..<12:
			return 22

		case 32..<36:
			return 22

		case 0..<5:
			return 10

		case 36..<40:
			return 8

		case ..<0:
			return -10

		default:
			return -20
		}
	}


	// MARK: - Wind

	private static func windScore(
		for weather: DailyWeather
	) -> Double {

		switch weather.windSpeedMax {

		case ..<15:
			return 35

		case 15..<25:
			return 28

		case 25..<35:
			return 18

		case 35..<50:
			return 8

		case 50..<65:
			return 0

		default:
			return -15
		}
	}


	// MARK: - Sunshine

	private static func sunshineScore(
		for weather: DailyWeather
	) -> Double {

		guard weather.daylightDuration > 0 else {
			return 0
		}

		let ratio =
			weather.sunshineDuration /
			weather.daylightDuration

		switch ratio {

		case 0.7...:
			return 20

		case 0.4..<0.7:
			return 14

		case 0.2..<0.4:
			return 8

		default:
			return 3
		}
	}


	// MARK: - Precipitation

	private static func precipitationPenalty(
		for weather: DailyWeather
	) -> Double {

		var penalty = 0.0

		// Total precipitation amount
		switch weather.precipitationSum {

		case ..<1:
			break

		case 1..<5:
			penalty += 5

		case 5..<15:
			penalty += 12

		case 15..<30:
			penalty += 22

		default:
			penalty += 35
		}

		// How long precipitation lasts
		switch weather.precipitationHours {

		case ..<2:
			break

		case 2..<5:
			penalty += 5

		case 5..<10:
			penalty += 10

		default:
			penalty += 15
		}

		return penalty
	}


	// MARK: - Wind Gusts

	private static func gustPenalty(
		for weather: DailyWeather
	) -> Double {

		switch weather.windGustsMax {

		case ..<40:
			return 0

		case 40..<55:
			return 5

		case 55..<70:
			return 10

		default:
			return 18
		}
	}


	// MARK: - UV

	private static func uvPenalty(
		for weather: DailyWeather
	) -> Double {

		switch weather.uvIndexMax {

		case ..<8:
			return 0

		case 8..<11:
			return 3

		default:
			return 7
		}
	}


	// MARK: - Severe Weather
	//
	// Ordinary rain is intentionally NOT handled here.
	// Rain amount and duration are already accounted for
	// by precipitationPenalty.

	private static func weatherSeverityPenalty(
		for weather: DailyWeather
	) -> Double {

		switch weather.weatherCode {

		// Fog / poor visibility
		case 45, 48:
			return 10

		// Freezing drizzle
		case 56, 57:
			return 15

		// Freezing rain
		case 66, 67:
			return 20

		// Snow
		case 71, 73:
			return 8

		case 75:
			return 15

		// Snow showers
		case 85:
			return 8

		case 86:
			return 15

		// Thunderstorm
		case 95:
			return 45

		// Thunderstorm with hail
		case 96, 99:
			return 60

		default:
			return 0
		}
	}
}
