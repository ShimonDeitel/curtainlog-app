import XCTest
@testable import CurtainBlindLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = CurtainBlindLogItem(room: "A", windowSize: "B", fabricSource: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(CurtainBlindLogItem(room: "\(i)", windowSize: "B", fabricSource: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(CurtainBlindLogItem(room: "over", windowSize: "B", fabricSource: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(CurtainBlindLogItem(room: "\(i)", windowSize: "B", fabricSource: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = CurtainBlindLogItem(room: "A", windowSize: "B", fabricSource: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = CurtainBlindLogItem(room: "A", windowSize: "B", fabricSource: "C")
        store.add(item)
        item.room = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.room, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(CurtainBlindLogItem(room: "A", windowSize: "B", fabricSource: "C"))
        store.add(CurtainBlindLogItem(room: "D", windowSize: "E", fabricSource: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(CurtainBlindLogItem(room: "Persist", windowSize: "B", fabricSource: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.room == "Persist" }))
    }
}
