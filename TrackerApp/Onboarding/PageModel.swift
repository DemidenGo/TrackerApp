//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.04.2023.
//

import UIKit

final class PageModel: UIViewController {

    private var pageController: UIPageViewController?
    private lazy var pages: [Pages] = Pages.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController()
        setupFinishOnboardingClosure()
    }

    init(pageController: UIPageViewController?) {
        self.pageController = pageController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupFinishOnboardingClosure() {
        Pages.loginButtonTapAction = {
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid Configuration: unable to get window from UIApplication")
            }
            let tabBarController = TabBarController()
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }

    private func setupPageController() {
        guard let pageController = pageController else { return }
        pageController.dataSource = self
        pageController.view.frame = view.frame
        let firstPage = PageView(with: pages[0])
        pageController.setViewControllers([firstPage], direction: .forward, animated: true)
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
    }
}

//MARK: - UIPageViewControllerDataSource

extension PageModel: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? PageView else { return nil }
        let currentPageIndex = currentPage.page.index
        let previousPageIndex = currentPageIndex - 1
        if previousPageIndex >= 0 {
            return PageView(with: pages[previousPageIndex])
        } else {
            guard let lastPage = pages.last else { return nil }
            return PageView(with: lastPage)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? PageView else { return nil }
        let currentPageIndex = currentPage.page.index
        let nextPageIndex = currentPageIndex + 1
        if nextPageIndex < pages.count {
            return PageView(with: pages[nextPageIndex])
        } else {
            guard let firstPage = pages.first else { return nil }
            return PageView(with: firstPage)
        }
    }
}
