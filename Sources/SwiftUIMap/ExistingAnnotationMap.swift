import Foundation
import MapKit
import SwiftUI
import CoreLocation
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct rawExistingAnnotationMap: UIViewRepresentable {
    var zoom: Double
    var address: String
    var points: [Annotations]
    var pointOfInterestFilter: MKPointOfInterestFilter
    var selected: (_ Annotations: Annotations, _ Cluster: Bool) -> Void
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

    func makeCoordinator() -> rawExistingAnnotationMapCoordinator {
        return rawExistingAnnotationMapCoordinator(self, points: points) { annotation, cluster, address  in
//            print("tapped passed back, annotation = \(annotation)")
            selected(annotation, cluster)
        } deselected: {
            deselected()
        }
    }

    class rawExistingAnnotationMapCoordinator: NSObject, MKMapViewDelegate {
        var entireMapViewController: rawExistingAnnotationMap
        var points: [Annotations]
        var selected: (_ Annotations: Annotations, _ Cluster: Bool, _ Address: String) -> Void
        var deselected: () -> Void
        init(_ control: rawExistingAnnotationMap, points: [Annotations], selected: @escaping (_ Annotations: Annotations, _ Cluster: Bool, _ Address: String) -> Void, deselected: @escaping () -> Void) {
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
            if mapView.selectedAnnotations.count > 0 {
                //                mapView.deselectAnnotation(view as? MKAnnotation, animated: true)
            }
            //            if points != [] {
            let annotationLong = entireMapViewController.points.first { Annotations in
                
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(Annotations.address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }
                    
                    // Use your location
                    location.coordinate.longitude == view.annotation?.coordinate.longitude
                }
            }!
            let annotation = entireMapViewController.points.first(where: { Annotation in
                
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(Annotation.address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }
                    
                    // Use your location
                    location.coordinate.latitude == view.annotation?.coordinate.latitude && location.coordinate.longitude == view.annotation?.coordinate.longitude
                }
            })!
            print("tapped annotation, annotation = \(annotation)")
            if let cluster = view.annotation as? MKClusterAnnotation {
                //*** Need array list of annotation inside cluster here ***
                let arrayList = cluster.memberAnnotations
                print("cluster list = \(arrayList)")
                // If you want the map to display the cluster members
                if arrayList.count > 1 {
                    entireMapViewController.zoom = entireMapViewController.zoom/3
                    //                    entireMapViewController.selected(annotation, true)
                    entireMapViewController.address = annotation.address
                    print("zoom = \(entireMapViewController.zoom)")
                    entireMapViewController.selected(annotation, true)
                }else {
                    entireMapViewController.selected(annotation, false)
                    entireMapViewController.address = annotation.address
                }
            }else {
                entireMapViewController.selected(annotation, false)
                entireMapViewController.address = annotation.address
            }
            //            }else {
            //                print("no annotation")
            //            }
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            deselected()
        }
    }
}

public struct ExistingAnnotationMap: View {
    @State public var zoom: Double
    @State public var address: String
    @State public var points: [Annotations]
    @State public var pointOfInterestFilter: MKPointOfInterestFilter
    @State public var selected: (_ Annotations: Annotations, _ Cluster: Bool) -> Void
    @State public var deselected: () -> Void
    
    public init(zoom: Double, address: String, points: [Annotations], pointsOfInterestFilter: MKPointOfInterestFilter, selected: @escaping (_ Annotations: Annotations, _ Cluster: Bool) -> Void, deselected: @escaping () -> Void) {
            self.zoom = zoom
            self.address = address
            self.points = points
            self.pointOfInterestFilter = pointsOfInterestFilter
            self.selected = selected
            self.deselected = deselected
        }
    
    public var body: some View {
        rawExistingAnnotationMap(zoom: zoom, address: address, points: points, pointOfInterestFilter: pointOfInterestFilter, selected: {Annotations, Cluster in
            address = Annotations.address
            if zoom > 0.05 {
                zoom = zoom/3
                if zoom < 0.05 {
                    zoom = 0.05
                }
            }
            selected(Annotations, Cluster)
        }, deselected: deselected)
    }
}
#endif
