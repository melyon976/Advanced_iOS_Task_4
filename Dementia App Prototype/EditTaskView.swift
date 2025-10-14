//
//  EditTaskView.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 6/10/2025.
//

import SwiftUI
import FirebaseFirestore

struct EditTaskView: View {
    var toDoIndex: Int
    var toDoBinding: Binding<ToDoItem> {
        $viewModel.toDos[toDoIndex]
    }
    
    @Environment(\.dismiss) var dismiss        // to close the screen after saving/deleting
    @State private var goHome = false
    
    @ObservedObject var viewModel = ToDoViewModel.shared
    
    @State private var taskName = "" //toDoBinding.wrappedValue.itemName
    @State private var taskDescription = "" //toDoBinding.wrappedValue.desc
    @State private var imageName = "dog"       // default or let user choose later
    @State private var reminderDate: Date? = nil
    
    var body: some View {
        ZStack {Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Text("Edit Task")
                    .font(.largeTitle)
                
                Spacer() .frame(height: 50)
                
                Text("Task Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("eg. Walk the dog", text: $taskName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                    .onAppear {
                        taskName = viewModel.toDos[toDoIndex].itemName
                    }
                Spacer() .frame(height: 5)
                
                Text("Description (optional):")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Tap to add description", text: $taskDescription)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                    .onAppear {
                        taskDescription = viewModel.toDos[toDoIndex].desc ?? "" // blank if desc is nil
                    }
                
                Spacer() .frame(height: 5)
                
                Text("When should we remind you?")
                    .frame(maxWidth: .infinity, alignment: .leading)

                DatePicker(
                    "Select a date",
                    selection: Binding(
                        get: { viewModel.toDos[toDoIndex].when },   // get actual saved date
                        set: { viewModel.toDos[toDoIndex].when = $0 } // save changes back to model
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .frame(width: 350)
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 1)
                )
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()   // go back to list, doesn't set anything
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 50).fill(.gray))
                    .foregroundColor(.white)
                    Spacer()
                    if taskName != "" { //if been filled out, show the button
                        Button("Save changes") {
                            viewModel.toDos[toDoIndex].itemName = taskName
                            if taskDescription != "" {    //if description has been changed, update
                                viewModel.toDos[toDoIndex].desc = taskDescription
                            }
                            dismiss() // go back to list
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 50).fill(Color("DarkAccentColor")))
                        .foregroundColor(.white)
                        
                    } else {
                        Button(" "){
                        }
                    }
                } .padding(.horizontal, 30)
                
                Spacer()
                
                Button("Delete this task") {
                    viewModel.toDos[toDoIndex].present = false
                    viewModel.moveToEnd(at: toDoIndex)
                    print(viewModel.toDos.map { $0.itemName })
                    dismiss() // go back to list
                } .foregroundColor(.red)
                
                Spacer()
            } .padding()
        }
    }
}


#Preview {
//    EditTaskView()
}
