//
//  WeeklyDestinationScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct WeeklyDestinationScorer {

    private static let badDayThreshold = 45.0

    static func score(
        dailyScores: [Double]
    ) -> Double {

        guard !dailyScores.isEmpty else {
            return 0
        }


        // MARK: - Full average

        let fullAverage =
            dailyScores.reduce(0, +) /
            Double(dailyScores.count)


        // MARK: - Robust average

        let robustAverage: Double

        if dailyScores.count >= 5 {

            var scores = dailyScores

            if let worstIndex = scores.indices.min(
                by: {
                    scores[$0] < scores[$1]
                }
            ) {
                scores.remove(at: worstIndex)
            }

            robustAverage =
                scores.reduce(0, +) /
                Double(scores.count)

        } else {

            robustAverage = fullAverage
        }


        // MARK: - Base weekly score

        var score =
            (robustAverage * 0.80) +
            (fullAverage * 0.20)


        // MARK: - Bad day count

        let badDayCount = dailyScores.filter {
            $0 < badDayThreshold
        }.count

        let additionalBadDays =
            max(badDayCount - 1, 0)

        score -=
            Double(additionalBadDays) * 2.5


        // MARK: - Consecutive bad days

        let longestRun = longestBadRun(
            scores: dailyScores,
            threshold: badDayThreshold
        )

        if longestRun > 1 {

            score -=
                Double(longestRun - 1) * 3
        }


        // MARK: - Final score

        return min(
            max(score, 0),
            100
        )
    }


    private static func longestBadRun(
        scores: [Double],
        threshold: Double
    ) -> Int {

        var longest = 0
        var current = 0

        for score in scores {

            if score < threshold {

                current += 1
                longest = max(
                    longest,
                    current
                )

            } else {

                current = 0
            }
        }

        return longest
    }
}
