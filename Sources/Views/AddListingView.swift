import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 16.0, *)
struct AddListingView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var location: String = ""
    @State private var tradeOption: SnowboardListing.TradeOption = .faceToFace
    @State private var condition: SnowboardListing.Condition = .likeNew
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var photos: [ListingPhotoDraft] = []
    @Binding var isPresented: Bool

    private let maxPhotos = 6

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

                Section(header: Text("Photos")) {
                    if photos.isEmpty {
                        Text("Add a few photos so riders can inspect your gear before they message you.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(photos) { photo in
                                ListingPhotoPreview(photo: photo) {
                                    removePhoto(photo)
                                }
                            }

                            if photos.count < maxPhotos {
                                PhotosPicker(
                                    selection: $selectedPhotoItems,
                                    maxSelectionCount: max(maxPhotos - photos.count, 1),
                                    matching: .images
                                ) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 28, weight: .medium))
                                        Text("Add")
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(width: 96, height: 96)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
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
        .onChange(of: selectedPhotoItems) { newItems in
            guard !newItems.isEmpty else { return }
            Task { await loadPhotos(from: newItems) }
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
            photos: photos.map { SnowboardListing.Photo(id: $0.id, data: $0.data) },
            seller: marketplace.currentUser
        )
        marketplace.addListing(newListing)
        resetForm()
    }

    private func resetForm() {
        title = ""
        description = ""
        price = ""
        location = ""
        tradeOption = .faceToFace
        condition = .likeNew
        photos.removeAll()
        selectedPhotoItems.removeAll()
    }

    private func removePhoto(_ photo: ListingPhotoDraft) {
        photos.removeAll { $0.id == photo.id }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var loaded: [ListingPhotoDraft] = []

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let sanitizedData = sanitize(imageData: data)
            else { continue }

            loaded.append(ListingPhotoDraft(data: sanitizedData))
        }

        if !loaded.isEmpty {
            await MainActor.run {
                photos.append(contentsOf: loaded)
                if photos.count > maxPhotos {
                    photos = Array(photos.prefix(maxPhotos))
                }
            }
        }

        await MainActor.run {
            selectedPhotoItems.removeAll()
        }
    }

    private func sanitize(imageData data: Data) -> Data? {
#if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        let maxDimension: CGFloat = 1600
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.jpegData(compressionQuality: 0.8)
#else
        return data
#endif
    }
}

private struct ListingPhotoDraft: Identifiable, Equatable {
    let id: UUID
    let data: Data

    init(id: UUID = UUID(), data: Data) {
        self.id = id
        self.data = data
    }
}

private struct ListingPhotoPreview: View {
    let photo: ListingPhotoDraft
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 96, height: 96)
                .overlay(
                    Group {
#if canImport(UIKit)
                        if let image = UIImage(data: photo.data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            placeholder
                        }
#else
                        placeholder
#endif
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                )

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white, .black.opacity(0.35))
                    .padding(6)
            }
        }
    }

    private var placeholder: some View {
        VStack(spacing: 6) {
            Image(systemName: "photo")
                .font(.system(size: 26, weight: .medium))
            Text("Preview")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

@available(iOS 16.0, *)
struct AddListingView_Previews: PreviewProvider {
    static var previews: some View {
        AddListingView(isPresented: .constant(true))
            .environmentObject(MarketplaceViewModel())
    }
}
