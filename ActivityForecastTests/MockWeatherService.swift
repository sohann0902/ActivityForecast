//
//  MockWeatherService.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 01/10/26.
//

@testable import ActivityForecast

final class MockWeatherService: WeatherServiceProtocol {

    var result: Result<WeatherForecast, Error>!

    func fetchForecast(for city: City) async throws -> WeatherForecast {
        try result.get()
    }
}

final class MockActivityScoringEngine: ActivityScoringEngineProtocol {

	var scoredResult: [DailyActivityRanking] = []

	private(set) var receivedForecast: WeatherForecast?

	func score(forecast: WeatherForecast) -> [DailyActivityRanking] {
		receivedForecast = forecast
		return scoredResult
	}
}
