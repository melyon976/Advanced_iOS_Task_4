//
//  ViewModel.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 6/10/2025.
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
}
