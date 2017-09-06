import Foundation
import CoreLocation
import GameplayKit

extension CLLocationCoordinate2D {
    public var graphNode: GKGraphNode2D {
        return GKGraphNode2D(point: float2_)
    }
    var float2_: float2 {
        return float2(Float(latitude), Float(longitude))
    }
}

extension GKGraphNode2D {
    public var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(position.x), longitude: Double(position.y))
    }
}

extension GKPolygonObstacle {
    public convenience init(locations: [CLLocationCoordinate2D]) {
        let points = locations.map { (location: CLLocationCoordinate2D) -> float2 in
            location.float2_
        }
        self.init(points: points)
    }

    public static func createFrom(locations: [CLLocationCoordinate2D]) -> GKPolygonObstacle {
        let points = locations.map { (location: CLLocationCoordinate2D) -> float2 in
            location.float2_
        }
        return GKPolygonObstacle(points: points)
    }
}
