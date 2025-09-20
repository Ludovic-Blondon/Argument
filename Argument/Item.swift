//
//  Item.swift
//  Argument
//
//  Created by Ludovic Blondon on 20/09/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
