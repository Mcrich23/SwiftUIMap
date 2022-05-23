import Foundation
import MapKit
import SwiftUI
import CoreLocation
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct rawMutableAnnotationMap: UIViewRepresentable {
    var zoom: Double
    var address: String
    var modifierMap: MKMapView
    
//    var annotationSelected: MKAnnotationView
    func updateUIView(_ mapView: MKMapView, context: Context) {
            let span = MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            var chicagoCoordinate = CLLocationCoordinate2D()
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
                }

                // Use your location
                chicagoCoordinate.latitude = location.coordinate.latitude
                chicagoCoordinate.longitude = location.coordinate.longitude
                let region = MKCoordinateRegion(center: chicagoCoordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
    
        func makeUIView(context: Context) -> MKMapView {

            let myMap = MKMapView(frame: .zero)
            let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(rawMutableAnnotationMapCoordinator.addAnnotation(gesture:)))
            longPress.minimumPressDuration = 0.5
            myMap.addGestureRecognizer(longPress)
//            for point in points {
//
//                let geoCoder = CLGeocoder()
//                geoCoder.geocodeAddressString(point.address) { (placemarks, error) in
//                    guard
//                        let placemarks = placemarks,
//                        let location = placemarks.first?.location
//                    else {
//                        // handle no location found
//                        return
//                    }
//
//                    // Use your location
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate.latitude = location.coordinate.latitude
//                    annotation.coordinate.longitude = location.coordinate.longitude
//                    annotation.title = point.title
//                    annotation.subtitle = point.subtitle
//                    myMap.addAnnotation(annotation)
//                }
//            }
            myMap.pointOfInterestFilter = modifierMap.pointOfInterestFilter
            myMap.showsCompass = modifierMap.showsCompass
            myMap.showsScale = modifierMap.showsScale
            myMap.showsTraffic = modifierMap.showsTraffic
            myMap.showsBuildings = modifierMap.showsBuildings
            myMap.delegate = context.coordinator
            return myMap
        }

    func makeCoordinator() -> rawMutableAnnotationMapCoordinator {
        return rawMutableAnnotationMapCoordinator(self)
    }

    class rawMutableAnnotationMapCoordinator: NSObject, MKMapViewDelegate {
        var entireMapViewController: rawMutableAnnotationMap
        var currentAnnotations = [MKPointAnnotation]()
        init(_ control: rawMutableAnnotationMap) {
            self.entireMapViewController = control
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.removeAnnotation(view.annotation!)
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        }
        @objc func addAnnotation(gesture: UIGestureRecognizer) {
            
            if gesture.state == .began {
                
                if let mapView = gesture.view as? MKMapView {
                    let point = gesture.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    if currentAnnotations.contains(annotation) {
                        mapView.removeAnnotation(annotation)
                        let annotationRemove = currentAnnotations.firstIndex(of: annotation)!
                        currentAnnotations.remove(at: annotationRemove)
                    } else {
                        mapView.addAnnotation(annotation)
                        currentAnnotations.append(annotation)
                    }
                    print("pinCoordinate = lat: \(coordinate.latitude), long: \(coordinate.longitude)")
                }
            }
        }
    }
}
/**
 A map that users can add annotations to.
 
 - parameter zoom: Starting zoom of map (range: 0-1, lower is closer in)
 - parameter address: Starting address in the center of the map
 - warning: Requires MapKit to be imported 

 # Example #
 ```
 MutableMapView(
     zoom: 0.4,
     address: "Seattle, Wa"
 )
 ```
 */
public struct MutableMapView: View {
    @Binding public var zoom: Double
    @Binding public var address: String
    @State public var modifierMap = MKMapView()
    
    public init(zoom: Binding<Double>, address: Binding<String>) {
            self._zoom = zoom
            self._address = address
        }
    
    public var body: some View {
        rawMutableAnnotationMap(zoom: zoom, address: address, modifierMap: modifierMap)
    }
    // MARK: Modifiers
    public func pointOfInterestCategories(include points: [MKPointOfInterestCategory]) -> MutableMapView {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(including: points)
        return self
    }
    public func pointOfInterestCategories(exclude points: [MKPointOfInterestCategory]) -> MutableMapView {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(excluding: points)
        return self
    }
    public func pointsOfInterest(_ filter: MKPointOfInterestFilter!) -> MutableMapView {
        modifierMap.pointOfInterestFilter = filter
        return self
    }
    public func showCompass(_ show: Bool) -> MutableMapView {
        modifierMap.showsCompass = show
        return self
    }
    public func showScale(_ show: Bool) -> MutableMapView {
        modifierMap.showsScale = show
        return self
    }
    public func showTraffic(_ show: Bool) -> MutableMapView {
        modifierMap.showsTraffic = show
        return self
    }
    public func showBuildings(_ show: Bool) -> MutableMapView {
        modifierMap.showsBuildings = show
        return self
    }
    public func mapType(_ type: MKMapType) -> MutableMapView {
        modifierMap.mapType = type
        return self
    }
    public func mapDelegate(_ delegate: MKMapViewDelegate?) -> MutableMapView {
        modifierMap.delegate = delegate
        return self
    }
    public func camera(_ camera: MKMapCamera) -> MutableMapView {
        modifierMap.camera = camera
        return self
    }
    public func isZoomEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isZoomEnabled = enabled
        return self
    }
    public func cameraBoundary(_ boundary: MKMapView.CameraBoundary?) -> MutableMapView {
        modifierMap.cameraBoundary = boundary
        return self
    }
    public func cameraZoomRange(_ range: MKMapView.CameraZoomRange!) -> MutableMapView {
        modifierMap.cameraZoomRange = range
        return self
    }
    public func isPitchEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isPitchEnabled = enabled
        return self
    }
    public func isRotateEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isRotateEnabled = enabled
        return self
    }
    public func isScrollEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isScrollEnabled = enabled
        return self
    }
    public func isMultipleTouchEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isMultipleTouchEnabled = enabled
        return self
    }
    public func isUserInteractionEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isUserInteractionEnabled = enabled
        return self
    }
    public func userTrackingMode(_ mode: MKUserTrackingMode) -> MutableMapView {
        modifierMap.userTrackingMode = mode
        return self
    }
}
#endif
