//
//  ForecastViewModelTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 01/10/26.
//

import XCTest
@testable import ActivityForecast

@MainActor
final class ForecastViewModelTests: XCTestCase {

    func test_fetchForecast_whenServiceSucceeds_setsLoadedState() async {
        let weatherService = MockWeatherService()
        let scoringEngine = MockActivityScoringEngine()

        let forecast = makeForecast()
        let rankings = makeRankings()

        weatherService.result = .success(forecast)
        scoringEngine.scoredResult = rankings

        let viewModel = ForecastViewModel(
            weatherService: weatherService,
            scoringEngine: scoringEngine
        )

        await viewModel.fetchForecast(for: makeCity())

        XCTAssertEqual(
            viewModel.state,
            .loaded(rankings)
        )
    }

    func test_fetchForecast_whenServiceSucceeds_passesForecastToScoringEngine() async {
        let weatherService = MockWeatherService()
        let scoringEngine = MockActivityScoringEngine()

        let forecast = makeForecast()

        weatherService.result = .success(forecast)
        scoringEngine.scoredResult = []

        let viewModel = ForecastViewModel(
            weatherService: weatherService,
            scoringEngine: scoringEngine
        )

        await viewModel.fetchForecast(for: makeCity())

        XCTAssertEqual(
            scoringEngine.receivedForecast,
            forecast
        )
    }

    func test_fetchForecast_whenServiceThrows_setsErrorState() async {
        let weatherService = MockWeatherService()
        let scoringEngine = MockActivityScoringEngine()

        let error = URLError(.notConnectedToInternet)

        weatherService.result = .failure(error)

        let viewModel = ForecastViewModel(
            weatherService: weatherService,
            scoringEngine: scoringEngine
        )

        await viewModel.fetchForecast(for: makeCity())

        XCTAssertEqual(
            viewModel.state,
            .error(error.localizedDescription)
        )
    }
	
	private func makeForecast() -> WeatherForecast {
		
		WeatherForecast(elevation: 14, timezone: "IST", days: [])
	}
	
	private func makeRankings() -> [DailyActivityRanking] {
		[
			DailyActivityRanking(date: "2026-09-30", activities: [])
		]
	}
}
