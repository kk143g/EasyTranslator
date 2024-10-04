//
//  CountryPicker.swift
//  EasyTranslator
//
//  Created by KhawarShahzad on 19/11/2022.
//

import SwiftUI

struct CountryPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = CountryPickerViewController

    let countryPicker = CountryPickerViewController()

    @Binding var country: Country?
    @Binding var language: SupportedLanguage?

    func makeUIViewController(context: Context) -> CountryPickerViewController {
        countryPicker.selectedCountry = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? ""
        countryPicker.delegate = context.coordinator
        return countryPicker
    }

    func updateUIViewController(_ uiViewController: CountryPickerViewController, context: Context) {
        //
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, CountryPickerDelegate {
        var parent: CountryPicker
        init(_ parent: CountryPicker) {
            self.parent = parent
        }
        func countryPicker(didSelect country: Country) {
            parent.country = country
        }
        func languagePicker(didSelect language: SupportedLanguage) {
            parent.language = language
        }
    }
}
