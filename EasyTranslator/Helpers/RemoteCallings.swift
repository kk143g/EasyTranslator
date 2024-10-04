//
//  RemoteCallings.swift
//  EasyTranslator
//
//  Created by KhawarShahzad on 10/12/2022.
//

import Foundation
import SwiftUI
import Combine

protocol RemoteCallingsProtocol {
    var languageModelUpdated: CurrentValueSubject<Bool, Never> { get }
    var showLanguageModelDowwnloadError: CurrentValueSubject<String?, Never> { get }
}

// MARK: - RemoteCallings

class RemoteCallings: RemoteCallingsProtocol {
    lazy var languageModelUpdated = CurrentValueSubject<Bool, Never>(false)
    lazy var showLanguageModelDowwnloadError = CurrentValueSubject<String?, Never>(nil)

    static let `default` = RemoteCallings()
}

struct RemoteCallingsProtocolKey: EnvironmentKey {
    static var defaultValue: RemoteCallingsProtocol {
        return RemoteCallings.default
    }
}

extension EnvironmentValues {
    var remoteCallings: RemoteCallingsProtocol {
        get { return self[RemoteCallingsProtocolKey.self] }
        set { self[RemoteCallingsProtocolKey.self] = newValue }
    }
}
