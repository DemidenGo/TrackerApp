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
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                             image: UIImage(named: "TrackersTabBarItem"),
                                             selectedImage: UIImage(named: "TrackersTabBarItemSelected"))
        trackersVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "YSDisplay-Medium", size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceGray], for: .normal)
        trackersVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "YSDisplay-Medium", size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceBlue], for: .selected)

        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика",
                                               image: UIImage(named: "StatisticsTabBarItem"),
                                               selectedImage: UIImage(named: "StatisticsTabBarItemSelected"))
        statisticsVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "YSDisplay-Medium", size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceGray], for: .normal)
        statisticsVC.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "YSDisplay-Medium", size: 10) ?? .systemFont(ofSize: 10),
             NSAttributedString.Key.foregroundColor: UIColor.interfaceBlue], for: .selected)
    }
}
