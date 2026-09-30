//
//  MockGeocodingService.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//

import XCTest
@testable import ActivityForecast

final class MockGeocodingService: GeocodingServiceProtocol {

	var result: Result<[City], Error> = .success([])

	private(set) var searchCallCount = 0
	private(set) var receivedQuery: String?

	func searchCities(query: String) async throws -> [City] {
		searchCallCount += 1
		receivedQuery = query

		return try result.get()
	}
}
