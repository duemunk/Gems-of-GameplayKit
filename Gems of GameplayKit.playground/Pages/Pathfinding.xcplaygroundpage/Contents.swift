//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import GameplayKit
import MapKit


/*:
 ---
 # Simple Example
 */

do {
    let obstacle = GKPolygonObstacle(
        points: [
            float2(0, 0),
            float2(1, 0),
            float2(1, 2),
            float2(0, 2),
            ]
    )
    obstacle.vertexCount

    let graph = GKObstacleGraph<GKGraphNode2D>(
        obstacles: [obstacle],
        bufferRadius: 0
    )

    let from = GKGraphNode2D(point: float2(x: -1, y: 1))
    let to = GKGraphNode2D(point: float2(x: 2, y: 1))

    graph.connectUsingObstacles(node: from)
    graph.connectUsingObstacles(node: to)

    let path = graph.findPath(from: from, to: to)
}


/*:
 ---
 # Applied to MapKit
 */

let viewController = MapViewController()
viewController.accent = .accent
viewController.primary = .primary
viewController.secondary = .secondary
viewController.background = UIColor.background.withAlphaComponent(0.5)
Playground.present(viewController: viewController)

let left = 12.564
let right = 12.573
let top = 55.676
let bottom = 55.671

let span = MKCoordinateSpan(latitudeDelta: top - bottom, longitudeDelta: right - left)
let center = CLLocationCoordinate2D(latitude: bottom + span.latitudeDelta / 2 , longitude: left + span.longitudeDelta / 2)

let region = MKCoordinateRegion(center: center, span: span)
viewController.mapView.setRegion(region, animated: false)



let ids: [String] = [
    "27169193", // Glassalen
    "4235664", // Lake
    "25616602", // Wagamamma
    "27169203", // Caterpillar
//    "27169230", // Cakenhagen
    "28432654", // Circle next to Wagamamma
    "28463477", // MAD
    "28463481", // Kiin Kiin Piin To
    "28463593", // H.C. Andersen Castle
    "28463686", // Mazzollis
    "28463692", // Stage on side of Grøften
    "42123600", // Price's Dinner
    "42123614", // Paafuglen
    "42123621", // Golden Tower?
    "89694228", // The Flying Trunk
    "89694234", // Small Stage
    "89694236", // Small circle left of Wagamamma
    "89694238", // Bumper cars etc.
    "1039422894", // Start Flyer
]

let osm = try OSM()


var locationses: [[CLLocationCoordinate2D]] = []
var overlayPolygons: [MKPolygon] = []
for id in ids {
    guard let locations = osm.locations(forId: id) else {
        print("No locations for id:", id)
        continue
    }

    var withoutLastDupe = Array(locations.dropLast())
    if !["27169193", "4235664"].contains(id) {
        withoutLastDupe.reverse()
    }

    // Add to map
    let poly = MKPolygon(coordinates: withoutLastDupe, count: withoutLastDupe.count)
    overlayPolygons.append(poly)

    // Add to obstacles
    locationses.append(withoutLastDupe)
}

public class Pathfinding {
    var graph: GKObstacleGraph<GKGraphNode2D>

    public init(obstacles: [[CLLocationCoordinate2D]], bufferRadius: Float) {
        let polygons = obstacles.map(GKPolygonObstacle.init(locations:))
        self.graph = GKObstacleGraph(obstacles: polygons, bufferRadius: bufferRadius)
    }

    private func path(from: GKGraphNode2D, to: GKGraphNode2D) -> [GKGraphNode2D] {
        graph.connectUsingObstacles(node: from)
        graph.connectUsingObstacles(node: to)
        let path = graph
            .findPath(from: from, to: to)
            .map { $0 as! GKGraphNode2D }
        graph.remove([from, to])
        return path
    }

    public func path(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        return path(from: from.graphNode, to: to.graphNode)
            .map{ $0.location }
    }
}


viewController.obstacles = overlayPolygons


let polygons = locationses.map(GKPolygonObstacle.init(locations:))

let pathFinding = Pathfinding(obstacles: locationses, bufferRadius: 0.00005)

// Setup origin and destination
var from = CLLocationCoordinate2D(latitude: 55.6738, longitude: 12.5661)
var to = CLLocationCoordinate2D(latitude: 55.6735, longitude: 12.5707)

func update() {
    viewController.to = to
    viewController.from = from

    // Find path
    let path = pathFinding.path(from: from, to: to)
    let newPathPolyline = MKPolyline(coordinates: path, count: path.count)
    viewController.path = newPathPolyline
}

update()

viewController.didTap = { (coordinate: CLLocationCoordinate2D) in
    to = coordinate
    update()
}

viewController.didLongPress = { (coordinate: CLLocationCoordinate2D) in
    from = coordinate
    update()
}







/* Screenshots for talk */
do {
    let size = CGSize(width: 700, height: 525)
    let map = viewController

    // Empty
    map.obstacles = []
    map.from = nil
    map.to = nil
    map.path = nil
    map.background = nil

    map.didFinishRendering = { fully in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            map.save(filename: "PathFindingEmpty", size: size)

            // With background drop
            map.background = UIColor.background.withAlphaComponent(0.75)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                map.save(filename: "PathFindingOverlay", size: size)

                // With obstacles
                map.obstacles = overlayPolygons

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    map.save(filename: "PathFindingObstacles", size: size)

                    // With from and to pins
                    let from1 = CLLocationCoordinate2D(latitude: 55.6738, longitude: 12.5661)
                    let to1 = CLLocationCoordinate2D(latitude: 55.6735, longitude: 12.5707)
                    map.to = to1
                    map.from = from1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        map.save(filename: "PathFindingFromTo", size: size)

                        let path1 = pathFinding.path(from: from1, to: to1)
                        map.path = MKPolyline(coordinates: path1, count: path1.count)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            map.save(filename: "PathFinding1", size: size)

                            let from2 = CLLocationCoordinate2D(latitude: 55.6742, longitude: 12.5701)
                            let to2 = CLLocationCoordinate2D(latitude: 55.6732, longitude: 12.5663)

                            map.to = to2
                            map.from = from2
                            let path2 = pathFinding.path(from: from2, to: to2)
                            map.path = MKPolyline(coordinates: path2, count: path2.count)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                map.save(filename: "PathFinding2", size: size)
                            }
                        }
                    }
                }
            }
        }
    }
}


//: [Next](@next)
