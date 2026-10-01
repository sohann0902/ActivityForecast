import SwiftUI

struct ForecastView: View {
    let city: City
    @State private var viewModel: ForecastViewModel

	init(city: City, weatherService: WeatherServiceProtocol, scoringEngine: ActivityScoringEngineProtocol) {
        self.city = city
		_viewModel = State(initialValue: ForecastViewModel(weatherService: weatherService, scoringEngine: scoringEngine))
    }

    var body: some View {
        content
            .navigationTitle(city.name)
            .task(id: city.id) {
                await viewModel.fetchForecast(for: city)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let days):
            List {
                Section {
					Text("Activity rankings are based on weather suitability only and assume the selected location offers access to activities such as skiing and surfing.")
                        .font(.caption)
						.italic()
                        .foregroundStyle(.secondary)
						.listRowBackground(Color.clear)
                }
                ForEach(days) { day in
                    Section(day.date) {
                        ForEach(day.activities) { result in
							
							RankingCell(result: result)
                        }
                    }
                }
            }
			.scrollContentBackground(.hidden)
			
        case .error(let message):
            ContentUnavailableView {
                Label("Unable to load forecast", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") {
                    Task { await viewModel.fetchForecast(for: city) }
                }
            }
        }
    }
}


struct RankingCell: View {
	let result: ActivityResult
	
	var body: some View {
		HStack {
			Image(result.activity.imageName)
				.resizable()
				.scaledToFit()
				.frame(width: 40)
				.padding(4)
				.background(result.activity.background)
				.clipShape(RoundedRectangle(cornerRadius: 5))
			
			
			VStack(alignment: .leading) {
				Text(result.activity.title)
					.font(.headline)
				ProgressView(value: result.score, total: 100)
					.frame(width: 60)
					.tint(progressBarColor(score: result.score))
			}
			
			Spacer()
			
			Text("\(Int(result.score))")
				.font(.headline)
		}
	}
	
	private func progressBarColor(score: Double) -> Color {
		if score <= 30 {
			return .red
		} else if score <= 60 {
			return .yellow
		} else if score <= 80 {
			return .green.opacity(0.5)
		} else {
			return .green
		}
	}
}
