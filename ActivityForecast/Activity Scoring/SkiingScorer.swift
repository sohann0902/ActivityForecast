//
//  SkiingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import Foundation

struct SkiScorer {

	static func score(for weather: DailyWeather) -> Double {

		guard hasSufficientSnow(weather) else {
			return 0
		}

		let snow = snowScore(for: weather)
		let temperature = temperatureScore(for: weather)
		let wind = windScore(for: weather)

		let severityPenalty = weatherSeverityPenalty(for: weather)

		let finalScore =
			snow +
			temperature +
			wind -
			severityPenalty

		return finalScore.clamped(to: 0...100)
	}

	private static func hasSufficientSnow(
		_ weather: DailyWeather
	) -> Bool {

		weather.snowDepth >= 30
	}

	// Snow depth is the main factor.
	private static func snowScore(
		for weather: DailyWeather
	) -> Double {

		let depthScore = snowDepthScore(weather.snowDepth)
		let freshSnowScore = freshSnowScore(weather.snowfallSum)

		return depthScore + freshSnowScore
	}


	private static func snowDepthScore(
		_ depth: Double
	) -> Double {

		switch depth {

		// Already filtered by skiability gate
		case ..<30:
			return 0

		case 30..<50:
			return 15

		case 50..<100:
			return 30

		case 100..<150:
			return 40

		default:
			return 45
		}
	}


	private static func freshSnowScore(
		_ snowfall: Double
	) -> Double {

		switch snowfall {

		case ..<2:
			return 0

		case 2..<7:
			return 3

		case 7..<15:
			return 6

		case 15...30:
			return 10

		case 30..<45:
			return 5

		// Extremely heavy snowfall can create concerns
		default:
			return -10
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

		// Dangerous
		case ..<(-23):
			return 0

		// Very cold
		case -23..<(-18):
			return 5

		// Cold
		case -18..<(-12):
			return 15

		// Ideal
		case -12..<0:
			return 30

		case 0...3:
			return 15

		// Slushy
		case 3...7:
			return 0

		case 7...12:
			return -15

		default:
			return -25
		}
	}


	private static func windScore(
		for weather: DailyWeather
	) -> Double {

		let wind = weather.windSpeedMax

		switch wind {

		// ideal
		case ..<24:
			return 25

		case 24..<48:
			return 15

		// Becoming problematic
		case 48..<56:
			return 5

		case 56..<64:
			return 0

		default:
			return 0
		}
	}

	private static func weatherSeverityPenalty(
		for weather: DailyWeather
	) -> Double {

		var penalty = 0.0
		
		if weather.windGustsMax >= 80 {
			penalty += 15
		} else if weather.windGustsMax >= 65 {
			penalty += 8
		}


		// Extreme Cold
		if weather.apparentTemperatureMin < -23 {
			penalty += 10
		}


		// Heavy Precipitatio
		if weather.precipitationSum >= 30 {
			penalty += 15
		} else if weather.precipitationSum >= 15 {
			penalty += 8
		}

		switch weather.weatherCode {

		// Fog
		case 45, 48:
			penalty += 10

		// Heavy snow
		case 75:
			penalty += 10

		// Snow showers
		case 85:
			penalty += 5

		case 86:
			penalty += 10

		// Thunderstorm
		case 95:
			penalty += 25

		// Thunderstorm with hail
		case 96, 99:
			penalty += 35

		default:
			break
		}


		return penalty
	}
}



