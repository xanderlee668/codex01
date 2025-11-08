import SwiftUI

struct CreateTripView: View {
    @EnvironmentObject private var marketplace: MarketplaceViewModel
    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var resort: String = ""
    @State private var departureLocation: String = ""
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var minimumParticipants: Int = 4
    @State private var maximumParticipants: Int = 6
    @State private var estimatedCost: Double = 320
    @State private var tripDescription: String = ""

    private var isCreateDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        resort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        departureLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        minimumParticipants < 1 ||
        maximumParticipants < minimumParticipants
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basics") {
                    TextField("Trip title", text: $title)
                    TextField("Destination resort", text: $resort)
                    DatePicker("Start date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Logistics") {
                    TextField("Departure location", text: $departureLocation)
                    Stepper(value: $minimumParticipants, in: 1...20) {
                        Text("Minimum riders: \(minimumParticipants)")
                    }
                    Stepper(value: $maximumParticipants, in: minimumParticipants...24) {
                        Text("Maximum riders: \(maximumParticipants)")
                    }
                    HStack {
                        Text("Estimated per-person cost")
                        Spacer()
                        Text(estimatedCost, format: .currency(code: "GBP"))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $estimatedCost, in: 50...1_000, step: 10)
                }

                Section("Details") {
                    TextEditor(text: $tripDescription)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4))
                        )
                }
            }
            .navigationTitle("New Group Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createTrip() }
                        .disabled(isCreateDisabled)
                }
            }
        }
    }

    private func createTrip() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedResort = resort.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDeparture = departureLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = tripDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        _ = marketplace.createTrip(
            title: trimmedTitle,
            resort: trimmedResort,
            startDate: startDate,
            departureLocation: trimmedDeparture,
            participantRange: minimumParticipants...maximumParticipants,
            estimatedCostPerPerson: estimatedCost,
            description: trimmedDescription.isEmpty ? "Group ride organised via Snowboard Swap." : trimmedDescription
        )
        isPresented = false
    }
}

struct CreateTripView_Previews: PreviewProvider {
    @State static var presented = true
    static var previews: some View {
        CreateTripView(isPresented: $presented)
            .environmentObject(MarketplaceViewModel())
    }
}
