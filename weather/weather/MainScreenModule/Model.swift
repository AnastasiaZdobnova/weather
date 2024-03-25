//
//  Model.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay


class WeatherModel {
    private let networkService = NetworkService()
    private let disposeBag = DisposeBag()
    var relay = PublishRelay<String>()
    private let apiKey = "fc18430ba19404244839d857488daa4a"
    private let city = "Москва"
    

    func fetchWeather() {
        networkService.fetchCityKey(city: city, apiKey: apiKey) { [weak self] (citySearchResult, error) in
            if let error = error {
                print("Ошибка при получении ключа города: \(error)")
                return
            }
            guard let self = self, let cityKey = citySearchResult?.key else { return }
            self.networkService.fetchWeatherForecast(cityKey: cityKey, apiKey: self.apiKey) { weatherForecast in
                guard let forecast = weatherForecast else { return }
                self.relay.accept("Получен прогноз погоды для \(self.city)")
                // Используйте данные прогноза по своему усмотрению
            }
        }

    }
}
