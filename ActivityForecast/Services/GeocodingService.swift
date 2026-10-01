//
//  GeocodingService.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import Foundation

protocol GeocodingServiceProtocol {
    func searchCities(query: String) async throws -> [City]
}

final class GeocodingService: GeocodingServiceProtocol {

	private let baseURL =
		"https://geocoding-api.open-meteo.com/v1/search"

	private let session: URLSession

	init(session: URLSession = .shared) {
		self.session = session
	}

	func searchCities(query: String) async throws -> [City] {
		var components = URLComponents(string: baseURL)

		components?.queryItems = [
			URLQueryItem(name: "name", value: query)
		]

		guard let url = components?.url else {
			throw URLError(.badURL)
		}

		let (data, response) = try await session.data(from: url)

		guard let httpResponse = response as? HTTPURLResponse,
			  httpResponse.statusCode == 200 else {
			throw URLError(.badServerResponse)
		}

		let decodedResponse = try JSONDecoder().decode(
			GeocodingResponseDTO.self,
			from: data
		)

		return decodedResponse.results?.map {
			$0.toDomain()
		} ?? []
	}
}
