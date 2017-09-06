import UIKit
import MapKit

public class MapViewController: UIViewController {

    public var didTap: ((CLLocationCoordinate2D) -> ())? = nil
    public var didLongPress: ((CLLocationCoordinate2D) -> ())? = nil
    public var didFinishRendering: ((Bool) -> ())? = nil
    public var didFinishLoading: (() -> ())? = nil
    public var didAddAnnotation: ((MKPointAnnotation) -> ())? = nil


    public var from: CLLocationCoordinate2D? {
        didSet {
            if let from = from {
                fromPin.coordinate = from
                mapView.addAnnotation(fromPin)
            } else {
                mapView.removeAnnotation(fromPin)
            }
        }
    }
    public var to: CLLocationCoordinate2D? = nil {
        didSet {
            if let to = to {
                toPin.coordinate = to
                mapView.addAnnotation(toPin)
            } else {
                mapView.removeAnnotation(toPin)
            }
        }
    }

    public var path: MKPolyline? = nil {
        didSet {
            if let oldValue = oldValue {
                mapView.remove(oldValue)
            }
            if let path = path {
                mapView.add(path)
            }
        }
    }
    public var obstacles: [MKPolygon] = [] {
        didSet {
            oldValue.forEach(mapView.remove)
            updateToObstacles()
        }
    }

    private let fromPin = MKPointAnnotation()
    private let toPin = MKPointAnnotation()
    private var backgroundOverlay = MKPolygon()

    public var accent: UIColor?
    public var primary: UIColor?
    public var secondary: UIColor?
    public var background: UIColor? {
        didSet {
            updateBackground()
        }
    }

    public private(set) var mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .mutedStandard
        map.showsPointsOfInterest = false
        map.showsScale = false
        map.showsCompass = false
        map.showsTraffic = false
        return map
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMap))
        tap.require(toFail: longPress)
        mapView.addGestureRecognizer(tap)
        mapView.addGestureRecognizer(longPress)
        updateToObstacles()
    }

    private func updateToObstacles() {
        obstacles.forEach(mapView.add)

//        mapView.showsBuildings = obstacles.isEmpty
    }

    private func updateBackground() {
        mapView.remove(backgroundOverlay)
        let points = mapView.visibleMapRect.points
        backgroundOverlay = MKPolygon(points: points, count: points.count)
        mapView.insert(backgroundOverlay, at: 0)
    }

    @objc private func didTapMap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        didTap?(coordinate)
    }

    @objc private func didLongPressMap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        didLongPress?(coordinate)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
}

extension MapViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            if obstacles.contains(polygon) {
                renderer.strokeColor = accent
                renderer.fillColor = secondary
                renderer.lineWidth = 1
            } else {
                renderer.fillColor = background
            }
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = primary
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }

    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        didFinishRendering?(fullyRendered)
    }

    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        didFinishLoading?()
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        updateBackground()
    }
}

extension MKMapRect {

    var points: [MKMapPoint] {
        return [
            MKMapPoint(x: MKMapRectGetMinX(self), y: MKMapRectGetMinY(self)),
            MKMapPoint(x: MKMapRectGetMaxX(self), y: MKMapRectGetMinY(self)),
            MKMapPoint(x: MKMapRectGetMaxX(self), y: MKMapRectGetMaxY(self)),
            MKMapPoint(x: MKMapRectGetMinX(self), y: MKMapRectGetMaxY(self)),
        ]
    }
}
