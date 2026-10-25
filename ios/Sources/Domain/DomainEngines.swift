import Foundation

public struct GameModeEngine {
    public enum Mode: String, CaseIterable, Identifiable {
        case strokePlay = "STROKE_PLAY"
        case stableford = "STABLEFORD"
        case matchPlay = "MATCH_PLAY"
        case scramble = "SCRAMBLE"
        case fourBall = "FOUR_BALL"

        public var id: String { rawValue }
        public var displayName: String {
            switch self {
            case .strokePlay: return "Stroke Play"
            case .stableford: return "Stableford"
            case .matchPlay: return "Match Play"
            case .scramble: return "Scramble"
            case .fourBall: return "Four-Ball"
            }
        }
    }

    public static func calculateStablefordPoints(netScore: Int, par: Int) -> Int {
        let diff = netScore - par
        switch diff {
        case 2...: return 0 // Double Bogey or worse
        case 1: return 1    // Bogey
        case 0: return 2    // Par
        case -1: return 3   // Birdie
        case -2: return 4   // Eagle
        default: return 5   // Albatross or better (-3 or lower)
        }
    }

    public static func calculateMatchPlayStanding(
        p1Scores: [Int],
        p2Scores: [Int]
    ) -> (advantage: Int, statusText: String) {
        var p1HolesWon = 0
        var p2HolesWon = 0
        let minHoles = min(p1Scores.count, p2Scores.count)

        for i in 0..<minHoles {
            let s1 = p1Scores[i]
            let s2 = p2Scores[i]
            if s1 < s2 { p1HolesWon += 1 }
            else if s2 < s1 { p2HolesWon += 1 }
        }

        let netAdvantage = p1HolesWon - p2HolesWon
        let remainingHoles = 18 - minHoles

        let statusText: String
        if netAdvantage == 0 {
            statusText = "All Square (AS)"
        } else if netAdvantage > 0 {
            if netAdvantage > remainingHoles {
                statusText = "\(abs(netAdvantage)) & \(remainingHoles) (P1 Wins)"
            } else {
                statusText = "\(abs(netAdvantage)) UP (P1)"
            }
        } else {
            if abs(netAdvantage) > remainingHoles {
                statusText = "\(abs(netAdvantage)) & \(remainingHoles) (P2 Wins)"
            } else {
                statusText = "\(abs(netAdvantage)) UP (P2)"
            }
        }

        return (netAdvantage, statusText)
    }
}

public struct ClubRecommendationEngine {
    public static func recommendClub(
        targetDistanceYards: Double,
        clubs: [GolfBagClub]
    ) -> GolfBagClub? {
        let activeClubs = clubs.filter { $0.averageDistanceMeters > 0.0 }
        if activeClubs.isEmpty { return nil }

        return activeClubs.min(by: {
            abs($0.averageDistanceYards - targetDistanceYards) < abs($1.averageDistanceYards - targetDistanceYards)
        })
    }
}

public struct WhsHandicapEngine {
    public static func calculateScoreDifferential(
        adjustedGrossScore: Int,
        courseRating: Double,
        slopeRating: Int,
        pcc: Double = 0.0
    ) -> Double {
        let diff = (113.0 / Double(slopeRating)) * (Double(adjustedGrossScore) - courseRating - pcc)
        return (diff * 10.0).rounded() / 10.0
    }

    public static func calculateHandicapIndex(differentials: [Double]) -> Double {
        guard !differentials.isEmpty else { return 54.0 }

        let sorted = differentials.sorted()
        let count = sorted.count

        let usedCount: Int
        let adjustment: Double

        switch count {
        case 1...3:
            usedCount = 1; adjustment = -2.0
        case 4:
            usedCount = 1; adjustment = -1.0
        case 5:
            usedCount = 1; adjustment = 0.0
        case 6:
            usedCount = 2; adjustment = -1.0
        case 7...8:
            usedCount = 2; adjustment = 0.0
        case 9...11:
            usedCount = 3; adjustment = 0.0
        case 12...14:
            usedCount = 4; adjustment = 0.0
        case 15...16:
            usedCount = 5; adjustment = 0.0
        case 17...18:
            usedCount = 6; adjustment = 0.0
        case 19:
            usedCount = 7; adjustment = 0.0
        default:
            usedCount = 8; adjustment = 0.0 // Lowest 8 of 20
        }

        let lowest = Array(sorted.prefix(usedCount))
        let avg = (lowest.reduce(0.0, +) / Double(usedCount)) + adjustment
        let index = (avg * 10.0).rounded() / 10.0
        return min(max(index, -10.0), 54.0)
    }
}
