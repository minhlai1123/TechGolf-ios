import SwiftUI

public struct ShotTrackerView: View {
    public let roundId: String
    public let holeId: String
    public let clubs: [GolfBagClub]

    @Environment(\.dismiss) private var dismiss
    @StateObject private var shotService = ShotService()

    @State private var activeShot: Shot?
    @State private var selectedClubId: String?
    @State private var isStarting = false
    @State private var isSaving = false

    // Simulated walking: ball is ~215 yards away
    @State private var startLat = 21.028500
    @State private var startLng = 105.854200
    @State private var currentLat = 21.030300
    @State private var currentLng = 105.855400

    public init(roundId: String, holeId: String, clubs: [GolfBagClub]) {
        self.roundId = roundId
        self.holeId = holeId
        self.clubs = clubs
    }

    private var walkingDistanceYards: Int {
        Int(DistanceEngine.distanceBetweenYards(lat1: startLat, lng1: startLng, lat2: currentLat, lng2: currentLng).rounded())
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if activeShot == nil {
                    // Step 1: Start
                    VStack(spacing: 8) {
                        Image(systemName: "figure.golf")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("Bắt đầu ghi nhận cú đánh")
                            .font(.title2.bold())
                        Text("Đứng tại vị trí chuẩn bị đánh bóng")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    Picker("Chọn gậy", selection: $selectedClubId) {
                        ForEach(clubs) { club in
                            Text("\(club.customName ?? club.clubType) (TB: \(Int(club.averageDistanceYards)) yds)").tag(Optional(club.id))
                        }
                    }
                    .pickerStyle(.wheel)

                    Spacer()

                    Button {
                        Task {
                            isStarting = true
                            activeShot = try? await shotService.startShot(
                                roundId: roundId,
                                playerId: "player-1",
                                userId: nil,
                                holeId: holeId,
                                clubId: selectedClubId ?? clubs.first?.id,
                                lat: startLat,
                                lng: startLng,
                                elevation: 12.0
                            )
                            isStarting = false
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isStarting {
                                ProgressView().tint(.white)
                            } else {
                                Text("BẮT ĐẦU CÚ ĐÁNH TẠI ĐÂY")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 52)
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding()
                } else {
                    // Step 2: In Flight / Walking
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Di chuyển tới vị trí bóng dừng...")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(spacing: 6) {
                            Text("\(walkingDistanceYards) YDS")
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                            Text("KHOẢNG CÁCH CÚ ĐÁNH THỰC TẾ")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }

                    Spacer()

                    Button {
                        Task {
                            isSaving = true
                            try? await shotService.saveShot(
                                shotId: activeShot!.id,
                                startLat: startLat,
                                startLng: startLng,
                                startElev: 12.0,
                                endLat: currentLat,
                                endLng: currentLng,
                                endElev: 14.0,
                                clubId: selectedClubId ?? clubs.first?.id
                            )
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("LƯU CÚ ĐÁNH NÀY (\(walkingDistanceYards) YDS)")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 52)
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Shot Tracker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

public struct LivePlayLeaderboardView: View {
    public let roundId: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var roundService = RoundService()
    @State private var scores: [RoundScore] = []
    @State private var players = ["Tôi (Golfer)", "Golfer 2"]

    public init(roundId: String) {
        self.roundId = roundId
    }

    public var body: some View {
        NavigationStack {
            List {
                Section(header: HStack {
                    Text("Bảng Xếp Hạng Trực Tiếp")
                    Spacer()
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("LIVE").font(.caption2.bold()).foregroundColor(.green)
                }) {
                    ForEach(players.indices, id: \.self) { idx in
                        let name = players[idx]
                        let totalGross = idx == 0 ? 38 : 41
                        HStack {
                            Text("\(idx + 1)").bold().foregroundColor(.secondary).frame(width: 24)
                            Image(systemName: "figure.golf").foregroundColor(.green)
                            Text(name).font(.headline)
                            Spacer()
                            Text("\(totalGross) Gross")
                                .font(.headline.bold())
                                .foregroundColor(Color(red: 0.11, green: 0.37, blue: 0.13))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("LivePlay Leaderboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
            .task {
                scores = (try? await roundService.fetchRoundScores(roundId: roundId)) ?? []
            }
        }
    }
}

public struct StatsDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    private let demoDiffs = [8.2, 9.4, 7.8, 11.2, 10.0, 8.5, 9.1, 7.5, 12.0, 8.9]

    public init() {}

    private var handicapIndex: Double {
        WhsHandicapEngine.calculateHandicapIndex(differentials: demoDiffs)
    }

    public var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text("WHS HANDICAP INDEX")
                        .font(.caption.bold())
                        .foregroundColor(Color.green)
                    Text("\(String(format: "%.1f", handicapIndex))")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Tính từ 8 vòng tốt nhất trong 20 vòng gần nhất")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.08, green: 0.25, blue: 0.12))
                .cornerRadius(12)
            }
            .listRowBackground(Color.clear)

            Section(header: Text("Chỉ số hiệu suất (Stats)")) {
                HStack {
                    Text("Fairways Hit (FIR)")
                    Spacer()
                    Text("64.2%").bold().foregroundColor(.green)
                }
                HStack {
                    Text("Greens in Regulation (GIR)")
                    Spacer()
                    Text("55.0%").bold().foregroundColor(.green)
                }
                HStack {
                    Text("Putts / Hole")
                    Spacer()
                    Text("1.8").bold().foregroundColor(.green)
                }
                HStack {
                    Text("Scrambling")
                    Spacer()
                    Text("42.0%").bold().foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Golf Stats & WHS")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Đóng") { dismiss() }
            }
        }
    }
}
