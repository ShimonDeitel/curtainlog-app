import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: CurtainBlindLogItem?

    var body: some View {
        Group {

        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            row(for: item)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingItem = item }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Curtain & Blind Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .foregroundColor(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .foregroundColor(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)

        }

    }

    private func row(for item: CurtainBlindLogItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.room)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.windowSize)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
            Text(item.fabricSource)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Theme.accent)
            Text("No Windows yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

}

struct EditItemView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var item: CurtainBlindLogItem?

    @State private var room: String = ""
    @State private var windowSize: String = ""
    @State private var fabricSource: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Room") {
                    TextField("Room", text: $room)
                        .accessibilityIdentifier("fieldRoom")
                }
                Section("Window Size") {
                    TextField("Window Size", text: $windowSize)
                        .accessibilityIdentifier("fieldWindowSize")
                }
                Section("Fabric/Source") {
                    TextField("Fabric/Source", text: $fabricSource)
                        .accessibilityIdentifier("fieldFabricSource")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Window" : "Edit Window")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(room.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    room = item.room
                    windowSize = item.windowSize
                    fabricSource = item.fabricSource
                }
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.room = room
            existing.windowSize = windowSize
            existing.fabricSource = fabricSource
            store.update(existing)
        } else {
            let newItem = CurtainBlindLogItem(room: room, windowSize: windowSize, fabricSource: fabricSource)
            store.add(newItem)
        }
        dismiss()
    }
}
