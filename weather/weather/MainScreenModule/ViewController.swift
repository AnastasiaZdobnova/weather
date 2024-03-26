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

protocol ViewControllerProtocol {
    var viewModel: ViewModelProtocol { get }
}

class ViewController: UIViewController, ViewControllerProtocol, CLLocationManagerDelegate {
    
    var viewModel: ViewModelProtocol = WeatherViewModel()
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "Город"
        label.textColor = ColorConstants.textColor
        return label
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.init(systemName: "location.square"), for: .normal)
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите город"
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConstants.backgroundColor
        setupUI()
        subscribes()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupUI(){
        view.addSubview(locationButton)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(cityLabel)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(LayoutConstants.standardMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(LayoutConstants.WeatherScreen.textFieldWidth)
            make.height.equalTo(LayoutConstants.WeatherScreen.textFieldHeight)
        }
        
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(LayoutConstants.standardMargin)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(LayoutConstants.standardMargin)
            make.left.right.equalToSuperview().inset(LayoutConstants.standardMargin)
            make.bottom.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(LayoutConstants.standardMargin)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(LayoutConstants.standardMargin)
            make.width.equalTo(LayoutConstants.WeatherScreen.buttonWidth)
            make.height.equalTo(LayoutConstants.WeatherScreen.buttonHeight)
        }
        
    }
    
    private func subscribes() {
        
        textField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                if let text = self?.textField.text {
                    self?.viewModel.buttonPressed(text: text)
                }
                self?.textField.text = ""
            })
            .disposed(by: disposeBag)
        
        viewModel.relay
            .bind(to: tableView.rx.items(cellIdentifier: "WeatherTableViewCell", cellType: WeatherTableViewCell.self)) { (row, element, cell) in
                cell.configure(with: element)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        locationButton.rx.tap
            .bind { [weak self] in
                self?.locationManager.requestLocation()
                self?.textField.text = ""
            }
            .disposed(by: disposeBag)
        
        viewModel.relayCity
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] city in
                self?.cityLabel.text = city
            })
            .disposed(by: disposeBag)
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location.coordinate)
            self.viewModel.requestByCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения местоположения: \(error)")
    }
}

