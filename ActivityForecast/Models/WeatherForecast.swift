//
//  WeatherForecast.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 29/09/26.
//


struct WeatherForecast: Equatable {
    let days: [DailyWeather]
}

struct DailyWeather: Identifiable, Equatable {

    var id: String { date }

    let date: String

    let weatherCode: Int

    let apparentTemperatureMax: Double
    let apparentTemperatureMin: Double

    let snowfallSum: Double
    /// Average snow depth during skiing hours, in centimetres.
    let snowDepth: Double

    let precipitationSum: Double
    let precipitationHours: Double

    let windSpeedMax: Double
    let windGustsMax: Double

    let uvIndexMax: Double

    let sunshineDuration: Double
    let daylightDuration: Double
}

struct ForecastResponseDTO: Decodable {

	let daily: DailyWeatherDTO
	let hourly: HourlyWeatherDTO
}

struct DailyWeatherDTO: Decodable {

	let time: [String]

	let weatherCode: [Int]

	let apparentTemperatureMax: [Double]
	let apparentTemperatureMin: [Double]

	let snowfallSum: [Double]

	let precipitationSum: [Double]
	let precipitationHours: [Double]

	let windSpeedMax: [Double]
	let windGustsMax: [Double]

	let uvIndexMax: [Double]

	let sunshineDuration: [Double]
	let daylightDuration: [Double]

	enum CodingKeys: String, CodingKey {
		case time

		case weatherCode = "weather_code"

		case apparentTemperatureMax = "apparent_temperature_max"
		case apparentTemperatureMin = "apparent_temperature_min"

		case snowfallSum = "snowfall_sum"

		case precipitationSum = "precipitation_sum"
		case precipitationHours = "precipitation_hours"

		case windSpeedMax = "wind_speed_10m_max"
		case windGustsMax = "wind_gusts_10m_max"

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
			hourly.averageSnowDepthCentimetresByDate()

		let days = daily.time.indices.map { index in

			let date = daily.time[index]

			return DailyWeather(
				date: date,

				weatherCode:
					daily.weatherCode[index],

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

				windSpeedMax:
					daily.windSpeedMax[index],

				windGustsMax:
					daily.windGustsMax[index],

				uvIndexMax:
					daily.uvIndexMax[index],

				sunshineDuration:
					daily.sunshineDuration[index],

				daylightDuration:
					daily.daylightDuration[index]
			)
		}

		return WeatherForecast(
			days: days
		)
	}
}

extension HourlyWeatherDTO {

	func averageSnowDepthCentimetresByDate() -> [String: Double] {

		let hoursPerDay = 24
		let skiingHours = 8...17
		
		var result: [String: Double] = [:]
		
		for startIndex in stride(from: 0, to: snowDepth.count, by: hoursPerDay) {
			
			let endIndex = min(startIndex + hoursPerDay, snowDepth.count)
			
			guard startIndex < time.count else {
				continue
			}
			
			let date = String(time[startIndex].prefix(10))
			
			let dayDepths = Array(snowDepth[startIndex..<endIndex])
			
			let skiingDepths = skiingHours.compactMap { hour -> Double? in
				guard hour < dayDepths.count else {
					return nil
				}
				
				return dayDepths[hour] * 100 // API metres -> domain centimetres
			}
			
			guard !skiingDepths.isEmpty else {
				result[date] = 0
				continue
			}
			
			let average =
			skiingDepths.reduce(0, +) /
			Double(skiingDepths.count)
			
			result[date] = average
		}
		
		return result
	}
}
