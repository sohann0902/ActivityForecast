//
//  WeatherForecast.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


import SwiftUI

struct WeatherForecast {
    let elevation: Double
    let timezone: String
    let days: [DailyWeather]
}

struct DailyWeather: Identifiable {

    var id: String { date }

    let date: String

    let weatherCode: Int

    let temperatureMax: Double
    let temperatureMin: Double

    let apparentTemperatureMax: Double
    let apparentTemperatureMin: Double

    let snowfallSum: Double
    let snowDepth: Double

    let precipitationSum: Double
    let precipitationHours: Double
    let precipitationProbabilityMax: Double

    let windSpeedMax: Double
    let windGustsMax: Double
    let windDirectionDominant: Double

    let uvIndexMax: Double

    let sunshineDuration: Double
    let daylightDuration: Double
}

struct ForecastResponseDTO: Decodable {

	let elevation: Double
	let timezone: String

	let daily: DailyWeatherDTO
	let hourly: HourlyWeatherDTO
}

struct DailyWeatherDTO: Decodable {

	let time: [String]

	let weatherCode: [Int]

	let temperatureMax: [Double]
	let temperatureMin: [Double]

	let apparentTemperatureMax: [Double]
	let apparentTemperatureMin: [Double]

	let snowfallSum: [Double]

	let precipitationSum: [Double]
	let precipitationHours: [Double]
	let precipitationProbabilityMax: [Double]

	let windSpeedMax: [Double]
	let windGustsMax: [Double]
	let windDirectionDominant: [Double]

	let uvIndexMax: [Double]

	let sunshineDuration: [Double]
	let daylightDuration: [Double]

	enum CodingKeys: String, CodingKey {
		case time

		case weatherCode = "weather_code"

		case temperatureMax = "temperature_2m_max"
		case temperatureMin = "temperature_2m_min"

		case apparentTemperatureMax = "apparent_temperature_max"
		case apparentTemperatureMin = "apparent_temperature_min"

		case snowfallSum = "snowfall_sum"

		case precipitationSum = "precipitation_sum"
		case precipitationHours = "precipitation_hours"
		case precipitationProbabilityMax = "precipitation_probability_max"

		case windSpeedMax = "wind_speed_10m_max"
		case windGustsMax = "wind_gusts_10m_max"
		case windDirectionDominant = "wind_direction_10m_dominant"

		case uvIndexMax = "uv_index_max"

		case sunshineDuration = "sunshine_duration"
		case daylightDuration = "daylight_duration"
	}
}

struct HourlyWeatherDTO: Decodable {

	let time: [String]
	let snowDepth: [Double]

	enum CodingKeys: String, CodingKey {
		case time
		case snowDepth = "snow_depth"
	}
}

extension ForecastResponseDTO {

	func toDomain() -> WeatherForecast {

		let snowDepthByDate =
			hourly.averageSnowDepthByDate()

		let days = daily.time.indices.map { index in

			let date = daily.time[index]

			return DailyWeather(
				date: date,

				weatherCode:
					daily.weatherCode[index],

				temperatureMax:
					daily.temperatureMax[index],

				temperatureMin:
					daily.temperatureMin[index],

				apparentTemperatureMax:
					daily.apparentTemperatureMax[index],

				apparentTemperatureMin:
					daily.apparentTemperatureMin[index],

				snowfallSum:
					daily.snowfallSum[index],

				snowDepth:
					snowDepthByDate[date] ?? 0,

				precipitationSum:
					daily.precipitationSum[index],

				precipitationHours:
					daily.precipitationHours[index],

				precipitationProbabilityMax:
					daily.precipitationProbabilityMax[index],

				windSpeedMax:
					daily.windSpeedMax[index],

				windGustsMax:
					daily.windGustsMax[index],

				windDirectionDominant:
					daily.windDirectionDominant[index],

				uvIndexMax:
					daily.uvIndexMax[index],

				sunshineDuration:
					daily.sunshineDuration[index],

				daylightDuration:
					daily.daylightDuration[index]
			)
		}

		return WeatherForecast(
			elevation: elevation,
			timezone: timezone,
			days: days
		)
	}
}

extension HourlyWeatherDTO {

	func averageSnowDepthByDate() -> [String: Double] {

		var grouped: [String: [Double]] = [:]

		for (time, depth) in zip(time, snowDepth) {

			let date = String(
				time.prefix(10)
			)

			grouped[date, default: []]
				.append(depth)
		}

		return grouped.mapValues { values in

			guard !values.isEmpty else {
				return 0
			}

			return values.reduce(0, +)
				/ Double(values.count)
		}
	}
}
