//
//  IndoorScorerTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//


import XCTest
@testable import ActivityForecast

final class IndoorScorerTests: XCTestCase {

    func testPleasantOutdoorWeatherKeepsIndoorAroundBaseline() {
        let weather = makeWeather(
            weatherCode: 1,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 0,
            precipitationHours: 0,
            windSpeedMax: 10,
            windGustsMax: 18,
            sunshineDuration: 32_000,
            daylightDuration: 43_200
        )

        let score = IndoorScorer.score(for: weather)

        XCTAssertGreaterThanOrEqual(score, 40)
        XCTAssertLessThanOrEqual(score, 60)
    }

    func testRainIncreasesIndoorScore() {
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
            precipitationSum: 12,
            precipitationHours: 6,
            windSpeedMax: 10
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: rainyWeather),
            IndoorScorer.score(for: dryWeather)
        )
    }

    func testLongRainScoresHigherThanShortRain() {
        let shortRain = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 8,
            precipitationHours: 1
        )

        let longRain = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 8,
            precipitationHours: 9
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: longRain),
            IndoorScorer.score(for: shortRain)
        )
    }

    func testColdWeatherIncreasesIndoorScore() {
        let comfortableWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20
        )

        let coldWeather = makeWeather(
            apparentTemperatureMax: 5,
            apparentTemperatureMin: 1
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: coldWeather),
            IndoorScorer.score(for: comfortableWeather)
        )
    }

    func testHotWeatherIncreasesIndoorScore() {
        let comfortableWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20
        )

        let hotWeather = makeWeather(
            apparentTemperatureMax: 40,
            apparentTemperatureMin: 36
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: hotWeather),
            IndoorScorer.score(for: comfortableWeather)
        )
    }

    func testModerateWindIncreasesIndoorScore() {
        let calmWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 10
        )

        let windyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 40
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: windyWeather),
            IndoorScorer.score(for: calmWeather)
        )
    }

    func testExtremeWindCanReduceIndoorScore() {
        let moderateWind = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 40,
            windGustsMax: 45
        )

        let extremeWind = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 80,
            windGustsMax: 100
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: moderateWind),
            IndoorScorer.score(for: extremeWind)
        )
    }

    func testLowSunshineSlightlyIncreasesIndoorScore() {
        let sunnyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            sunshineDuration: 35_000,
            daylightDuration: 43_200
        )

        let gloomyWeather = makeWeather(
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            sunshineDuration: 5_000,
            daylightDuration: 43_200
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: gloomyWeather),
            IndoorScorer.score(for: sunnyWeather)
        )
    }

    func testThunderstormDoesNotMakeIndoorScoreExtremelyHigh() {
        let weather = makeWeather(
            weatherCode: 95,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 20,
            precipitationHours: 8,
            windSpeedMax: 30,
            windGustsMax: 70
        )

        let score = IndoorScorer.score(for: weather)

        XCTAssertLessThan(score, 90)
    }

    func testHailThunderstormReducesIndoorScoreComparedToNormalRain() {
        let rainyWeather = makeWeather(
            weatherCode: 61,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 15,
            precipitationHours: 7,
            windSpeedMax: 20,
            windGustsMax: 30
        )

        let severeStorm = makeWeather(
            weatherCode: 99,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            precipitationSum: 15,
            precipitationHours: 7,
            windSpeedMax: 20,
            windGustsMax: 30
        )

        XCTAssertGreaterThan(
            IndoorScorer.score(for: rainyWeather),
            IndoorScorer.score(for: severeStorm)
        )
    }

    func testScoreNeverExceedsOneHundred() {
        let weather = makeWeather(
            apparentTemperatureMax: 40,
            apparentTemperatureMin: 36,
            precipitationSum: 50,
            precipitationHours: 15,
            windSpeedMax: 40,
            sunshineDuration: 0,
            daylightDuration: 43_200
        )

        XCTAssertLessThanOrEqual(
            IndoorScorer.score(for: weather),
            100
        )
    }

    func testScoreNeverGoesBelowZero() {
        let weather = makeWeather(
            weatherCode: 99,
            apparentTemperatureMax: 24,
            apparentTemperatureMin: 20,
            windSpeedMax: 90,
            windGustsMax: 120
        )

        XCTAssertGreaterThanOrEqual(
            IndoorScorer.score(for: weather),
            0
        )
    }
}