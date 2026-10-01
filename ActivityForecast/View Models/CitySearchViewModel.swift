//
//  CitySearchViewModel.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import Foundation
import Observation

@Observable
final class CitySearchViewModel {
    var searchText = "Mum" {
        didSet {
            guard searchText != oldValue else { return }
            // Invalidate immediately, including during the view's debounce delay.
            activeRequestID = nil
            state = .idle
        }
    }
    private(set) var state: CitySearchState = .idle

    private let geocodingService: GeocodingServiceProtocol
    private var activeRequestID: UUID?

    init(geocodingService: GeocodingServiceProtocol) {
        self.geocodingService = geocodingService
    }

    func searchCities() async {
        // A cancelled task must not invalidate a newer search.
        guard !Task.isCancelled else { return }

        let requestID = UUID()
        activeRequestID = requestID
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 2 else {
            state = .idle
            return
        }

        state = .loading

        do {
            let cities = try await geocodingService.searchCities(query: query)
            // Some service implementations can return even after cancellation.
            try Task.checkCancellation()
            guard activeRequestID == requestID else { return }
            state = cities.isEmpty ? .empty : .loaded(cities)
        } catch {
            guard activeRequestID == requestID else { return }
            if Task.isCancelled || error is CancellationError ||
                (error as? URLError)?.code == .cancelled {
                state = .idle
                return
            }
            state = .error(error.localizedDescription)
        }
    }
}
