import XCTest
@testable import Trimline

@MainActor
final class TrimlineTests: XCTestCase {
    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(ProjectEntry(room: "Test", material: "Today", lengthFeet: "Good"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        let store = Store()
        store.isPro = false
        while store.entries.count < Store.freeLimit {
            store.add(ProjectEntry(room: "X", material: "Y", lengthFeet: "Z"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProEvenAtLimit() {
        let store = Store()
        store.isPro = true
        while store.entries.count < Store.freeLimit {
            store.add(ProjectEntry(room: "X", material: "Y", lengthFeet: "Z"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesEntry() {
        let store = Store()
        let entry = ProjectEntry(room: "ToDelete", material: "Today", lengthFeet: "Good")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateModifiesEntry() {
        let store = Store()
        var entry = ProjectEntry(room: "Orig", material: "Today", lengthFeet: "Good")
        store.add(entry)
        entry.room = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.room, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
