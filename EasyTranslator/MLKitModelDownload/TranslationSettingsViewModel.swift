//
//  ConfigurationsViewModel.swift
//  EasyTranslator
//
//  Created by KhawarShahzad on 23/05/2023.
//

import SwiftUI
import Combine
import Foundation

class TranslationSettingsViewModel: ObservableObject {
    var cancellables: [AnyCancellable] = []

    @Published var downloadModelsProgress: [ModelDownloadProgress] = []
    
    @Published var availableLanguages = [SupportedLanguage]()

    @Published var suggestedLanguages = [SupportedLanguage]()
    @Published var otherLanguages = [SupportedLanguage]()

    @Published var searchedText = ""

    @Published var alertMessage = ""
    @Published var shouldShowAlert  = false

    init(modelsToDownload: [SupportedLanguage] = []) {
        
        downloadModelsProgress = LanguageModelHelper.shared.downloadModelsProgress
        
        sortLanguagesForTranslation()
        
        bind()
        
        if !modelsToDownload.isEmpty {
            autoDownloadRequiredModels(modelsToDownload: modelsToDownload)
        }
    }
    
    func bind() {
        $searchedText.sink { [weak self] _ in
            guard let self = self else { return }
            self.sortLanguagesForTranslation()
        }
        .store(in: &cancellables)
    }
}

extension TranslationSettingsViewModel {
    func autoDownloadRequiredModels(modelsToDownload: [SupportedLanguage]) {
        for modelToDownload in modelsToDownload {
            if !self.isModelDownloaded(language: modelToDownload) && (downloadModelsProgress.first(where: { $0.language == modelToDownload }) == nil) {
                // Adding this delay for second download, because MLKit giving error on start next download quickly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startModelDownload(language: modelToDownload)
                }
            }
        }
    }
    
    func languageModelUpdated() {
        downloadModelsProgress = LanguageModelHelper.shared.downloadModelsProgress
        
        sortLanguagesForTranslation()
    }
    
    func isModelDownloaded(language: SupportedLanguage) -> Bool {
        return LanguageModelHelper.shared.isModelDownloaded(language: language)
    }
    
    func deleteTranslationModelTapped(language: SupportedLanguage) {
        self.deleteTranslationModel(language)
    }
    
    func deleteTranslationModel(_ language: SupportedLanguage) {
        LanguageModelHelper.shared.deleteTranslationModel(language) { [weak self] isCompleted, isError in
            guard let self = self else { return }

            self.languageModelUpdated()
            
            // Remove from suggested section if it's not App language
            if !LanguageModelHelper.shared.isAppLanguage(language: language) {
                suggestedLanguages.removeAll(where: { $0.isoCode == language.isoCode })
                if !otherLanguages.contains(language) {
                    otherLanguages.append(language)
                }
            }
            
            sortSectionData()
        }
    }
    
    func startModelDownload(language: SupportedLanguage) {
        LanguageModelHelper.shared.startModelDownload(language: language)
        languageModelUpdated()
        
        // Remove from other's section as downloaded started
        if otherLanguages.contains(language) {
            otherLanguages.removeAll(where: { $0.isoCode == language.isoCode })
        }
        
        // Add in suggested section as download started
        if !suggestedLanguages.contains(language) {
            suggestedLanguages.append(language)
        }
        
        sortSectionData()

        Helpers.showToast(message: "Language (\(language.name)) download started")
    }
    
    func sortLanguagesForTranslation() {
        var searchedTextCopy = searchedText
        if searchedTextCopy.containsOnlyWhiteSpaces() {
            searchedTextCopy = ""
        }
        
        availableLanguages = CountryManager.shared.getLanguages().filter({ $0.isoCode != "en" })
        
        suggestedLanguages.removeAll()
        otherLanguages.removeAll()
        
        if searchedTextCopy.isEmpty {
            suggestedLanguages.append(contentsOf: [SupportedLanguage(isoCode: "pl"),
                                                   SupportedLanguage(isoCode: "de"),
                                                   SupportedLanguage(isoCode: "uk")])
        } else {
            availableLanguages = availableLanguages
                .filter { $0.name.lowercased().contains(searchedTextCopy.lowercased()) || $0.nativeName.lowercased().contains(searchedTextCopy.lowercased()) }
        }
                
        for language in availableLanguages {
            if isModelDownloaded(language: language) || downloadModelsProgress.first(where: { $0.language.isoCode == language.isoCode }) != nil || (!searchedTextCopy.isEmpty && LanguageModelHelper.shared.isAppLanguage(language: language)) {
                if !suggestedLanguages.contains(language) {
                    suggestedLanguages.append(language)
                }
            } else {
                otherLanguages.append(language)
            }
        }
        
        sortSectionData()
    }
    
    func sortSectionData() {
        suggestedLanguages = suggestedLanguages.sorted(by: { ($0.name.lowercased()) < ($1.name.lowercased()) })
        otherLanguages = otherLanguages.sorted(by: { ($0.name.lowercased()) < ($1.name.lowercased()) })
    }
    
    func clearSearch() {
        searchedText = ""
        sortLanguagesForTranslation()
    }
}
