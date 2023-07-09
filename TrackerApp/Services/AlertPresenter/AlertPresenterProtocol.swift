//
//  AlertPresenterProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 09.07.2023.
//

import UIKit

protocol AlertPresenterProtocol {
    var viewController: UIViewController? { get set }
    func showAlert(message: String, deleteAction: @escaping () -> Void)
}
