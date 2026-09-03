import SwiftUI
import SwiftData

public struct AllotmentTabView: View {
    @StateObject private var viewModel = AllotmentViewModel()
    @State private var showingResultSheet = false
    @Query(sort: \SavedPAN.addedDate, order: .reverse) private var savedPANs: [SavedPAN]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Main Verification Card
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fast Allotment Verification")
                                .font(.headline)
                            Text("Select an IPO and enter or pick your saved PAN.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        // IPO Selector Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SELECT IPO")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(viewModel.ipos) { ipo in
                                    Button(ipo.companyName) {
                                        viewModel.selectedIPO = ipo
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.selectedIPO?.companyName ?? "Select an IPO")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(14)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Saved PAN Quick Chips (if any)
                        if !savedPANs.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SAVED PROFILES")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(savedPANs) { item in
                                            let isSelected = viewModel.panNumber.uppercased() == item.panNumber.uppercased()
                                            Button {
                                                viewModel.panNumber = item.panNumber
                                            } label: {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "person.fill")
                                                        .font(.caption2)
                                                    Text(item.name)
                                                        .font(.caption.weight(.medium))
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(
                                                    isSelected ?
                                                    Color.accentColor :
                                                    Color(UIColor.tertiarySystemBackground)
                                                )
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // PAN Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PAN NUMBER")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            
                            TextField("ABCDE1234F", text: $viewModel.panNumber)
                                .font(.system(.body, design: .monospaced).weight(.semibold))
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(12)
                            
                            if let error = viewModel.validationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        PrimaryButton(
                            title: "Check Status",
                            iconName: "magnifyingglass",
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.validateAndCheckAllotment()
                                if viewModel.allotmentResult != nil {
                                    showingResultSheet = true
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(18)
                    
                    // Quick Action: Recent Allotments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent & Expected Allotments")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        ForEach(viewModel.recentAllotmentIPOs.prefix(6)) { ipo in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ipo.companyName)
                                        .font(.subheadline.weight(.semibold))
                                    Text("Allotment: \(DateFormatter.localizedString(from: ipo.allotmentDate, dateStyle: .medium, timeStyle: .none))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.selectedIPO = ipo
                                } label: {
                                    Text("Select")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.12))
                                        .foregroundColor(.accentColor)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(14)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Check Allotment")
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showingResultSheet) {
                if let result = viewModel.allotmentResult {
                    AllotmentResultView(result: result) {
                        showingResultSheet = false
                        viewModel.clearForm()
                    }
                }
            }
        }
    }
}
