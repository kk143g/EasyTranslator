//
//  LanguageModelHelper.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 6/9/24.
//

import Foundation
import MLKit
import Combine

struct ModelDownloadProgress {
    var language: SupportedLanguage
    var progress: Progress
}

class LanguageModelHelper: NSObject, ObservableObject {
    private var cancellables: [AnyCancellable] = []
    
    static let shared = LanguageModelHelper()
    
    @Published var downloadModelsProgress: [ModelDownloadProgress] = []
    
    @Published var localModels = ModelManager.modelManager().downloadedTranslateModels
    let COUNTRIES_FOR_TRANSLATION_MODELS = "COUNTRIES_FOR_TRANSLATION_MODELS"
    
    override init() {
        super.init()
        addLanguageObserver()
    }
    
    func isModelDownloaded(language: SupportedLanguage) -> Bool {
        return ModelManager.modelManager().isModelDownloaded(TranslateRemoteModel.translateRemoteModel(language: TranslateLanguage(rawValue: language.isoCode)))
    }
    
    func deleteTranslationModel(_ model: SupportedLanguage, completion: @escaping ((_ completed: Bool, _ isError: Bool) -> Void)) {
        let languageModel = TranslateRemoteModel.translateRemoteModel(language: TranslateLanguage(rawValue: model.isoCode))
        if ModelManager.modelManager().isModelDownloaded(languageModel) {
            ModelManager.modelManager().deleteDownloadedModel(languageModel) { [weak self] error in
                guard let self = self else { return }
                
                guard error == nil else {
                    completion(false, true)
                    Helpers.showToast(message: error?.localizedDescription ?? "Some thing went wrong")
                    return
                }
                // Model deleted.
                DispatchQueue.main.async {
                    self.localModels = ModelManager.modelManager().downloadedTranslateModels
                }
                completion(true, false)
            }
        }
    }
    
    func startModelDownload(language: SupportedLanguage) {
        let languageModel = TranslateRemoteModel.translateRemoteModel(language: TranslateLanguage(rawValue: language.isoCode))
        if !ModelManager.modelManager().isModelDownloaded(languageModel) {
            // Keep a reference to the download progress so you can check that the model
            // is available before you use it.
            let progress = ModelManager.modelManager().download(
                languageModel,
                conditions: ModelDownloadConditions(
                    allowsCellularAccess: false,
                    allowsBackgroundDownloading: true
                )
            )
            downloadModelsProgress.append(ModelDownloadProgress(language: language, progress: progress))
        }
    }
    
    func checkIfAllModelsAvailable() {
        var isAllModelsDownloaded = false
        if let supportedLanguages = getSavedLanguagesForTranslation() {
            for supportedLanguage in supportedLanguages {
                isAllModelsDownloaded = isModelDownloaded(language: supportedLanguage)
            }
        }
        if isAllModelsDownloaded {
            downloadModelsProgress.removeAll()
        }
        
        RemoteCallings.default.languageModelUpdated.send(true)
    }
}

extension LanguageModelHelper {
    func addLanguageObserver() {
        
        NotificationCenter
            .default
            .publisher(for: .mlkitModelDownloadDidSucceed)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                        as? TranslateRemoteModel
                else { return }
                
                Helpers.showToast(message: "Language \(SupportedLanguage(isoCode: model.language.rawValue).name) successfully downloaded")

                // The model was downloaded and is available on the device
                self.downloadModelsProgress.removeAll(where: { $0.language.isoCode == model.language.rawValue })
                DispatchQueue.main.async {
                    self.localModels = ModelManager.modelManager().downloadedTranslateModels
                }
                self.checkIfAllModelsAvailable()
            }
            .store(in: &cancellables)
        
        NotificationCenter
            .default
            .publisher(for: .mlkitModelDownloadDidFail)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                        as? TranslateRemoteModel
                else { return }
                _ = userInfo[ModelDownloadUserInfoKey.error.rawValue]
                self.downloadModelsProgress.removeAll(where: { $0.language.isoCode == model.language.rawValue })
                Helpers.showToast(message: "Language \(SupportedLanguage(isoCode: model.language.rawValue).name) download failed")
                
                self.checkIfAllModelsAvailable()
                
                DispatchQueue.main.async {
                    self.localModels = ModelManager.modelManager().downloadedTranslateModels
                }
            }
            .store(in: &cancellables)
    }
}

extension LanguageModelHelper {
    func getSavedLanguagesForTranslation() -> [SupportedLanguage]? {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: COUNTRIES_FOR_TRANSLATION_MODELS),
                let decoded = try? decoder.decode([SupportedLanguage].self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func saveLanguagesForTranslation(language: [SupportedLanguage]) {
        var languages = [SupportedLanguage]()
        let encoder = JSONEncoder()
        if let existingCountries = getSavedLanguagesForTranslation() {
            languages = existingCountries
        }
        
        let languagesAlreadyAddedSet = Set(language)
        languages = languages.filter { !languagesAlreadyAddedSet.contains($0) }
        
        if !languages.contains(language) {
            languages.append(contentsOf: language)
            
            if let encoded = try? encoder.encode(languages) {
                UserDefaults.standard.set(encoded, forKey: COUNTRIES_FOR_TRANSLATION_MODELS)
            } else {
                UserDefaults.standard.set(nil, forKey: COUNTRIES_FOR_TRANSLATION_MODELS)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    func currentFormattedDeviceLanguage() -> SupportedLanguage? {
        if let currentLanguage = Locale.current.languageCode {
            return SupportedLanguage(isoCode: currentLanguage.lowercased())
        }
        return nil
    }
    
    func isAppLanguage(language: SupportedLanguage) -> Bool {
        return [SupportedLanguage(isoCode: "pl"),
                SupportedLanguage(isoCode: "de"),
                SupportedLanguage(isoCode: "uk")].contains(language)
    }
}
