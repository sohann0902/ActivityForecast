//
//  ContentView.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import SwiftUI

struct ContentView: View {
	@State private var viewModel: CitySearchViewModel
	
	init(geocodingService: GeocodingServiceProtocol) {
		_viewModel = State(
			initialValue: CitySearchViewModel(
				geocodingService: geocodingService
			)
		)
	}
	
	var body: some View {
		@Bindable var viewModel = viewModel
		
		VStack {
			
			TextField("Search city", text: $viewModel.searchText)
				.padding()
				.background(.secondary.opacity(0.3))
				.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
				.padding()
				.textInputAutocapitalization(.words)
		
			
			searchResults
			
			Spacer()
		}
		.scrollDismissesKeyboard(.interactively)
		.task(id: viewModel.searchText) {
			
			let query = viewModel.searchText
				.trimmingCharacters(in: .whitespacesAndNewlines)
			
			if query.count < 2 {
				await viewModel.searchCities()
				return
			}
			
			try? await Task.sleep(for: .milliseconds(400))
			
			guard !Task.isCancelled else {
				return
			}
			
			await viewModel.searchCities()
		}
	}
	
	@ViewBuilder
	private var searchResults: some View {
		switch viewModel.state {
		case .idle:
			Text("Search for a city")

		case .loading:
			ProgressView()

		case .loaded(let cities):
			List(cities) { city in
				Button {
					viewModel.selectCity(city)
//					print(viewModel.selectedCity)
				} label: {
					VStack(alignment: .leading) {
						Text("\(city.name), \(city.region ?? ""), \(city.country ?? "")")
							.multilineTextAlignment(.leading)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					
				}
				
				.buttonStyle(.plain)
			}
			.scrollContentBackground(.hidden)
			.listStyle(.plain)

		case .empty:
			Text("No cities found")

		case .error(let message):
			Text(message)
		}
	}
}

#Preview {
	ContentView(geocodingService: GeocodingService())
}
