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
            ProgressView("Loading 7-day forecast…")
        case .loaded(let days):
            List {
                Section {
                    Text("Activities ranked by weather suitability. Surfing scores use weather only; they do not confirm surf spots or wave conditions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(days) { day in
                    Section(day.date) {
                        ForEach(Array(day.activities.enumerated()), id: \.element.id) { index, result in
                            HStack {
                                Text("\(index + 1). \(result.activity.title)")
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(Int(result.score.score))/100")
                                        .monospacedDigit()
                                    Text(result.score.rating.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
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
