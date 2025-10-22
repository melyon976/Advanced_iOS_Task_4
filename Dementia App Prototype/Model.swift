//
//  Model.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon, Chi Sum Lau, Jeffery Wang on 6/10/2025.
//

import Foundation

struct ToDoItem: Codable, Identifiable, Equatable {
    let id: UUID
    var itemName: String
    var desc: String?
    var checked: Bool
    var imageName: String
    var when: Date = Date()
    var present: Bool //means that the task isn't deleted and wants to be shown in the list. Needed for out-of-bounds errors
}
