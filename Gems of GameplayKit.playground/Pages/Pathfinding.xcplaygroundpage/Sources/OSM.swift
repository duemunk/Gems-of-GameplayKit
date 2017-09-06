import Foundation
import CoreLocation


public struct OSM: Codable {
    let nodes: [Node]
    let ways: [Way]
    enum CodingKeys: String, CodingKey {
        case nodes = "node"
        case ways = "way"
    }

    public init() throws {
        let osmUrl = Bundle.main.url(forResource: "osm", withExtension: "json")!
        let data = try Data(contentsOf: osmUrl)
        self = try JSONDecoder().decode(OSM.self, from: data)
    }

    func node(forReference reference: String) -> Node? {
        return nodes.filter { (node: Node) -> Bool in
            node.id == reference
            }.first
    }

    func way(forId id: String) -> Way? {
        return ways.filter { (way: Way) in
            way.id == id
            }.first
    }

    public func locations(forId id: String) -> [CLLocationCoordinate2D]? {
        guard let way = way(forId: id) else { return nil }
        return way.references.flatMap { (reference: Way.Reference) -> CLLocationCoordinate2D? in
            return node(forReference: reference.ref)?.location
        }
    }
}

struct Node: Codable {
    let id: String
    let lat: String
    let lon: String

    var location: CLLocationCoordinate2D? {
        guard let latitude = Double(lat), let longitude = Double(lon) else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Way: Codable {
    let id: String
    let references: [Reference]

    enum CodingKeys: String, CodingKey {
        case id
        case references = "nd"
    }

    struct Reference: Codable {
        let ref: String
    }
}
