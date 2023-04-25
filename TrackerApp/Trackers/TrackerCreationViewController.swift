//
//  RegularEventViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 16.03.2023.
//

import UIKit

final class TrackerCreationViewController: UIViewController {

    var trackerStore: TrackerStoreProtocol?
    lazy var categoriesViewController = CategoriesViewController()
    lazy var scheduleViewController = ScheduleViewController()

    var trackerType: TrackerType?
    var dismissPreviousControllerCallback: (() -> Void)?
    var swipeCallback: (() -> Void)?

    private var selectedTrackerName: String?
    private var selectedCategory: String?
    private var selectedSchedule: Set<WeekDay>?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private var isTrackerDataComplete: Bool {
        let isTrackerNameSelect = selectedTrackerName != nil
        let isCategorySelect = selectedCategory != nil
        guard let selectedSchedule = selectedSchedule else { return false }
        let isScheduleSelect = !selectedSchedule.isEmpty
        let isEmojiSelect = selectedEmoji != nil
        let isColorSelect = selectedColor != nil
        return isTrackerNameSelect && isCategorySelect && isScheduleSelect && isEmojiSelect && isColorSelect
    }

    private var isCharactersLimitLabelAddedToScreen: Bool { scrollView.subviews.contains(charactersLimitLabel) }
    private lazy var buttonsTableViewHeight: CGFloat = 150
    private lazy var offset: CGFloat = 38

    private let emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

    private lazy var colors: [UIColor] = {
        let baseColorName = "Color "
        var colorStringArray = [String]()
        (0...17).forEach { colorStringArray.append(baseColorName + String($0)) }
        var colorsUIArray = [UIColor]()
        colorStringArray.forEach { colorsUIArray.append(UIColor(named: $0) ?? .gray) }
        return colorsUIArray
    }()

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

    private lazy var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая привычка"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = .backgroundColor
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont(name: "YSDisplay-Regular", size: 17)
        textField.makeIndent(points: 16)
        textField.delegate = self
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.smartInsertDeleteType = .no
        return textField
    }()

    private lazy var buttonsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var emojiLabel: UILabel = makeLabel(text: "Emoji")
    private lazy var colorLabel: UILabel = makeLabel(text: "Цвет")

    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiAndColorCell.self, forCellWithReuseIdentifier: EmojiAndColorCell.identifier)
        return collectionView
    }()

    private lazy var selectedBackgroundViewForEmoji: UIView = {
        let view = UIView()
        view.backgroundColor = .interfaceLightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiAndColorCell.self, forCellWithReuseIdentifier: EmojiAndColorCell.identifier)
        return collectionView
    }()

    private lazy var selectedBackgroundViewForColor: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let button = makeButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.buttonRed, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.buttonRed.cgColor
        button.addTarget(self, action: #selector(closeControllerAction), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = makeButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .interfaceGray
        button.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        return button
    }()

    private lazy var charactersLimitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "YSDisplay-Regular", size: 17)
        label.textColor = .buttonRed
        label.alpha = 0.0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
    }

    @objc private func closeControllerAction() {
        dismiss(animated: true) { [weak self] in
            self?.refreshViews()
            self?.setToNilTemporaryValues()
            self?.dismissPreviousControllerCallback?()
        }
    }

    @objc private func createAction() {
        guard let selectedTrackerName = selectedTrackerName,
              let selectedCategory = selectedCategory,
              let selectedSchedule = selectedSchedule,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else { return }
        let newTracker = Tracker(id: UUID().uuidString,
                                 name: selectedTrackerName,
                                 color: selectedColor,
                                 emoji: selectedEmoji,
                                 schedule: selectedSchedule)
        try? trackerStore?.save(newTracker, in: selectedCategory)
        closeControllerAction()
    }

    private func activateCreateButton() {
        guard isTrackerDataComplete else { return }
        createButton.backgroundColor = .black
    }

    private func deactivateCreateButton() {
        guard !isTrackerDataComplete else { return }
        createButton.backgroundColor = .interfaceGray
    }

    private func setToNilTemporaryValues() {
        selectedTrackerName = nil
        selectedCategory = nil
        selectedSchedule = nil
        selectedEmoji = nil
        selectedColor = nil
    }

    private func refreshViews() {
        trackerNameTextField.text = nil
        setCategoryButtonTitle()
        setScheduleButtonTitle()
        deselectEmoji()
        deselectColor()
        createButton.backgroundColor = .interfaceGray
        scrollView.contentOffset = .zero
    }

    private func setCategoryButtonTitle(with additionalText: String? = nil) {
        let categoryButton = buttonsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ButtonTableCell
        if let additionalText = additionalText {
            categoryButton?.set(label: "Категория", additionalText: additionalText)
        } else {
            categoryButton?.set(label: "Категория")
        }
    }

    private func setScheduleButtonTitle(with additionalText: String? = nil) {
        let scheduleButton = buttonsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ButtonTableCell
        if let additionalText = additionalText {
            scheduleButton?.set(label: "Расписание", additionalText: additionalText)
        } else {
            scheduleButton?.set(label: "Расписание")
        }
    }

    private func deselectEmoji() {
        if let emojiIndex = emojies.firstIndex(where: { $0 == selectedEmoji }) {
            emojiCollectionView.deselectItem(at: IndexPath(row: emojiIndex, section: 0), animated: true)
        }
    }

    private func deselectColor() {
        if let colorIndex = colors.firstIndex(where: { $0 == selectedColor }) {
            colorCollectionView.deselectItem(at: IndexPath(row: colorIndex, section: 0), animated: true)
        }
    }

    private func showCharactersLimitLabel() {
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width,
                                        height: scrollView.contentSize.height + offset)
        contentView.subviews.suffix(from: 2).forEach { $0.slideAlongYAxisBy(points: offset) }
        setupCharactersLimitLabelConstraints()
        charactersLimitLabel.animateAlpha(to: 1.0)
    }

    private func hideCharactersLimitLabel() {
        charactersLimitLabel.animateAlpha(to: 0.0) { [weak self] in
            self?.charactersLimitLabel.removeFromSuperview()
        }
        contentView.subviews.suffix(from: 2).forEach { $0.slideAlongYAxisBy(points: -offset) }
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width,
                                        height: scrollView.contentSize.height - offset)
    }

    private func setupViewController() {
        view.backgroundColor = .white
        hideKeyboardByTap()
        if trackerType == .irregular {
            selectedSchedule = []
            WeekDay.allCases.forEach { selectedSchedule?.insert($0) }
            buttonsTableViewHeight = 75
            buttonsTableView.separatorStyle = .none
        }
    }

    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [mainTitleLabel,
         trackerNameTextField,
         buttonsTableView,
         emojiLabel,
         emojiCollectionView,
         colorLabel,
         colorCollectionView,
         cancelButton,
         createButton].forEach { contentView.addSubview($0) }

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

            mainTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            mainTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            trackerNameTextField.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),

            buttonsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: buttonsTableViewHeight),

            emojiLabel.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 30),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 57) / 2),

            colorLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiCollectionView.bottomAnchor, constant: 45),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 30),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 57) / 2),

            cancelButton.topAnchor.constraint(greaterThanOrEqualTo: colorCollectionView.bottomAnchor, constant: 44),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }

    private func setupCharactersLimitLabelConstraints() {
        scrollView.addSubview(charactersLimitLabel)
        NSLayoutConstraint.activate([
            charactersLimitLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            charactersLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont(name: "YSDisplay-Bold", size: 19)
        return label
    }

    private func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }

    private func tapCategoriesAction() {
        categoriesViewController.callback = { [weak self] categoryName in
            guard let categoryName = categoryName else {
                self?.setCategoryButtonTitle()
                self?.selectedCategory = nil
                self?.deactivateCreateButton()
                return
            }
            self?.setCategoryButtonTitle(with: categoryName)
            self?.selectedCategory = categoryName
            self?.activateCreateButton()
        }
        categoriesViewController.presentationController?.delegate = categoriesViewController
        present(categoriesViewController, animated: true)
    }

    private func tapScheduleAction() {
        scheduleViewController.callback = { [weak self] selectedSchedule in
            guard !selectedSchedule.isEmpty else {
                self?.setScheduleButtonTitle()
                self?.selectedSchedule = nil
                self?.deactivateCreateButton()
                return
            }
            let additionalText = selectedSchedule.map { $0.inShortStyleString }
            self?.setScheduleButtonTitle(with: additionalText.sortByWeekDaysString)
            self?.selectedSchedule = selectedSchedule
            self?.activateCreateButton()
        }
        selectedSchedule = nil
        present(scheduleViewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCreationViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newTrackerName = textField.text, newTrackerName != "" else {
            selectedTrackerName = nil
            deactivateCreateButton()
            return
        }
        selectedTrackerName = newTrackerName
        activateCreateButton()
        if isCharactersLimitLabelAddedToScreen { hideCharactersLimitLabel() }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharactersCount = textField.text?.count ?? 0
        let newLength = currentCharactersCount + string.count - range.length
        if newLength > 38, !isCharactersLimitLabelAddedToScreen { showCharactersLimitLabel() }
        if newLength <= 38, isCharactersLimitLabelAddedToScreen { hideCharactersLimitLabel() }
        return newLength <= 38
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPath.row == 0 ? tapCategoriesAction() : tapScheduleAction()
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch trackerType {
        case .regular:
            return 2
        case .irregular:
            return 1
        case .none:
            preconditionFailure("Error: need to select tracker type")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = buttonsTableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.set(label: "Категория")
        } else {
            cell.set(label: "Расписание")
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 57) / 6, height: (UIScreen.main.bounds.width - 57) / 6)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if cell.selectedBackgroundView != nil {
            cell.selectedBackgroundView = nil
            switch collectionView {
            case emojiCollectionView:
                selectedEmoji = nil
            default:
                selectedColor = nil
            }
            deactivateCreateButton()
            return
        }
        switch collectionView {
        case emojiCollectionView:
            cell.selectedBackgroundView = selectedBackgroundViewForEmoji
            selectedEmoji = emojies[indexPath.row]
            activateCreateButton()
        default:
            selectedBackgroundViewForColor.layer.borderColor = colors[indexPath.row].cgColor.copy(alpha: 0.3)
            cell.selectedBackgroundView = selectedBackgroundViewForColor
            selectedColor = colors[indexPath.row]
            activateCreateButton()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.selectedBackgroundView = nil
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerCreationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return emojies.count
        default:
            return colors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiAndColorCell.identifier,
                                                            for: indexPath) as? EmojiAndColorCell else {
            return UICollectionViewCell()
        }
        switch collectionView {
        case emojiCollectionView:
            cell.setLabel(text: emojies[indexPath.row])
            return cell
        default:
            cell.setLabel(color: colors[indexPath.row])
            return cell
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension TrackerCreationViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refreshViews()
        setToNilTemporaryValues()
        swipeCallback?()
    }
}
