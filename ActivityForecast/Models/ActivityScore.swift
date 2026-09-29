//
//  ActivityScore.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


import SwiftUI

struct ActivityScore {
	let score: Double
	let rating: ScoreRating

	init(score: Double) {
		let score = min(max(score, 0), 100)

		self.score = score
		self.rating = ScoreRating.from(score: score)
	}
}
