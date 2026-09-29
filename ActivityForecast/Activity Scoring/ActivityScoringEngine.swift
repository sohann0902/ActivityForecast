//
//  ActivityScoringEngine.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

protocol ActivityScoringEngineProtocol {
    func score(forecast: WeatherForecast) -> [DailyActivityRanking]
}

struct ActivityScoringEngine: ActivityScoringEngineProtocol {

    func score(day: DailyWeather) -> DailyActivityRanking {

        let weatherCondition = WeatherCondition.from(
            code: day.weatherCode
        )

        let skiing = SkiingScorer.score(
            snowDepth: day.snowDepth,
            snowfallSum: day.snowfallSum,
			temperatureMax: day.temperatureMax, temperatureMin: day.temperatureMin,
            windSpeedMax: day.windSpeedMax,
            windGustsMax: day.windGustsMax,
            weatherCondition: weatherCondition
        )

        let surfing = ActivityScore(
            score: SurfingScorer.score(
                apparentTemperatureMax: day.apparentTemperatureMax,
                precipitationSum: day.precipitationSum,
                precipitationHours: day.precipitationHours,
                precipitationProbabilityMax: day.precipitationProbabilityMax,
                windSpeedMax: day.windSpeedMax,
                windGustsMax: day.windGustsMax,
                sunshineDuration: day.sunshineDuration,
                daylightDuration: day.daylightDuration,
                weatherCondition: weatherCondition
            )
        )

        let outdoor = ActivityScore(
            score: OutdoorSightseeingScorer.score(
                apparentTemperatureMax: day.apparentTemperatureMax,
                precipitationProbabilityMax: day.precipitationProbabilityMax,
                precipitationHours: day.precipitationHours,
                precipitationSum: day.precipitationSum,
                windSpeedMax: day.windSpeedMax,
                windGustsMax: day.windGustsMax,
                sunshineDuration: day.sunshineDuration,
                daylightDuration: day.daylightDuration,
                uvIndexMax: day.uvIndexMax,
                weatherCondition: weatherCondition
            )
        )

        let indoor = ActivityScore(
            score: IndoorSightseeingScorer.score(
                apparentTemperatureMax: day.apparentTemperatureMax,
                precipitationSum: day.precipitationSum,
                precipitationHours: day.precipitationHours,
                windSpeedMax: day.windSpeedMax,
                windGustsMax: day.windGustsMax,
                weatherCondition: weatherCondition
            )
        )

        // Original order breaks ties deterministically, including zero scores.
        let activities = [
            ActivityResult(activity: .skiing, score: skiing),
            ActivityResult(activity: .surfing, score: surfing),
            ActivityResult(activity: .outdoorSightseeing, score: outdoor),
            ActivityResult(activity: .indoorSightseeing, score: indoor)
        ].enumerated().sorted { lhs, rhs in
            if lhs.element.score.score == rhs.element.score.score {
                return lhs.offset < rhs.offset
            }
            return lhs.element.score.score > rhs.element.score.score
        }.map { $0.element }

        return DailyActivityRanking(date: day.date, activities: activities)
    }

    func score(forecast: WeatherForecast) -> [DailyActivityRanking] {
        forecast.days.map { score(day: $0) }
    }
}
