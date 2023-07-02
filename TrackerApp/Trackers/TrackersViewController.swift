//
//  ViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 27.02.2023.
//

import UIKit

final class TrackersViewController: UIViewController {

    private let analyticsService: AnalyticsServiceProtocol
    lazy var trackerStore: TrackerStoreProtocol = TrackerStore(delegate: self)
    lazy var recordsStore: RecordStoreProtocol = RecordStore()
    private var currentDate = Date().startOfDay
    private lazy var delay = 1 // Delay in seconds for animation after tracker creation

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: Images.Trackers.addButton)?.withTintColor(.label)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addNewTracker), for: .touchUpInside)
        return button
    }()

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.trackersTitle
        label.font = UIFont(name: Fonts.bold, size: 34)   
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.calendar = Calendar(identifier: .iso8601)
        return datePicker
    }()

    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: Fonts.regular, size: 17)
        textField.placeholder = L10n.Trackers.searchFieldPlaceholder
        textField.delegate = self
        return textField
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
        label.text = L10n.Trackers.emptyStateTitle
        label.font = UIFont(name: Fonts.medium, size: 12)
        return label
    }()

    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.identifier)
        collectionView.isHidden = trackerStore.numberOfSections == 0 ? true : false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.top = 24
        return collectionView
    }()

    init(analyticsService: AnalyticsServiceProtocol = AnalyticsService()) {
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["main_screen": "viewDidAppear"])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["main_screen": "viewDidDisappear"])
    }

    private func setupViewController() {
        hideKeyboardByTap()
        view.backgroundColor = .viewBackgroundColor
    }

    private func setupConstraints() {
        [addButton,
         mainLabel,
         datePicker,
         searchTextField,
         stubImageView,
         stubLabel,
         trackersCollectionView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),

            mainLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: mainLabel.centerYAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 100),

            searchTextField.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),

            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 51),

            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func addNewTracker() {
        let trackerTypeViewController = TrackerTypeViewController()
        trackerTypeViewController.trackerStore = trackerStore
        present(trackerTypeViewController, animated: true)
        analyticsService.report(event: "click", params: ["main_screen": "add_track"])
    }

    @objc private func dateChanged() {
        currentDate = datePicker.date.startOfDay
        trackerStore.trackersFor(currentDate.weekDayString, searchRequest: nil)
        reloadCollectionView()
        presentedViewController?.dismiss(animated: true)
    }

    private func reloadCollectionView() {
        trackersCollectionView.reloadData()
        trackersCollectionView.isHidden = trackerStore.numberOfSections == 0 ? true : false
        trackersCollectionView.contentOffset = CGPoint(x: 0, y: -24)
        if trackerStore.numberOfSections == 0 {
            stubImageView.image = UIImage(named: Images.Trackers.nothingFound)
            stubLabel.text = L10n.Trackers.nothingFoundTitle
        }
    }

    private func config(cell: TrackerCell, with tracker: Tracker, _ trackerRecords: Set<TrackerRecord>) {
        cell.delegate = self
        cell.configure(with: tracker)
        let dayCounter = trackerRecords.count
        cell.set(dayCounter)
        if isCompletedOnCurrentDate(tracker.id, trackerRecords) {
            cell.buttonSetCheckmark()
        } else {
            cell.buttonSetPlus()
        }
    }

    private func isCompletedOnCurrentDate(_ trackerID: String, _ trackerRecords: Set<TrackerRecord>) -> Bool {
        return trackerRecords.contains(TrackerRecord(id: trackerID, date: currentDate))
    }

    private func saveTrackerRecord(for trackerID: String) {
        let trackerRecord = TrackerRecord(id: trackerID, date: currentDate)
        try? recordsStore.save(trackerRecord)
    }

    private func deleteTrackerRecord(for trackerID: String) {
        let trackerRecord = TrackerRecord(id: trackerID, date: currentDate)
        try? recordsStore.delete(trackerRecord)
    }

    private func editTracker(at indexPath: IndexPath) {
        guard let tracker = trackerStore.object(at: indexPath),
              let category = trackerStore.name(of: indexPath.section) else { return }
        let dayCounter = trackerStore.records(for: indexPath).count
        let viewController = TrackerCreationViewController(trackerType: .existing)
        viewController.trackerStore = trackerStore
        viewController.edit(existing: tracker, in: category, with: dayCounter)
        present(viewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let searchRequest = textField.text, searchRequest != "" {
            trackerStore.trackersFor(currentDate.weekDayString, searchRequest: searchRequest)
        } else {
            trackerStore.trackersFor(currentDate.weekDayString, searchRequest: nil)
        }
        reloadCollectionView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 41) / 2, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: 20),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [UIAction(title: L10n.Trackers.pinTitle) { _ in

            },
                                     UIAction(title: L10n.Trackers.editTitle) { [weak self] _ in
                self?.editTracker(at: indexPath)
            },
                                     UIAction(title: L10n.Trackers.deleteTitle, attributes: .destructive) { _ in

            }])
        })
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            preconditionFailure("Error: unable to get cell for use in preview")
        }
        return UITargetedPreview(view: cell.contextMenuPreview)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            preconditionFailure("Error: unable to get cell for use in preview")
        }
        return UITargetedPreview(view: cell.contextMenuPreview)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell,
              let tracker = trackerStore.object(at: indexPath) else { return UICollectionViewCell() }
        let trackerRecords = trackerStore.records(for: indexPath)
        config(cell: cell, with: tracker, trackerRecords)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = trackersCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SupplementaryView.identifier, for: indexPath) as? SupplementaryView,
              let sectionName = trackerStore.name(of: indexPath.section) else { return UICollectionReusableView() }
        view.setTitle(text: sectionName)
        return view
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {

    func trackerCellDidTapButton(_ cell: TrackerCell) {
        delay = 0
        guard currentDate <= Date().startOfDay,
              let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let trackerRecords = trackerStore.records(for: indexPath)
        if isCompletedOnCurrentDate(cell.trackerID, trackerRecords) {
            deleteTrackerRecord(for: cell.trackerID)
        } else {
            saveTrackerRecord(for: cell.trackerID)
            analyticsService.report(event: "click", params: ["main_screen": "track"])
        }
        delay = 1
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {

    func didUpdateTracker(_ insertedSections: IndexSet,
                          _ deletedSections: IndexSet,
                          _ updatedSections: IndexSet,
                          _ updatedIndexPaths: [IndexPath],
                          _ insertedIndexPaths: [IndexPath],
                          _ deletedIndexPaths: [IndexPath]) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) { [weak self] in
            self?.trackersCollectionView.isHidden = self?.trackerStore.numberOfSections == 0 ? true : false
            self?.trackersCollectionView.performBatchUpdates {
                self?.trackersCollectionView.insertSections(insertedSections)
                self?.trackersCollectionView.deleteSections(deletedSections)
                self?.trackersCollectionView.reloadSections(updatedSections)
                self?.trackersCollectionView.insertItems(at: insertedIndexPaths)
                self?.trackersCollectionView.deleteItems(at: deletedIndexPaths)
                self?.trackersCollectionView.reloadItems(at: updatedIndexPaths)
            } completion: { _ in
                if let indexPathToScroll = insertedIndexPaths.last {
                    self?.trackersCollectionView.scrollToItem(at: indexPathToScroll,
                                                              at: .centeredVertically,
                                                              animated: true)
                }
            }
        }
    }
}
