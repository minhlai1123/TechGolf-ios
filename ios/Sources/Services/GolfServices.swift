import Foundation
import Supabase

public final class AuthService: ObservableObject {
    private var client: SupabaseClient { SupabaseManager.shared.client }

    public init() {}

    public var currentUserId: String? {
        return client.auth.currentUser?.id.uuidString
    }

    public func signUp(email: String, pass: String, fullName: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: pass,
            data: ["full_name": .string(fullName)]
        )
    }

    public func signIn(email: String, pass: String) async throws {
        try await client.auth.signIn(email: email, password: pass)
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }
}

public final class CourseService: ObservableObject {
    private var client: SupabaseClient { SupabaseManager.shared.client }

    public init() {}

    public func fetchCourses() async throws -> [Course] {
        return try await client.from("courses")
            .select()
            .eq("status", value: "ACTIVE")
            .execute()
            .value
    }

    public func fetchHoles(courseId: String) async throws -> [Hole] {
        let holes: [Hole] = try await client.from("holes")
            .select()
            .eq("course_id", value: courseId)
            .execute()
            .value
        return holes.sorted(by: { $0.holeNumber < $1.holeNumber })
    }

    public func fetchTees(courseId: String) async throws -> [CourseTee] {
        return try await client.from("course_tees")
            .select()
            .eq("course_id", value: courseId)
            .execute()
            .value
    }
}

public final class RoundService: ObservableObject {
    private var client: SupabaseClient { SupabaseManager.shared.client }

    public init() {}

    public func createRound(
        courseId: String,
        gameMode: String,
        playerNames: [String],
        creatorId: String
    ) async throws -> Round {
        let roundId = UUID().uuidString
        let round = Round(
            id: roundId,
            courseId: courseId,
            gameMode: gameMode,
            status: "IN_PROGRESS",
            currentHole: 1,
            createdBy: creatorId
        )

        try await client.from("rounds").insert(round).execute()

        for (index, name) in playerNames.enumerated() {
            let player = RoundPlayer(
                id: UUID().uuidString,
                roundId: roundId,
                userId: index == 0 ? creatorId : nil,
                playerName: name,
                playerOrder: index + 1
            )
            try await client.from("round_players").insert(player).execute()
        }

        return round
    }

    public func fetchRoundPlayers(roundId: String) async throws -> [RoundPlayer] {
        let players: [RoundPlayer] = try await client.from("round_players")
            .select()
            .eq("round_id", value: roundId)
            .execute()
            .value
        return players.sorted(by: { $0.playerOrder < $1.playerOrder })
    }

    public func fetchRoundScores(roundId: String) async throws -> [RoundScore] {
        return try await client.from("round_scores")
            .select()
            .eq("round_id", value: roundId)
            .execute()
            .value
    }

    public func saveScore(
        roundId: String,
        playerId: String,
        holeId: String,
        gross: Int,
        putts: Int,
        penalties: Int,
        fairwayHit: String?,
        gir: Bool?
    ) async throws {
        let score = RoundScore(
            id: UUID().uuidString,
            roundId: roundId,
            playerId: playerId,
            holeId: holeId,
            grossScore: gross,
            putts: putts,
            penalties: penalties,
            fairwayHit: fairwayHit,
            gir: gir
        )

        try await client.from("round_scores")
            .upsert(score, onConflict: "round_id,player_id,hole_id")
            .execute()
    }
}

public final class ShotService: ObservableObject {
    private var client: SupabaseClient { SupabaseManager.shared.client }

    public init() {}

    public func fetchClubs(userId: String) async throws -> [GolfBagClub] {
        return try await client.from("golf_bag_clubs")
            .select()
            .eq("user_id", value: userId)
            .eq("is_active", value: true)
            .execute()
            .value
    }

    public func startShot(
        roundId: String,
        playerId: String,
        userId: String?,
        holeId: String,
        clubId: String?,
        lat: Double,
        lng: Double,
        elevation: Double? = nil
    ) async throws -> Shot {
        let shot = Shot(
            id: UUID().uuidString,
            roundId: roundId,
            playerId: playerId,
            userId: userId,
            holeId: holeId,
            clubId: clubId,
            status: "STARTED",
            startLatitude: lat,
            startLongitude: lng,
            startElevation: elevation,
            endLatitude: nil,
            endLongitude: nil,
            endElevation: nil,
            distance: nil,
            distanceUnit: "YARDS"
        )
        try await client.from("shots").insert(shot).execute()
        return shot
    }

    public func saveShot(
        shotId: String,
        startLat: Double,
        startLng: Double,
        startElev: Double?,
        endLat: Double,
        endLng: Double,
        endElev: Double?,
        clubId: String?
    ) async throws {
        let dist = DistanceEngine.distanceBetweenYards(lat1: startLat, lng1: startLng, lat2: endLat, lng2: endLng)
        let elevDelta = (startElev != nil && endElev != nil) ? (endElev! - startElev!) : nil

        let updates: [String: AnyJSON] = [
            "end_latitude": .double(endLat),
            "end_longitude": .double(endLng),
            "end_elevation": endElev != nil ? .double(endElev!) : .null,
            "elevation_delta": elevDelta != nil ? .double(elevDelta!) : .null,
            "distance": .double(dist),
            "status": .string("SAVED"),
            "club_id": clubId != nil ? .string(clubId!) : .null
        ]

        try await client.from("shots")
            .update(updates)
            .eq("id", value: shotId)
            .execute()
    }
}
