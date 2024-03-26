//
//  NetworkService.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay

protocol NetworkServiceProtocol {
    var relay: PublishRelay<WeatherForecast> { get }
    var keyRelay: PublishRelay<String?> { get }
    var relayCity: PublishRelay<String?> { get }
    func fetchCityKey(city: String, apiKey: String)
    func fetchWeatherForecast(cityKey: String, apiKey: String)
    func requestByCoordinates(latitude: Double, longitude: Double, apiKey: String)
}

final class NetworkService: NetworkServiceProtocol {
    
    var relay = PublishRelay<WeatherForecast>()
    var keyRelay = PublishRelay<String?>()
    var relayCity = PublishRelay<String?>()
    
    func requestByCoordinates(latitude: Double, longitude: Double, apiKey: String) {
        
        let urlString = "https://dataservice.accuweather.com//locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(latitude)%2C\(longitude)&language=ru-RU&details=false&toplevel=false"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let citySearchResult = try JSONDecoder().decode(CitySearchResultElement.self, from: data)
                let cityInfo = citySearchResult
                self.keyRelay.accept(cityInfo.key)
                if (cityInfo.localizedName != ""){
                    self.relayCity.accept(cityInfo.localizedName)
                }
                else{
                    self.relayCity.accept(cityInfo.englishName)
                }
            } catch let decodeError {
                print("Decoding error: \(decodeError)")
                return
            }
        }.resume()
    }
    
    func fetchCityKey(city: String, apiKey: String) {
        let urlString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=\(apiKey)&q=\(city)&language=ru-RU&details=false"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let citySearchResult = try JSONDecoder().decode(CitySearchResult.self, from: data)
                let cityInfo = citySearchResult.first
                self.keyRelay.accept(cityInfo?.key)
                self.relayCity.accept(cityInfo?.localizedName)
            } catch let decodeError {
                print("Decoding error: \(decodeError)")
                return
            }
        }.resume()
    }


    func fetchWeatherForecast(cityKey: String, apiKey: String) {
        
        let urlString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(cityKey)?apikey=\(apiKey)&language=ru-Ru&details=false&metric=true"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let weatherForecast = try JSONDecoder().decode(WeatherForecast.self, from: data)
                self.relay.accept(weatherForecast)
            } catch let decodeError {
                print("Decoding fetchWeatherForecast error: \(decodeError)")
                return
            }
        }.resume()
    }
}
