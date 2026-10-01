//
//  ActivityScoringEngineTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 01/10/26.
//

import XCTest
@testable import ActivityForecast

@MainActor
final class ActivityScoringEngineTests: XCTestCase {

    func test_scoreDay_returnsRankingForSameDate() {
        let engine = ActivityScoringEngine()
        let day = makeDay(date: "2026-10-01")

        let result = engine.score(day: day)

        XCTAssertEqual(result.date, "2026-10-01")
    }

    func test_scoreDay_returnsAllFourActivities() {
        let engine = ActivityScoringEngine()
        let day = makeDay()

        let result = engine.score(day: day)

        XCTAssertEqual(result.activities.count, 4)

        let activities = Set(result.activities.map(\.activity))

        XCTAssertEqual(
            activities,
            Set([
                .skiing,
                .surfing,
                .outdoorSightseeing,
                .indoorSightseeing
            ])
        )
    }

    func test_scoreDay_sortsActivitiesFromHighestToLowestScore() {
        let engine = ActivityScoringEngine()
        let day = makeDay()

        let result = engine.score(day: day)

        let scores = result.activities.map(\.score)

        XCTAssertEqual(
            scores,
            scores.sorted(by: >)
        )
    }

    func test_scoreForecast_returnsOneRankingPerDay() {
        let engine = ActivityScoringEngine()

        let forecast = WeatherForecast(
            days: [
                makeDay(date: "2026-10-01"),
                makeDay(date: "2026-10-02"),
                makeDay(date: "2026-10-03")
            ]
        )

        let result = engine.score(forecast: forecast)

        XCTAssertEqual(result.count, 3)
    }

    func test_scoreForecast_preservesForecastDayOrder() {
        let engine = ActivityScoringEngine()

        let forecast = WeatherForecast(
            days: [
                makeDay(date: "2026-10-01"),
                makeDay(date: "2026-10-02"),
                makeDay(date: "2026-10-03")
            ]
        )

        let result = engine.score(forecast: forecast)

        XCTAssertEqual(
            result.map(\.date),
            [
                "2026-10-01",
                "2026-10-02",
                "2026-10-03"
            ]
        )
    }

    func test_scoreForecast_whenNoDays_returnsEmptyArray() {
        let engine = ActivityScoringEngine()

        let forecast = WeatherForecast(
            days: []
        )

        let result = engine.score(forecast: forecast)

        XCTAssertTrue(result.isEmpty)
    }
    // Preserve the ranking fixtures while sharing DailyWeather construction.
    private func makeDay(date: String = "2026-10-01") -> DailyWeather {
        makeWeather(
            date: date,
            apparentTemperatureMax: 20,
            apparentTemperatureMin: 10,
            uvIndexMax: 3,
            sunshineDuration: 20_000,
            daylightDuration: 40_000
        )
    }

}
