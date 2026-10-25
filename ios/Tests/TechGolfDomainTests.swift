import XCTest
@testable import TechGolfCore

final class TechGolfDomainTests: XCTestCase {

    func testHaversineDistance() {
        let lat1 = 21.028500
        let lng1 = 105.854200
        let lat2 = 21.029800
        let lng2 = 105.854200

        let meters = DistanceEngine.distanceBetweenMeters(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        let yards = DistanceEngine.distanceBetweenYards(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)

        XCTAssertTrue(meters > 140.0 && meters < 150.0, "Meters should be around 144m")
        XCTAssertTrue(yards > meters, "Yards should exceed meters")
    }

    func testPlaysLikeDistance() {
        let flat = 150.0
        let uphill = DistanceEngine.calculatePlaysLikeYards(flatDistanceYards: flat, elevationDeltaMeters: 10.0)
        let downhill = DistanceEngine.calculatePlaysLikeYards(flatDistanceYards: flat, elevationDeltaMeters: -10.0)

        XCTAssertTrue(uphill > flat, "Uphill plays longer")
        XCTAssertTrue(downhill < flat, "Downhill plays shorter")
    }

    func testStablefordScoring() {
        let par = 4
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 1, par: par), 5) // Albatross
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 2, par: par), 4) // Eagle
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 3, par: par), 3) // Birdie
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 4, par: par), 2) // Par
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 5, par: par), 1) // Bogey
        XCTAssertEqual(GameModeEngine.calculateStablefordPoints(netScore: 6, par: par), 0) // Double Bogey
    }

    func testWhsHandicapCalculation() {
        let diff = WhsHandicapEngine.calculateScoreDifferential(
            adjustedGrossScore: 85,
            courseRating: 72.0,
            slopeRating: 130,
            pcc: 0.0
        )
        XCTAssertEqual(diff, 11.3, accuracy: 0.1)

        let diffs = [11.3, 10.5, 9.8, 12.0, 14.1, 13.0, 8.5, 9.2, 10.1, 11.0]
        let index = WhsHandicapEngine.calculateHandicapIndex(differentials: diffs)
        XCTAssertTrue(index >= 0.0 && index <= 54.0)
    }
}
