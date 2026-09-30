//
//  CitySearchViewModelTests.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//

import XCTest
@testable import ActivityForecast

@MainActor
final class CitySearchViewModelTests: XCTestCase {

	// MARK: - Short Query

	func test_searchCities_whenQueryIsTooShort_setsStateToIdle() async {
		let service = MockGeocodingService()

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "M"

		await viewModel.searchCities()

		XCTAssertEqual(viewModel.state, .idle)
	}

	func test_searchCities_whenQueryIsTooShort_doesNotCallService() async {
		let service = MockGeocodingService()

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "M"

		await viewModel.searchCities()

		XCTAssertEqual(service.searchCallCount, 0)
	}

	// MARK: - Trimming

	func test_searchCities_trimsWhitespaceBeforeSearching() async {
		let service = MockGeocodingService()
		service.result = .success([])

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "   Mumbai   "

		await viewModel.searchCities()

		XCTAssertEqual(service.receivedQuery, "Mumbai")
	}

	// MARK: - Success

	func test_searchCities_whenCitiesAreReturned_setsLoadedState() async {
		let service = MockGeocodingService()

		let city = makeCity()

		service.result = .success([city])

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "Mumbai"

		await viewModel.searchCities()

		XCTAssertEqual(
			viewModel.state,
			.loaded([city])
		)
	}

	// MARK: - Empty

	func test_searchCities_whenNoCitiesAreReturned_setsEmptyState() async {
		let service = MockGeocodingService()

		service.result = .success([])

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "Something"

		await viewModel.searchCities()

		XCTAssertEqual(viewModel.state, .empty)
	}

	// MARK: - Error

	func test_searchCities_whenServiceThrows_setsErrorState() async {
		let service = MockGeocodingService()

		let error = URLError(.notConnectedToInternet)

		service.result = .failure(error)

		let viewModel = CitySearchViewModel(
			geocodingService: service
		)

		viewModel.searchText = "Mumbai"

		await viewModel.searchCities()

		XCTAssertEqual(
			viewModel.state,
			.error(error.localizedDescription)
		)
	}

}


