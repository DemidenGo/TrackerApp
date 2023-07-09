//
//  TrackerTypeViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 16.03.2023.
//

import UIKit

enum TrackerType {
    case regular
    case irregular
    case existing
}

final class TrackerTypeViewController: UIViewController {

    var trackerStore: TrackerStoreProtocol?
    var updateTrackersCompletion: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.trackerCreationTitle
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var regularEventButton: UIButton = {
        let button = makeButton(title: L10n.Trackers.regularTrackerTitle)
        button.addTarget(self, action: #selector(addRegularTracker), for: .touchUpInside)
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = makeButton(title: L10n.Trackers.irregularTrackerTitle)
        button.addTarget(self, action: #selector(addIrregularTracker), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        [regularEventButton, irregularEventButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setupConstraints()
    }

    private func makeButton(title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .buttonColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.setTitleColor(.viewBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
        return button
    }

    @objc private func addRegularTracker() {
        presentViewController(newTracker: .regular)
    }

    @objc private func addIrregularTracker() {
        presentViewController(newTracker: .irregular)
    }

    private func presentViewController(newTracker type: TrackerType) {
        let viewController = TrackerCreationViewController(trackerType: type)
        viewController.trackerStore = trackerStore
        viewController.completion = { [weak self] in
            self?.dismiss(animated: true)
            self?.updateTrackersCompletion?()
        }
        present(viewController, animated: true)
    }

    private func setupConstraints() {
        [titleLabel, stackView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension TrackerTypeViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateTrackersCompletion?()
    }
}
