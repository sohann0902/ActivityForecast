//
//  IndoorScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import Foundation

struct IndoorScorer {

	static func score(for weather: DailyWeather) -> Double {

		let baseline = 50.0

		let precipitation = precipitationBonus(for: weather)
		let temperature = temperatureBonus(for: weather)
		let wind = windAdjustment(for: weather)
		let sunshine = lowSunshineBonus(for: weather)

		let severityPenalty = severeWeatherPenalty(for: weather)

		let finalScore =
			baseline +
			precipitation +
			temperature +
			wind +
			sunshine -
			severityPenalty

		return finalScore.clamped(to: 0...100)
	}


	// Rain makes indoor activities more attractive.
	private static func precipitationBonus(
		for weather: DailyWeather
	) -> Double {

		var bonus = 0.0

		switch weather.precipitationSum {

		case ..<1:
			break

		case 1..<5:
			bonus += 5

		case 5..<15:
			bonus += 10

		case 15..<30:
			bonus += 15

		default:
			bonus += 20
		}

		switch weather.precipitationHours {

		case ..<2:
			break

		case 2..<5:
			bonus += 4

		case 5..<10:
			bonus += 8

		default:
			bonus += 12
		}

		return bonus
	}


	// Uncomfortable heat/cold makes indoor activities more appealing.
	private static func temperatureBonus(
		for weather: DailyWeather
	) -> Double {

		let apparentTemperature =
			(
				weather.apparentTemperatureMax +
				weather.apparentTemperatureMin
			) / 2

		switch apparentTemperature {


		case 15...28:
			return 0

		case 8..<15:
			return 5

		case 28..<33:
			return 5

		case 2..<8:
			return 10

		case 33..<38:
			return 10

		case ..<2:
			return 15

		default:
			return 15
		}
	}


	// Moderate wind makes indoor activities more attractive.
	private static func windAdjustment(
		for weather: DailyWeather
	) -> Double {

		switch weather.windSpeedMax {

		case ..<20:
			return 0

		case 20..<35:
			return 2

		case 35..<50:
			return 4

		case 50..<65:
			return 2

		default:
			return -3
		}
	}



	// A cloudy day can make indoor activities slightly more appealing.
	private static func lowSunshineBonus(
		for weather: DailyWeather
	) -> Double {

		guard weather.daylightDuration > 0 else {
			return 0
		}

		let ratio =
			weather.sunshineDuration /
			weather.daylightDuration

		switch ratio {

		case ..<0.2:
			return 5

		case 0.2..<0.4:
			return 3

		default:
			return 0
		}
	}


	// Dangerous weather should NOT make indoor score keep increasing, because travelling to indoor venues may also be unsafe.
	private static func severeWeatherPenalty(
		for weather: DailyWeather
	) -> Double {

		var penalty = 0.0

		switch weather.weatherCode {

		// Fog
		case 45, 48:
			penalty += 5

		// Freezing drizzle
		case 56, 57:
			penalty += 10

		// Freezing rain
		case 66, 67:
			penalty += 18

		// Heavy snow
		case 75:
			penalty += 12

		// Heavy snow showers
		case 86:
			penalty += 15

		// Thunderstorm
		case 95:
			penalty += 20

		// Thunderstorm with hail
		case 96, 99:
			penalty += 30

		default:
			break
		}

		// Extreme gusts can make travel difficult.
		if weather.windGustsMax >= 80 {
			penalty += 15
		} else if weather.windGustsMax >= 65 {
			penalty += 8
		}

		return penalty
	}
}
