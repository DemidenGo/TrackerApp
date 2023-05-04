//
//  OnboardingPageViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 03.05.2023.
//

import UIKit

final class OnboardingPageViewController: UIViewController {

    let page: OnboardingPage
    private let finishOnboardingAction: () -> Void

    private var onboardingLabelIndent: CGFloat { UIScreen.main.bounds.height <= 667 ? 27 : 64 }
    private var loginButtonIndent: CGFloat { UIScreen.main.bounds.height <= 667 ? 50 : 84 }

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: page.backgroundImage)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .displayBold32
        label.textAlignment = .center
        label.text = page.onboardingMessage
        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle(page.loginButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .displayMedium16
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(loginButtonTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = OnboardingPage.allCases.count
        pageControl.currentPage = page.index
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .interfaceGray
        return pageControl
    }()

    init(with page: OnboardingPage, finishOnboarding action: @escaping () -> Void) {
        self.page = page
        self.finishOnboardingAction = action
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    @objc private func loginButtonTapAction() {
        finishOnboardingAction()
    }

    private func setupConstraints() {
        [backgroundImageView, onboardingLabel, pageControl, loginButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            onboardingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: onboardingLabelIndent),
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -loginButtonIndent),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 60),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -24)
        ])
    }
}
