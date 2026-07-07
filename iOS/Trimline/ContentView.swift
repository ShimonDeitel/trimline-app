import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: ProjectEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.room)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Trimline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
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
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: ProjectEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.room).font(Theme.bodyFont).fontWeight(.semibold)
            Text(entry.material).font(Theme.captionFont).foregroundStyle(.secondary)
            if !entry.cost.isEmpty {
                Text(entry.cost).font(Theme.captionFont).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var room: String
    @State private var material: String
    @State private var lengthFeet: String
    @State private var cost: String
    @FocusState private var focusedField: Field?
    private enum Field { case f1, f2, f3, f4 }

    let existing: ProjectEntry?
    let onSave: (ProjectEntry) -> Void

    init(entry: ProjectEntry?, onSave: @escaping (ProjectEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _room = State(initialValue: entry?.room ?? "")
        _material = State(initialValue: entry?.material ?? "")
        _lengthFeet = State(initialValue: entry?.lengthFeet ?? "")
        _cost = State(initialValue: entry?.cost ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Room", text: $room)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_room")
                    TextField("Material", text: $material)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_material")
                    TextField("Lengthfeet", text: $lengthFeet)
                        .focused($focusedField, equals: .f3)
                        .accessibilityIdentifier("field_lengthFeet")
                    TextField("Notes", text: $cost)
                        .focused($focusedField, equals: .f4)
                        .accessibilityIdentifier("field_cost")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existing == nil ? "New Project" : "Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = ProjectEntry(
                            id: existing?.id ?? UUID(),
                            room: room,
                            material: material,
                            lengthFeet: lengthFeet,
                            cost: cost,
                            createdAt: existing?.createdAt ?? Date()
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(room.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
