//
//  DetailView.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 30/9/2025.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct DetailView: View {
    
    @State var editing = false
    @State var titlePlaceHolder = ""
    var descPlaceHolder = ""
    
    var toDoIndex: Int
    var toDoBinding: Binding<ToDoItem> {
        $viewModel.toDos[toDoIndex]
    }
    @ObservedObject var viewModel: ToDoViewModel = .shared
    @Environment(\.dismiss) var dismiss
    
    private var relativeFormatter: RelativeDateTimeFormatter {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short  // gives "in 4 hr"
        return f
    }
    
    var shareMessage: String {
        let taskName = viewModel.toDos[toDoIndex].itemName
        let taskTime = viewModel.toDos[toDoIndex].when.formatted(date: .abbreviated, time: .shortened)
        return "Hey, just wondering if you could help me with a task. I need help with Task: \(taskName) at \(taskTime). Would you be free to help?"
    }

    
    var body: some View {
        ZStack {
            VStack {
                Image(viewModel.toDos[toDoIndex].imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)              
                    .ignoresSafeArea(edges: [.leading, .trailing])
                    .clipped()
                    .overlay(
                        Rectangle()
                            .fill(toDoBinding.wrappedValue.checked ? Color.green.opacity(0.3) : Color.white.opacity(0))
                            .shadow(radius: 5)
                        )
                
                Spacer().frame(height:40)
                    
                Text(viewModel.toDos[toDoIndex].itemName)
                    .font(.title)
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.center)
                
                Text("(\(relativeFormatter.localizedString(for: viewModel.toDos[toDoIndex].when, relativeTo: Date())))")
                    .foregroundColor(
                        viewModel.toDos[toDoIndex].when.timeIntervalSinceNow <= 3600 && !viewModel.toDos[toDoIndex].checked
                            ? .orange //due 1 hour or less
                            : .gray //otherwise gray
                        )
                
                Text(viewModel.toDos[toDoIndex].desc ?? "This is easy, you’ve got this!") //aesthic, for when the user doesn't enter a description for the task
                    .padding()
                    .foregroundColor(Color("CustomBrownColor"))
                    .font(.system(size: 18))
                    .frame(width: 400)
                
                Spacer()
                    .frame(height: 100)
                
                Button(action: {
                    viewModel.toDos[toDoIndex].checked.toggle()
                    if toDoBinding.wrappedValue.checked {
                        AudioServicesPlaySystemSound(1504) //1370, 1342,1504
                    } else {
                        AudioServicesPlaySystemSound(1571)
                    }
                }) {
                    Text(toDoBinding.wrappedValue.checked ? "Completed!" : "Mark as complete")
                        .padding()
                        .frame(width: 200)
                        .foregroundColor(.black)
                        .background(toDoBinding.wrappedValue.checked ? Color("GreenColor") : Color.white)
                        .cornerRadius(50)
                        .font(.system(size: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(toDoBinding.wrappedValue.checked ? Color("DarkGreenColor") : Color("DarkAccentColor"), lineWidth: 2)
                        )
                }
                
                Spacer()
                
                NavigationLink(destination: EditTaskView(toDoIndex: toDoIndex)) {
                    Text("Edit task")
                        .padding()
                        .frame(width: 200)
                        .foregroundColor(.orange)
                        .cornerRadius(50)
                        .font(.system(size: 20))
                }
                
                Text("Having Trouble?") .foregroundColor(.white)
                    .padding(.vertical, 20)
                Spacer()
            } .ignoresSafeArea(edges: .top) //moves everything up to a little to the notch
                
            VStack {
                Spacer() .frame(height: 70)
                HStack {
                    Button(action: { dismiss() }) {
                        Text("< Back")
                            .padding()
                            .foregroundColor(.black)
                            .background(.thinMaterial)   // frosted glass background
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    ShareLink(item: shareMessage) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding()
                            .foregroundColor(.black)
                            .background(.thinMaterial)
                            .cornerRadius(20)
                    }

                    
                } .padding(.horizontal)
                    .frame(width: 400)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .opacity(toDoBinding.wrappedValue.checked ? 1 : 0)
                
                Spacer() .frame(height: 135) //185
                
                HStack {
                    Spacer()
                    
                    
                } .frame(width: 380)
                
                Spacer()
            } .ignoresSafeArea(edges: .top)
        }.navigationBarBackButtonHidden(true)
    }
}


#Preview {
    DetailView(toDoIndex: 1)
}
