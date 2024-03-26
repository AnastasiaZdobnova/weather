//
//  Model.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay

struct SimpleWeatherForecast {
    let date: String
    let minimumTemperature: Double
    let maximumTemperature: Double
    let dayIconPhrase: String
    let nightIconPhrase: String
}

class WeatherModel {
    private let networkService = NetworkService()
    private let disposeBag = DisposeBag()
    var relay = PublishRelay<[SimpleWeatherForecast]>()
    private let apiKey = "4XroeXveI0SqedpgYvAnksxD27bwpRJI"
    private var simpleForecast : [SimpleWeatherForecast] = []
    
    func fetchWeather(text: String) {
        
        networkService.fetchCityKey(city: text, apiKey: apiKey) { [weak self] (citySearchResult, error) in
            if let error = error {
                print("Ошибка при получении ключа города: \(error)")
                return
            }
            guard let self = self, let cityKey = citySearchResult?.key else { return }
            self.networkService.fetchWeatherForecast(cityKey: cityKey, apiKey: self.apiKey) { [weak self] (weatherForecast, error) in
                if let error = error {
                    print("Ошибка при получении ключа города: \(error)")
                    return
                }
                else{
                    guard let forecast = weatherForecast else { return }
                    self?.simpleForecast = (self?.processForecast(forecast))!
                    self?.relay.accept(self?.simpleForecast ?? [])
                
                }
            }
        }
    }
    
    func processForecast(_ forecast: WeatherForecast) -> [SimpleWeatherForecast] {
        return forecast.DailyForecasts.map { dailyForecast in
            let date = dailyForecast.Date
            let minTemp = dailyForecast.Temperature.Minimum.Value
            let maxTemp = dailyForecast.Temperature.Maximum.Value
            let dayPhrase = dailyForecast.Day.IconPhrase
            let nightPhrase = dailyForecast.Night.IconPhrase
            
            return SimpleWeatherForecast(
                date: date,
                minimumTemperature: minTemp,
                maximumTemperature: maxTemp,
                dayIconPhrase: dayPhrase,
                nightIconPhrase: nightPhrase
            )
        }
    }
}
