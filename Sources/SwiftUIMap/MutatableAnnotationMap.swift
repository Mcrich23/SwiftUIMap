import Foundation
import MapKit
import SwiftUI
import CoreLocation
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct rawMutableAnnotationMap: UIViewRepresentable {
    var zoom: Double
    var address: String
    var points: [Annotations]
    var pointOfInterestFilter: MKPointOfInterestFilter
    var selected: (_ Address: String, _ Cluster: Bool) -> Void
    var deselected: () -> Void
    
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
            let longPressRemove = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(rawMutableAnnotationMapCoordinator.removeAnnotation(gesture:)))
            longPressRemove.minimumPressDuration = 0.7
            myMap.addGestureRecognizer(longPressRemove)
            for point in points {

                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(point.address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }

                    // Use your location
                    let annotation = MKPointAnnotation()
                    annotation.coordinate.latitude = location.coordinate.latitude
                    annotation.coordinate.longitude = location.coordinate.longitude
                    annotation.title = point.title
                    annotation.subtitle = point.subtitle
                    myMap.addAnnotation(annotation)
                }
            }
            myMap.pointOfInterestFilter = pointOfInterestFilter
            myMap.delegate = context.coordinator
            return myMap
        }

    func makeCoordinator() -> rawMutableAnnotationMapCoordinator {
        return rawMutableAnnotationMapCoordinator(self, points: points) { address, cluster  in
//            print("tapped passed back, annotation = \(annotation)")
            selected(address, cluster)
        } deselected: {
            deselected()
        }
    }

    class rawMutableAnnotationMapCoordinator: NSObject, MKMapViewDelegate {
        var entireMapViewController: rawMutableAnnotationMap
        var points: [Annotations]
        var selected: (_ Address: String, _ Cluster: Bool) -> Void
        var deselected: () -> Void
        init(_ control: rawMutableAnnotationMap, points: [Annotations], selected: @escaping (_ Address: String, _ Cluster: Bool) -> Void, deselected: @escaping () -> Void) {
            self.entireMapViewController = control
            self.points = points
            self.selected = selected
            self.deselected = deselected
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String(describing: annotation.title))
            if points != [] && points != nil {
                let annotationDetails = points.first { annotate in
                    annotate.title == annotationView.annotation?.title
                }
                if annotationDetails!.glyphImage != "" {
                    annotationView.glyphImage = UIImage(systemName: annotationDetails!.glyphImage)
                }
                annotationView.glyphTintColor = annotationDetails!.glyphTintColor
                annotationView.markerTintColor = annotationDetails!.markerTintColor
                annotationView.tintColor = annotationDetails!.tintColor
                annotationView.displayPriority = annotationDetails!.displayPriority
                annotationView.clusteringIdentifier = "test"
                let removeElement = points.firstIndex(of: annotationDetails!)
                points.remove(at: removeElement!)
            }
            return annotationView
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let coordinates = view.annotation!.coordinate
            let annotationCluster = view.annotation as? MKClusterAnnotation
            if mapView.selectedAnnotations.count > 0 {
                //                mapView.deselectAnnotation(view as? MKAnnotation, animated: true)
            }
            //            if points != [] {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { placemarks, error in
                if error == nil {
                    let placemark = placemarks!.first
                    let location = String(describing: placemark!.location)
                    if let cluster = annotationCluster {
                        //*** Need array list of annotation inside cluster here ***
                        let arrayList = cluster.memberAnnotations
                        print("cluster list = \(arrayList)")
                        // If you want the map to display the cluster members
                        if arrayList.count > 1 {
                            self.entireMapViewController.selected(location, true)
                        }else {
                            self.entireMapViewController.selected(location, false)
                        }
                    }else {
                        self.entireMapViewController.selected(location, false)
                    }
                    //            }else {
                    //                print("no annotation")
                    //            }
                }else {
                    print("error, \(error)")
                }
            }
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            deselected()
        }
        @objc func removeAnnotation(gesture: UIGestureRecognizer) {

            if gesture.numberOfTouches == 2 {
                
                if let mapView = gesture.view as? MKMapView {
                    let point = gesture.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mapView.removeAnnotation(annotation)
                    print("pinCoordinate = lat: \(coordinate.latitude), long: \(coordinate.longitude)")
                }
            }
        }
        @objc func addAnnotation(gesture: UIGestureRecognizer) {
            
            if gesture.state == .began {
                
                if let mapView = gesture.view as? MKMapView {
                    let point = gesture.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    print("pinCoordinate = lat: \(coordinate.latitude), long: \(coordinate.longitude)")
                }
            }
        }
    }
}

public struct MutableAnnotationMap: View {
    @State public var zoom: Double
    @State public var address: String
    @State public var points: [Annotations]
    @State public var pointOfInterestFilter: MKPointOfInterestFilter
    @State public var selected: (_ Address: String, _ Cluster: Bool) -> Void
    @State public var deselected: () -> Void
    
    public init(zoom: Double, address: String, points: [Annotations], pointsOfInterestFilter: MKPointOfInterestFilter, selected: @escaping (_ Address: String, _ Cluster: Bool) -> Void, deselected: @escaping () -> Void) {
            self.zoom = zoom
            self.address = address
            self.points = points
            self.pointOfInterestFilter = pointsOfInterestFilter
            self.selected = selected
            self.deselected = deselected
        }
    
    public var body: some View {
        rawMutableAnnotationMap(zoom: zoom, address: address, points: points, pointOfInterestFilter: pointOfInterestFilter, selected: {Address, Cluster in
            address = Address
            if zoom > 0.05 {
                zoom = zoom/3
                if zoom < 0.05 {
                    zoom = 0.05
                }
            }
            selected(Address, Cluster)
        }, deselected: deselected)
    }
}
#endif
