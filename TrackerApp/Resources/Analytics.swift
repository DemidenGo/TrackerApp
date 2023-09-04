//
//  AnalyticsEvent.swift
//  TrackerApp
//

import Foundation

enum Analytics {

    enum Events {
        static let open = "open"
        static let close = "close"
        static let click = "click"
    }

    enum Params {

        enum Keys {
            static let mainScreen = "main_screen"
        }

        enum Values {
            static let viewDidAppear = "viewDidAppear"
            static let viewDidDisappear = "viewDidDisappear"
            static let addTrack = "add_track"
            static let track = "track"
            static let filter = "filter"
            static let edit = "edit"
            static let delete = "delete"
        }
    }
}
