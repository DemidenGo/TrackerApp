//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.04.2023.
//

import UIKit

final class OnboardingViewController: UIViewController {

    private lazy var showMainScreenAction = {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration: unable to get window from UIApplication")
        }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController()
    }

    private func setupPageController() {
        let pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
        let firstPage = OnboardingPageViewController(with: .first, finishOnboarding: showMainScreenAction)
        pageController.dataSource = self
        pageController.view.frame = view.frame
        pageController.setViewControllers([firstPage], direction: .forward, animated: true)
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
    }
}

//MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController else { return nil }
        return OnboardingPageViewController(with: currentPage.page.previous,
                                     finishOnboarding: showMainScreenAction)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController else { return nil }
        return OnboardingPageViewController(with: currentPage.page.next,
                                            finishOnboarding: showMainScreenAction)
    }
}
