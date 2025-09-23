//
//  WebPConverter.swift
//  Argument
//
//  Created by Ludovic Blondon on 23/09/2025.
//

import UIKit
import Foundation

/// Utilitaire pour la conversion d'images au format WebP
class WebPConverter {

    /// Convertit une UIImage en données WebP
    /// - Parameters:
    ///   - image: L'image à convertir
    ///   - quality: La qualité de compression (0.0 à 1.0)
    /// - Returns: Les données WebP ou nil si la conversion échoue
    static func convertToWebP(image: UIImage, quality: Float = 0.9) -> Data? {
        // Pour l'instant, on utilise une approche fallback
        // En production, on utiliserait libwebp ou SDWebImage

        // Stratégie 1: Essayer via les formats natifs iOS
        if let webpData = convertUsingNativeAPIs(image: image) {
            return webpData
        }

        // Stratégie 2: Fallback vers JPEG optimisé
        // (En attendant l'intégration complète de libwebp)
        return image.jpegData(compressionQuality: CGFloat(quality))
    }

    /// Tentative de conversion via les APIs natives iOS
    private static func convertUsingNativeAPIs(image: UIImage) -> Data? {
        // Vérifier d'abord si WebP est supporté pour éviter les logs d'erreur
        guard isWebPSupported() else {
            return nil
        }

        guard let cgImage = image.cgImage else { return nil }

        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data,
            "org.webmproject.webp" as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.9
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        if CGImageDestinationFinalize(destination) {
            return data as Data
        }

        return nil
    }

    /// Vérifie si WebP est supporté nativement sur le système
    static func isWebPSupported() -> Bool {
        let supportedTypes = CGImageDestinationCopyTypeIdentifiers()
        let typesArray = supportedTypes as! [String]
        return typesArray.contains("org.webmproject.webp")
    }

    /// Version avec intégration libwebp (à activer quand la dépendance sera configurée)
    /*
    static func convertToWebPWithLibWebP(image: UIImage, quality: Float = 0.9) -> Data? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow

        guard let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else {
            return nil
        }

        let pixels = CFDataGetBytePtr(pixelData)

        // Utilisation de libwebp
        var output: UnsafeMutablePointer<UInt8>?
        let size = WebPEncodeRGBA(
            pixels,
            Int32(width),
            Int32(height),
            Int32(bytesPerRow),
            quality,
            &output
        )

        guard size > 0, let outputData = output else {
            return nil
        }

        let webpData = Data(bytes: outputData, count: Int(size))
        WebPFree(outputData)

        return webpData
    }
    */
}