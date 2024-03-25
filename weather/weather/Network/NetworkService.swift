//
//  NetworkService.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class NetworkService {
    
    var relay = PublishRelay<WeatherForecast>()
    
    func fetchCityKey(city: String, apiKey: String, completion: @escaping (CitySearchResultElement?, Error?) -> Void) {
        let urlString = "https://dataservice.accuweather.com/locations/v1/cities/search?apikey=4XroeXveI0SqedpgYvAnksxD27bwpRJI&q=%D0%BC%D0%BE%D1%81%D0%BA%D0%B2%D0%B0&language=ru-RU&details=false"
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



    
    func fetchWeatherForecast(cityKey: String, apiKey: String, completion: @escaping (WeatherForecast?) -> Void) {
        let urlString = "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(cityKey)?apikey=\(apiKey)&language=ru-RU&details=false&metric=true"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            
            let weatherForecast = try? JSONDecoder().decode(WeatherForecast.self, from: data)
            completion(weatherForecast)
        }.resume()
    }
    
}
