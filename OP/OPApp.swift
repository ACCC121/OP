//
//  OPApp.swift
//  OP
//
//  Created by Casper Aurelius on 8/12/2023.
//

import SwiftUI
import SwiftData

@main
struct OPApp: App {
    var body: some Scene {
        WindowGroup {
            OpportunitiesListView()
        }
        .modelContainer(for: Contact.self)
    }
}
    

