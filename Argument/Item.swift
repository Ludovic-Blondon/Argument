//
//  ArgumentNote.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import Foundation
import SwiftData
import UIKit

@Model
final class ArgumentNote {
    var title: String
    var content: String
    var imageData: Data?
    var createdAt: Date
    var modifiedAt: Date
    
    init(title: String, content: String = "", imageData: Data? = nil) {
        self.title = title
        self.content = content
        self.imageData = imageData
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    // Computed property pour obtenir l'image
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    // Méthode pour mettre à jour la date de modification
    func updateModificationDate() {
        self.modifiedAt = Date()
    }
    
    // Computed property pour un aperçu du contenu
    var contentPreview: String {
        if !content.isEmpty {
            return String(content.prefix(100))
        } else if imageData != nil {
            return "📷 Image"
        } else {
            return "Note vide"
        }
    }
    
    // Computed property pour vérifier si c'est une note image
    var isImageNote: Bool {
        return imageData != nil
    }
}
