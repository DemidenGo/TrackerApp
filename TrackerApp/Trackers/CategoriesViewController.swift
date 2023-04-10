//
//  CategoriesSelectingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.03.2023.
//

import UIKit

final class CategoriesViewController: UIViewController {

    var callback: (([TrackerCategory]?, Int?) -> ())?
    lazy var newCategoryViewController = NewCategoryViewController()
    lazy var categories = [TrackerCategory]()
    private var selectedCategoryName: String?
    private var isNewCategory: Bool { !categories.contains(where: { $0.title == selectedCategoryName }) }

    private var selectedCategoryIndex: Int? {
        if let selectedCategoryIndex = categories.firstIndex(where: { $0.title == selectedCategoryName }) {
            return selectedCategoryIndex
        }
        return nil
    }

    private var selectedCategoryIndexPath: IndexPath? {
        if let selectedCategoryIndex = selectedCategoryIndex {
            return IndexPath(row: selectedCategoryIndex, section: 0)
        }
        return nil
    }

    private var selectedCategoryCell: UITableViewCell? {
        if let selectedCategoryIndexPath = self.selectedCategoryIndexPath {
            return categoriesTableView.cellForRow(at: selectedCategoryIndexPath)
        }
        return nil
    }

    private enum CellState {
        case checked, unchecked
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Категория"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "StarIcon")
        imageView.isHidden = categories.isEmpty ? false : true
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.isHidden = categories.isEmpty ? false : true
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
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
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
    }

    @objc private func addCategoryButtonAction() {
        newCategoryViewController.presentationController?.delegate = newCategoryViewController
        newCategoryViewController.callback = { [weak self] newCategoryName in
            guard let newCategoryName = newCategoryName, let self = self else { return }
            self.setCell(state: .unchecked)
            self.selectedCategoryName = newCategoryName
            if !self.isNewCategory {
                self.setCell(state: .checked)
                return
            }
            self.appendNewCategory(name: newCategoryName)
            self.updateTableView()
            self.setCell(state: .checked)
        }
        present(newCategoryViewController, animated: true)
    }

    private func appendNewCategory(name: String) {
        let newCategory = TrackerCategory(title: name, trackers: [])
        categories.append(newCategory)
        categories.sort(by: { $0.title < $1.title })
    }

    private func updateTableView() {
        if let selectedCategoryIndexPath = self.selectedCategoryIndexPath {
            categoriesTableView.performBatchUpdates {
                categoriesTableView.insertRows(at: [selectedCategoryIndexPath], with: .automatic)
            }
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

    private func setCell(state: CellState) {
        guard let selectedCategoryCell = selectedCategoryCell else { return }
        switch state {
        case .checked:
            selectedCategoryCell.accessoryType = .checkmark
        case .unchecked:
            selectedCategoryCell.accessoryType = .none
        }
    }

    private func customizeCornersAndSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == categories.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.selectedBackgroundView?.layer.cornerRadius = 16
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCell(state: .unchecked)
        selectedCategoryName = categories[indexPath.row].title
        setCell(state: .checked)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?(self.categories, indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell else { return UITableViewCell() }
        cell.set(label: categories[indexPath.row].title)
        customizeCornersAndSeparator(for: cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CategoriesViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        selectedCategoryName = nil
        callback?(nil, nil)
    }
}
