import XCTest
@testable import ActivityForecast

@MainActor
final class ForecastMappingTests: XCTestCase {
    func testSnowDepthConvertsFromAPIMetresToDomainCentimetres() throws {
        let day = try mappedDay(snowDepthMetres: 1.2)
        XCTAssertEqual(day.snowDepth, 120, accuracy: 0.0001)
        XCTAssertGreaterThan(SkiScorer.score(for: day), 0)
    }

    func testMappedSnowDepthRespectsThirtyCentimetreSkiingMinimum() throws {
        let belowMinimum = try mappedDay(snowDepthMetres: 0.29)
        let atMinimum = try mappedDay(snowDepthMetres: 0.30)
        XCTAssertEqual(SkiScorer.score(for: belowMinimum), 0)
        XCTAssertGreaterThan(SkiScorer.score(for: atMinimum), 0)
    }

    private func mappedDay(snowDepthMetres: Double) throws -> DailyWeather {
        let date = "2026-10-01"
        let daily: [String: Any] = [
            "time": [date], "weather_code": [0],
            "temperature_2m_max": [-3], "temperature_2m_min": [-8],
            "apparent_temperature_max": [-3], "apparent_temperature_min": [-8],
            "snowfall_sum": [0], "precipitation_sum": [0],
            "precipitation_hours": [0], "precipitation_probability_max": [0],
            "wind_speed_10m_max": [10], "wind_gusts_10m_max": [15],
            "wind_direction_10m_dominant": [0], "uv_index_max": [3],
            "sunshine_duration": [20000], "daylight_duration": [40000]
        ]
        let response: [String: Any] = [
            "elevation": 1500, "timezone": "Europe/Zurich", "daily": daily,
            "hourly": [
                "time": (0..<24).map { String(format: "%@T%02d:00", date, $0) },
                "snow_depth": Array(repeating: snowDepthMetres, count: 24)
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: response)
        let dto = try JSONDecoder().decode(ForecastResponseDTO.self, from: data)
        return try XCTUnwrap(dto.toDomain().days.first)
    }
}
