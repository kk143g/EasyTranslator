//
//  ConfigurationsView.swift
//  EasyTranslator
//
//  Created by KhawarShahzad on 23/05/2023.
//

import SwiftUI
import SSSwiftUIGIFView

struct TranslationSettingsView: View {
    @EnvironmentObject var viewModel: TranslationSettingsViewModel
    @Environment(\.remoteCallings) var remoteCallings
    
    @State var navigationHeight: CGFloat = .zero
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                
                VStack(spacing: 0) {

                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(height: 15)

                        VStack(spacing: 0) {

                            Color.clear.frame(height: 10)

                            SearchView(searchedText: $viewModel.searchedText,
                                               searchPlaceholder: "Search") {
                                viewModel.clearSearch()
                            }
                            .padding(.horizontal, 16)
                            
                            Color.clear.frame(height: 15)

                            ScrollView {
                                VStack(spacing: 0) {
                                    if !viewModel.suggestedLanguages.isEmpty {
                                        LanguagesSectionView(sectionTitle: "Suggested Languages",
                                                             languageData: viewModel.suggestedLanguages)
                                    }

                                    Color.clear.frame(height: 15)

                                    if !viewModel.otherLanguages.isEmpty {
                                        LanguagesSectionView(sectionTitle: "Other Languages",
                                                             languageData: viewModel.otherLanguages)
                                    }
                                    
                                    if viewModel.suggestedLanguages.isEmpty && viewModel.otherLanguages.isEmpty {
                                        Text("No language model found")
                                            .foregroundColor(Color.black)
                                            .multilineTextAlignment(.center)
                                    }
                                  
                                    Color.clear.frame(height: 30)
                                }
                            }
                        }
                        .background(
                            Rectangle()
                                .fill(Color.white)
                                .cornerRadius(10)
                        )
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                }
                
            }
            .navigationTitle("Manage translation files")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowAlert) {
            Button("OK", role: .cancel) { }
        }
        .onReceive(remoteCallings.languageModelUpdated) { newValue in
            if newValue {
                viewModel.languageModelUpdated()
            }
        }
    }
}

struct LanguagesSectionView: View {
    @EnvironmentObject var viewModel: TranslationSettingsViewModel
    
    var sectionTitle: String
    var languageData: [SupportedLanguage]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(sectionTitle)
                    .foregroundColor(Color.blue)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 15)

            Color.clear.frame(height: 6)

            LazyVStack(spacing: 6) {
                ForEach(0..<languageData.count, id: \.self) { i in
                    VStack {
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(languageData[i].name)
                                    .foregroundColor(Color.black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                
                                Text(languageData[i].nativeName)
                                    .foregroundColor(Color.black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            
                            Spacer()

                            Button {
                                if viewModel.isModelDownloaded(language: languageData[i]) {
                                    viewModel.deleteTranslationModelTapped(language: languageData[i])
                                } else if viewModel.downloadModelsProgress.first(where: { $0.language == languageData[i] }) == nil {
                                    viewModel.startModelDownload(language: languageData[i])
                                }
                            } label: {
                                if viewModel.isModelDownloaded(language: languageData[i]) {
                                    Image("red_basket_icon")
                                        .resizable()
                                        .foregroundColor(Color.black)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    
                                    Image("tick-check-mark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                } else if viewModel.downloadModelsProgress.first(where: { $0.language == languageData[i] }) != nil {
                                    SwiftUIGIFPlayerView(gifName: "downloading_gif")
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                } else {
                                    Image("download_icon")
                                        .resizable()
                                        .tint(Color.black)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .padding(15)
                    }
                    .background(
                        Rectangle()
                            .fill(viewModel.isModelDownloaded(language: languageData[i]) ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                            .cornerRadius(10)
                    )
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}

struct TranslationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationSettingsView()
            .environmentObject(TranslationSettingsViewModel())
    }
}

struct SearchView: View {
    @Binding var searchedText: String
    var searchPlaceholder: String

    var clearSearchCallback: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TextField(
                searchPlaceholder,
                text: $searchedText
            )
            .submitLabel(.search)
            .tint(.black)
            
            Spacer()
            
            Button {
                clearSearchCallback()
            } label: {
                Image(searchedText.containsOnlyWhiteSpaces() ? "grey_search_icon" : "crossGray")
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(5.0)
        .overlay(
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 1)
                .foregroundColor(.gray)
        )
    }
}
