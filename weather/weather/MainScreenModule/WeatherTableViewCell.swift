//
//  WeatherTableViewCell.swift
//  weather
//
//  Created by Анастасия Здобнова on 26.03.2024.
//

import Foundation
import SnapKit

class WeatherTableViewCell: UITableViewCell {
    private let dateLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let dayPhraseLabel = UILabel()
    private let nightPhraseLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(dateLabel)
        addSubview(temperatureLabel)
        addSubview(dayPhraseLabel)
        addSubview(nightPhraseLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
        }
        
        dayPhraseLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
        }
        
        nightPhraseLabel.snp.makeConstraints { make in
            make.top.equalTo(dayPhraseLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configure(with forecast: SimpleWeatherForecast) {
        dateLabel.text = formatDate(forecast.date)
        temperatureLabel.text = "Температура: от \(forecast.minimumTemperature)°C до \(forecast.maximumTemperature)°C"
        dayPhraseLabel.text = "Днем: \(forecast.dayIconPhrase)"
        nightPhraseLabel.text = "Ночью: \(forecast.nightIconPhrase)"
    }
    
    override func prepareForReuse() {
        dateLabel.text = nil
        temperatureLabel.text = nil
        dayPhraseLabel.text = nil
        nightPhraseLabel.text = nil
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: date)
        }
        return dateString
    }
}
