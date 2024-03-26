//
//  Model.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay

protocol ModelProtocol {
    var networkService : NetworkServiceProtocol { get }
    var apiKey : String { get }
    var simpleForecast : [SimpleWeatherForecast] { get }
    var relay : PublishRelay<[SimpleWeatherForecast]> { get }
    var relayCity : PublishRelay<String> { get }
    
    func requestByCoordinates(latitude: Double, longitude: Double)
    func fetchWeather(text: String)
    
}

class WeatherModel: ModelProtocol {
    var networkService : NetworkServiceProtocol = NetworkService()
    private let disposeBag = DisposeBag()
    var relay = PublishRelay<[SimpleWeatherForecast]>()
    var relayCity = PublishRelay<String>()
    internal let apiKey = "wIVHOrzDnKxH87ZWmAiSbNmy9o6E02kx"
    internal var simpleForecast : [SimpleWeatherForecast] = []
    
    func requestByCoordinates(latitude: Double, longitude: Double) {
        
        networkService.relayCity.subscribe { event in
            self.relayCity.accept(event.element! ?? "Ошибка")
            self.relay.accept([])
        }.disposed(by: disposeBag)
        
        networkService.keyRelay
            .subscribe(onNext: { [weak self] cityKey in
                guard let key = cityKey else {
                    print("Ошибка: cityKey является nil")
                    self?.relayCity.accept("Ошибка")
                    self?.relay.accept([])
                    return
                }
                self?.getData(cityKey: key)
            }, onError: { error in
                print("Произошла ошибка: \(error)")
                self.relayCity.accept("Ошибка")
                self.relay.accept([])
            })
            .disposed(by: disposeBag)
        
        networkService.requestByCoordinates(latitude: latitude, longitude: longitude, apiKey: apiKey)
    }
    
    func fetchWeather(text: String) {
        
        networkService.relayCity.subscribe { event in
            self.relayCity.accept(event.element! ?? "Ошибка")
            self.relay.accept([])
        }.disposed(by: disposeBag)
        
        networkService.keyRelay
            .subscribe(onNext: { [weak self] cityKey in
                guard let key = cityKey else {
                    print("Ошибка: cityKey является nil")
                    self?.relayCity.accept("Город не найден")
                    return
                }
                self?.getData(cityKey: key)
            }, onError: { error in
                print("Произошла ошибка: \(error)")
                self.relayCity.accept("Ошибка")
                self.relay.accept([])
            })
            .disposed(by: disposeBag)

        networkService.fetchCityKey(city: text, apiKey: apiKey)
        
    }
    
    
    private func getData (cityKey: String) {
        
        networkService.relay
            .subscribe(onNext: { [weak self] forecast in
                guard let self = self else { return }
                let simpleForecast = processForecast(forecast)
                self.simpleForecast = simpleForecast
                self.relay.accept(simpleForecast)
            }, onError: { error in
                print("Произошла ошибка: \(error)")
                self.relayCity.accept("Ошибка")
                self.relay.accept([])
            })
            .disposed(by: disposeBag)
        
        self.networkService.fetchWeatherForecast(cityKey: cityKey, apiKey: self.apiKey)
    }
    
    private func processForecast(_ forecast: WeatherForecast) -> [SimpleWeatherForecast] {
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
