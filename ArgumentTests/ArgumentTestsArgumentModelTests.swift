//
//  ArgumentModelTests.swift
//  ArgumentTests
//
//  Created by Ludovic Blondon on 21/09/2025.
//

import Testing
import Foundation
import UIKit
@testable import Argument

@Suite("Tests pour ArgumentNote")
struct ArgumentNoteTests {
    
    @Test("Création d'une note texte simple")
    func createTextNote() async throws {
        let note = ArgumentNote(title: "Test Note", content: "Contenu de test")
        
        #expect(note.title == "Test Note")
        #expect(note.content == "Contenu de test")
        #expect(note.imageData == nil)
        #expect(note.isImageNote == false)
        #expect(note.image == nil)
    }
    
    @Test("Création d'une note avec titre seulement")
    func createTitleOnlyNote() async throws {
        let note = ArgumentNote(title: "Titre seulement")
        
        #expect(note.title == "Titre seulement")
        #expect(note.content == "")
        #expect(note.imageData == nil)
        #expect(note.isImageNote == false)
    }
    
    @Test("Création d'une note avec image")
    func createImageNote() async throws {
        // Créer des données d'image factices
        let imageData = Data([0x89, 0x50, 0x4E, 0x47]) // Début d'un header PNG
        let note = ArgumentNote(title: "Note avec image", imageData: imageData)
        
        #expect(note.title == "Note avec image")
        #expect(note.content == "")
        #expect(note.imageData == imageData)
        #expect(note.isImageNote == true)
    }
    
    @Test("Aperçu du contenu pour note texte")
    func textContentPreview() async throws {
        let shortContent = "Court contenu"
        let note = ArgumentNote(title: "Test", content: shortContent)
        
        #expect(note.contentPreview == shortContent)
    }
    
    @Test("Aperçu du contenu pour texte long")
    func longTextContentPreview() async throws {
        let longContent = String(repeating: "A", count: 150)
        let note = ArgumentNote(title: "Test", content: longContent)
        
        #expect(note.contentPreview.count == 100)
        #expect(note.contentPreview == String(repeating: "A", count: 100))
    }
    
    @Test("Aperçu du contenu pour note image")
    func imageContentPreview() async throws {
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])
        let note = ArgumentNote(title: "Test", imageData: imageData)
        
        #expect(note.contentPreview == "📷 Image")
    }
    
    @Test("Aperçu du contenu pour note vide")
    func emptyContentPreview() async throws {
        let note = ArgumentNote(title: "Test", content: "")
        
        #expect(note.contentPreview == "Note vide")
    }
    
    @Test("Mise à jour de la date de modification")
    func updateModificationDate() async throws {
        let note = ArgumentNote(title: "Test")
        let originalDate = note.modifiedAt
        
        // Attendre un petit moment pour s'assurer que la date change
        try await Task.sleep(for: .milliseconds(10))
        
        note.updateModificationDate()
        
        #expect(note.modifiedAt > originalDate)
    }
    
    @Test("Dates de création et modification à l'initialisation")
    func creationDates() async throws {
        let beforeCreation = Date()
        let note = ArgumentNote(title: "Test")
        let afterCreation = Date()
        
        #expect(note.createdAt >= beforeCreation)
        #expect(note.createdAt <= afterCreation)
        #expect(note.modifiedAt >= beforeCreation)
        #expect(note.modifiedAt <= afterCreation)
        
        // Les dates peuvent différer de quelques microsecondes, on vérifie qu'elles sont très proches
        let timeDifference = abs(note.createdAt.timeIntervalSince(note.modifiedAt))
        #expect(timeDifference < 0.001, "Les dates de création et modification devraient être très proches à l'initialisation")
    }
    
    @Test("Conversion d'image depuis les données")
    func imageConversion() async throws {
        // Créer une image UIKit simple avec une taille spécifique
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        
        let imageData = testImage.pngData()
        let note = ArgumentNote(title: "Test", imageData: imageData)
        
        #expect(note.image != nil)
        #expect(note.isImageNote == true)
        // Vérifier que l'image a une taille raisonnable (peut être mise à l'échelle)
        if let noteImage = note.image {
            #expect(noteImage.size.width > 0)
            #expect(noteImage.size.height > 0)
        }
    }
}

@Suite("Tests pour l'interface utilisateur")
struct UITests {
    
    @Test("Filtrage des notes par titre")
    func filterNotesByTitle() async throws {
        let notes = [
            ArgumentNote(title: "Argument important", content: "Contenu"),
            ArgumentNote(title: "Note personnelle", content: "Autre contenu"),
            ArgumentNote(title: "Argument secondaire", content: "Encore du contenu")
        ]
        
        let searchText = "argument"
        let filtered = notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
        
        #expect(filtered.count == 2)
        #expect(filtered.contains { $0.title == "Argument important" })
        #expect(filtered.contains { $0.title == "Argument secondaire" })
    }
    
    @Test("Filtrage des notes par contenu")
    func filterNotesByContent() async throws {
        let notes = [
            ArgumentNote(title: "Titre 1", content: "Information importante"),
            ArgumentNote(title: "Titre 2", content: "Données personnelles"),
            ArgumentNote(title: "Titre 3", content: "Information générale")
        ]
        
        let searchText = "information"
        let filtered = notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
        
        #expect(filtered.count == 2)
        #expect(filtered.contains { $0.content == "Information importante" })
        #expect(filtered.contains { $0.content == "Information générale" })
    }
    
    @Test("Validation du titre pour la sauvegarde")
    func titleValidation() async throws {
        let validTitles = ["Titre valide", "  Titre avec espaces  ", "123", "émojis 🎉"]
        let invalidTitles = ["", "   ", "  \t  ", "\n\n", " \t\n "]
        
        for title in validTitles {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(!trimmed.isEmpty, "Le titre '\(title)' devrait être valide après trim")
        }
        
        for title in invalidTitles {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(trimmed.isEmpty, "Le titre '\(title)' devrait être invalide après trim")
        }
    }
}

@Suite("Tests de performance et edge cases")
struct EdgeCaseTests {
    
    @Test("Gestion des caractères spéciaux dans le titre")
    func specialCharactersInTitle() async throws {
        let specialTitles = [
            "Titre avec émojis 🎉📱",
            "Caractères spéciaux: àéèùç",
            "Symboles: ∞ ± ≤ ≥",
            "Guillemets: \"test\" 'test'",
            "Tirets: test-test_test"
        ]
        
        for title in specialTitles {
            let note = ArgumentNote(title: title, content: "Test content")
            #expect(note.title == title)
            #expect(note.contentPreview == "Test content")
        }
    }
    
    @Test("Gestion des très longs titres")
    func veryLongTitle() async throws {
        let longTitle = String(repeating: "Très long titre ", count: 20) // ~320 caractères
        let note = ArgumentNote(title: longTitle, content: "Contenu")
        
        #expect(note.title == longTitle)
        #expect(note.title.count > 300)
        #expect(note.contentPreview == "Contenu")
    }
    
    @Test("Gestion des données d'image corrompues")
    func corruptedImageData() async throws {
        let corruptedData = Data([0xFF, 0xFF, 0xFF, 0xFF]) // Données invalides
        let note = ArgumentNote(title: "Test", imageData: corruptedData)
        
        #expect(note.isImageNote == true)
        #expect(note.imageData == corruptedData)
        #expect(note.image == nil) // L'image ne peut pas être créée à partir de données corrompues
        #expect(note.contentPreview == "📷 Image")
    }
    
    @Test("Performance avec beaucoup de notes")
    func performanceWithManyNotes() async throws {
        let startTime = Date()
        
        // Créer 1000 notes
        var notes: [ArgumentNote] = []
        for i in 0..<1000 {
            notes.append(ArgumentNote(title: "Note \(i)", content: "Contenu \(i)"))
        }
        
        let creationTime = Date().timeIntervalSince(startTime)
        #expect(creationTime < 2.0, "La création de 1000 notes devrait prendre moins de 2 secondes")
        
        // Test de filtrage - chercher des notes contenant "99"
        let filterStartTime = Date()
        let filtered = notes.filter { $0.title.contains("99") }
        let filterTime = Date().timeIntervalSince(filterStartTime)
        
        #expect(filterTime < 0.1, "Le filtrage devrait être rapide")
        
        // Calcul correct : Notes avec "99" dans le titre
        // Note 99, Note 199, Note 299, ..., Note 999 = 10 notes
        // Plus Note 990, 991, 992, 993, 994, 995, 996, 997, 998, 999 = 10 notes supplémentaires
        // Mais Note 999 est déjà comptée, donc 19 au total
        #expect(filtered.count == 19, "Il devrait y avoir 19 notes contenant '99' dans le titre")
    }
}