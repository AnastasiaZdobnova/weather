//
//  WeatherData.swift
//  weather
//
//  Created by Анастасия Здобнова on 25.03.2024.
//

import Foundation

struct WeatherForecast: Codable {
    let Headline: HeadlineInfo
    let DailyForecasts: [DailyForecast]
}

struct HeadlineInfo: Codable {
    let EffectiveDate: String
    let EffectiveEpochDate: Int
    let Severity: Int
    let Text: String
    let Category: String
    let EndDate: String?
    let EndEpochDate: Int?
    let MobileLink: String
    let Link: String
}


struct DailyForecast: Codable {
    let Date: String
    let EpochDate: Int
    let Temperature: TemperatureRange
    let Day: DayInfo
    let Night: NightInfo
    let Sources: [String]
    let MobileLink: String
    let Link: String
}

struct TemperatureRange: Codable {
    let Minimum: TemperatureValue
    let Maximum: TemperatureValue
}

struct TemperatureValue: Codable {
    let Value: Double
    let Unit: String
    let UnitType: Int
}

struct DayInfo: Codable {
    let Icon: Int
    let IconPhrase: String
    let HasPrecipitation: Bool
}

struct NightInfo: Codable {
    let Icon: Int
    let IconPhrase: String
    let HasPrecipitation: Bool
}
