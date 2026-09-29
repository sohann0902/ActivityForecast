//
//  CitySearchViewModel.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import SwiftUI

@Observable
class CitySearchViewModel {
	var searchText = "Mum"
	var state : CitySearchState = .idle
	
	private let geocodingService: GeocodingServiceProtocol
	
	init(geocodingService: GeocodingServiceProtocol) {
		self.geocodingService = geocodingService
	}
	
	func searchCities() async {
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard query.count >= 2 else {
			state = .idle
			return
		}
		
		state = .loading
		
		do {
			let cities = try await geocodingService.searchCities(query: query)
			
			if cities.isEmpty {
				state = .empty
			} else {
				state = .loaded(cities)
			}
			
		} catch is CancellationError {
			// user probably kept typing
			return
			
		} catch {
			state = .error(error.localizedDescription)
		}
	}
	
}
