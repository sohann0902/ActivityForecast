//
//  DailyDestinationScorer.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import SwiftUI

struct DailyDestinationScorer {

    static func score(
        activityScores: [Activity: Double],
        supportedActivities: Set<Activity>
    ) -> Double {

        let outdoorActivities: [Activity] = [
            .outdoorSightseeing,
            .skiing,
            .surfing
        ]

        let outdoorScores = outdoorActivities.compactMap { activity -> Double? in

            guard supportedActivities.contains(activity) else {
                return nil
            }

            return activityScores[activity]
        }

        let outdoor = outdoorScore(
            from: outdoorScores
        )


        // MARK: Indoor fallback

        guard
            supportedActivities.contains(.indoorSightseeing),
            let indoor = activityScores[.indoorSightseeing]
        else {
            return outdoor
        }


        // Destination has no meaningful outdoor activity.
        if outdoorScores.isEmpty {
            return indoor
        }


        return applyIndoorFallback(
            outdoorScore: outdoor,
            indoorScore: indoor
        )
    }


    // MARK: - Outdoor opportunities

    private static func outdoorScore(
        from scores: [Double]
    ) -> Double {

        let sorted = scores.sorted(by: >)

        guard let best = sorted.first else {
            return 0
        }

        var score = best


        if sorted.count > 1 {

            let secondBonus =
                max(sorted[1] - 60, 0) * 0.15

            score += secondBonus
        }


        if sorted.count > 2 {

            let thirdBonus =
                max(sorted[2] - 60, 0) * 0.05

            score += thirdBonus
        }


        return min(score, 100)
    }


    // MARK: - Indoor fallback

    private static func applyIndoorFallback(
        outdoorScore: Double,
        indoorScore: Double
    ) -> Double {

        guard indoorScore > outdoorScore else {
            return outdoorScore
        }

        let improvement =
            (indoorScore - outdoorScore) * 0.15

        return min(
            outdoorScore + improvement,
            100
        )
    }
}
