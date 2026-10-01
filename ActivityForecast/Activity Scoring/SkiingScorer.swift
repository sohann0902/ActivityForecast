//
//  SkiingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


struct SkiScorer {

	static func score(for weather: DailyWeather) -> Double {

		// MARK: 1. Skiability Gate

		guard hasSufficientSnow(weather) else {
			return 0
		}

		// MARK: 2. Positive / Negative Factors

		let snow = snowScore(for: weather)
		let temperature = temperatureScore(for: weather)
		let wind = windScore(for: weather)

		// MARK: 3. Additional Severe Weather Penalties

		let severityPenalty = weatherSeverityPenalty(for: weather)

		let finalScore =
			snow +
			temperature +
			wind -
			severityPenalty

		return finalScore.clamped(to: 0...100)
	}


	// MARK: - Snow Gate

	private static func hasSufficientSnow(
		_ weather: DailyWeather
	) -> Bool {

		weather.snowDepth >= 30
	}


	// MARK: - Snow
	//
	// Snow can contribute roughly 0...50 points.
	//
	// Snow depth is the main factor.
	// Fresh snowfall modifies the quality of the existing base.

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

		// Already filtered by skiability gate,
		// but kept here for safety.
		case ..<30:
			return 0

		// Poor / fair base
		case 30..<50:
			return 15

		// Good base
		case 50..<100:
			return 30

		// Excellent base
		case 100..<150:
			return 40

		// Very deep / fully covered
		default:
			return 45
		}
	}


	private static func freshSnowScore(
		_ snowfall: Double
	) -> Double {

		switch snowfall {

		// Essentially no fresh snow.
		// Not necessarily bad if the base is already good.
		case ..<2:
			return 0

		// Light refresh
		case 2..<7:
			return 3

		// Useful fresh snow
		case 7..<15:
			return 6

		// Ideal powder range
		case 15...30:
			return 10

		// Heavy snowfall.
		// Still potentially good, but no longer ideal.
		case 30..<45:
			return 5

		// Extremely heavy snowfall can create
		// operational / avalanche / access concerns.
		default:
			return -10
		}
	}


	// MARK: - Temperature
	//
	// Ideal skiing temperatures add points.
	//
	// Very cold temperatures reduce the score because of
	// frostbite / comfort concerns.
	//
	// Warm temperatures reduce the score because snow
	// becomes wet, heavy and slushy.

	private static func temperatureScore(
		for weather: DailyWeather
	) -> Double {

		let apparentTemperature =
			(
				weather.apparentTemperatureMax +
				weather.apparentTemperatureMin
			) / 2

		switch apparentTemperature {

		// Dangerous / extreme cold
		case ..<(-23):
			return -15

		// Very cold
		case -23..<(-18):
			return 5

		// Cold but still skiable
		case -18..<(-12):
			return 15

		// Ideal
		case -12..<0:
			return 30

		// Around freezing.
		// Still skiable, but snow may start softening.
		case 0...3:
			return 15

		// Slushy / degrading snow
		case 3...7:
			return 0

		// Warm enough to significantly hurt snow quality
		case 7...12:
			return -15

		// Very poor skiing temperature
		default:
			return -25
		}
	}


	// MARK: - Wind
	//
	// Calm wind adds strongly to suitability.
	// Strong wind eventually becomes a negative factor.

	private static func windScore(
		for weather: DailyWeather
	) -> Double {

		let wind = weather.windSpeedMax

		switch wind {

		// Safe / ideal
		case ..<24:
			return 25

		// Moderate impact
		case 24..<48:
			return 15

		// Becoming problematic
		case 48..<56:
			return 5

		// Lift closure / whiteout territory
		case 56..<64:
			return -10

		// Very unsuitable
		default:
			return -25
		}
	}


	// MARK: - Severe Weather

	private static func weatherSeverityPenalty(
		for weather: DailyWeather
	) -> Double {

		var penalty = 0.0


		// MARK: Strong Wind Gusts

		if weather.windGustsMax >= 80 {
			penalty += 15
		} else if weather.windGustsMax >= 65 {
			penalty += 8
		}


		// MARK: Extreme Cold

		if weather.apparentTemperatureMin < -23 {
			penalty += 10
		}


		// MARK: Heavy Precipitation

		if weather.precipitationSum >= 30 {
			penalty += 15
		} else if weather.precipitationSum >= 15 {
			penalty += 8
		}


		// MARK: Weather Code / Visibility

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


extension Comparable {

	func clamped(
		to range: ClosedRange<Self>
	) -> Self {

		min(
			max(self, range.lowerBound),
			range.upperBound
		)
	}
}
