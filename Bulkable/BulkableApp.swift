//
//  BulkableApp.swift
//  Bulkable
//
//  Created by Maksymilian Rechnio on 28/03/2024.
//

import SwiftUI

@main
struct BulkableApp: App {
    @StateObject var manager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            BulkableTabView()
                .environmentObject(manager)
                
        }
    }
}
