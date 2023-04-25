//
//  ViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 27.02.2023.
//

import UIKit

final class TrackersViewController: UIViewController {

    lazy var trackerTypeViewController = TrackerTypeViewController()
    lazy var trackerStore: TrackerStoreProtocol = TrackerStore(delegate: self)
    lazy var recordsStore: RecordStoreProtocol = RecordStore()
    private var currentDate = Date().startOfDay
    private lazy var delay = 1 // Delay in seconds for animation after tracker creation

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "AddButton")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addNewTracker), for: .touchUpInside)
        return button
    }()

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Трекеры"
        label.font = UIFont(name: "YSDisplay-Bold", size: 34)   
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.calendar = Calendar(identifier: .iso8601)
        return datePicker
    }()

    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: "YSDisplay-Regular", size: 17)
        textField.placeholder = "Поиск"
        textField.delegate = self
        return textField
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "StarIcon")
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
    }

    private func setupViewController() {
        hideKeyboardByTap()
        view.backgroundColor = .white
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
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func addNewTracker() {
        trackerTypeViewController.trackerStore = trackerStore
        present(trackerTypeViewController, animated: true)
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
            stubImageView.image = UIImage(named: "NothingFoundIcon")
            stubLabel.text = "Ничего не найдено"
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
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
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
        }
        delay = 1
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {

    func didUpdateTracker(_ insertedSections: IndexSet, _ deletedSections: IndexSet, _ updatedIndexPaths: [IndexPath], _ insertedIndexPaths: [IndexPath], _ deletedIndexPaths: [IndexPath]) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) { [weak self] in
            self?.trackersCollectionView.isHidden = self?.trackerStore.numberOfSections == 0 ? true : false
            self?.trackersCollectionView.performBatchUpdates {
                self?.trackersCollectionView.insertSections(insertedSections)
                self?.trackersCollectionView.deleteSections(deletedSections)
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
