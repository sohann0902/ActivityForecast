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

		let activities = [
				ActivityResult(
					activity: .skiing,
					score: SkiScorer.score(for: day)
				),
				ActivityResult(
					activity: .surfing,
					score: SurfScorer.score(for: day)
				),
				ActivityResult(
					activity: .outdoorSightseeing,
					score: OutdoorScorer.score(for: day)
				),
				ActivityResult(
					activity: .indoorSightseeing,
					score: IndoorScorer.score(for: day)
				)
			]
			.sorted {
				$0.score > $1.score
			}

        return DailyActivityRanking(date: day.date, activities: activities)
    }

    func score(forecast: WeatherForecast) -> [DailyActivityRanking] {
        forecast.days.map { score(day: $0) }
    }
}
