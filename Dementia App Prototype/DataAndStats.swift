//
//  AccountsAndData.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon, Chi Sum Lau, Jeffery Wang on 30/9/2025.
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
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var tasksCompleted = 0
    @State private var tasksNotCompleted = 0
    @State private var taskSuccessRate: Double? = nil
    @State private var born = 0
    @State private var errorMessage = ""
    @State private var allUsersResult = ""
    @State private var result = ""
    
    @State private var birthdateText: String = "N/A"
    @State private var ageText: String = "N/A"
    
    @State private var username = UserDefaults.standard.string(forKey: "loggedInUsername") ?? ""
    
    @StateObject var viewModel = ToDoViewModel.shared
    @State private var navigateToLanding = false
    
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
                        VStack(spacing: 4) {
                            Text("\(firstName) \(lastName)").font(.title)
                            Text("\nUsername: \(username)")
                            Text("Age: \(ageText) yrs old")
                            Text("Born: \(birthdateText)")
                            if let rate = taskSuccessRate {
                                        Text("\nTask success rate: \(String(format: "%.f%%", rate))")
                                
                                    } else {
                                        Text("\nTask success rate: N/A")
                                    }
                            
                        }.padding()
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage).foregroundColor(.red)
                    } else {
                        ProgressView("Loading user...")
                    }
                    
                    Button("\nLog out") {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.removeObject(forKey: "loggedInUsername")
                        navigateToLanding = true
                    }
                    .foregroundColor(.red)
                    .underline()
                    
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
                                        collectedUserData += "Name: \(data["first_name"] as? String ?? "N/A") \(data["last_name"] as? String ?? "N/A")\n"
                                        
                                        if let username = data["username"] as? String {
                                            let birthdate = await getBirthdateString(for: username) ?? "N/A"
                                            collectedUserData += "Born: \(birthdate)\n"
                                        }
                                        
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
                    .opacity(0)
                    
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
                    .opacity(0)
                    
                    Button("print currrent username") {
                        let currentUsername = UserDefaults.standard.string(forKey: "loggedInUsername") ?? ""
                        print("\(currentUsername) has \(taskSuccessRate ?? 0)"  )
                    }
                    .opacity(0)
                    
                    
                    
                    
                    
                } .task { // runs when the view appears (async-friendly)
                    await loadUserDetails()
                }
            }
        } .navigationDestination(isPresented: $navigateToLanding) { // The page it moves to
            LandingPage1()
        }
        .task {
            await loadUserDetails()
            await fetchBirthdateAndAge()
            
            // Await first, then unwrap
            let rate = await getTaskSuccessRate(for: username)
            if let taskSuccessRate = rate {
                print("Task success rate: \(taskSuccessRate)%")
                // You can assign to a @State variable if needed
                self.taskSuccessRate = taskSuccessRate
            } else {
                print("No task data available")
            }
        }
    }
    
    func loadUserDetails() async {
            guard !username.isEmpty else {
                errorMessage = "No username found."
                return
            }
            
            do {
                let snapshot = try await db.collection("users")
                    .whereField("username", isEqualTo: username)
                    .getDocuments()
                
                guard let document = snapshot.documents.first else {
                    errorMessage = "No user found with username \(username)."
                    return
                }
                
                let data = document.data()
                firstName = data["first_name"] as? String ?? "N/A"
                lastName = data["last_name"] as? String ?? "N/A"
                tasksCompleted = data["tasks_completed"] as? Int ?? 0
                tasksNotCompleted = data["tasks_not_completed"] as? Int ?? 0
            } catch {
                errorMessage = "Error loading user: \(error.localizedDescription)"
                print(errorMessage)
            }
        }
        
        // MARK: - Fetch Birthdate and Age
        func fetchBirthdateAndAge() async {
            guard !username.isEmpty else {
                birthdateText = "N/A"
                ageText = "N/A"
                return
            }
            
            do {
                let snapshot = try await db.collection("users")
                    .whereField("username", isEqualTo: username)
                    .getDocuments()
                
                guard let document = snapshot.documents.first,
                      let timestamp = document.data()["born"] as? Timestamp else {
                    birthdateText = "N/A"
                    ageText = "N/A"
                    return
                }
                
                // Format birthdate
                let date = timestamp.dateValue()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                birthdateText = formatter.string(from: date)
                
                // Calculate age
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
                ageText = "\(ageComponents.year ?? 0)"
                
            } catch {
                birthdateText = "N/A"
                ageText = "N/A"
                print("Error fetching birthdate/age: \(error.localizedDescription)")
            }
        }
    
    // MARK: - Get Birthdate string for a given username
    func getBirthdateString(for username: String) async -> String? {
        guard !username.isEmpty else { return nil }
        
        do {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            guard let document = snapshot.documents.first,
                  let timestamp = document.data()["born"] as? Timestamp else {
                return nil
            }
            
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy" // Customize format here
            return formatter.string(from: date)
            
        } catch {
            print("Error fetching birthdate for \(username): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Get task success rate for a username
    func getTaskSuccessRate(for username: String) async -> Double? {
        guard !username.isEmpty else { return nil }
        
        let db = Firestore.firestore()
        
        do {
            // 1. Get the user document by username
            let userSnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            guard let userDoc = userSnapshot.documents.first else {
                print("No user found for username: \(username)")
                return nil
            }
            
            let userID = userDoc.documentID
            
            // 2. Get the user's todos collection
            let todosSnapshot = try await db.collection("users")
                .document(userID)
                .collection("toDos")
                .getDocuments()
            
            // 3. Filter only present todos and count checked/unchecked
            let todos = todosSnapshot.documents.compactMap { try? $0.data(as: ToDoItem.self) }
            let presentTodos = todos.filter { $0.present }
            
            let checkedCount = presentTodos.filter { $0.checked }.count
            let uncheckedCount = presentTodos.filter { !$0.checked }.count
            let total = checkedCount + uncheckedCount
            
            guard total > 0 else { return nil } // avoid division by zero
            
            let successRate = (Double(checkedCount) / Double(total)) * 100
            return successRate
            
        } catch {
            print("Error fetching tasks for \(username): \(error.localizedDescription)")
            return nil
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
