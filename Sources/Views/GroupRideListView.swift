import SwiftUI

struct GroupRideListView: View {
    @EnvironmentObject private var rideViewModel: GroupRideViewModel
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationView {
            Group {
                if rideViewModel.rides.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.skiing.crosscountry")
                            .font(.system(size: 56))
                            .foregroundColor(.secondary)
                        Text("还没有新的外滑活动")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("发起一个活动，召集同好一起去雪场吧！")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(rideViewModel.rides) { ride in
                            GroupRideCard(ride: ride)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("外滑组队")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Label("发起活动", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateGroupRideView(isPresented: $showingCreateSheet)
                    .environmentObject(rideViewModel)
            }
        }
    }
}

private struct GroupRideCard: View {
    let ride: GroupRide

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: ride.organizer.avatarSymbol)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.organizer.displayName)
                        .font(.headline)
                    Text("发起人 · \(ride.organizer.homeResort)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(ride.formattedCost)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(ride.resortName)
                    .font(.title3)
                    .fontWeight(.semibold)
                Label(ride.resortLocation, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label(ride.formattedDateRange, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label("人数上限：\(ride.participantLimit) 人", systemImage: "person.3")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("预计人均费用包含交通与住宿，如有装备租赁需求可在群聊中补充说明。")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct GroupRideListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupRideListView()
            .environmentObject(GroupRideViewModel())
    }
}
