import SwiftUI
import FirebaseFirestore
import AudioToolbox

struct DatabaseThings: View {
    let db = Firestore.firestore()
    @State private var result: String = "[result]"
    @State private var allUsersResult: String = "No users retrieved yet."
    @State private var soundID = 1543
    @State private var searchFirstName: String = "" // input from user

    var body: some View {
        Text("Testing External Database") .font(.title)
        Text("👩🏻‍🔬") .font(.largeTitle)
        
        VStack(spacing: 20) {
            Button("Submit new user") { // adds a new user document
                result = "Attempting to add user..."
                Task {
                    do {
                        let ref = try await db.collection("users").addDocument(data: [
                            "given_name": "Grace",
                            "family_name": "Stafford",
                            "born": 1998
                        ])
                        result = "Added with ID: \(ref.documentID)"
                        print("Document added with ID: \(ref.documentID)")
                    } catch {
                        result = "Error: \(error.localizedDescription)"
                        print("Error adding document: \(error)")
                    }
                }
                AudioServicesPlaySystemSound(1104)
            } .padding()
                .background(Color("AccentColor"))
                .foregroundColor(.black)
                .cornerRadius(20)
            
            //-----------------------------------------------------------------------------------
            
            Button("Retrieve existing users (All)") {
                result = "Attempting to find user..."
                allUsersResult = "Fetching users..." // clear and update the new variable
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
                                collectedUserData += "ID: \(id)\n"
                                collectedUserData += "Name: \(data["given_name"] as? String ?? "N/A") \(data["family_name"] as? String ?? "N/A")\n"
                                collectedUserData += "Born: \(data["born"] as? Int ?? 0)\n"
                                collectedUserData += "---\n"
                            }
                            collectedUserData += "Retrieved on: \(Date())"
                        }
                        
                        print("\n--- collectedUserData content ---")
                        print(collectedUserData)
                        print("-------------------------------")
                        
                        self.allUsersResult = collectedUserData // assigns the accumulated data
                        self.result = "Successfully retrieved all users."
                    } catch {
                        self.allUsersResult = "Error retrieving documents: \(error.localizedDescription)"
                        self.result = "Error retrieving documents: \(error.localizedDescription)"
                    }
                }
                AudioServicesPlaySystemSound(1255) //feedback sounds
            }
            .padding()
            .background(Color("CustomPinkColor"))
            .foregroundColor(.black)
            .cornerRadius(20)
            
            Button("Retrieve users by first name") {  //✅ WORKING CODE
                result = "Attempting to find user..."
                allUsersResult = "Fetching users..."
                
                Task {
                    do {
                        // Query Firestore for users where "first_name" matches searchFirstName
                        let snapshot = try await db.collection("users")
                            .whereField("given_name", isEqualTo: "Melissa")
                            .getDocuments()
                        print("---------------------")
                        print(result)
                        print(allUsersResult)
                        
                        var collectedUserData = ""
                        if snapshot.documents.isEmpty {
                            collectedUserData = "No users found with first name \"\(searchFirstName)\"."
                        } else {
                            for document in snapshot.documents {
                                let data = document.data()
                                let id = document.documentID
                                collectedUserData += "ID: \(id)\n"
                                collectedUserData += "Name: \(data["first_name"] as? String ?? "N/A") \(data["last_name"] as? String ?? "N/A")\n"
                                collectedUserData += "Born: \(data["born"] as? Date ?? Date())\n"
                                collectedUserData += "Account type: \(data["account_type"] as? String ?? "N/A")\n"
                                collectedUserData += "---\n"
                            }
                            collectedUserData += "Retrieved on: \(Date())"
                        }
                        
                        self.allUsersResult = collectedUserData
                        self.result = "Successfully retrieved users."
                        print(result)
                        print(allUsersResult)
                    } catch {
                        self.allUsersResult = "Error retrieving documents: \(error.localizedDescription)"
                        self.result = "Error retrieving documents: \(error.localizedDescription)"
                    }
                }
                AudioServicesPlaySystemSound(1255) // feedback sound
            }
            .padding()
            .background(Color("CustomOrangeColor"))
            .foregroundColor(.black)
            .cornerRadius(20)
            
            
            
            HStack { //sounds for testing purposes
                Button("Play sound") {
                    // AudioServicesPlaySystemSound(SystemSoundID(soundID))
                    AudioServicesPlaySystemSound(1150) //1008, 1060, 1170, 1263
                    soundID += 1
                }
                
                Button("+") {
                    soundID += 1
                }
                Button("-") {
                    soundID -= 1
                }
                Text("[\(soundID)]")
            }
            
            //-----------------------------------------------------------------------------------
            
            Button("Add to existing user (2)") { //use the .document(<documentID>) to edit
                result = "Attempting to add user..."
                Task {
                    do {
                        try await db.collection("users").document("kjEt5qJlQoBUyg6GDkvy").setData([
                            "given_name": "Jim",
                            "last_name" : "Stafford",
                            "born" : 1943
                        ])
                        result = "Added/Updated user with ID: Stacy"
                        print("Document written with ID: ada | \(Date())")
                    } catch {
                        result = "Error: \(error.localizedDescription)"
                        print("Error writing document: \(error)")
                    }
                }
                AudioServicesPlaySystemSound(1104)
            } .padding()
                .background(Color("CustomGreenColor"))
                .foregroundColor(.black)
                .cornerRadius(20)
            
            Button("Add tasks_completed to user") { //WORKING CODE!
                result = "Attempting to add tasks_completed..."
                Task {
                    do {
                        try await db.collection("users")
                            .document("kjEt5qJlQoBUyg6GDkvy")
                            .updateData([
                                "tasks_completed": FieldValue.increment(1.0)
                            ])
                        result = "Updated document kjEt5qJlQoBUyg6GDkvy: tasks_completed incremented."
                        print("Document kjEt5qJlQoBUyg6GDkvy tasks_completed incremented.")
                    } catch {
                        result = "Error updating document: \(error.localizedDescription)"
                        print("Error updating document: \(error)")
                    }
                }
                AudioServicesPlaySystemSound(1104)
            }
            
            Button("try to add incomplete task") { //WORKING CODE!
                Task {
                    do {
                        try await db.collection("users")
                            .document("kjEt5qJlQoBUyg6GDkvy")
                            .updateData([
                                "tasks_not_completed": FieldValue.increment(1.0)
                            ])
                        print("Document kjEt5qJlQoBUyg6GDkvy tasks_not_completed incremented.")
                    } catch {
                        print("Error updating document: \(error)")
                    }
                }
            }
            
            
            Button("set data") {  //changes only a few feilds, keeping the rest the same like name and birth year
                Task {
                    do {
                        try await db.collection("users")
                            .document("kjEt5qJlQoBUyg6GDkvy")
                            .updateData([
                                "tasks_completed" : 1,
                                "tasks_not_completed" : 2
                            ])
                        print("Successfully updated task numbers for user.")
                    } catch {
                        print("Error updating document for user: \(error.localizedDescription)")
                    }
                }
            }
            
            Text(result)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }
}



func addOneIncompleteTask (documentID: String) {
    let db = Firestore.firestore()
    
    Task {
        do {
            try await db.collection("users")
                .document("kjEt5qJlQoBUyg6GDkvy")
                .updateData([
                    "tasks_not_completed": FieldValue.increment(1.0)
                ])
            print("Document kjEt5qJlQoBUyg6GDkvy tasks_not_completed incremented.")
        } catch {
            print("Error updating document: \(error)")
        }
    }
}


#Preview {
    DatabaseThings()
}
