//
//  ViewModel.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon, Chi Sum Lau, Jeffery Wang on 6/10/2025.
//

import SwiftUI
import FirebaseFirestore

class ToDoViewModel: ObservableObject {
    static let shared = ToDoViewModel()
    
    @Published var toDos: [ToDoItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private init() {
        loadFromUserDefaults()
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(toDos) {
            UserDefaults.standard.set(encoded, forKey: "toDos")
        }
    }
    
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "toDos"),
           let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            toDos = decoded
        } else {
            setDefaultToDos()
        }
    }
    
    func setDefaultToDos() {
        let db = Firestore.firestore()
        toDos = [
            ToDoItem(
                id: UUID(),
                itemName: "Buy groceries",
                desc: "Apples, Carrots, Chicken breast, Eggs, Milk, Cheese, Bread, Rice, Olive oil, Nuts",
                checked: false,
                imageName: "groceries",
                when: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                present: true
            ),
            ToDoItem(
                id: UUID(),
                itemName: "Walk the dog",
                desc: "at 4pm",
                checked: true,
                imageName: "dog",
                when: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
                present: true
            ),

            ToDoItem(
                id: UUID(),
                itemName: "Read a book",
                desc: "Harry Potter + Book club later this week with Tommy and Angela",
                checked: false,
                imageName: "book",
                when: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
                present: true
            )
        ]
        Task {
            do {
                try await db.collection("users")
                    .document("kjEt5qJlQoBUyg6GDkvy")
                    .updateData([
                        "tasks_completed" : 1,
                        "tasks_not_completed" : 2
                    ])
                print("Successfully updated task numbers for user")
            } catch {
                print("Error updating document for user: \(error.localizedDescription)")
            }
        }
    }
    
    func resetToDos() {
        UserDefaults.standard.removeObject(forKey: "toDos") // clear persisted data
        setDefaultToDos() // resets in-memory data
    }
    
    func moveToEnd(at index: Int) {
        guard toDos.indices.contains(index) else { return } // prevent out-of-bounds
        let item = toDos.remove(at: index)
        toDos.append(item)
    }
    
    
    
    // MARK: - Upload tasks by userID
    func uploadAllTasksToFirestore(userID id: String) async -> Bool {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(id).collection("toDos")
        
        do {
            // Clear old tasks
            let snapshot = try await collectionRef.getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
            print("🧹 Cleared old tasks for user \(id)")
            
            // Upload current tasks
            for task in toDos {
                try collectionRef.document(task.id.uuidString).setData(from: task)
            }
            
            print("✅ Successfully synced all tasks to Firestore for user \(id)")
            return true
            
        } catch {
            print("❌ Failed to sync tasks for user \(id): \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Load tasks by userID
    func loadTasksFromFirestore(userID id: String) async -> Bool {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(id).collection("toDos")
        
        do {
            let snapshot = try await collectionRef.getDocuments()
            let tasks = try snapshot.documents.compactMap { document in
                try document.data(as: ToDoItem.self)
            }
            
            DispatchQueue.main.async {
                self.toDos = tasks
                print("✅ Successfully loaded \(tasks.count) tasks from Firestore for user \(id)")
            }
            
            return true
            
        } catch {
            print("❌ Failed to load tasks for user \(id): \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Upload tasks by username
    func uploadAllTasksToFirestore(username name: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            // Find document ID for username
            let querySnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: name)
                .getDocuments()
            
            guard let userDoc = querySnapshot.documents.first else {
                print("❌ No user found with username: \(name)")
                return false
            }
            
            let userID = userDoc.documentID
            let collectionRef = db.collection("users").document(userID).collection("toDos")
            
            // Clear old tasks
            let snapshot = try await collectionRef.getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
            print("🧹 Cleared old tasks for user \(name)")
            
            // Upload current tasks
            for task in toDos {
                try collectionRef.document(task.id.uuidString).setData(from: task)
            }
            
            print("✅ Successfully synced all tasks to Firestore for user \(name)")
            return true
            
        } catch {
            print("❌ Failed to sync tasks for user \(name): \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Load tasks by username
    func loadTasksFromFirestore(username name: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            // Find document ID for username
            let querySnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: name)
                .getDocuments()
            
            guard let userDoc = querySnapshot.documents.first else {
                print("❌ No user found with username: \(name)")
                return false
            }
            
            let userID = userDoc.documentID
            let collectionRef = db.collection("users").document(userID).collection("toDos")
            
            let snapshot = try await collectionRef.getDocuments()
            let tasks = try snapshot.documents.compactMap { document in
                try document.data(as: ToDoItem.self)
            }
            
            DispatchQueue.main.async {
                self.toDos = tasks
                print("✅ Successfully loaded \(tasks.count) tasks from Firestore for user \(name)")
            }
            
            return true
            
        } catch {
            print("❌ Failed to load tasks for user \(name): \(error.localizedDescription)")
            return false
        }
    }
}

extension ToDoViewModel {
    func initializeTasksForUser(username: String) async {
        let db = Firestore.firestore()
        
        do {
            // Query for user document
            let querySnapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            guard let userDoc = querySnapshot.documents.first else {
                print("❌ No user found with username: \(username)")
                return
            }
            
            let userID = userDoc.documentID
            let tasksCollection = db.collection("users").document(userID).collection("toDos")
            
            let snapshot = try await tasksCollection.getDocuments()
            
            if snapshot.documents.isEmpty {
                // New user
                await MainActor.run {
                    self.setDefaultToDos()
                }
                await self.uploadAllTasksToFirestore(username: username)
            } else {
                await self.loadTasksFromFirestore(username: username)
            }
            
        } catch {
            print("❌ Error initializing tasks for user \(username): \(error.localizedDescription)")
            // fallback: load default tasks locally and sync
            DispatchQueue.main.async {
                self.setDefaultToDos()
            }
            await self.uploadAllTasksToFirestore(username: username)
        }
    }
}
