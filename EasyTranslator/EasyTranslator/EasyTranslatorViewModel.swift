//
//  EasyTranslatorViewModel.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 10/3/24.
//
import Foundation
import MLKit
import NaturalLanguage
import Combine

class EasyTranslatorViewModel: ObservableObject {
    @Published var alertMessage = ""
    @Published var shouldShowAlert  = false

    @Published var textToTranslate: String = ""
    @Published var translatedText: String = ""
    
    @Published var availableLanguages: [SupportedLanguage] = []
    @Published var targetLanguage: SupportedLanguage = SupportedLanguage(name: "English", nativeName: "English", isoCode: "en")

    @Published var shouldMoveToModelDownload = false

    init() {
        getAvailableLanguages()
    }
}
// MARK: Translate text
extension EasyTranslatorViewModel {
    func getAvailableLanguages() {
        availableLanguages = CountryManager.shared.getLanguages().filter({ $0.isoCode != "en" })
        availableLanguages = availableLanguages.sorted(by: { ($0.name.lowercased()) < ($1.name.lowercased()) })
    }
    
    func translateText() {
        let languageId = LanguageIdentification.languageIdentification()
        languageId.identifyLanguage(for: textToTranslate) { [weak self] languageCode, error in
            guard let self = self else { return }
            
            if error != nil {
                self.alertMessage = error?.localizedDescription ?? "Some thing went wrong"
                return
            }
            
            if let languageCode = languageCode, languageCode != "und" {
                let sourceLanguageML = TranslateLanguage(rawValue: languageCode)
                let targetLanguageML = TranslateLanguage(rawValue: targetLanguage.isoCode)
                
                print("------- Detected langauge: \(languageCode)-------")
                
                // Check if source language supported
                let sourceLanguageFormatted = SupportedLanguage(isoCode: sourceLanguageML.rawValue)
                if !CountryManager.shared.getLanguages(bypassExisting: false).contains(sourceLanguageFormatted) {
                    Helpers.showToast(message: "Language not supported")
                    print("------- Language not supported -------")
                    return
                }
                
                // If current and target language are same then quit translation
                if sourceLanguageML == targetLanguageML {
                    Helpers.showToast(message: "Source and Target languages are same")
                    print("------- Source and Target languages are same -------")
                    return
                }
                
                // Continue iwth Translation
                let options = TranslatorOptions(sourceLanguage: sourceLanguageML, targetLanguage: targetLanguageML)
                let languageTranslator = Translator.translator(options: options)
                
                print("------- Checking if Language donwload required -------")
                let sourceLanguageModel = TranslateRemoteModel.translateRemoteModel(language: sourceLanguageML)
                let targetLanguageModel = TranslateRemoteModel.translateRemoteModel(language: targetLanguageML)
                
                if ModelManager.modelManager().isModelDownloaded(sourceLanguageModel), ModelManager.modelManager().isModelDownloaded(targetLanguageModel) {
                    // Model available. Okay to start translating.
                    languageTranslator.translate(textToTranslate) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else {
                            if let error = error {
                                switch error._code {
                                case 13: // Means model files are found, need to download model
                                    // do something
                                    self.showModelDownloadRequiredPopup(sourceLanguage: sourceLanguageFormatted,
                                                                        targetLanguage: self.targetLanguage,
                                                                        sourceLanguageModel: sourceLanguageModel,
                                                                        targetLanguageModel: targetLanguageModel)
                                    return
                                default:
                                    break
                                }
                            }
                            Helpers.showToast(message: "Something went wrong")
                            return
                        }
                        
                        print("------- Text Translated: \(translatedText) -------")
                        
                        // Translation succeeded.
                        self.translatedText = translatedText
                    }
                } else {
                    self.showModelDownloadRequiredPopup(sourceLanguage: sourceLanguageFormatted,
                                                        targetLanguage: targetLanguage,
                                                        sourceLanguageModel: sourceLanguageModel,
                                                        targetLanguageModel: targetLanguageModel)
                }
            } else {
                Helpers.showToast(message: error?.localizedDescription ?? "No language identified")
            }
        }
    }
    
    func showModelDownloadRequiredPopup(sourceLanguage: SupportedLanguage, targetLanguage: SupportedLanguage, sourceLanguageModel: TranslateRemoteModel, targetLanguageModel: TranslateRemoteModel) {
        
        var modelRequired: [String] = []
        var modelDownloadRequired: [SupportedLanguage] = []

        if !ModelManager.modelManager().isModelDownloaded(sourceLanguageModel) {
            modelRequired.append(sourceLanguage.name)
            modelDownloadRequired.append(sourceLanguage)
        }
        
        if !ModelManager.modelManager().isModelDownloaded(targetLanguageModel) {
            modelRequired.append(targetLanguage.name)
            modelDownloadRequired.append(targetLanguage)
        }
        
        if modelRequired.isEmpty {
            // TODO: Move to donwload screen
            return
        }
        var modelNamesStr = ""

        for modelName in modelRequired {
            modelNamesStr = modelNamesStr.isEmpty ? "• \(modelName)" : "\(modelNamesStr)\n• \(modelName)"
        }
        self.alertMessage = "Please download langauge model for:\n\(modelNamesStr)"
        shouldMoveToModelDownload = true
    }
}
