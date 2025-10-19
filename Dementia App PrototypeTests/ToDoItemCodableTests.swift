//
//  ToDoItemCodableTests.swift
//  Dementia App PrototypeTests
//
//  Created by Jeffery Wang on 19/10/2025.
//

import XCTest
@testable import Dementia_App_Prototype

final class ToDoItemCodableTests: XCTestCase {
    func testToDoItemEncodesAndDecodes() throws {
        let item = ToDoItem(id: UUID(), itemName: "Test", desc: "Optional", checked: false, imageName: "dog", present: true)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(ToDoItem.self, from: data)
        XCTAssertEqual(item, decoded)
    }
}

