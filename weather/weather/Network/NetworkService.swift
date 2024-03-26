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
    func fetchCityKey(city: String, apiKey: String, completion: @escaping (CitySearchResultElement?, Error?) -> Void)
    func fetchWeatherForecast(cityKey: String, apiKey: String, completion: @escaping (WeatherForecast?, Error?) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    var relay = PublishRelay<WeatherForecast>()
    
    func fetchCityKey(city: String, apiKey: String, completion: @escaping (CitySearchResultElement?, Error?) -> Void) {
        let urlString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=4XroeXveI0SqedpgYvAnksxD27bwpRJI&q=\(city)&language=ru-RU&details=false"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                completion(nil, error)
                return
            }
            
            do {
                let citySearchResult = try JSONDecoder().decode(CitySearchResult.self, from: data)
                let cityInfo = citySearchResult.first
                print(cityInfo?.key)
                completion(cityInfo, nil)
            } catch let decodeError {
                print("Decoding error: \(decodeError)")
                completion(nil, decodeError)
            }
        }.resume()
    }


    func fetchWeatherForecast(cityKey: String, apiKey: String, completion: @escaping (WeatherForecast?, Error?) -> Void) {
        
        let urlString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(cityKey)?apikey=\(apiKey)&language=ru-Ru&details=false&metric=true"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                completion(nil, error)
                return
            }
            
            do {
                let weatherForecast = try JSONDecoder().decode(WeatherForecast.self, from: data)
                print(weatherForecast)
                completion(weatherForecast, nil)
            } catch let decodeError {
                print("Decoding fetchWeatherForecast error: \(decodeError)")
                completion(nil, decodeError)
            }
        }.resume()
    }
}
