import SwiftUI
import CoreLocation

public struct GpsRangefinderView: View {
    public let courseName: String
    public let holes: [Hole]
    public let roundId: String

    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var shotService = ShotService()

    @State private var currentHoleIndex = 0
    @State private var useYards = true
    @State private var isPlaysLikeActive = false
    @State private var clubs: [GolfBagClub] = []

    @State private var showScoreEntry = false
    @State private var showScorecard = false
    @State private var showShotTracker = false
    @State private var showLivePlay = false

    public init(courseName: String, holes: [Hole], roundId: String) {
        self.courseName = courseName
        self.holes = holes
        self.roundId = roundId
    }

    private var currentHole: Hole? {
        guard !holes.isEmpty, currentHoleIndex < holes.count else { return nil }
        return holes[currentHoleIndex]
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Hole Header Banner
            HStack {
                Button {
                    if currentHoleIndex > 0 { currentHoleIndex -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(currentHoleIndex > 0 ? .white : .gray)
                }
                .disabled(currentHoleIndex == 0)

                Spacer()

                if let hole = currentHole {
                    VStack {
                        Text("HỐ \(hole.holeNumber) OF \(holes.count)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Text("Par \(hole.par) • HCP \(hole.handicapIndex)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Button {
                    if currentHoleIndex < holes.count - 1 { currentHoleIndex += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(currentHoleIndex < holes.count - 1 ? .white : .gray)
                }
                .disabled(currentHoleIndex >= holes.count - 1)
            }
            .padding()
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))

            // Main F-M-B Card
            if let hole = currentHole {
                let userLat = locationManager.currentLocation?.latitude ?? 21.028500
                let userLng = locationManager.currentLocation?.longitude ?? 105.854200

                let distFront = DistanceEngine.distanceBetweenMeters(
                    lat1: userLat, lng1: userLng,
                    lat2: hole.greenFrontLat ?? 21.0308, lng2: hole.greenFrontLng ?? 105.8558
                )
                let distCenter = DistanceEngine.distanceBetweenMeters(
                    lat1: userLat, lng1: userLng,
                    lat2: hole.greenCenterLat ?? 21.0310, lng2: hole.greenCenterLng ?? 105.8560
                )
                let distBack = DistanceEngine.distanceBetweenMeters(
                    lat1: userLat, lng1: userLng,
                    lat2: hole.greenBackLat ?? 21.0312, lng2: hole.greenBackLng ?? 105.8562
                )

                let multiplier = useYards ? 1.093613 : 1.0
                let playsLikeDelta = isPlaysLikeActive ? 6.0 : 0.0

                let dispFront = Int((distFront * multiplier + playsLikeDelta).rounded())
                let dispCenter = Int((distCenter * multiplier + playsLikeDelta).rounded())
                let dispBack = Int((distBack * multiplier + playsLikeDelta).rounded())

                VStack(spacing: 16) {
                    if isPlaysLikeActive {
                        HStack {
                            Image(systemName: "mountain.2.fill")
                                .foregroundColor(.yellow)
                            Text("PLAYS LIKE ACTIVE (+6 yds)")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(6)
                    }

                    // Center Green Distance
                    VStack(spacing: 4) {
                        Text("\(dispCenter)")
                            .font(.system(size: 76, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("CENTER GREEN (\(useYards ? "YDS" : "M"))")
                            .font(.caption.bold())
                            .foregroundColor(Color.green)
                    }

                    Divider().background(Color.gray.opacity(0.3))

                    // Front & Back
                    HStack {
                        VStack {
                            Text("FRONT").font(.caption).foregroundColor(.gray)
                            Text("\(dispFront)").font(.title2.bold()).foregroundColor(.white)
                        }
                        Spacer()
                        VStack {
                            Text("BACK").font(.caption).foregroundColor(.gray)
                            Text("\(dispBack)").font(.title2.bold()).foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                .cornerRadius(16)
                .padding()

                // Caddie Recommendation Card
                if let recommended = ClubRecommendationEngine.recommendClub(targetDistanceYards: Double(dispCenter), clubs: clubs) {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.golf")
                            .font(.title2)
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GỢI Ý GẬY CADDIE")
                                .font(.caption2.bold())
                                .foregroundColor(.green)
                            Text("\(recommended.customName ?? recommended.clubType) • TB: \(Int(recommended.averageDistanceYards)) yds")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 0.05, green: 0.16, blue: 0.09))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }

            Spacer()

            // Map Area Placeholder
            ZStack {
                Color(red: 0.08, green: 0.14, blue: 0.08)
                    .cornerRadius(16)
                VStack(spacing: 6) {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("Bản đồ Vệ tinh & Cung khoảng cách 150/200/250y")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()

            // Bottom Action Bar
            HStack(spacing: 20) {
                Button {
                    showShotTracker = true
                } label: {
                    VStack {
                        Image(systemName: "target")
                        Text("Đo gậy").font(.caption2)
                    }
                    .foregroundColor(.white)
                }

                Button {
                    showLivePlay = true
                } label: {
                    VStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("LivePlay").font(.caption2)
                    }
                    .foregroundColor(.yellow)
                }

                Button {
                    showScoreEntry = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Ghi điểm")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.11, green: 0.45, blue: 0.18))
                    .cornerRadius(25)
                }

                Button {
                    showScorecard = true
                } label: {
                    VStack {
                        Image(systemName: "tablecells")
                        Text("Scorecard").font(.caption2)
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(useYards ? "YDS" : "MTR") {
                        useYards.toggle()
                    }
                    .font(.caption.bold())
                    .foregroundColor(.white)

                    Button {
                        isPlaysLikeActive.toggle()
                    } label: {
                        Image(systemName: "mountain.2")
                            .foregroundColor(isPlaysLikeActive ? .yellow : .white)
                    }
                }
            }
        }
        .sheet(isPresented: $showScoreEntry) {
            ScoreEntryView(
                roundId: roundId,
                holeNumber: currentHole?.holeNumber ?? 1,
                par: currentHole?.par ?? 4,
                holeId: currentHole?.id ?? ""
            )
        }
        .sheet(isPresented: $showScorecard) {
            ScorecardMatrixView(roundId: roundId, holes: holes)
        }
        .sheet(isPresented: $showShotTracker) {
            ShotTrackerView(
                roundId: roundId,
                holeId: currentHole?.id ?? "",
                clubs: clubs
            )
        }
        .sheet(isPresented: $showLivePlay) {
            LivePlayLeaderboardView(roundId: roundId)
        }
        .onAppear {
            locationManager.requestPermission()
            // Fallback clubs if none fetched
            clubs = [
                GolfBagClub(id: "1", userId: "u", clubType: "DRIVER", customName: "Driver", averageDistanceMeters: 215.0, totalShotsRecorded: 10, isActive: true),
                GolfBagClub(id: "2", userId: "u", clubType: "IRON_7", customName: "7 Iron", averageDistanceMeters: 145.0, totalShotsRecorded: 15, isActive: true),
                GolfBagClub(id: "3", userId: "u", clubType: "PITCHING_WEDGE", customName: "PW", averageDistanceMeters: 110.0, totalShotsRecorded: 12, isActive: true),
                GolfBagClub(id: "4", userId: "u", clubType: "PUTTER", customName: "Putter", averageDistanceMeters: 0.0, totalShotsRecorded: 50, isActive: true)
            ]
        }
    }
}
