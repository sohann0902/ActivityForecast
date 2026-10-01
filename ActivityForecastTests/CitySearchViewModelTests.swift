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

    func test_searchCities_cancellationErrorsReturnToIdle() async {
        let errors: [Error] = [CancellationError(), URLError(.cancelled)]
        for error in errors {
            let service = MockGeocodingService()
            service.result = .failure(error)
            let viewModel = CitySearchViewModel(geocodingService: service)
            await viewModel.searchCities()
            XCTAssertEqual(viewModel.state, .idle)
        }
    }

    func test_searchCities_oldSuccessCannotOverwriteNewerResults() async {
        await assertOldRequestCannotOverwriteNewerResults(result: .success([]))
    }

    func test_searchCities_oldErrorCannotOverwriteNewerResults() async {
        await assertOldRequestCannotOverwriteNewerResults(
            result: .failure(URLError(.notConnectedToInternet))
        )
    }

    func test_searchCities_oldCancellationCannotClearNewerResults() async {
        await assertOldRequestCannotOverwriteNewerResults(
            result: .failure(URLError(.cancelled))
        )
    }

    func test_searchCities_editingQueryInvalidatesResultsBeforeNextSearch() async {
        let service = ControlledGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: service)
        let task = Task { await viewModel.searchCities() }
        await service.waitForRequest(0)
        XCTAssertEqual(viewModel.state, .loading)

        viewModel.searchText = "London"
        service.complete(0, with: .success([makeCity()]))
        await task.value
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_searchCities_clearingQueryInvalidatesPendingRequest() async {
        let service = ControlledGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: service)
        let task = Task { await viewModel.searchCities() }
        await service.waitForRequest(0)

        viewModel.searchText = ""
        await viewModel.searchCities()
        service.complete(0, with: .success([makeCity()]))
        await task.value
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(service.requestCount, 1)
    }

    func test_searchCities_cancelledTaskDiscardsSuccessfulResponse() async {
        let service = ControlledGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: service)
        let task = Task { await viewModel.searchCities() }
        await service.waitForRequest(0)

        task.cancel()
        service.complete(0, with: .success([makeCity()]))
        await task.value
        XCTAssertEqual(viewModel.state, .idle)
    }

    private func assertOldRequestCannotOverwriteNewerResults(
        result: Result<[City], Error>
    ) async {
        let service = ControlledGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: service)
        let older = Task { await viewModel.searchCities() }
        await service.waitForRequest(0)
        let newer = Task { await viewModel.searchCities() }
        await service.waitForRequest(1)

        // Repeat the same query: query text alone cannot identify the latest request.
        service.complete(1, with: .success([makeCity()]))
        await newer.value
        service.complete(0, with: result)
        await older.value
        XCTAssertEqual(viewModel.state, .loaded([makeCity()]))
    }

}



// Explicit continuations make request ordering deterministic without sleeps.
@MainActor
private final class ControlledGeocodingService: GeocodingServiceProtocol {
    private(set) var requestCount = 0
    private var pending: [Int: CheckedContinuation<[City], Error>] = [:]
    private var started: [Int: CheckedContinuation<Void, Never>] = [:]

    func searchCities(query: String) async throws -> [City] {
        let id = requestCount
        requestCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            pending[id] = continuation
            started.removeValue(forKey: id)?.resume()
        }
    }

    func waitForRequest(_ id: Int) async {
        if pending[id] != nil { return }
        await withCheckedContinuation { started[id] = $0 }
    }

    func complete(_ id: Int, with result: Result<[City], Error>) {
        guard let continuation = pending.removeValue(forKey: id) else {
            XCTFail("No pending request \(id)")
            return
        }
        continuation.resume(with: result)
    }
}
