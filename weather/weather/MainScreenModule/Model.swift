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
    var relay = PublishRelay<[SimpleWeatherForecast]>()
    var relayCity = PublishRelay<String>()
    private let apiKey = "SXPHETs2IYVLCKnIs7MlKSYiRB9dzpTg"
    private var simpleForecast : [SimpleWeatherForecast] = []
    
    func requestByCoordinates(latitude: Double, longitude: Double){
        
        networkService.relayCity.subscribe { event in
            self.relayCity.accept(event.element! ?? "Ошибка")
        }.disposed(by: disposeBag)
        
        networkService.keyRelay
            .subscribe(onNext: { [weak self] cityKey in
                guard let key = cityKey else {
                    print("Ошибка: cityKey является nil")
                    self?.relayCity.accept("Геопозиция не распознана")
                    return
                }
                self?.getData(cityKey: key)
            }, onError: { error in
                print("Произошла ошибка: \(error)")
                self.relayCity.accept("Данные о погоде не найдены")
            })
            .disposed(by: disposeBag)
        
        networkService.requestByCoordinates(latitude: latitude, longitude: longitude, apiKey: apiKey)
    }
    
    func fetchWeather(text: String) {
        
        networkService.relayCity.subscribe { event in
            self.relayCity.accept(event.element! ?? "Ошибка")
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
                self.relayCity.accept("Произошла ошибка")
            })
            .disposed(by: disposeBag)

        networkService.fetchCityKey(city: text, apiKey: apiKey)
        
    }
    
    
    func getData (cityKey: String){
        
        networkService.relay
            .subscribe(onNext: { [weak self] forecast in
                guard let self = self else { return }
                let simpleForecast = processForecast(forecast)
                self.simpleForecast = simpleForecast
                self.relay.accept(simpleForecast)
            }, onError: { error in
                print("Произошла ошибка: \(error)")
                self.relayCity.accept("Произошла ошибка")
            })
            .disposed(by: disposeBag)
        
        self.networkService.fetchWeatherForecast(cityKey: cityKey, apiKey: self.apiKey)
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
