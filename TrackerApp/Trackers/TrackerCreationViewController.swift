//
//  RegularEventViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 16.03.2023.
//

import UIKit

final class TrackerCreationViewController: UIViewController {

    var trackerStore: TrackerStoreProtocol?
    var callback: (() -> Void)?

    private let trackerType: TrackerType
    private var selectedTrackerName: String?
    private var selectedCategory: String?
    private var selectedSchedule: Set<WeekDay>?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var trackerID: String?
    private var isPinned = false
    private var trackerNameTextFieldConstraint = NSLayoutConstraint()

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

    private let emojies = Constants.emojies

    private lazy var colors: [UIColor] = {
        var colorStringArray = [String]()
        (0...17).forEach { colorStringArray.append(Constants.baseColorName + String($0)) }
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
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.bold, size: 32)
        label.text = "TEST"
        return label
    }()

    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = .backgroundColor
        textField.placeholder = L10n.Trackers.trackerNamePlaceholder
        textField.font = UIFont(name: Fonts.regular, size: 17)
        textField.makeIndent(points: 16)
        textField.delegate = self
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.smartInsertDeleteType = .no
        textField.text = selectedTrackerName
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

    private lazy var emojiLabel: UILabel = makeLabel(text: L10n.Trackers.emojiTitle)
    private lazy var colorLabel: UILabel = makeLabel(text: L10n.Trackers.colorTitle)

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
        button.setTitle(L10n.Trackers.cancelTitle, for: .normal)
        button.setTitleColor(.buttonRed, for: .normal)
        button.backgroundColor = .viewBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.buttonRed.cgColor
        button.addTarget(self, action: #selector(closeControllerAction), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = makeButton()
        button.setTitle(L10n.Trackers.createTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .interfaceGray
        button.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        return button
    }()

    private lazy var charactersLimitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.charLimitTitle
        label.font = UIFont(name: Fonts.regular, size: 17)
        label.textColor = .buttonRed
        label.alpha = 0.0
        return label
    }()

    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectEmojiIfNeeded()
        selectColorIfNeeded()
    }

    func edit(existing tracker: Tracker, in category: String, with dayCounter: Int, isPinned: Bool) {
        selectedCategory = category
        selectedTrackerName = tracker.name
        selectedSchedule = tracker.schedule
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        trackerID = tracker.id
        self.isPinned = isPinned
        let daysTitle = String.localizedStringWithFormat(L10n.Trackers.trackedDaysTitle, dayCounter)
        daysCounterLabel.text = "\(dayCounter) " + daysTitle
    }

    private func selectEmojiIfNeeded() {
        guard let emoji = selectedEmoji, let index = emojies.firstIndex(of: emoji) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        emojiCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView(emojiCollectionView, didSelectItemAt: indexPath)
    }

    private func selectColorIfNeeded() {
        guard let color = selectedColor else { return }
        let serializedColors = colors.map { UIColorMarshalling.serialize(color: $0) }
        let deserializedColors = serializedColors.map { UIColorMarshalling.deserialize(hexString: $0) }
        guard let index = deserializedColors.firstIndex(of: color) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        colorCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView(colorCollectionView, didSelectItemAt: indexPath)
    }

    @objc private func closeControllerAction() {
        dismiss(animated: true) { [weak self] in
            self?.callback?()
        }
    }

    @objc private func createAction() {
        guard let selectedTrackerName = selectedTrackerName,
              let selectedCategory = selectedCategory,
              let selectedSchedule = selectedSchedule,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else { return }
        let trackerID: String
        if let existingTrackerID = self.trackerID {
            trackerID = existingTrackerID
        } else {
            trackerID = UUID().uuidString
        }
        let newTracker = Tracker(id: trackerID,
                                 name: selectedTrackerName,
                                 color: selectedColor,
                                 emoji: selectedEmoji,
                                 schedule: selectedSchedule)
        try? trackerStore?.save(newTracker, in: selectedCategory, isPinned: isPinned)
        closeControllerAction()
    }

    private func activateCreateButton() {
        guard isTrackerDataComplete else { return }
        createButton.backgroundColor = .buttonColor
        createButton.setTitleColor(.viewBackgroundColor, for: .normal)
    }

    private func deactivateCreateButton() {
        guard !isTrackerDataComplete else { return }
        createButton.backgroundColor = .interfaceGray
        createButton.setTitleColor(.white, for: .normal)
    }

    private func setCategoryButtonTitle(with additionalText: String? = nil) {
        let categoryButton = buttonsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ButtonTableCell
        if let additionalText = additionalText {
            categoryButton?.set(label: L10n.Trackers.categoryTitle, additionalText: additionalText)
        } else {
            categoryButton?.set(label: L10n.Trackers.categoryTitle)
        }
    }

    private func setScheduleButtonTitle(with additionalText: String? = nil) {
        let scheduleButton = buttonsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ButtonTableCell
        if let additionalText = additionalText {
            scheduleButton?.set(label: L10n.Trackers.scheduleTitle, additionalText: additionalText)
        } else {
            scheduleButton?.set(label: L10n.Trackers.scheduleTitle)
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
        view.backgroundColor = .viewBackgroundColor
        hideKeyboardByTap()
        switch trackerType {
        case .regular:
            mainTitleLabel.text = L10n.Trackers.newRegularTrackerTitle
        case .irregular:
            selectedSchedule = []
            WeekDay.allCases.forEach { selectedSchedule?.insert($0) }
            buttonsTableViewHeight = 75
            buttonsTableView.separatorStyle = .none
            mainTitleLabel.text = L10n.Trackers.newIrregularTrackerTitle
        case .existing:
            mainTitleLabel.text = L10n.Trackers.editTrackerTitle
            trackerNameTextFieldConstraint.constant = 116
            setupDaysCounterLabelConstraints()
            createButton.setTitle(L10n.Trackers.saveTitle, for: .normal)
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

        trackerNameTextFieldConstraint = trackerNameTextField.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor,
                                                                                   constant: 38)

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

            trackerNameTextFieldConstraint,
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

    private func setupDaysCounterLabelConstraints() {
        contentView.addSubview(daysCounterLabel)
        NSLayoutConstraint.activate([
            daysCounterLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 38),
            daysCounterLabel.bottomAnchor.constraint(equalTo: trackerNameTextField.topAnchor, constant: -40),
            daysCounterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont(name: Fonts.bold, size: 19)
        return label
    }

    private func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: Fonts.medium, size: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }

    private func tapCategoriesAction() {
        let categoriesViewModel = CategoriesViewModel()
        let categoriesViewController = CategoriesViewController(viewModel: categoriesViewModel)
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
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.callback = { [weak self] selectedSchedule in
            guard !selectedSchedule.isEmpty else {
                self?.setScheduleButtonTitle()
                self?.selectedSchedule = nil
                self?.deactivateCreateButton()
                return
            }
            let additionalText = selectedSchedule.map { $0.localizedStringInShortStyle }
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
        case .regular, .existing:
            return 2
        case .irregular:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = buttonsTableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.set(label: L10n.Trackers.categoryTitle, additionalText: selectedCategory)
        } else {
            cell.set(label: L10n.Trackers.scheduleTitle,
                     additionalText: selectedSchedule?.map { $0.localizedStringInShortStyle }.sortByWeekDaysString)
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
