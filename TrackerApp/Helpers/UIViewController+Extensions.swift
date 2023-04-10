//
//  UIViewController+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 24.03.2023.
//

import UIKit

extension UIViewController {
    func hideKeyboardByTap() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
