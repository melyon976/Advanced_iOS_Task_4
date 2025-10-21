//
//  AccountsAndData.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 30/9/2025.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct Settings: View {
    var body: some View {
        Text("⚙️ Settings\n")
        
        Text("Dark/light mode")
        Text("Text size")
        Text("Sound on/off")
        
        Text("\nData and Statistics")
        Text("Account Details")
        Text("Friends/contacts")
    }
    
}

struct DataAndStats: View {
    let db = Firestore.firestore()
    @State private var result: String = "[result]" //placeholder while loading
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var born = 0
    @State private var errorMessage = ""
    @State private var tasksCompleted = 0
    @State private var tasksNotCompleted = 0
    
    @StateObject var viewModel = ToDoViewModel.shared
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                Text("📊 Accounts and Data\n") .font(.title) . frame(height: 50)
                
                ScrollView {
                    Spacer().frame(height: 20)
                    Image("JimStaffordPfp")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 170)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 5)
                    
                    if !firstName.isEmpty {
                        Text("\(firstName) \(lastName)") .font(.title) .padding()
                        Text("Age: \(2025 - born) years old")
                        Text("Carers: Gabby Stafford \n")
                        
                        Text("Task success rate: \(String(format: "%.f%%", (Double(tasksCompleted) / Double(tasksNotCompleted + tasksCompleted)) * 100))")
                        Text("Tasks complete: \(tasksCompleted) | Tasks incomplete: \(tasksNotCompleted)")
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        ProgressView("Loading user...")
                    }
                    
                    Button("Fetch existing users (All)") {
                        result = "Attempting to find user..."
                        allUsersResult = "Fetching users..."
                        Task {
                            do {
                                let snapshot = try await db.collection("users").getDocuments()
                                
                                var collectedUserData = ""
                                if snapshot.documents.isEmpty {
                                    collectedUserData = "No users found in the database."
                                } else {
                                    for document in snapshot.documents { //loop to present all the entries
                                        let data = document.data()
                                        let id = document.documentID
                                        collectedUserData += "Name: \(data["given_name"] as? String ?? "N/A") \(data["family_name"] as? String ?? "N/A")\n"
                                        collectedUserData += "Born: \(data["born"] as? Int ?? 0)\n"
                                        collectedUserData += "Account Type: \(data["account_type"] as? String ?? "[Unknown]")\n"
                                        collectedUserData += "ID: \(id)\n"
                                        collectedUserData += "-----\n"
                                    }
                                    collectedUserData += "Retrieved on: \(Date())"
                                }
                                
                                print("\n--- collectedUserData content ---")
                                print(collectedUserData)
                                print("-------------------------------")
                                
                                self.allUsersResult = collectedUserData // assign the accumulated data
                                self.result = "Successfully retrieved all users."
                            } catch {
                                self.allUsersResult = "Error retrieving documents: \(error.localizedDescription)"
                                self.result = "Error retrieving documents: \(error.localizedDescription)"
                            }
                        }
                        AudioServicesPlaySystemSound(1255)
                    }
                    .padding()
                    .foregroundColor(.blue)
                    .cornerRadius(20)
                    .underline()
                    
                    Text(allUsersResult)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(5)
                    //        Text("Percent completed (out of present)")
                    //        Text("Deleted tasks")
                    Spacer()
                    
                    Button("Load tasks from database") {
                        Task {
                            await viewModel.loadTasksFromFirestore(userID: "kjEt5qJlQoBUyg6GDkvy")
                        }
                    }
                    
                } .task { // runs when the view appears (async-friendly)
                    await loadUserDetails()
                }
            }
        }
    }
    
    func loadUserDetails() async {
        do {
            let document = try await db.collection("users").document("kjEt5qJlQoBUyg6GDkvy").getDocument()
            
            if let data = document.data() {
                firstName = data["given_name"] as? String ?? "N/A"
                lastName = data["family_name"] as? String ?? "N/A"
                born = data["born"] as? Int ?? 0
                tasksCompleted = data["tasks_completed"] as? Int ?? 0
                tasksNotCompleted = data["tasks_not_completed"] as? Int ?? 0
                print("Loaded user: \(firstName) \(lastName)")
            } else {
                errorMessage = "No data found for this user."
            }
        } catch {
            errorMessage = "Error loading user: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
}

struct AccountDetails: View {
    var body: some View {
        Text("👤 Account Details\n")
        Text("My account details")
        Text("Sign out")
    }
}

struct FriendsAndContacts: View {
    var body: some View {
        Text("👥 Friends and Contacts\n")
        Text("My account details")
        Text("Friends [permissions]")
        Text("Invite a friend")
    }
}

#Preview {
    //    Spacer()
    //    Settings()
    //    Spacer()
    //    DataAndStats()
    //    Spacer()
    //    AccountDetails()
    //    Spacer()
    //    FriendsAndContacts()
    //    Spacer()
    
    DataAndStats()
}
