//
//  ContentView.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import SwiftUI

struct ContentView: View {
	@State private var viewModel: CitySearchViewModel
	@FocusState var isFocused
	private let weatherService: WeatherServiceProtocol
	private let activityScoringEngine: ActivityScoringEngineProtocol
	
	@State private var searchTask: Task<Void, Never>?
	
	init(
		geocodingService: GeocodingServiceProtocol,
		weatherService: WeatherServiceProtocol,
		activityScoringEngine: ActivityScoringEngineProtocol
	) {
		self.weatherService = weatherService
		self.activityScoringEngine = activityScoringEngine
		
		_viewModel = State(
			initialValue: CitySearchViewModel(
				geocodingService: geocodingService
			)
		)
	}
	
	var body: some View {
		@Bindable var viewModel = viewModel
		
		NavigationStack {
			VStack {
				
				Text("Search for a city")
					.font(.title)
					.fontWeight(.black)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal)
					
				
				TextField("Eg. New York", text: $viewModel.searchText)
					.padding()
					.background(.secondary.opacity(0.3))
					.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
					.padding(.horizontal)
					.textInputAutocapitalization(.words)
					.focused($isFocused)
				
				searchResults
				
				Spacer()
			}
			.scrollDismissesKeyboard(.interactively)
			.onChange(of: viewModel.searchText) { _, newValue in

				searchTask?.cancel()

				searchTask = Task {

					let query = newValue
						.trimmingCharacters(in: .whitespacesAndNewlines)

					if query.count < 2 {
						await viewModel.searchCities()
						return
					}

					try? await Task.sleep(
						for: .milliseconds(400)
					)

					guard !Task.isCancelled else {
						return
					}

					await viewModel.searchCities()
				}
			}
			.onAppear {
				isFocused = true
			}
		}
	}
	
	@ViewBuilder
	private var searchResults: some View {
		switch viewModel.state {
		case .idle:
			EmptyView()
			
		case .loading:
			ProgressView()
			
		case .loaded(let cities):
			List(cities) { city in
				
				NavigationLink {
					ForecastView(
							city: city,
							weatherService: weatherService, scoringEngine: activityScoringEngine
						)
				} label: {
					VStack(alignment: .leading) {
						Text("\(city.name), \(city.region ?? ""), \(city.country ?? "")")
							.multilineTextAlignment(.leading)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
				}
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
	ContentView(geocodingService: GeocodingService(), weatherService: WeatherService(), activityScoringEngine: ActivityScoringEngine())
}
