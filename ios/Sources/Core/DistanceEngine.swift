import Foundation
import CoreLocation

public struct DistanceEngine {
    private static let earthRadiusMeters = 6371000.0
    private static let metersToYardsFactor = 1.0936132983
    private static let yardsToMetersFactor = 0.9144

    public static func distanceBetweenMeters(
        lat1: Double,
        lng1: Double,
        lat2: Double,
        lng2: Double
    ) -> Double {
        let phi1 = lat1 * .pi / 180.0
        let phi2 = lat2 * .pi / 180.0
        let deltaPhi = (lat2 - lat1) * .pi / 180.0
        let deltaLambda = (lng2 - lng1) * .pi / 180.0

        let a = sin(deltaPhi / 2.0) * sin(deltaPhi / 2.0) +
                cos(phi1) * cos(phi2) *
                sin(deltaLambda / 2.0) * sin(deltaLambda / 2.0)

        let c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        return earthRadiusMeters * c
    }

    public static func distanceBetweenYards(
        lat1: Double,
        lng1: Double,
        lat2: Double,
        lng2: Double
    ) -> Double {
        return metersToYards(distanceBetweenMeters(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2))
    }

    public static func metersToYards(_ meters: Double) -> Double {
        return meters * metersToYardsFactor
    }

    public static func yardsToMeters(_ yards: Double) -> Double {
        return yards * yardsToMetersFactor
    }

    public static func calculatePlaysLikeYards(
        flatDistanceYards: Double,
        elevationDeltaMeters: Double?,
        windSpeedMps: Double = 0.0,
        windDirectionAngleDeg: Double = 0.0
    ) -> Double {
        var adjusted = flatDistanceYards
        if let elevDelta = elevationDeltaMeters {
            // Uphill plays longer (+), Downhill plays shorter (-)
            adjusted += (elevDelta * 1.05)
        }
        if windSpeedMps > 0.0 {
            let headwindComponent = windSpeedMps * cos(windDirectionAngleDeg * .pi / 180.0)
            adjusted += (headwindComponent * 1.2)
        }
        return max(0.0, adjusted)
    }

    public static func calculateBearing(
        lat1: Double,
        lng1: Double,
        lat2: Double,
        lng2: Double
    ) -> Double {
        let phi1 = lat1 * .pi / 180.0
        let phi2 = lat2 * .pi / 180.0
        let deltaLambda = (lng2 - lng1) * .pi / 180.0

        let y = sin(deltaLambda) * cos(phi2)
        let x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda)
        let bearingRad = atan2(y, x)
        return (bearingRad * 180.0 / .pi + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
}
