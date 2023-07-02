//
//  ScheduleViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.03.2023.
//

import UIKit

final class ScheduleViewController: UIViewController {

    var callback: ((Set<WeekDay>) -> ())?
    private lazy var selectedSchedule: Set<WeekDay> = Set<WeekDay>()

    private var doneButtonIndent: CGFloat {
        guard let window = UIApplication.shared.windows.first else {
            preconditionFailure("Error: unable to get key window")
        }
        let safeAreaInsets = window.safeAreaInsets.top + window.safeAreaInsets.bottom
        return UIScreen.main.bounds.height <= 760 ? 24 : UIScreen.main.bounds.height - safeAreaInsets - 690
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.scheduleTitle
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.allowsSelection = false
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .buttonColor
        button.setTitle(L10n.Trackers.doneTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
        button.setTitleColor(.viewBackgroundColor, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setupConstraints()
    }

    @objc private func doneButtonAction() {
        checkSwitchesStatus()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?(self.selectedSchedule)
            self.selectedSchedule = []
            self.scheduleTableView.reloadData()
        }
    }

    private func checkSwitchesStatus() {
        for (index, weekDay) in WeekDay.allCases.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = scheduleTableView.cellForRow(at: indexPath)
            guard let switchView = cell?.accessoryView as? UISwitch else { return }
            if switchView.isOn { selectedSchedule.insert(weekDay) }
        }
    }

    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleLabel, scheduleTableView, doneButton].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 7 * 75),

            doneButton.topAnchor.constraint(equalTo: scheduleTableView.bottomAnchor, constant: doneButtonIndent),
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func makeSwitchView(at indexPath: IndexPath) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.onTintColor = .interfaceBlue
        switchView.tag = indexPath.row
        return switchView
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {   }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell else { return UITableViewCell() }
        let weekDay = WeekDay.allCases[indexPath.row]
        cell.set(label: weekDay.localizedString.capitalized)
        if indexPath.row == WeekDay.allCases.count - 1 {
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        cell.accessoryView = makeSwitchView(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
