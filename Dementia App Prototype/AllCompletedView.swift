//
//  AllCompletedView.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon, Chi Sum Lau, Jeffery Wang on 6/10/2025.
//
import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct AllCompletedView: View {
    @ObservedObject var viewModel: ToDoViewModel = .shared
    
    var body: some View {
        Text("\n")
        Image("relaxImage")
            .resizable()
            .frame(width: 300, height: 240)
        Text("Well done!") .font(.title)
        Text("All tasks are complete for today 🎉\n\n") .font(.title2)
        Divider()
        
        
    }
}

#Preview {
    AllCompletedView()
}
