//
//  SurfingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import Foundation

struct SurfScorer {

	static func score(for weather: DailyWeather) -> Double {

		let wind = windScore(for: weather)
		let temperature = temperatureScore(for: weather)
		let sunshine = sunshineScore(for: weather)

		let penalty = weatherPenalty(for: weather)

		let finalScore =
			wind +
			temperature +
			sunshine -
			penalty

		return finalScore.clamped(to: 0...100)
	}

	private static func windScore(
		for weather: DailyWeather
	) -> Double {

		let wind = weather.windSpeedMax

		switch wind {
		case ..<15:
			return 60

		case 15..<25:
			return 48

		case 25..<35:
			return 30

		case 35..<50:
			return 12

		case 50..<65:
			return 0

		default:
			return -20
		}
	}

	private static func temperatureScore(
		for weather: DailyWeather
	) -> Double {

		let apparentTemperature =
			(
				weather.apparentTemperatureMax +
				weather.apparentTemperatureMin
			) / 2

		switch apparentTemperature {

		case 20...30:
			return 30

		case 15..<20:
			return 24

		case 10..<15:
			return 16

		case 5..<10:
			return 8

		case ..<5:
			return -5

		case 30...35:
			return 20

		case 35...40:
			return 8

		default:
			return -10
		}
	}

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
			return 10

		case 0.4..<0.7:
			return 7

		case 0.2..<0.4:
			return 4

		default:
			return 1
		}
	}


	// Weather Penalties

	private static func weatherPenalty(
		for weather: DailyWeather
	) -> Double {

		var penalty = 0.0


		// MARK: Wind Gusts

		if weather.windGustsMax >= 70 {
			penalty += 20

		} else if weather.windGustsMax >= 55 {
			penalty += 10
		}


		// MARK: Precipitation

		if weather.precipitationSum >= 30 {
			penalty += 20

		} else if weather.precipitationSum >= 15 {
			penalty += 12

		} else if weather.precipitationSum >= 5 {
			penalty += 5
		}


		// weather Code

		switch weather.weatherCode {

		// Fog
		case 45, 48:
			penalty += 8

		// Heavy rain
		case 65:
			penalty += 15

		// Rain showers
		case 80:
			penalty += 5

		case 81:
			penalty += 10

		case 82:
			penalty += 18

		// Thunderstorm
		case 95:
			penalty += 50

		// Thunderstorm with hail
		case 96, 99:
			penalty += 65

		default:
			break
		}

		// uv
		if weather.uvIndexMax >= 11 {
			penalty += 5
		}
		return penalty
	}
}
