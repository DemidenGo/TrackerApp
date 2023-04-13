//
//  TrackerCellDelegate.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 22.03.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapButton(_ cell: TrackerCell)
}
