//
//  IndoorSightseeingScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct IndoorSightseeingScorer {

    static func score(
        apparentTemperatureMax: Double,
        precipitationSum: Double,
        precipitationHours: Double,
        windSpeedMax: Double,
        windGustsMax: Double,
        weatherCondition: WeatherCondition
    ) -> Double {

        var score = 100.0


        // MARK: - 1. Precipitation inconvenience
        // Rain matters only because the user still has to move
        // between hotels, stations, museums, restaurants, etc.

        let precipitationAmountScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationSum,
            idealMaximum: 2,
            worstValue: 40
        )

        let precipitationDurationScore = ScoreNormalizer.lowerIsBetter(
            value: precipitationHours,
            idealMaximum: 2,
            worstValue: 16
        )

        let precipitationScore =
            (precipitationAmountScore * 0.55) +
            (precipitationDurationScore * 0.45)

        // Maximum precipitation penalty = 15
        score -= (1 - precipitationScore) * 15


        // MARK: - 2. Wind inconvenience

        let windSpeedScore = ScoreNormalizer.lowerIsBetter(
            value: windSpeedMax,
            idealMaximum: 20,
            worstValue: 60
        )

        let gustScore = ScoreNormalizer.lowerIsBetter(
            value: windGustsMax,
            idealMaximum: 30,
            worstValue: 80
        )

        let windScore =
            (windSpeedScore * 0.6) +
            (gustScore * 0.4)

        // Maximum wind penalty = 15
        score -= (1 - windScore) * 15


        // MARK: - 3. Temperature inconvenience

        let temperatureScore = ScoreNormalizer.idealRange(
            value: apparentTemperatureMax,
            minimum: -10,
            idealMinimum: 10,
            idealMaximum: 30,
            maximum: 45
        )

        // Maximum temperature penalty = 10
        score -= (1 - temperatureScore) * 10


        // MARK: - 4. Severe weather penalty

        score -= weatherPenalty(for: weatherCondition)


        // MARK: - 5. Clamp

        return min(max(score, 0), 100)
    }


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
             .rainShowers,
             .snow,
             .snowShowers:

            return 0


        case .fog:
            return 3

        case .rimeFog:
            return 5


        case .freezingDrizzle:
            return 10

        case .freezingRain:
            return 20


        case .thunderstorm:
            return 15

        case .thunderstormWithHail:
            return 25


        case .unknown:
            return 0
        }
    }
}
