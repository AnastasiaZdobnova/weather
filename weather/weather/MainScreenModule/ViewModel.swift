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
    
    func buttonPressed(text: String) {
        model.relay.subscribe { event in
            self.relay.accept(event.element!)
        }.disposed(by: disposeBag)
        
        model.fetchWeather(text: text)
    }
    
}
