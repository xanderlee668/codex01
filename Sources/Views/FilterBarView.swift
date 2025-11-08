import SwiftUI

struct FilterBarView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.65))
                TextField("Search boards, locations or sellers", text: $marketplace.filterText)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.white)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    PickerChipView(title: "All trade options", isSelected: marketplace.selectedTradeOption == nil) {
                        marketplace.selectedTradeOption = nil
                    }

                    ForEach(SnowboardListing.TradeOption.allCases) { option in
                        PickerChipView(title: option.rawValue, isSelected: marketplace.selectedTradeOption == option) {
                            if marketplace.selectedTradeOption == option {
                                marketplace.selectedTradeOption = nil
                            } else {
                                marketplace.selectedTradeOption = option
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    PickerChipView(title: "All conditions", isSelected: marketplace.selectedCondition == nil) {
                        marketplace.selectedCondition = nil
                    }

                    ForEach(SnowboardListing.Condition.allCases) { condition in
                        PickerChipView(title: condition.rawValue, isSelected: marketplace.selectedCondition == condition) {
                            if marketplace.selectedCondition == condition {
                                marketplace.selectedCondition = nil
                            } else {
                                marketplace.selectedCondition = condition
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .foregroundColor(.white)
    }
}

private struct PickerChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
        }
        .buttonStyle(ChipGlassButtonStyle(isSelected: isSelected))
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
