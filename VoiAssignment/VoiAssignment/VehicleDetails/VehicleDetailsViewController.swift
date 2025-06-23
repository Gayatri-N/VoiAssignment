//
//  VehicleDetailsViewController.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import UIKit

final class VehicleDetailsViewController: UIViewController {
    
    private let vehicleInfo: VehicleInfo

    // MARK: - Initialization methods
    init(vehicleInfo: VehicleInfo) {
        self.vehicleInfo = vehicleInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    // MARK: - Private methods
    private func initView() {
        title = "Vehicle Info"
        view.backgroundColor = .systemGray6
        let safeArea = view.safeAreaLayoutGuide

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        stackView.addArrangedSubview(getLabel(for: "ID", value: vehicleInfo.id))
        stackView.addArrangedSubview(getLabel(for: "Name", value: vehicleInfo.name))
        stackView.addArrangedSubview(getLabel(for: "Category", value: vehicleInfo.category))
        let priceValue = "\(vehicleInfo.price) \(vehicleInfo.currency)"
        stackView.addArrangedSubview(getLabel(for: "Price", value: priceValue))
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
    }
    
    private func getLabel(for field: String, value: String) -> UILabel {
        let label = UILabel()
        label.text = "\(field): \(value)"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }
}
