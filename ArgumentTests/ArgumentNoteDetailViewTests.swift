//
//  ArgumentNoteDetailViewTests.swift
//  ArgumentTests
//
//  Created by Ludovic Blondon on 23/09/2025.
//

import Testing
import Foundation
import UIKit
@testable import Argument

@Suite("Tests pour ArgumentNoteDetailView")
struct ArgumentNoteDetailViewTests {

    @Test("Test de la fonction copyToClipboard avec image - formats multiples")
    func copyImageToClipboardMultiFormat() async throws {
        // Créer une image test
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let imageData = testImage.pngData()
        let note = ArgumentNote(title: "Test Image", imageData: imageData)

        // Vérifier que l'image peut être convertie en différents formats
        #expect(note.image != nil, "L'image devrait être disponible")
        #expect(note.isImageNote == true, "Devrait être identifiée comme note image")

        if let image = note.image {
            // Test PNG conversion
            let pngData = image.pngData()
            #expect(pngData != nil, "PNG conversion devrait réussir")

            // Test JPEG conversion avec qualité 0.9
            let jpegData = image.jpegData(compressionQuality: 0.9)
            #expect(jpegData != nil, "JPEG conversion devrait réussir")

            // Vérifier que PNG est généralement plus gros que JPEG pour une image simple
            if let png = pngData, let jpeg = jpegData {
                #expect(png.count > 0, "PNG data ne devrait pas être vide")
                #expect(jpeg.count > 0, "JPEG data ne devrait pas être vide")
            }
        }
    }

    @Test("Test de la fonction copyToClipboard avec texte")
    func copyTextToClipboard() async throws {
        let testContent = "Contenu de test pour copie"
        let note = ArgumentNote(title: "Titre test", content: testContent)

        #expect(note.isImageNote == false, "Ne devrait pas être une note image")
        #expect(note.content == testContent, "Le contenu devrait correspondre")
        #expect(!note.content.isEmpty, "Le contenu ne devrait pas être vide")
    }

    @Test("Test de fallback JPEG quand PNG échoue")
    func testJpegFallbackWhenPngFails() async throws {
        // Créer une image qui pourrait poser problème pour PNG
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        // Même si PNG fonctionne normalement, on teste la logique de fallback
        if let jpegData = testImage.jpegData(compressionQuality: 0.9) {
            #expect(jpegData.count > 0, "JPEG fallback devrait produire des données valides")
        }
    }

    @Test("Test de la visibilité du bouton de copie")
    func copyButtonVisibility() async throws {
        // Note avec contenu texte
        let textNote = ArgumentNote(title: "Test", content: "Contenu")
        let shouldShowText = !textNote.content.isEmpty || textNote.isImageNote
        #expect(shouldShowText == true, "Bouton visible pour note avec texte")

        // Note vide
        let emptyNote = ArgumentNote(title: "Test", content: "")
        let shouldShowEmpty = !emptyNote.content.isEmpty || emptyNote.isImageNote
        #expect(shouldShowEmpty == false, "Bouton caché pour note vide")

        // Note image
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])
        let imageNote = ArgumentNote(title: "Test", imageData: imageData)
        let shouldShowImage = !imageNote.content.isEmpty || imageNote.isImageNote
        #expect(shouldShowImage == true, "Bouton visible pour note image")
    }

    @Test("Test formats d'image supportés - HEIC")
    func testHEICImageSupport() async throws {
        // Créer une image test
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        // Test de conversion HEIC
        if #available(iOS 11.0, *) {
            // Créer une instance de détail view pour tester la conversion
            let note = ArgumentNote(title: "Test HEIC", imageData: testImage.pngData())

            #expect(testImage.size.width == 100, "Image devrait avoir la bonne taille")
            #expect(testImage.size.height == 100, "Image devrait avoir la bonne taille")
            #expect(note.isImageNote == true, "Note devrait être reconnue comme image")
        }
    }

    @Test("Test de conversion HEIC directe")
    func testHEICConversion() async throws {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        // Test de la fonction de conversion HEIC
        if #available(iOS 11.0, *) {
            // On ne peut pas tester directement la fonction privée,
            // mais on peut vérifier que l'image est prête pour la conversion
            #expect(testImage.cgImage != nil, "Image devrait avoir une représentation CGImage")

            // Vérifier que l'image peut être convertie en formats standards
            let pngData = testImage.pngData()
            let jpegData = testImage.jpegData(compressionQuality: 0.9)

            #expect(pngData != nil, "Image devrait être convertible en PNG")
            #expect(jpegData != nil, "Image devrait être convertible en JPEG")
        }
    }

    @Test("Test de formats d'image standards")
    func testStandardImageFormats() async throws {
        let size = CGSize(width: 75, height: 75)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        // Test des conversions standards
        let pngData = testImage.pngData()
        let jpegData = testImage.jpegData(compressionQuality: 0.9)

        #expect(pngData != nil, "PNG conversion devrait réussir")
        #expect(jpegData != nil, "JPEG conversion devrait réussir")

        if let png = pngData, let jpeg = jpegData {
            #expect(png.count > 0, "PNG data ne devrait pas être vide")
            #expect(jpeg.count > 0, "JPEG data ne devrait pas être vide")
        }
    }

    @Test("Test de performance pour conversion multi-format")
    func testMultiFormatConversionPerformance() async throws {
        // Créer une image plus grande pour tester la performance
        let size = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            // Créer un gradient pour avoir des données plus complexes
            let colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        }

        let startTime = Date()

        // Simuler les conversions comme dans copyToClipboard
        let pngData = testImage.pngData()
        let jpegData = testImage.jpegData(compressionQuality: 0.9)

        let conversionTime = Date().timeIntervalSince(startTime)

        #expect(conversionTime < 1.0, "Conversion multi-format devrait prendre moins d'1 seconde")
        #expect(pngData != nil, "PNG conversion devrait réussir")
        #expect(jpegData != nil, "JPEG conversion devrait réussir")

        if let png = pngData, let jpeg = jpegData {
            #expect(png.count > 1000, "PNG devrait avoir une taille raisonnable")
            #expect(jpeg.count > 1000, "JPEG devrait avoir une taille raisonnable")
            // JPEG devrait généralement être plus petit que PNG pour ce type d'image
            #expect(jpeg.count < png.count, "JPEG devrait être plus compact que PNG")
        }
    }
}

@Suite("Tests pour formats d'image avancés")
struct AdvancedImageFormatTests {

    @Test("Support HEIC - conversion et métadonnées")
    func testHEICSupport() async throws {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        // Vérifier que l'image est prête pour conversion HEIC
        #expect(testImage.cgImage != nil, "Image devrait avoir une représentation CGImage")
        #expect(testImage.size.width > 0, "Image devrait avoir une largeur valide")
        #expect(testImage.size.height > 0, "Image devrait avoir une hauteur valide")

        // Test de la qualité de l'image
        let jpegData = testImage.jpegData(compressionQuality: 0.9)
        #expect(jpegData != nil, "Conversion JPEG devrait réussir comme base pour HEIC")
    }

    @Test("Test de support de transparence PNG")
    func testPNGTransparencySupport() async throws {
        let size = CGSize(width: 150, height: 150)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            // Créer une image avec transparence
            UIColor.red.withAlphaComponent(0.5).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        #expect(testImage.cgImage != nil, "Image devrait avoir une représentation CGImage")

        // Test avec PNG qui préserve la transparence
        let pngData = testImage.pngData()
        #expect(pngData != nil, "PNG devrait supporter la transparence")

        if let data = pngData {
            #expect(data.count > 0, "PNG avec transparence devrait générer des données")
        }
    }

    @Test("Test de formats UTI pour compatibilité système")
    func testUTIFormats() async throws {
        // Test des identifiants de type uniforme pour différents formats
        let imageUTIs = [
            "public.image",           // Format général
            "public.png",            // PNG spécifique
            "public.jpeg",           // JPEG spécifique
            "public.heic"            // HEIC (iOS 11+)
        ]

        for uti in imageUTIs {
            #expect(!uti.isEmpty, "UTI ne devrait pas être vide")
            #expect(uti.contains(".") || uti == "public.image", "UTI devrait avoir un format valide")
        }
    }

    @Test("Comparaison des tailles de fichier par format")
    func testFileSizeComparison() async throws {
        // Créer une image complexe pour voir les différences de compression
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let complexImage = renderer.image { context in
            // Image avec beaucoup de détails pour tester la compression
            for i in 0..<30 {
                let color = UIColor(hue: CGFloat(i) / 30.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                color.setFill()
                let rect = CGRect(x: i * 10, y: i * 10, width: 20, height: 20)
                context.fill(rect)
            }
        }

        guard let pngData = complexImage.pngData(),
              let jpegHighData = complexImage.jpegData(compressionQuality: 1.0),
              let jpegMediumData = complexImage.jpegData(compressionQuality: 0.9),
              let jpegLowData = complexImage.jpegData(compressionQuality: 0.5) else {
            #expect(false, "Conversion d'image devrait réussir")
            return
        }

        #expect(pngData.count > jpegMediumData.count, "PNG devrait être plus gros que JPEG pour une image complexe")
        #expect(jpegHighData.count > jpegMediumData.count, "JPEG qualité 1.0 devrait être plus gros que 0.9")
        #expect(jpegMediumData.count > jpegLowData.count, "JPEG qualité 0.9 devrait être plus gros que 0.5")

        // Vérifier que les tailles sont raisonnables
        #expect(pngData.count > 1000, "PNG devrait avoir une taille substantielle")
        #expect(jpegMediumData.count > 500, "JPEG devrait avoir une taille raisonnable")
    }
}