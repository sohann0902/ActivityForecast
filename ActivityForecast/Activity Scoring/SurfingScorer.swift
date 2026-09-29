//
//  SurfingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct SurfingScorer {

    static func score(
        apparentTemperatureMax: Double,
        precipitationSum: Double,
        precipitationHours: Double,
        precipitationProbabilityMax: Double,
        windSpeedMax: Double,
        windGustsMax: Double,
        sunshineDuration: Double,
        daylightDuration: Double,
        weatherCondition: WeatherCondition
    ) -> Double {

        // MARK: - 1. Wind

        let windSpeedScore = ScoreNormalizer.lowerIsBetter(
            value: windSpeedMax,
            idealMaximum: 12,
            worstValue: 45
        )

        let gustScore = ScoreNormalizer.lowerIsBetter(
            value: windGustsMax,
            idealMaximum: 20,
            worstValue: 65
        )

        let windScore =
            (windSpeedScore * 0.6) +
            (gustScore * 0.4)


        // MARK: - 2. Precipitation

        let probabilityScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationProbabilityMax,
            idealMaximum: 20,
            worstValue: 100
        )

        let durationScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationHours,
            idealMaximum: 1,
            worstValue: 12
        )

        let amountScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationSum,
            idealMaximum: 1,
            worstValue: 20
        )

        let precipitationScore =
            (probabilityScore * 0.30) +
            (durationScore * 0.35) +
            (amountScore * 0.35)


        // MARK: - 3. Apparent temperature

        let temperatureScore = ScoreNormalizer.idealRange(
            value: apparentTemperatureMax,
            minimum: 5,
            idealMinimum: 18,
            idealMaximum: 30,
            maximum: 38
        )


        // MARK: - 4. Sunshine

        let sunshineRatio: Double

        if daylightDuration > 0 {
            sunshineRatio = min(
                max(sunshineDuration / daylightDuration, 0),
                1
            )
        } else {
            sunshineRatio = 0
        }

        let sunshineScore = sunshineRatio * 100


        // MARK: - 5. Weighted base score

        var score =
            (windScore * 0.35) +
            (precipitationScore * 0.30) +
            (temperatureScore * 0.20) +
            (sunshineScore * 0.15)


        // MARK: - 6. Weather penalty

        score -= weatherPenalty(for: weatherCondition)


        // MARK: - 7. Clamp

        return min(max(score, 0), 100)
    }


    // MARK: - Weather Penalty

    private static func weatherPenalty(
        for condition: WeatherCondition
    ) -> Double {

        switch condition {

        case .clear,
             .mainlyClear,
             .partlyCloudy,
             .overcast,
             .drizzle,
             .rain,
             .rainShowers:

            return 0


        case .fog:
            return 10

        case .rimeFog:
            return 15


        case .snow,
             .snowShowers:

            return 10


        case .freezingDrizzle:
            return 20

        case .freezingRain:
            return 30


        case .thunderstorm:
            return 30

        case .thunderstormWithHail:
            return 40


        case .unknown:
            return 0
        }
    }
}
