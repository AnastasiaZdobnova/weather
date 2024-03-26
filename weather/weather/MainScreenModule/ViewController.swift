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
    }
    
    private func setupUI(){
        view.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
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

    }
    
   
}

