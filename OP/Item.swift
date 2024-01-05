//
//  Item.swift
//  OP
//
//  Created by Casper Aurelius on 5/1/2024.
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
