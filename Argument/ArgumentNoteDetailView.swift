//
//  ArgumentNoteDetailView.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import SwiftUI
import SwiftData

struct ArgumentNoteDetailView: View {
    @Bindable var note: ArgumentNote
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var showingShareSheet = false
    
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