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

class ViewController: UIViewController {
    var viewModel = WeatherViewModel()
    let disposeBag = DisposeBag()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Нажми меня", for: .normal)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setupUI()
        subscribes()
    }
    
    private func setupUI(){
        view.addSubview(button)
        view.addSubview(label)
        
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func subscribes() {
        button.rx.tap.subscribe { _ in
            self.viewModel.buttonPressed()
        }.disposed(by: disposeBag)
        
        
        viewModel.relay
            .observe(on: MainScheduler.instance) // Убедитесь, что обновление UI происходит в главном потоке
            .subscribe { event in
                self.label.text = event.element
                print(event.element)
            }
            .disposed(by: disposeBag)
        
    }
}

