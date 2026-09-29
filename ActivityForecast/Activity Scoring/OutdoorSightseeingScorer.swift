//
//  OutdoorSightseeingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct OutdoorSightseeingScorer {

    func score(
        apparentTemperatureMax: Double,
        precipitationProbabilityMax: Double,
        precipitationHours: Double,
        precipitationSum: Double,
        windSpeedMax: Double,
        windGustsMax: Double,
        sunshineDuration: Double,
        daylightDuration: Double,
        uvIndexMax: Double,
        weatherCondition: WeatherCondition
    ) -> Double {

        let temperatureScore = ScoreNormalizer.idealRange(
            value: apparentTemperatureMax,
            minimum: 0,
            idealMinimum: 18,
            idealMaximum: 26,
            maximum: 40
        )

        let probabilityScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationProbabilityMax,
            idealMaximum: 20,
            worstValue: 90
        )

        let durationScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationHours,
            idealMaximum: 0.5,
            worstValue: 8
        )

        let amountScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationSum,
            idealMaximum: 0.5,
            worstValue: 20
        )

        let precipitationScore =
            probabilityScore * 0.30 +
            durationScore * 0.35 +
            amountScore * 0.35

        let windSpeedScore = ScoreNormalizer.lowerIsBetter(
            value: windSpeedMax,
            idealMaximum: 15,
            worstValue: 45
        )

        let gustScore = ScoreNormalizer.lowerIsBetter(
            value: windGustsMax,
            idealMaximum: 25,
            worstValue: 60
        )

        let windScore =
            windSpeedScore * 0.60 +
            gustScore * 0.40

        let sunshineRatio =
            daylightDuration > 0
            ? sunshineDuration / daylightDuration
            : 0

        let sunshineScore = ScoreNormalizer.higherIsBetter(
            value: sunshineRatio,
            minimumUseful: 0.10,
            idealMinimum: 0.70
        )

        var score =
            temperatureScore * 35 +
            precipitationScore * 35 +
            windScore * 15 +
            sunshineScore * 15

        score -= uvPenalty(for: uvIndexMax)

        score -= weatherPenalty(for: weatherCondition)

        return min(max(score, 0), 100)
    }

    private func uvPenalty(for uvIndex: Double) -> Double {
        switch uvIndex {
        case ..<3:
            return 0
        case 3..<6:
            return 1
        case 6..<8:
            return 3
        case 8..<11:
            return 5
        default:
            return 7
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
             .drizzle,
             .rain,
             .snow,
             .rainShowers,
             .snowShowers:
            return 0

        case .fog:
            return 8

        case .rimeFog:
            return 12

        case .freezingDrizzle:
            return 15

        case .freezingRain:
            return 20

        case .thunderstorm:
            return 15

        case .thunderstormWithHail:
            return 20

        case .unknown:
            return 0
        }
    }
}
