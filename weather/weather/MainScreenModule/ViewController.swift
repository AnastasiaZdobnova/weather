//
//  ViewController.swift
//  weather
//
//  Created by Анастасия Здобнова on 24.03.2024.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var viewModel = WeatherViewModel()
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = UIImage(systemName: "location.square") {
            button.setImage(image, for: .normal)
        }
        return button
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите город"
        return textField
    }()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        subscribes()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Запрашиваем разрешение пользователя
        //locationManager.startUpdatingLocation() // Начинаем отслеживание местоположения
        
    }
    
    private func setupUI(){
        view.addSubview(locationButton)
        view.addSubview(textField)
        view.addSubview(tableView)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
        
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
    }
    
    private func subscribes() {
        
        textField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                if let text = self?.textField.text {
                    self?.viewModel.buttonPressed(text: text)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.relay
            .bind(to: tableView.rx.items(cellIdentifier: "WeatherTableViewCell", cellType: WeatherTableViewCell.self)) { (row, element, cell) in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
        
        locationButton.rx.tap
            .bind { [weak self] in
                
                self?.locationManager.requestLocation() // Requests a single location update
            }
            .disposed(by: disposeBag)
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location.coordinate) // Выводим координаты местоположения в консоль
            self.viewModel.requestByCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения местоположения: \(error)")
        
    }
    
}

