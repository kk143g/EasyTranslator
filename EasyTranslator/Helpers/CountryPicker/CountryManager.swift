//
//  CountryManager.swift
//  CountryPicker
//
//  Created by Samet Macit on 31.12.2020.
//  Copyright © 2021 Mobven. All rights reserved.

import Foundation
import UIKit

public final class CountryManager {
    public static let shared = CountryManager()
    private init() {}
    
    // Default theme is support dark mode
    public var config: Configuration = Config()
    
    // For localization we use current locale by default but you can change localeIdentifier for specific cases
    public var localeIdentifier: String = NSLocale.current.identifier
    
    /// - Returns: Country array
    public func getCountries() -> [Country] {
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return [] }
        return (try? JSONDecoder().decode([Country].self, from: data)) ?? []
    }
    
    /// - Returns: Languages array
    public func getLanguages(bypassExisting: Bool = true) -> [SupportedLanguage] {
        guard let path = Bundle.main.path(forResource: "languages", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return [] }
        var allLanguages = (try? JSONDecoder().decode([SupportedLanguage].self, from: data)) ?? []
        if !config.languagesAlreadyAdded.isEmpty && bypassExisting {
            let languagesAlreadyAddedSet = Set(config.languagesAlreadyAdded)
            allLanguages = allLanguages.filter { !languagesAlreadyAddedSet.contains($0) }
        }
        return allLanguages
    }
}
