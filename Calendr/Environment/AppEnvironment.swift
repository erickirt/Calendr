//
//  AppEnvironment.swift
//  Calendr
//
//  Created by Paker on 10/08/2024.
//

import Foundation

enum AppEnvironment {

    /// Config.xcconfig -> Info.plist
    private static func get<T>(_ key: String) -> T? {
        Bundle.main.object(forInfoDictionaryKey: key) as? T
    }

    static let SENTRY_DSN: String? = get("SENTRY_DSN")
}
