import Foundation

public struct Profile: Codable, Identifiable {
    public let id: String
    public let email: String
    public let fullName: String
    public let avatarUrl: String?
    public let handicapIndex: Double
    public let role: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case handicapIndex = "handicap_index"
        case role
    }
}

public struct GolfBagClub: Codable, Identifiable {
    public let id: String
    public let userId: String
    public let clubType: String
    public let customName: String?
    public let averageDistanceMeters: Double
    public let totalShotsRecorded: Int
    public let isActive: BooleanLiteralType

    public var averageDistanceYards: Double {
        return averageDistanceMeters * 1.093613
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case clubType = "club_type"
        case customName = "custom_name"
        case averageDistanceMeters = "average_distance_meters"
        case totalShotsRecorded = "total_shots_recorded"
        case isActive = "is_active"
    }
}

public struct Course: Codable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let city: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let totalHoles: Int
    public let description: String?

    enum CodingKeys: String, CodingKey {
        case id, name, address, city, country, latitude, longitude
        case totalHoles = "total_holes"
        case description
    }
}

public struct CourseTee: Codable, Identifiable {
    public let id: String
    public let courseId: String
    public let name: String
    public let color: String
    public let rating: Double
    public let slopeRating: Int
    public let totalYardage: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case name, color, rating
        case slopeRating = "slope_rating"
        case totalYardage = "total_yardage"
    }
}

public struct Hole: Codable, Identifiable {
    public let id: String
    public let courseId: String
    public let holeNumber: Int
    public let par: Int
    public let handicapIndex: Int
    public let greenCenterLat: Double?
    public let greenCenterLng: Double?
    public let greenFrontLat: Double?
    public let greenFrontLng: Double?
    public let greenBackLat: Double?
    public let greenBackLng: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case holeNumber = "hole_number"
        case par
        case handicapIndex = "handicap_index"
        case greenCenterLat = "green_center_lat"
        case greenCenterLng = "green_center_lng"
        case greenFrontLat = "green_front_lat"
        case greenFrontLng = "green_front_lng"
        case greenBackLat = "green_back_lat"
        case greenBackLng = "green_back_lng"
    }
}

public struct Round: Codable, Identifiable {
    public let id: String
    public let courseId: String
    public let gameMode: String
    public let status: String
    public let currentHole: Int
    public let createdBy: String

    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case gameMode = "game_mode"
        case status
        case currentHole = "current_hole"
        case createdBy = "created_by"
    }
}

public struct RoundPlayer: Codable, Identifiable {
    public let id: String
    public let roundId: String
    public let userId: String?
    public let playerName: String
    public let playerOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case roundId = "round_id"
        case userId = "user_id"
        case playerName = "player_name"
        case playerOrder = "player_order"
    }
}

public struct RoundScore: Codable, Identifiable {
    public let id: String
    public let roundId: String
    public let playerId: String
    public let holeId: String
    public let grossScore: Int
    public let putts: Int
    public let penalties: Int
    public let fairwayHit: String?
    public let gir: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case roundId = "round_id"
        case playerId = "player_id"
        case holeId = "hole_id"
        case grossScore = "gross_score"
        case putts, penalties
        case fairwayHit = "fairway_hit"
        case gir
    }
}

public struct Shot: Codable, Identifiable {
    public let id: String
    public let roundId: String
    public let playerId: String
    public let userId: String?
    public let holeId: String
    public let clubId: String?
    public let status: String
    public let startLatitude: Double
    public let startLongitude: Double
    public let startElevation: Double?
    public let endLatitude: Double?
    public let endLongitude: Double?
    public let endElevation: Double?
    public let distance: Double?
    public let distanceUnit: String

    enum CodingKeys: String, CodingKey {
        case id
        case roundId = "round_id"
        case playerId = "player_id"
        case userId = "user_id"
        case holeId = "hole_id"
        case clubId = "club_id"
        case status
        case startLatitude = "start_latitude"
        case startLongitude = "start_longitude"
        case startElevation = "start_elevation"
        case endLatitude = "end_latitude"
        case endLongitude = "end_longitude"
        case endElevation = "end_elevation"
        case distance
        case distanceUnit = "distance_unit"
    }
}
