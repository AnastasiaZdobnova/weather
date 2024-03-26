//
//  ViewModel.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class WeatherViewModel {
    
    private let model = WeatherModel()
    let disposeBag = DisposeBag()
    var relay = PublishRelay<[SimpleWeatherForecast]>()
    var relayCity = PublishRelay<String>()
    
    func buttonPressed(text: String) {
        
        model.relayCity.subscribe { event in
            self.relayCity.accept(event.element ?? "Ошибка")
        }.disposed(by: disposeBag)
        
        model.relay.subscribe { event in
            self.relay.accept(event.element!)
        }.disposed(by: disposeBag)
        
        model.fetchWeather(text: text)
    }
    
    func requestByCoordinates(latitude: Double, longitude: Double){
        
        model.relayCity.subscribe { event in
            self.relayCity.accept(event.element ?? "Ошибка")
        }.disposed(by: disposeBag)
        
        model.relay.subscribe { event in
            self.relay.accept(event.element!)
        }.disposed(by: disposeBag)
        
        model.requestByCoordinates(latitude: latitude, longitude: longitude)
    }
    
}
