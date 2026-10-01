//
//  WeatherService.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//

import Foundation

protocol WeatherServiceProtocol {
	func fetchForecast(for city: City) async throws -> WeatherForecast
}

final class WeatherService: WeatherServiceProtocol {

    private let baseURL =
        "https://api.open-meteo.com/v1/forecast"

    func fetchForecast(
        for city: City
    ) async throws -> WeatherForecast {

        var components = URLComponents(
            string: baseURL
        )

        let dailyVariables = [
            "weather_code",
            "apparent_temperature_max",
            "apparent_temperature_min",
            "snowfall_sum",
            "precipitation_sum",
            "precipitation_hours",
            "wind_speed_10m_max",
            "wind_gusts_10m_max",
            "uv_index_max",
            "sunshine_duration",
            "daylight_duration"
        ]

        components?.queryItems = [

            URLQueryItem(
                name: "latitude",
                value: String(city.latitude)
            ),

            URLQueryItem(
                name: "longitude",
                value: String(city.longitude)
            ),

            URLQueryItem(
                name: "daily",
                value: dailyVariables.joined(separator: ",")
            ),

            URLQueryItem(
                name: "hourly",
                value: "snow_depth"
            ),

            URLQueryItem(
                name: "timezone",
                value: "auto"
            ),

            URLQueryItem(
                name: "forecast_days",
                value: "7"
            ),

            URLQueryItem(
                name: "temperature_unit",
                value: "celsius"
            ),

            URLQueryItem(
                name: "wind_speed_unit",
                value: "kmh"
            ),

            URLQueryItem(
                name: "precipitation_unit",
                value: "mm"
            )
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let dto = try JSONDecoder().decode(
            ForecastResponseDTO.self,
            from: data
        )

        return dto.toDomain()
    }
}
