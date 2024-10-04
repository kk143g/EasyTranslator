//
//  SupportedLanguage.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 6/11/24.
//

import Foundation

public struct SupportedLanguage: Codable, Hashable {
    public var name: String
    public var nativeName: String
    public let isoCode: String

    public init(name: String, nativeName: String, isoCode: String) {
        self.name = name
        self.nativeName = nativeName
        self.isoCode = isoCode
    }
    
    public init(isoCode: String) {
        self.isoCode = isoCode
        self.name = ""
        self.nativeName = ""

        if let language = CountryManager.shared.getLanguages(bypassExisting: false).first(where: { $0.isoCode == isoCode }) {
            self.name = language.name
            self.nativeName = language.nativeName
        }
    }
}
