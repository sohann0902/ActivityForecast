//
//  TestsHelper.swift
//  ActivityForecast
//
//  Created by Sohan Maurya on 30/09/26.
//

@testable import ActivityForecast

func makeWeather(
	date: String = "2026-09-30",
	weatherCode: Int = 0,
	temperatureMax: Double = 22,
	temperatureMin: Double = 16,
	apparentTemperatureMax: Double = 22,
	apparentTemperatureMin: Double = 16,
	snowfallSum: Double = 0,
	snowDepth: Double = 0,
	precipitationSum: Double = 0,
	precipitationHours: Double = 0,
	precipitationProbabilityMax: Double = 0,
	windSpeedMax: Double = 10,
	windGustsMax: Double = 15,
	windDirectionDominant: Double = 0,
	uvIndexMax: Double = 5,
	sunshineDuration: Double = 28_800,
	daylightDuration: Double = 43_200
) -> DailyWeather {
	
	DailyWeather(
		date: date,
		weatherCode: weatherCode,
		temperatureMax: temperatureMax,
		temperatureMin: temperatureMin,
		apparentTemperatureMax: apparentTemperatureMax,
		apparentTemperatureMin: apparentTemperatureMin,
		snowfallSum: snowfallSum,
		snowDepth: snowDepth,
		precipitationSum: precipitationSum,
		precipitationHours: precipitationHours,
		precipitationProbabilityMax: precipitationProbabilityMax,
		windSpeedMax: windSpeedMax,
		windGustsMax: windGustsMax,
		windDirectionDominant: windDirectionDominant,
		uvIndexMax: uvIndexMax,
		sunshineDuration: sunshineDuration,
		daylightDuration: daylightDuration
	)
}

func makeCity() -> City {
	
	City(id: 1, name: "Mumbai", country: "India", region: "Maharashtra", latitude: 19.076, longitude: 72.8777)
}


func makeDay(
	date: String = "2026-10-01",
	weatherCode: Int = 0,
	temperatureMax: Double = 20,
	temperatureMin: Double = 10,
	apparentTemperatureMax: Double = 20,
	apparentTemperatureMin: Double = 10,
	snowfallSum: Double = 0,
	snowDepth: Double = 0,
	precipitationSum: Double = 0,
	precipitationHours: Double = 0,
	precipitationProbabilityMax: Double = 0,
	windSpeedMax: Double = 10,
	windGustsMax: Double = 15,
	windDirectionDominant: Double = 180,
	uvIndexMax: Double = 3,
	sunshineDuration: Double = 20_000,
	daylightDuration: Double = 40_000
) -> DailyWeather {
	DailyWeather(
		date: date,
		weatherCode: weatherCode,
		temperatureMax: temperatureMax,
		temperatureMin: temperatureMin,
		apparentTemperatureMax: apparentTemperatureMax,
		apparentTemperatureMin: apparentTemperatureMin,
		snowfallSum: snowfallSum,
		snowDepth: snowDepth,
		precipitationSum: precipitationSum,
		precipitationHours: precipitationHours,
		precipitationProbabilityMax: precipitationProbabilityMax,
		windSpeedMax: windSpeedMax,
		windGustsMax: windGustsMax,
		windDirectionDominant: windDirectionDominant,
		uvIndexMax: uvIndexMax,
		sunshineDuration: sunshineDuration,
		daylightDuration: daylightDuration
	)
}
