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
            let coordinates = view.annotation!.coordinate
            let annotationCluster = view.annotation as? MKClusterAnnotation
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
                    }else {
                        mapView.addAnnotation(annotation)
                        currentAnnotations.append(annotation)
                    }
                    print("pinCoordinate = lat: \(coordinate.latitude), long: \(coordinate.longitude)")
                }
            }
        }
    }
}

public struct MutableAnnotationMap: View {
    @State public var zoom: Double
    @State public var address: String
    @State public var modifierMap = MKMapView()
    
    public init(zoom: Double, address: String) {
            self.zoom = zoom
            self.address = address
        }
    
    public var body: some View {
        rawMutableAnnotationMap(zoom: zoom, address: address, modifierMap: modifierMap)
    }
    // MARK: Modifiers
    public func pointOfInterestCategories(include points: [MKPointOfInterestCategory]) -> MutableAnnotationMap {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(including: points)
        return self
    }
    public func pointOfInterestCategories(exclude points: [MKPointOfInterestCategory]) -> MutableAnnotationMap {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(excluding: points)
        return self
    }
    public func pointsOfInterest(_ filter: MKPointOfInterestFilter?) -> MutableAnnotationMap {
        modifierMap.pointOfInterestFilter = filter ?? .excludingAll
        return self
    }
    public func showCompass(_ show: Bool) -> MutableAnnotationMap {
        modifierMap.showsCompass = bool
        return self
    }
    public func showScale(_ show: Bool) -> MutableAnnotationMap {
        modifierMap.showsScale = bool
        return self
    }
    public func showTraffic(_ show: Bool) -> MutableAnnotationMap {
        modifierMap.showsTraffic = bool
        return self
    }
    public func showBuildings(_ show: Bool) -> MutableAnnotationMap {
        modifierMap.showsBuildings = bool
        return self
    }
}
#endif
