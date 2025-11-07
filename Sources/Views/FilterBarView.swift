import SwiftUI

struct FilterBarView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search boards, locations or sellers", text: $marketplace.filterText)
                    .textInputAutocapitalization(.never)
            }
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    PickerChipView(title: "All trade options", isSelected: marketplace.selectedTradeOption == nil) {
                        marketplace.selectedTradeOption = nil
                    }

                    ForEach(SnowboardListing.TradeOption.allCases) { option in
                        PickerChipView(title: option.rawValue, isSelected: marketplace.selectedTradeOption == option) {
                            marketplace.selectedTradeOption = option
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    PickerChipView(title: "All conditions", isSelected: marketplace.selectedCondition == nil) {
                        marketplace.selectedCondition = nil
                    }

                    ForEach(SnowboardListing.Condition.allCases) { condition in
                        PickerChipView(title: condition.rawValue, isSelected: marketplace.selectedCondition == condition) {
                            marketplace.selectedCondition = condition
                        }
                    }
                }
            }
        }
    }
}

private struct PickerChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                .foregroundColor(isSelected ? Color.accentColor : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct FilterBarView_Previews: PreviewProvider {
    static var previews: some View {
        FilterBarView()
            .environmentObject(MarketplaceViewModel())
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}
