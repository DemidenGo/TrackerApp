//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.04.2023.
//

import UIKit

final class OnboardingViewController: UIPageViewController {

    private let firstViewController = UIViewController()
    private let secondViewController = UIViewController()

    private lazy var firstImageView = makeImageView(with: "Onboarding-Background-1")
    private lazy var secondImageView = makeImageView(with: "Onboarding-Background-2")

    private lazy var firstLabel = makeLabel(text: "Отслеживайте только то, что хотите")
    private lazy var secondLabel = makeLabel(text: "Даже если это не литры воды и йога")

    private lazy var pages = [firstViewController, secondViewController]

    private var labelIndent: CGFloat {
        if UIScreen.main.bounds.height <= 667 {
            return 27
        }
        return 64
    }

    private var buttonIndent: CGFloat {
        if UIScreen.main.bounds.height <= 667 {
            return 50
        }
        return 84
    }

    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .interfaceGray
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints(in: firstViewController, for: [firstImageView, firstLabel])
        setupConstraints(in: secondViewController, for: [secondImageView, secondLabel])
        setupPageViewController()
    }

    @objc private func buttonAction() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration: unable to get window from UIApplication")
        }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
    }

    private func makeImageView(with imageNamed: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageNamed)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        label.textAlignment = .center
        return label
    }

    private func setupConstraints(in viewController: UIViewController, for views: [UIView]) {
        views.forEach { viewController.view.addSubview($0) }
        [button, pageControl].forEach { view.addSubview($0) }
        guard let imageView = views.first(where: { $0 is UIImageView }),
              let label = views.first(where: { $0 is UILabel }) else { return }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),

            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor, constant: labelIndent),
            label.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonIndent),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        if previousIndex >= 0 {
            return pages[previousIndex]
        } else {
            return pages.last
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        if nextIndex < pages.count {
            return pages[nextIndex]
        } else {
            return pages.first
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

