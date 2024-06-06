//
//  HomeView.swift
//  Bulkable
//
//  Created by Maksymilian Rechnio on 28/03/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    
    let welcomeArray = ["Welcome", "Welkom", "Witaj", "Willkommen"]
    @State private var currentIndex = 0
    
    var body: some View {
        
        VStack(alignment: .center){
            
            Text(welcomeArray[currentIndex])
                .font(.largeTitle)
                .padding()
                .foregroundColor(.cyan)
                .animation(.easeInOut(duration: 1), value: currentIndex)
                .onAppear{
                    startWelcomeTimer()
                }
                
            
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id}), id: \.key) { item in ActivityCard(activity: item.value)
                    
                }
                
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear{
            manager.fetchTodaySteps()
            manager.fetchTodayCalories()
            manager.fetchHeartRate()
        }
        
    }
    
    func startWelcomeTimer() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % welcomeArray.count
            }
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
