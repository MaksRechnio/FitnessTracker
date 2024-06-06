//
//  BulkableTabView.swift
//  Bulkable
//
//  Created by Maksymilian Rechnio on 28/03/2024.
//

import SwiftUI

struct BulkableTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    
    var body: some View {
        TabView(selection: $selectedTab){
            HomeView()
                .tag("Home")
                .tabItem{
                    Image(systemName: "house")
                }
                .environmentObject(manager)
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "person")
                }
        }
        
    }
}

#Preview {
    BulkableTabView()
}
