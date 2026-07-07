import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [CurtainBlindLogItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit is intentionally well above seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("curtainlog_items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CurtainBlindLogItem].self, from: data) else {
            items = [
        CurtainBlindLogItem(room: "Living Room", windowSize: "72in x 84in", fabricSource: "Linen, IKEA Ritva"),
        CurtainBlindLogItem(room: "Master Bedroom", windowSize: "48in x 60in", fabricSource: "Blackout, West Elm"),
        CurtainBlindLogItem(room: "Kitchen Nook", windowSize: "36in x 40in", fabricSource: "Café curtain, local seamstress")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: CurtainBlindLogItem) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: CurtainBlindLogItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CurtainBlindLogItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
