//
//  ArgumentNoteDetailView.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import SwiftUI
import SwiftData
import UIKit
import ImageIO
import CoreGraphics

struct ArgumentNoteDetailView: View {
    @Bindable var note: ArgumentNote
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var showingShareSheet = false
    @State private var showingCopyConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Titre
                if isEditing {
                    TextField("Titre", text: $note.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(note.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Contenu
                if note.isImageNote {
                    // Affichage de l'image
                    if let image = note.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                } else {
                    // Affichage/édition du texte
                    if isEditing {
                        TextEditor(text: $note.content)
                            .frame(minHeight: 300)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    } else {
                        if note.content.isEmpty {
                            Text("Note vide")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Text(note.content)
                                .font(.body)
                                .textSelection(.enabled) // Permet la sélection pour copier
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Argument")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Bouton de copie (masqué pendant l'édition)
                    if !isEditing && (!note.content.isEmpty || note.isImageNote) {
                        Button {
                            copyToClipboard()
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.glass)
                    }
                    
                    // Bouton de partage (masqué pendant l'édition)
                    if !isEditing && (!note.content.isEmpty || note.isImageNote) {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.glass)
                    }
                    
                    // Bouton d'édition
                    Button {
                        if isEditing {
                            // Sauvegarder les modifications
                            note.updateModificationDate()
                            try? modelContext.save()
                        }
                        isEditing.toggle()
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(isEditing ? .green : .primary)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if note.isImageNote, let image = note.image {
                ShareSheet(items: [image])
            } else {
                ShareSheet(items: ["\(note.title)\n\n\(note.content)"])
            }
        }
        .alert("Copié !", isPresented: $showingCopyConfirmation) {
            Button("OK") { }
        } message: {
            Text("Le contenu a été copié dans le presse-papiers.")
        }
    }
    
    // Fonction pour copier le contenu dans le presse-papiers
    private func copyToClipboard() {
        let pasteboard = UIPasteboard.general

        if note.isImageNote, let image = note.image {
            // Créer un dictionnaire avec tous les formats d'image en une fois
            var imageItems: [String: Any] = [:]

            // Format principal (UIImage)
            imageItems["public.image"] = image

            // Formats de données supplémentaires
            if let pngData = image.pngData() {
                imageItems["public.png"] = pngData
            }

            if let jpegData = image.jpegData(compressionQuality: 0.9) {
                imageItems["public.jpeg"] = jpegData
            }

            // HEIC si disponible
            if #available(iOS 11.0, *) {
                if let heicData = convertToHEIC(image: image) {
                    imageItems["public.heic"] = heicData
                }
            }

            // Assigner tous les formats en une seule fois
            pasteboard.items = [imageItems]
        } else {
            // Copie simple du texte
            pasteboard.string = note.content
        }

        showingCopyConfirmation = true
    }

    // MARK: - Fonctions de conversion d'image

    @available(iOS 11.0, *)
    private func convertToHEIC(image: UIImage) -> Data? {
        guard let cgImage = image.cgImage else { return nil }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.heic" as CFString, 1, nil) else {
            return nil
        }

        // Configuration pour HEIC avec qualité optimisée
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.9
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        if CGImageDestinationFinalize(destination) {
            return data as Data
        }

        return nil
    }

}

// Wrapper pour UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let schema = Schema([ArgumentNote.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let sampleNote = ArgumentNote(title: "Exemple d'argument", content: "Ceci est un exemple de contenu d'argument. Il peut être assez long et contenir plusieurs paragraphes pour tester l'affichage.")
    container.mainContext.insert(sampleNote)
    
    return ArgumentNoteDetailView(note: sampleNote)
        .modelContainer(container)
}
