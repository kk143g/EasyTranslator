//
//  EasyTranslatorApp.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 10/2/24.
//

import SwiftUI

@main
struct EasyTranslatorApp: App {
    var body: some Scene {
        WindowGroup {
            EasyTranslator()
                .environmentObject(EasyTranslatorViewModel())
        }
    }
}
