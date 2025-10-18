//
//  AddTaskView.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 30/9/2025.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox
import UserNotifications

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss        // to close the screen after saving
    @ObservedObject var viewModel = ToDoViewModel.shared
    
    @State private var taskName = ""
    @State private var taskDescription = ""
    @State private var imageName = "dog"     // default image or let user choose later
    @State private var when: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())! //will set to due in one hours time from now
    let db = Firestore.firestore()
    @State private var result: String = "[result]"
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    
    @State private var reminderMinutes: Int = 0
    let reminderOptions = [0, 5, 10, 15, 30] // minutes before

    var body: some View {
        ZStack {Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                
                Text("Add New Task")
                    .font(.title)
                Spacer() .frame(height: 20)
                
                Text("Task Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("eg. Walk the dog", text: $taskName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                Spacer() .frame(height: 5)
                
                Text("Description (optional)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Tap here to add description", text: $taskDescription)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 1)
                    )
                Spacer() .frame(height: 5)
                
//                Text("When should we remind you?")
//                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Time to complete task")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                DatePicker(
                    "Select a date",
                    selection: $when,
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
                
                Spacer() .frame(height: 5)
                
                HStack {
                    Text("Remind me before:")
                        .font(.body)
                        .padding(.leading) // a little breathing room from the edge
                    
                    Spacer().frame(width: 60)
                    
                    Picker("Remind me before", selection: $reminderMinutes) {
                        ForEach(reminderOptions, id: \.self) { minutes in
                            Text(minutes == 0 ? "No reminder" : "\(minutes) min before")
                        }
                    }
                    .pickerStyle(.menu)
                    .background(Color(.systemGray6))
                    .cornerRadius(50)
                    .accentColor(.black)
                    .padding(.trailing, 12) // keep picker away from the right edge
                }
                .padding(.vertical, 10) // space above and below inside the rounded rect
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 1)
                )

                Spacer() .frame(height: 5)
                
                HStack {
                    Button("Cancel") {
                        dismiss()    // to go back to list
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 50).fill(.gray))
                    .foregroundColor(.white)
                    Spacer()
                    if taskName != "" { //been filled out
                        Button("Save") {
                            let newTask = ToDoItem(
                                id: UUID(),
                                itemName: taskName,
                                desc: taskDescription.isEmpty ? nil : taskDescription,
                                checked: false,
                                imageName: imageName,
                                when: when, //is gaurenteed
                                present: true
                            )
                            viewModel.toDos.append(newTask)   // adds to their list
                            if reminderMinutes > 0 {
                                NotificationManager.shared.scheduleNotification(for: taskName, at: when, reminderMinutes: reminderMinutes)
                            }
//                            else {
//                                NotificationManager.shared.scheduleNotification(for: taskName, at: when)
//                            }
                            
                            result = "Attempting to add tasks_not_completed..."
                            Task {
                                do {
                                    try await db.collection("users")
                                        .document("kjEt5qJlQoBUyg6GDkvy")
                                        .updateData([
                                            "tasks_not_completed": FieldValue.increment(1.0)
                                        ])
                                    result = "Updated document kjEt5qJlQoBUyg6GDkvy: tasks_not_completed incremented."
                                    print("Document kjEt5qJlQoBUyg6GDkvy tasks_not_completed incremented.")
                                } catch {
                                    result = "Error updating document: \(error.localizedDescription)"
                                    print("Error updating document: \(error)")
                                }
                            }
                            AudioServicesPlaySystemSound(1104)
                            
                            dismiss()     // go back to list
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 50).fill(Color("DarkAccentColor")))
                        .foregroundColor(.white)
                        
                    }
                } .padding(.horizontal, 30)
                Spacer()
            }
                .padding()
        }
    }
}

#Preview {
    AddTaskView()
}
