//
//  NewCategoryViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.03.2023.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    var callback: ((String?) -> ())?
    private var newCategoryName: String?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.newCategoryTitle
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = .backgroundColor
        textField.placeholder = L10n.Trackers.categoryNamePlaceholder
        textField.font = UIFont(name: Fonts.regular, size: 17)
        textField.makeIndent(points: 16)
        textField.delegate = self
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.smartInsertDeleteType = .no
        textField.text = newCategoryName
        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .interfaceGray
        button.setTitle(L10n.Trackers.doneTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
    }

    func edit(_ category: String) {
        newCategoryName = category
        categoryNameTextField.becomeFirstResponder()
    }

    private func setupViewController() {
        view.backgroundColor = .viewBackgroundColor
        hideKeyboardByTap()
    }

    @objc private func doneButtonAction() {
        dismiss(animated: true) { [weak self] in
            self?.callback?(self?.newCategoryName)
            self?.disableDoneButton()
            self?.newCategoryName = nil
            self?.categoryNameTextField.text = nil
        }
    }

    private func setupConstraints() {
        [titleLabel, categoryNameTextField, doneButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func enableDoneButton() {
        doneButton.backgroundColor = .buttonColor
        doneButton.setTitleColor(.viewBackgroundColor, for: .normal)
        doneButton.isUserInteractionEnabled = true
    }

    private func disableDoneButton() {
        doneButton.backgroundColor = .interfaceGray
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.isUserInteractionEnabled = false
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text != "", text != L10n.Trackers.pinnedTitle.dropFirst() else {
            disableDoneButton()
            return
        }
        enableDoneButton()
        newCategoryName = textField.text
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension NewCategoryViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        newCategoryName = nil
        callback?(nil)
    }
}
