//
//  AlertPresenter.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 09.07.2023.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {

    weak var viewController: UIViewController?

    func showAlert(message: String, deleteAction: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: L10n.Trackers.deleteTitle, style: .destructive) { _ in deleteAction() }
        let cancelAction = UIAlertAction(title: L10n.Trackers.cancelTitle, style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0) }
        viewController?.present(alert, animated: true)
    }
}
