//
//  TabBarController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 14.03.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }

    private func setupTabBarController() {
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        setTabBarItems(trackersViewController, statisticsViewController)
        viewControllers = [trackersViewController, statisticsViewController]
    }

    private func setTabBarItems(_ trackersVC: UIViewController, _ statisticsVC: UIViewController) {
        trackersVC.tabBarItem = UITabBarItem(title: L10n.Trackers.trackersTitle,
                                             image: UIImage(named: Images.TabBar.firstItem),
                                             selectedImage: UIImage(named: Images.TabBar.firstItemSelected))
        trackersVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceGray], for: .normal)
        trackersVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceBlue], for: .selected)

        statisticsVC.tabBarItem = UITabBarItem(title: L10n.Trackers.statisticsTitle,
                                               image: UIImage(named: Images.TabBar.secondItem),
                                               selectedImage: UIImage(named: Images.TabBar.secondItemSelected))
        statisticsVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceGray], for: .normal)
        statisticsVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: Fonts.medium, size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceBlue], for: .selected)
    }
}
