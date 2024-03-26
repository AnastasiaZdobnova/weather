//
//  LayoutConstants.swift
//  weather
//
//  Created by Анастасия Здобнова on 26.03.2024.
//

import Foundation

struct LayoutConstants {
    // Общие отступы
    static let standardMargin: CGFloat = 16.0

    // Отступы для конкретного экрана или элемента
    struct WeatherScreen {
        static let textFieldHeight: CGFloat = 40.0
        static let textFieldWidth:  CGFloat = 200.0
        static let buttonWidth: CGFloat = 40.0
        static let buttonHeight: CGFloat = 40.0
    }

    // Другие экраны и элементы могут быть определены здесь аналогично
}
