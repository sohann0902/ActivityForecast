//
//  DailyActivityRanking.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import Foundation

struct DailyActivityRanking: Identifiable, Equatable {
	var id: String { date }
	let date: String
	let activities: [ActivityResult]
}

struct ActivityResult: Identifiable, Equatable {
	var id: Activity { activity }

	let activity: Activity
	let score: Double

	init(activity: Activity, score: Double) {
		let normalizedScore = min(max(score, 0), 100)

		self.activity = activity
		self.score = normalizedScore
	}
}
