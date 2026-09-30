//
//  SkiScorerTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//


import XCTest
@testable import ActivityForecast

final class SkiScorerTests: XCTestCase {
	
	func testScoreIsZeroWhenSnowDepthIsBelowMinimum() {
		let weather = makeWeather(
			snowfallSum: 20, snowDepth: 20
		)
		
		let score = SkiScorer.score(for: weather)
		
		XCTAssertEqual(score, 0)
	}
	
	func testIdealConditionsProduceHighScore() {
		let weather = makeWeather(
			weatherCode: 1, apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 20, snowDepth: 120,
			precipitationSum: 1, windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let score = SkiScorer.score(for: weather)
		
		XCTAssertGreaterThanOrEqual(score, 85)
	}
	
	func testWarmTemperatureReducesScore() {
		let idealWeather = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let warmWeather = makeWeather(
			apparentTemperatureMax: 12, apparentTemperatureMin: 8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: idealWeather),
			SkiScorer.score(for: warmWeather)
		)
	}
	
	func testExtremeColdReducesScore() {
		let normalWeather = makeWeather(
			apparentTemperatureMax: -5, apparentTemperatureMin: -10, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let extremeCold = makeWeather(
			apparentTemperatureMax: -24, apparentTemperatureMin: -28, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: normalWeather),
			SkiScorer.score(for: extremeCold)
		)
	}
	
	func testStrongWindReducesScore() {
		let calmWeather = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let windyWeather = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 65,
			windGustsMax: 80
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: calmWeather),
			SkiScorer.score(for: windyWeather)
		)
	}
	
	func testFreshSnowImprovesScoreWhenBaseIsSufficient() {
		let noFreshSnow = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 0, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let freshSnow = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 20, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: freshSnow),
			SkiScorer.score(for: noFreshSnow)
		)
	}
	
	func testExtremeFreshSnowCanReduceScore() {
		let idealFreshSnow = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 20, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let extremeFreshSnow = makeWeather(
			apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 50, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: idealFreshSnow),
			SkiScorer.score(for: extremeFreshSnow)
		)
	}
	
	func testThunderstormReducesScore() {
		let normalWeather = makeWeather(
			weatherCode: 1, apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		let stormWeather = makeWeather(
			weatherCode: 95, apparentTemperatureMax: -3, apparentTemperatureMin: -8, snowfallSum: 10, snowDepth: 120,
			windSpeedMax: 10,
			windGustsMax: 20
		)
		
		XCTAssertGreaterThan(
			SkiScorer.score(for: normalWeather),
			SkiScorer.score(for: stormWeather)
		)
	}
	
	func testScoreNeverExceedsOneHundred() {
		
		let weather = makeWeather( apparentTemperatureMin: -8, snowfallSum: 20, snowDepth: 200, windSpeedMax: 5, windGustsMax: 10)
		
		XCTAssertLessThanOrEqual(
			SkiScorer.score(for: weather),
			100
		)
	}
	
	func testScoreNeverGoesBelowZero() {
		let weather = makeWeather(
			weatherCode: 99, apparentTemperatureMax: 15, apparentTemperatureMin: 10, snowfallSum: 50, snowDepth: 120,
			precipitationSum: 40, windSpeedMax: 80,
			windGustsMax: 100
		)
		
		XCTAssertGreaterThanOrEqual(
			SkiScorer.score(for: weather),
			0
		)
	}

    func testSubzeroTemperatureHasNoGapBeforeFreezing() {
        for temperature in [-1.0, -0.5, -0.1] {
            let weather = makeWeather(
                apparentTemperatureMax: temperature,
                apparentTemperatureMin: temperature,
                snowDepth: 50
            )
            XCTAssertEqual(SkiScorer.score(for: weather), 85,
                           "Unexpected score at \(temperature)°C")
        }
    }

    func testFreezingTemperatureUsesAroundFreezingScore() {
        let weather = makeWeather(
            apparentTemperatureMax: 0,
            apparentTemperatureMin: 0,
            snowDepth: 50
        )
        XCTAssertEqual(SkiScorer.score(for: weather), 70)
    }

}

