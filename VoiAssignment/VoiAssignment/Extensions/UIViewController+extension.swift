//
//  UIViewController+extension.swift
//  VoiAssignment
//
//  Created by Gayatri Nagarkar on 2025-06-23.
//

import UIKit

extension UIViewController {

    func showErrorAlert(for error: Error, handler: ((UIAlertAction) -> Void)? = nil) {
        showAlert(for: "Error", message: error.localizedDescription)
    }
    
    func showAlert(for title: String, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
            alert.addAction(okAction)

            self?.present(alert, animated: true)
        }
    }
}
