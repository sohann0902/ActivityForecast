//
//  SurfScorerTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//


import XCTest
@testable import ActivityForecast

final class SurfScorerTests: XCTestCase {

    func testCalmWarmSunnyConditionsProduceHighScore() {
        let weather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 27,
            apparentTemperatureMin: 22,
            precipitationSum: 0,
            windSpeedMax: 10,
            windGustsMax: 18,
            uvIndexMax: 6,
            sunshineDuration: 32_000,
            daylightDuration: 43_200
        )

        let score = SurfScorer.score(for: weather)

        XCTAssertGreaterThanOrEqual(score, 80)
    }

    func testModerateWindReducesScore() {
        let calmWeather = makeWeather(
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let moderateWindWeather = makeWeather(
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            windSpeedMax: 30,
            windGustsMax: 40
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: calmWeather),
            SurfScorer.score(for: moderateWindWeather)
        )
    }

    func testStrongWindHeavilyReducesScore() {
        let calmWeather = makeWeather(
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let strongWindWeather = makeWeather(
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            windSpeedMax: 60,
            windGustsMax: 75
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: calmWeather),
            SurfScorer.score(for: strongWindWeather)
        )
    }

    func testComfortableTemperatureScoresHigherThanColdTemperature() {
        let comfortableWeather = makeWeather(
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            windSpeedMax: 10
        )

        let coldWeather = makeWeather(
            apparentTemperatureMax: 8,
            apparentTemperatureMin: 3,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: comfortableWeather),
            SurfScorer.score(for: coldWeather)
        )
    }

    func testHeavyRainReducesScore() {
        let dryWeather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            precipitationSum: 0,
            windSpeedMax: 10
        )

        let rainyWeather = makeWeather(
            weatherCode: 65,
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            precipitationSum: 25,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: dryWeather),
            SurfScorer.score(for: rainyWeather)
        )
    }

    func testThunderstormHeavilyReducesScore() {
        let normalWeather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let stormWeather = makeWeather(
            weatherCode: 95,
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let normalScore = SurfScorer.score(for: normalWeather)
        let stormScore = SurfScorer.score(for: stormWeather)

        XCTAssertGreaterThan(normalScore, stormScore)
        XCTAssertLessThan(stormScore, 60)
    }

    func testHailThunderstormProducesVeryLowScore() {
        let weather = makeWeather(
            weatherCode: 99,
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            windGustsMax: 18
        )

        let score = SurfScorer.score(for: weather)

        XCTAssertLessThan(score, 50)
    }

    func testMoreSunshineImprovesScore() {
        let cloudyWeather = makeWeather(
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            sunshineDuration: 5_000,
            daylightDuration: 43_200
        )

        let sunnyWeather = makeWeather(
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            sunshineDuration: 35_000,
            daylightDuration: 43_200
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: sunnyWeather),
            SurfScorer.score(for: cloudyWeather)
        )
    }

    func testExtremeUVReducesScore() {
        let normalUVWeather = makeWeather(
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            uvIndexMax: 5
        )

        let extremeUVWeather = makeWeather(
            apparentTemperatureMax: 25,
            apparentTemperatureMin: 21,
            windSpeedMax: 10,
            uvIndexMax: 12
        )

        XCTAssertGreaterThan(
            SurfScorer.score(for: normalUVWeather),
            SurfScorer.score(for: extremeUVWeather)
        )
    }

    func testScoreNeverExceedsOneHundred() {
        let weather = makeWeather(
            weatherCode: 0,
            apparentTemperatureMax: 26,
            apparentTemperatureMin: 22,
            precipitationSum: 0,
            windSpeedMax: 5,
            windGustsMax: 10,
            uvIndexMax: 5,
            sunshineDuration: 43_200,
            daylightDuration: 43_200
        )

        let score = SurfScorer.score(for: weather)

        XCTAssertLessThanOrEqual(score, 100)
    }

    func testScoreNeverGoesBelowZero() {
        let weather = makeWeather(
            weatherCode: 99,
            apparentTemperatureMax: 42,
            apparentTemperatureMin: 38,
            precipitationSum: 50,
            windSpeedMax: 80,
            windGustsMax: 100,
            uvIndexMax: 14,
            sunshineDuration: 0,
            daylightDuration: 43_200
        )

        let score = SurfScorer.score(for: weather)

        XCTAssertGreaterThanOrEqual(score, 0)
    }
}