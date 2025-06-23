//
//  VehicleLookupViewController.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import UIKit
import Combine

final class VehicleLookupViewController: UIViewController {

    private let viewModel: DefaultVehicleLookupViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?
    
    private let infoLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let activityIndicatorStackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView()
    private let activityIndicatorLabel = UILabel()

    // MARK: - Initialization methods
    init(viewModel: DefaultVehicleLookupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupSubscription()
    }
    
    // MARK: - Action methods
    @objc func didTapStartButton() {
        openQRScanView()
    }
    
    @objc func enableActivityIndicatorLabel() {
        timer?.invalidate()
        activityIndicatorLabel.isHidden = false
    }

    // MARK: - Private methods
    private func initView() {
        title = "Vehicle Lookup"
        view.backgroundColor = .systemGray6
        view.accessibilityIdentifier = AccessibilityIDs.vehicleLookupView.view
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Scan the QR code on the handle bar of the vehicle"
        infoLabel.textAlignment = .center
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.numberOfLines = 0
        infoLabel.accessibilityIdentifier = AccessibilityIDs.vehicleLookupView.infoLabel
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        startButton.accessibilityIdentifier = AccessibilityIDs.vehicleLookupView.startButton
        
        activityIndicatorStackView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorStackView.axis = .vertical
        activityIndicatorStackView.spacing = 20
        activityIndicatorStackView.isHidden = true

        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true

        activityIndicatorLabel.text = "It can take some time initially..."
        activityIndicatorLabel.textAlignment = .center
        activityIndicatorLabel.font = .systemFont(ofSize: 16)
        activityIndicatorLabel.numberOfLines = 0
        activityIndicatorLabel.isHidden = true

        setupView()
    }
    
    private func setupView() {
        let safeArea = view.layoutMarginsGuide

        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            infoLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 50),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -40)
        ])
        
        activityIndicatorStackView.addArrangedSubview(activityIndicator)
        activityIndicatorStackView.addArrangedSubview(activityIndicatorLabel)
        
        view.addSubview(activityIndicatorStackView)
        NSLayoutConstraint.activate([
            activityIndicatorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorStackView.topAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorStackView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupSubscription() {
        viewModel.actionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] action in
                guard let self else { return }
                handle(action)
            }
            .store(in: &subscriptions)
    }

    private func handle(_ action: VehicleInfoViewModelAction) {
        switch action {
        case .showActivity:
            showActivity()
            setStartButton(enabled: false)
            
        case .hideActivity:
            hideActivity()
            setStartButton(enabled: true)
            
        case .showVehicleInfo(let vehicleInfo):
            guard let navigationController = self.navigationController else { return }
            navigationController.pushViewController(
                VehicleDetailsViewController(vehicleInfo: vehicleInfo),
                animated: true
            )
            
        case .showErrorAlert(let error):
            showErrorAlert(for: error)
        }
    }
    
    private func handle(_ qrScanResult: QRScanResult) {
        switch qrScanResult {
        case .qrCode(let code):
            activityIndicatorLabel.isHidden = true
            timer = Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(enableActivityIndicatorLabel),
                userInfo: nil,
                repeats: false
            )
            viewModel.fetchVehicleInfo(for: code)
            
        case .cameraPermissionNotAvailable, .videoCaptureDeviceNotAvailable, .qrScanningNotSupported:
            showAlert(for: "Error", message: qrScanResult.errorMessage)
        }
    }
    
    private func showActivity() {
        activityIndicatorStackView.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideActivity() {
        activityIndicatorStackView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func openQRScanView() {
        let scanVC = QRScanViewController()
        scanVC.modalPresentationStyle = .pageSheet
        scanVC.actionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self else { return }
                handle(result)
            }
            .store(in: &subscriptions)
        present(scanVC, animated: true)
    }
    
    private func setStartButton(enabled: Bool) {
        startButton.isEnabled = enabled
        startButton.backgroundColor = enabled ? .systemBlue: .systemGray
    }
}

// MARK: - Helper -
extension VehicleLookupViewController {

    static func createInNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(
            rootViewController: VehicleLookupViewController(viewModel: DefaultVehicleLookupViewModel())
        )
        return navigationController
    }
}
