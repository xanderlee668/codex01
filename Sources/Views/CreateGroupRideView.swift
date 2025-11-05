import SwiftUI

struct CreateGroupRideView: View {
    @EnvironmentObject private var rideViewModel: GroupRideViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool

    @State private var resortName: String = ""
    @State private var resortLocation: String = ""
    @State private var departureDate: Date = Date().addingTimeInterval(86400)
    @State private var durationDays: Int = 3
    @State private var participantLimit: Int = 6
    @State private var estimatedCost: Double = 2800

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目标雪场")) {
                    TextField("雪场名称", text: $resortName)
                    TextField("所在地区", text: $resortLocation)
                }

                Section(header: Text("行程安排")) {
                    DatePicker("出发日期", selection: $departureDate, displayedComponents: .date)
                    Stepper(value: $durationDays, in: 1...14) {
                        Text("天数：\(durationDays) 天")
                    }
                    Stepper(value: $participantLimit, in: 2...20) {
                        Text("人数：\(participantLimit) 人")
                    }
                }

                Section(header: Text("预算")) {
                    HStack {
                        Text("预计人均费用")
                        Spacer()
                        TextField("¥0", value: $estimatedCost, format: .currency(code: "CNY"))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                }
            }
            .navigationTitle("发起外滑活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("发布") {
                        submit()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !resortName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !resortLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submit() {
        let trimmedName = resortName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = resortLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedLocation.isEmpty else { return }

        rideViewModel.addRide(
            resortName: trimmedName,
            resortLocation: trimmedLocation,
            departureDate: departureDate,
            durationDays: durationDays,
            participantLimit: participantLimit,
            estimatedCostPerPerson: estimatedCost
        )
        isPresented = false
        dismiss()
    }
}

struct CreateGroupRideView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupRideView(isPresented: .constant(true))
            .environmentObject(GroupRideViewModel())
    }
}
