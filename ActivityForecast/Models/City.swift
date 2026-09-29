//
//  City.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 28/09/26.
//

import SwiftUI

// app level
struct City: Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String?
    let region: String?
    let latitude: Double
	let longitude: Double
}

// for decoding from json
struct GeocodingResponseDTO: Decodable {
	let results: [CityDTO]?
}

struct CityDTO: Decodable {
	let id: Int
	let name: String
	let latitude: Double
	let longitude: Double
	let country: String?
	let admin1: String?
	
	func toDomain() -> City {
		City(
			id: id,
			name: name,
			country: country,
			region: admin1,
			latitude: latitude,
			longitude: longitude
		)
	}
}
