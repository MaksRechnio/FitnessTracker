//
//  ActivityCard.swift
//  Bulkable
//
//  Created by Maksymilian Rechnio on 28/03/2024.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}

struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        
        ZStack {
            Color(.systemGray6)
                .cornerRadius(15)
            
            VStack(spacing: 20) {
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5){
                        
                        Text(activity.title)
                            .font(.system(size: 20))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Text(activity.subtitle)
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(.blue)
                    
                    
                }

                
                Text(activity.amount)
                    .font(.system(size: 24))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }
            .padding()
            .cornerRadius(15)
        }
    }
}
            

#Preview {
    ActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: "2,378"))
}
