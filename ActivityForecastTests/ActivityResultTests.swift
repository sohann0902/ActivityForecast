//
//  ActivityResultTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 01/10/26.
//

import XCTest
@testable import ActivityForecast

final class ActivityResultTests: XCTestCase {

    func test_init_whenScoreIsBelowZero_clampsToZero() {
        let result = ActivityResult(
            activity: .skiing,
            score: -20
        )

        XCTAssertEqual(result.score, 0)
    }

    func test_init_whenScoreIsAboveHundred_clampsToHundred() {
        let result = ActivityResult(
            activity: .surfing,
            score: 150
        )

        XCTAssertEqual(result.score, 100)
    }

    func test_init_whenScoreIsWithinRange_keepsOriginalScore() {
        let result = ActivityResult(
            activity: .outdoorSightseeing,
            score: 74
        )

        XCTAssertEqual(result.score, 74)
    }
}
