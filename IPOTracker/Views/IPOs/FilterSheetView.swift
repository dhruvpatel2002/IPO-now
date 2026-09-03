import SwiftUI

public struct FilterSheetView: View {
    @ObservedObject var viewModel: IPOListViewModel
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Segment") {
                    Picker("Segment", selection: $viewModel.selectedSegment) {
                        ForEach(IPOSegmentFilter.allCases) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(IPOCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(IPOSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        viewModel.selectedSegment = .all
                        viewModel.selectedCategory = .ongoing
                        viewModel.sortOption = .openingDate
                    }
                }
            }
            .navigationTitle("Sort & Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
