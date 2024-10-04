//
//  EasyTranslator.swift
//  EasyTranslator
//
//  Created by Khawar Shahzad on 10/2/24.
//

import SwiftUI

struct EasyTranslator: View {

    @EnvironmentObject var viewModel: EasyTranslatorViewModel
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: TranslationSettingsView().environmentObject(TranslationSettingsViewModel()), isActive: $viewModel.shouldMoveToModelDownload) { EmptyView() }

            ScrollView {
                VStack(alignment: .center, spacing: 15) {

                    Button {
                        viewModel.shouldMoveToModelDownload = true
                    } label: {
                        Text("Manage model downloads")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Enter your text here:")
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)

                        TextEditor(text: $viewModel.textToTranslate)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )

                            )
                    }
                    
                    HStack {
                        Button {
                            viewModel.translateText()
                        } label: {
                            Text("Translate")
                                .foregroundColor(.white)
                        }
                        .frame(width: 100, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.blue)
                        )
                        .disabled(viewModel.textToTranslate.isEmpty)
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Menu {
                                ForEach(0..<viewModel.availableLanguages.count, id: \.self) { i in
                                    Button {
                                        viewModel.targetLanguage = viewModel.availableLanguages[i]
                                    } label: {
                                        Text(viewModel.availableLanguages[i].name)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.targetLanguage.name)

                                    Image("dropdown")
                                }
                            }
                            
                            Text("Select target language")
                        }
                    }
                    
                    TextEditor(text: $viewModel.translatedText)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 1)
                                )

                        )
                        .disabled(true)
                }
                .padding()
            }
            .navigationTitle("Text Translation Using Google ML Kit")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    EasyTranslator()
}
