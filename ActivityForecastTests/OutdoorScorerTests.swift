//
//  OutdoorScorerTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//


import XCTest
@testable import ActivityForecast

final class OutdoorScorerTests: XCTestCase {

    func testMildDryCalmDayProducesHighScore() {
        let weather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 0,
            precipitationHours: 0,
            windSpeedMax: 10,
            windGustsMax: 18,
            uvIndexMax: 5,
            sunshineDuration: 32_000,
            daylightDuration: 43_200
        )

        let score = OutdoorScorer.score(for: weather)

        XCTAssertGreaterThanOrEqual(score, 80)
    }

    func testColdWeatherReducesScore() {
        let mildWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10
        )

        let coldWeather = makeWeather(
            apparentTemperatureMax: 5,
            apparentTemperatureMin: 1,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: mildWeather),
            OutdoorScorer.score(for: coldWeather)
        )
    }

    func testHotWeatherReducesScore() {
        let mildWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10
        )

        let hotWeather = makeWeather(
            apparentTemperatureMax: 40,
            apparentTemperatureMin: 36,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: mildWeather),
            OutdoorScorer.score(for: hotWeather)
        )
    }

    func testStrongWindReducesScore() {
        let calmWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let windyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 55,
            windGustsMax: 70
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: calmWeather),
            OutdoorScorer.score(for: windyWeather)
        )
    }

    func testHeavyRainReducesScore() {
        let dryWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 0,
            precipitationHours: 0,
            windSpeedMax: 10
        )

        let rainyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 25,
            precipitationHours: 8,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: dryWeather),
            OutdoorScorer.score(for: rainyWeather)
        )
    }

    func testLongDurationRainIsWorseThanShortRain() {
        let shortRain = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 8,
            precipitationHours: 1,
            windSpeedMax: 10
        )

        let longRain = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 8,
            precipitationHours: 9,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: shortRain),
            OutdoorScorer.score(for: longRain)
        )
    }

    func testThunderstormHeavilyReducesScore() {
        let normalWeather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10
        )

        let stormWeather = makeWeather(
            weatherCode: 95,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10
        )

        let normalScore = OutdoorScorer.score(for: normalWeather)
        let stormScore = OutdoorScorer.score(for: stormWeather)

        XCTAssertGreaterThan(normalScore, stormScore)
        XCTAssertLessThan(stormScore, 60)
    }

    func testExtremeUVReducesScore() {
        let normalUV = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10,
            uvIndexMax: 5
        )

        let extremeUV = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10,
            uvIndexMax: 12
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: normalUV),
            OutdoorScorer.score(for: extremeUV)
        )
    }

    func testMoreSunshineImprovesScore() {
        let cloudyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10,
            sunshineDuration: 5_000,
            daylightDuration: 43_200
        )

        let sunnyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10,
            sunshineDuration: 35_000,
            daylightDuration: 43_200
        )

        XCTAssertGreaterThan(
            OutdoorScorer.score(for: sunnyWeather),
            OutdoorScorer.score(for: cloudyWeather)
        )
    }

    func testScoreNeverExceedsOneHundred() {
        let weather = makeWeather(
            weatherCode: 0,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 0,
            precipitationHours: 0,
            windSpeedMax: 5,
            windGustsMax: 10,
            uvIndexMax: 4,
            sunshineDuration: 43_200,
            daylightDuration: 43_200
        )

        XCTAssertLessThanOrEqual(
            OutdoorScorer.score(for: weather),
            100
        )
    }

    func testScoreNeverGoesBelowZero() {
        let weather = makeWeather(
            weatherCode: 99,
            apparentTemperatureMax: 42,
            apparentTemperatureMin: 38,
            precipitationSum: 50,
            precipitationHours: 12,
            windSpeedMax: 80,
            windGustsMax: 100,
            uvIndexMax: 14,
            sunshineDuration: 0,
            daylightDuration: 43_200
        )

        XCTAssertGreaterThanOrEqual(
            OutdoorScorer.score(for: weather),
            0
        )
    }
}