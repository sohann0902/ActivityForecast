//
//  SkiingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


struct SkiingScorer {

    func score(
        snowDepth: Double,
        snowfallSum: Double,
        temperatureMax: Double,
        temperatureMin: Double,
        windSpeedMax: Double,
        windGustsMax: Double,
        weatherCondition: WeatherCondition
    ) -> ActivityScore {

		guard snowDepth >= 0.10 else {
			return ActivityScore(score: 0)
		}


        let snowDepthScore = ScoreNormalizer.higherIsBetter(
            value: snowDepth,
            minimumUseful: 0.03,
            idealMinimum: 0.30
        )

        let temperatureScore = ScoreNormalizer.idealRange(
            value: temperatureMax,
            minimum: -20,
            idealMinimum: -8,
            idealMaximum: 2,
            maximum: 10
        )

        let windSpeedScore = ScoreNormalizer.lowerIsBetter(
            value: windSpeedMax,
            idealMaximum: 15,
            worstValue: 50
        )

        let gustScore = ScoreNormalizer.lowerIsBetter(
            value: windGustsMax,
            idealMaximum: 25,
            worstValue: 70
        )

        let windScore =
            windSpeedScore * 0.4 +
            gustScore * 0.6

        var snowScore =
            snowDepthScore * 40 +
            temperatureScore * 30 +
            windScore * 30

		let snowBonus = snowfallBonus(snowfallSum)
		let conditionPenalty = weatherPenalty(for: weatherCondition)
		
		var score =
			snowScore * 0.40 +
			temperatureScore * 0.30 +
			windScore * 0.30

		score += snowBonus
		score -= conditionPenalty

		return ActivityScore(score: score)
    }
	
	private func hasUsableSnow(
		snowDepth: Double,
		snowfallSum: Double
	) -> Bool {
		snowDepth >= 0.03 || snowfallSum >= 2
	}

	private func snowfallBonus(_ snowfall: Double) -> Double {
		switch snowfall {
		case ..<1:
			return 0
		case 1..<5:
			return 5
		case 5..<15:
			return 10
		case 15..<30:
			return 7
		default:
			return 3
		}
	}
	
	private func weatherPenalty(
		for condition: WeatherCondition
	) -> Double {
		switch condition {
		case .clear,
			 .mainlyClear,
			 .partlyCloudy,
			 .overcast,
			 .snow,
			 .snowShowers:
			return 0

		case .fog:
			return 10

		case .rimeFog:
			return 12

		case .drizzle,
			 .rain,
			 .rainShowers:
			return 10

		case .freezingDrizzle:
			return 15

		case .freezingRain:
			return 25

		case .thunderstorm:
			return 25

		case .thunderstormWithHail:
			return 30

		case .unknown:
			return 0
		}
	}
}
