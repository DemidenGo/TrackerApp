//
//  TrackerAppTests.swift
//  TrackerAppTests
//
//  Created by Юрий Демиденко on 04.07.2023.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerAppTests: XCTestCase {

    func testTrackersViewController() {
        let viewController = TrackersViewController()
        assertSnapshot(matching: viewController, as: .image)
    }
}
