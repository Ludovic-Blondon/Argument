//
//  ArgumentNotesListView.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import SwiftUI
import SwiftData

struct ArgumentNotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ArgumentNote.modifiedAt, order: .reverse) private var notes: [ArgumentNote]
    @State private var searchText = ""
    @State private var showingAddNote = false
    
    var filteredNotes: [ArgumentNote] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink {
                        ArgumentNoteDetailView(note: note)
                    } label: {
                        ArgumentNoteRow(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Rechercher...")
            .navigationTitle("Arguments")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddArgumentNoteView()
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredNotes[index])
            }
        }
    }
}

struct ArgumentNoteRow: View {
    let note: ArgumentNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Titre en gros et gras
            Text(note.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Aperçu du contenu en petit
            Text(note.contentPreview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ArgumentNotesListView()
        .modelContainer(for: ArgumentNote.self, inMemory: true)
}
