import SwiftUI

struct AddListingView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var location: String = ""
    @State private var tradeOption: SnowboardListing.TradeOption = .faceToFace
    @State private var condition: SnowboardListing.Condition = .likeNew
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basics")) {
                    TextField("Title, e.g. Burton Custom 154", text: $title)
                    Picker("Trade option", selection: $tradeOption) {
                        ForEach(SnowboardListing.TradeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Picker("Condition", selection: $condition) {
                        ForEach(SnowboardListing.Condition.allCases) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                }

                Section(header: Text("Price & location")) {
                    TextField("£ Price", text: $price)
                        .keyboardType(.numberPad)
                    TextField("City or resort", text: $location)
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4))
                        )
                }
            }
            .navigationTitle("List snowboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        createListing()
                        isPresented = false
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(price) != nil &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func createListing() {
        let newListing = SnowboardListing(
            id: UUID(),
            title: title,
            description: description,
            condition: condition,
            price: Double(price) ?? 0,
            location: location,
            tradeOption: tradeOption,
            isFavorite: false,
            imageName: "board_custom",
            seller: marketplace.currentUser
        )
        marketplace.addListing(newListing)
    }
}

struct AddListingView_Previews: PreviewProvider {
    static var previews: some View {
        AddListingView(isPresented: .constant(true))
            .environmentObject(MarketplaceViewModel())
    }
}
