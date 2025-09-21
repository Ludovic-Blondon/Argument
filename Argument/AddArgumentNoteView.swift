//
//  AddArgumentNoteView.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddArgumentNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Titre") {
                    TextField("Titre de l'argument", text: $title)
                        .font(.title2)
                }
                
                Section("Contenu") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Boutons pour choisir le type de contenu
                        HStack {
                            Button {
                                // Vider l'image pour revenir au texte
                                selectedImageData = nil
                                selectedPhotoItem = nil
                            } label: {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                    Text("Texte")
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(selectedImageData == nil)
                            
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Image")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            // Affichage de l'image sélectionnée
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                        } else {
                            // Zone de texte
                            TextEditor(text: $content)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("Nouvel Argument")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauver") {
                        saveNote()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    // Vider le contenu texte si on sélectionne une image
                    content = ""
                }
            }
        }
    }
    
    private func saveNote() {
        let note = ArgumentNote(
            title: title.trimmingCharacters(in: .whitespaces),
            content: selectedImageData == nil ? content : "",
            imageData: selectedImageData
        )
        
        modelContext.insert(note)
        dismiss()
    }
}

#Preview {
    AddArgumentNoteView()
        .modelContainer(for: ArgumentNote.self, inMemory: true)
}