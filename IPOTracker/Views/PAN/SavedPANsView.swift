import SwiftUI
import SwiftData

public struct SavedPANsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPAN.addedDate, order: .reverse) private var savedPANs: [SavedPAN]
    
    @State private var showingAddSheet = false
    @State private var newName = ""
    @State private var newPAN = ""
    @State private var validationError: String?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                if savedPANs.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("No Saved PANs")
                                .font(.headline)
                            Text("Save your PANs with friendly names (e.g. Self, Mom, Dad) for 1-tap allotment checking.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                showingAddSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Your First PAN")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 30)
                    }
                } else {
                    Section("Your Profiles") {
                        ForEach(savedPANs) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.panNumber)
                                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = item.panNumber
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deletePANs)
                    }
                }
                
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Saved locally on your device for easy 1-tap selection during allotment queries.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Saved PANs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newName = ""
                        newPAN = ""
                        validationError = nil
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addPANSheet
            }
        }
    }
    
    private var addPANSheet: some View {
        NavigationStack {
            Form {
                Section("Profile Details") {
                    TextField("Name (e.g. Self, Mom, HUF)", text: $newName)
                    
                    TextField("PAN Number (e.g. ABCDE1234F)", text: $newPAN)
                        .font(.system(.body, design: .monospaced).weight(.semibold))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                
                if let error = validationError {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add PAN Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePAN()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    private func savePAN() {
        validationError = nil
        let cleanedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPAN = newPAN.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard !cleanedName.isEmpty else {
            validationError = "Please enter a profile name."
            return
        }
        
        let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", panRegex)
        guard predicate.evaluate(with: cleanedPAN) else {
            validationError = "Enter a valid 10-character PAN (e.g. ABCDE1234F)."
            return
        }
        
        let profile = SavedPAN(name: cleanedName, panNumber: cleanedPAN)
        modelContext.insert(profile)
        showingAddSheet = false
    }
    
    private func deletePANs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(savedPANs[index])
        }
    }
}
