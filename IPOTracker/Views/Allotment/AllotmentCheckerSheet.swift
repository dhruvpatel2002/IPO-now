import SwiftUI
import SwiftData

public struct AllotmentCheckerSheet: View {
    public let ipo: IPO
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AllotmentViewModel()
    @Query(sort: \SavedPAN.addedDate, order: .reverse) private var savedPANs: [SavedPAN]
    
    public init(ipo: IPO) {
        self.ipo = ipo
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let result = viewModel.allotmentResult {
                    AllotmentResultView(result: result) {
                        viewModel.clearForm()
                        dismiss()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Check Allotment")
                                .font(.title2.weight(.bold))
                            Text(ipo.companyName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                        
                        // Saved PAN Quick Selection
                        if !savedPANs.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SELECT SAVED PAN")
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
                                                    Color(UIColor.secondarySystemBackground)
                                                )
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // PAN input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Permanent Account Number (PAN)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            TextField("ABCDE1234F", text: $viewModel.panNumber)
                                .font(.system(.title3, design: .monospaced).weight(.semibold))
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.validationError != nil ? Color.red : Color.clear, lineWidth: 1)
                                )
                            
                            if let error = viewModel.validationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Privacy reassurance note
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                            Text("Your PAN is used securely in-memory to check allotment status with the registrar.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        PrimaryButton(
                            title: "Verify Allotment",
                            iconName: "magnifyingglass",
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                viewModel.selectedIPO = ipo
                                await viewModel.validateAndCheckAllotment()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
