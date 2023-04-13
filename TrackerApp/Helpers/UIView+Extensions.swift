//
//  UIView+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 17.03.2023.
//

import UIKit

extension UIView {
    static var identifier: String {
        String(describing: self)
    }

    func slideAlongYAxisBy(points: CGFloat) {
        let xPosition = self.frame.origin.x
        let yPosition = self.frame.origin.y + points
        let width = self.frame.width
        let height = self.frame.height
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        }
    }

    func animateAlpha(to value: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.alpha = value
        } completion: { _ in
            completion?()
        }
    }
}
