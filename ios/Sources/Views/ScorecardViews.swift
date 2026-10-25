import SwiftUI

public struct RoundSetupView: View {
    public let course: Course

    @StateObject private var roundService = RoundService()
    @StateObject private var courseService = CourseService()
    @StateObject private var authService = AuthService()

    @State private var selectedMode = GameModeEngine.Mode.strokePlay
    @State private var players = ["Tôi (Golfer)", "Golfer 2"]
    @State private var newPlayerName = ""
    @State private var isStarting = false
    @State private var createdRoundId: String?
    @State private var holes: [Hole] = []

    public init(course: Course) {
        self.course = course
    }

    public var body: some View {
        Form {
            Section(header: Text("1. Chế độ chơi")) {
                Picker("Game Mode", selection: $selectedMode) {
                    ForEach(GameModeEngine.Mode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.inline)
            }

            Section(header: Text("2. Người chơi trong Flight (\(players.count)/4)")) {
                ForEach(players.indices, id: \.self) { idx in
                    HStack {
                        Text("\(idx + 1). \(players[idx])")
                        Spacer()
                    }
                }
                .onDelete { indices in
                    players.remove(atOffsets: indices)
                }

                if players.count < 4 {
                    HStack {
                        TextField("Tên người chơi mới", text: $newPlayerName)
                        Button("Thêm") {
                            if !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty {
                                players.append(newPlayerName.trimmingCharacters(in: .whitespaces))
                                newPlayerName = ""
                            }
                        }
                    }
                }
            }

            Section {
                Button {
                    Task {
                        isStarting = true
                        do {
                            let r = try await roundService.createRound(
                                courseId: course.id,
                                gameMode: selectedMode.rawValue,
                                playerNames: players,
                                creatorId: authService.currentUserId ?? "guest-id"
                            )
                            holes = (try? await courseService.fetchHoles(courseId: course.id)) ?? []
                            if holes.isEmpty {
                                holes = (1...9).map {
                                    Hole(id: "h-\($0)", courseId: course.id, holeNumber: $0, par: $0 == 3 ? 5 : ($0 == 2 ? 3 : 4), handicapIndex: $0 * 2, greenCenterLat: 21.031, greenCenterLng: 105.856, greenFrontLat: 21.0308, greenFrontLng: 105.8558, greenBackLat: 21.0312, greenBackLng: 105.8562)
                                }
                            }
                            createdRoundId = r.id
                        } catch {
                            // Fallback
                            holes = (1...9).map {
                                Hole(id: "h-\($0)", courseId: course.id, holeNumber: $0, par: $0 == 3 ? 5 : ($0 == 2 ? 3 : 4), handicapIndex: $0 * 2, greenCenterLat: 21.031, greenCenterLng: 105.856, greenFrontLat: 21.0308, greenFrontLng: 105.8558, greenBackLat: 21.0312, greenBackLng: 105.8562)
                            }
                            createdRoundId = "demo-round"
                        }
                        isStarting = false
                    }
                } label: {
                    HStack {
                        Spacer()
                        if isStarting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Bắt đầu vòng đấu")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color(red: 0.11, green: 0.37, blue: 0.13))
            }
        }
        .navigationTitle("Thiết lập Vòng Đấu")
        .navigationDestination(isPresented: Binding(
            get: { createdRoundId != nil },
            set: { if !$0 { createdRoundId = nil } }
        )) {
            if let rId = createdRoundId {
                GpsRangefinderView(
                    courseName: course.name,
                    holes: holes,
                    roundId: rId
                )
            }
        }
    }
}

public struct ScoreEntryView: View {
    public let roundId: String
    public let holeNumber: Int
    public let par: Int
    public let holeId: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var roundService = RoundService()

    @State private var grossScore: Int
    @State private var putts = 2
    @State private var penalties = 0
    @State private var fairwayHit: String? = "STRAIGHT"
    @State private var gir = true
    @State private var isSaving = false

    public init(roundId: String, holeNumber: Int, par: Int, holeId: String) {
        self.roundId = roundId
        self.holeNumber = holeNumber
        self.par = par
        self.holeId = holeId
        self._grossScore = State(initialValue: par)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Hố \(holeNumber) • Par \(par)")) {
                    Stepper("Gross Score: \(grossScore)", value: $grossScore, in: 1...15)
                    Stepper("Putts: \(putts)", value: $putts, in: 0...grossScore)
                    Stepper("Penalties: \(penalties)", value: $penalties, in: 0...10)
                }

                Section(header: Text("Fairway Hit (FIR)")) {
                    Picker("FIR", selection: Binding(
                        get: { fairwayHit ?? "NONE" },
                        set: { fairwayHit = $0 == "NONE" ? nil : $0 }
                    )) {
                        Text("Trái").tag("LEFT")
                        Text("Trúng (Straight)").tag("STRAIGHT")
                        Text("Phải").tag("RIGHT")
                        Text("Không tính (Par 3)").tag("NONE")
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Greens in Regulation (GIR)", isOn: $gir)
                }

                Section {
                    Button {
                        Task {
                            isSaving = true
                            try? await roundService.saveScore(
                                roundId: roundId,
                                playerId: "player-1",
                                holeId: holeId,
                                gross: grossScore,
                                putts: putts,
                                penalties: penalties,
                                fairwayHit: fairwayHit,
                                gir: gir
                            )
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Lưu điểm Hố \(holeNumber)")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Nhập Điểm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

public struct ScorecardMatrixView: View {
    public let roundId: String
    public let holes: [Hole]

    @Environment(\.dismiss) private var dismiss
    @StateObject private var roundService = RoundService()
    @State private var scores: [RoundScore] = []
    @State private var isLoading = true

    public init(roundId: String, holes: [Hole]) {
        self.roundId = roundId
        self.holes = holes
    }

    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Bảng điểm 9 / 18 hố")) {
                    HStack {
                        Text("HỐ").bold().frame(width: 40, alignment: .leading)
                        Text("PAR").bold().frame(width: 40, alignment: .leading)
                        Spacer()
                        Text("GROSS").bold()
                        Text("PUTTS").bold().frame(width: 60, alignment: .trailing)
                    }

                    ForEach(holes) { hole in
                        let score = scores.first(where: { $0.holeId == hole.id })
                        HStack {
                            Text("\(hole.holeNumber)").frame(width: 40, alignment: .leading)
                            Text("\(hole.par)").foregroundColor(.secondary).frame(width: 40, alignment: .leading)
                            Spacer()
                            Text(score != nil ? "\(score!.grossScore)" : "-")
                                .bold()
                                .foregroundColor(colorForDiff(gross: score?.grossScore, par: hole.par))
                            Text(score != nil ? "\(score!.putts)" : "-")
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }

                    // Total
                    HStack {
                        Text("TỔNG").bold()
                        Text("\(holes.reduce(0, { $0 + $1.par }))").foregroundColor(.secondary)
                        Spacer()
                        Text("\(scores.reduce(0, { $0 + $1.grossScore }))").bold()
                        Text("\(scores.reduce(0, { $0 + $1.putts }))").foregroundColor(.secondary).frame(width: 60, alignment: .trailing)
                    }
                    .font(.headline)
                    .listRowBackground(Color.green.opacity(0.15))
                }
            }
            .navigationTitle("Scorecard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
            .task {
                scores = (try? await roundService.fetchRoundScores(roundId: roundId)) ?? []
                isLoading = false
            }
        }
    }

    private func colorForDiff(gross: Int?, par: Int) -> Color {
        guard let g = gross else { return .primary }
        let diff = g - par
        if diff < 0 { return .green }
        if diff == 0 { return .primary }
        if diff == 1 { return .orange }
        return .red
    }
}
