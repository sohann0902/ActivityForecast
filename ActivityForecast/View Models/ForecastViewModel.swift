import Foundation
import Observation

@MainActor
@Observable
final class ForecastViewModel {
    private(set) var state: ForecastState = .idle
    private let weatherService: WeatherServiceProtocol
    private let scoringEngine: ActivityScoringEngineProtocol

    init(
        weatherService: WeatherServiceProtocol,
        scoringEngine: ActivityScoringEngineProtocol
    ) {
        self.weatherService = weatherService
        self.scoringEngine = scoringEngine
    }

    func fetchForecast(for city: City) async {
        state = .loading
        do {
            let forecast = try await weatherService.fetchForecast(for: city)
            try Task.checkCancellation()
            state = .loaded(scoringEngine.score(forecast: forecast))
        } catch {
            if Task.isCancelled || error is CancellationError {
                state = .idle
                return
            }
            state = .error(error.localizedDescription)
        }
    }
}
