//
//  CategoriesSelectingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.03.2023.
//

import UIKit

final class CategoriesViewController: UIViewController {

    var callback: ((String?) -> ())?
    var viewModel: CategoriesViewModelProtocol?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.categoryTitle
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: Images.Trackers.emptyState)
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.emptyCategoriesTitle
        label.font = UIFont(name: Fonts.medium, size: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .buttonColor
        button.setTitle(L10n.Trackers.addCategoryTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
        button.setTitleColor(.viewBackgroundColor, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addCategoryButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorColor = .tableSeparatorColor
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setupConstraints()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else { return }
        categoriesTableView.isHidden = viewModel.categories.isEmpty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel = viewModel, !viewModel.categories.isEmpty else { return }
        categoriesTableView.scrollToRow(at: viewModel.selectedCategoryIndexPath, at: .bottom, animated: true)
    }

    init(viewModel: CategoriesViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.categoriesObservable.bind { [weak self] _ in
            self?.categoriesTableView.isHidden = viewModel.categories.isEmpty
            self?.categoriesTableView.reloadData()
        }
    }

    @objc private func addCategoryButtonAction() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.presentationController?.delegate = newCategoryViewController
        newCategoryViewController.callback = { [weak self] category in
            guard let category = category else { return }
            self?.viewModel?.didCreate(category)
        }
        present(newCategoryViewController, animated: true)
    }

    private func dismissWithCallback() {
        dismiss(animated: true) { [weak self] in
            self?.callback?(self?.viewModel?.selectedCategory)
        }
    }

    private func setupConstraints() {
        [titleLabel, stubImageView, stubLabel, categoriesTableView, addCategoryButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30),

            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func customizeCornersAndSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.selectedBackgroundView?.layer.cornerRadius = 16
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        if indexPath.row == viewModel.categories.count - 2 {
            cell.layer.cornerRadius = 0
            cell.selectedBackgroundView?.layer.cornerRadius = 0
            cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectCategory(at: indexPath)
        dismissWithCallback()
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            return UIMenu(children: [
                UIAction(title: L10n.Trackers.editTitle) { _ in
                    self?.viewModel?.editCategory(at: indexPath)
                },
                UIAction(title: L10n.Trackers.deleteTitle, attributes: .destructive) { _ in
                    self?.viewModel?.deleteCategoryFromStore(at: indexPath)
                    self?.callback?(nil)
                }
            ])
        })
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell,
              let category = viewModel?.categories[indexPath.row] else { return UITableViewCell() }
        cell.set(label: category.title)
        cell.accessoryType = category.isSelected ? .checkmark : .none
        customizeCornersAndSeparator(for: cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CategoriesViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        callback?(nil)
    }
}
