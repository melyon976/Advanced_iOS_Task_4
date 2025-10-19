//
//  ToDoViewModelTests.swift
//  Dementia App PrototypeTests
//
//  Created by Jeffery Wang on 19/10/2025.
//

// ToDoViewModelTests.swift
import XCTest
@testable import Dementia_App_Prototype

final class ToDoViewModelTests: XCTestCase {
    var vm: ToDoViewModel!
    var originalSavedData: Data?

    override func setUp() {
        super.setUp()
        vm = ToDoViewModel.shared
        originalSavedData = UserDefaults.standard.data(forKey: "toDos")
        vm.resetToDos()
    }

    override func tearDown() {
        if let originalSavedData {
            UserDefaults.standard.set(originalSavedData, forKey: "toDos")
        } else {
            UserDefaults.standard.removeObject(forKey: "toDos")
        }
        vm = nil
        super.tearDown()
    }

    func testSetDefaultPopulatesList() {
        vm.setDefaultToDos()
        XCTAssertFalse(vm.toDos.isEmpty)
        XCTAssertTrue(vm.toDos.allSatisfy { $0.present })
    }

    func testSaveAndLoadFromUserDefaultsRoundTrip() {
        vm.setDefaultToDos()
        let original = vm.toDos
        vm.saveToUserDefaults()
        vm.toDos = []
        vm.loadFromUserDefaults()
        XCTAssertEqual(vm.toDos, original)
    }

    func testMoveToEndMovesTheCorrectItem() {
        vm.setDefaultToDos()
        guard vm.toDos.count >= 2 else { return XCTFail("Need at least two items") }
        let firstID = vm.toDos.first!.id
        vm.moveToEnd(at: 0)
        XCTAssertEqual(vm.toDos.last?.id, firstID)
    }

    func testResetToDosClearsPersistenceAndResetsDefaults() {
        vm.toDos = []
        vm.saveToUserDefaults()
        vm.resetToDos()
        XCTAssertFalse(vm.toDos.isEmpty)
        XCTAssertNotNil(UserDefaults.standard.data(forKey: "toDos"))
    }
}

