import Foundation
import MapKit
import SwiftUI
import CoreLocation
import Cocoa
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct SWiftUIMap: UIViewRepresentable {
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
                geoCoder.geocodeAddressString(point.location) { (placemarks, error) in
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
                    annotation.title = point.name
                    annotation.subtitle = point.subtitle
                    myMap.addAnnotation(annotation)
                }
            }
            myMap.pointOfInterestFilter = pointOfInterestFilter
            myMap.delegate = context.coordinator
            return myMap
        }

    func makeCoordinator() -> ResultsRawMapViewCoordinator {
        return ResultsRawMapViewCoordinator(self, points: points) { annotation, cluster, address  in
//            print("tapped passed back, annotation = \(annotation)")
            selected(annotation, cluster)
        } deselected: {
            deselected()
        }
    }

    class ResultsRawMapViewCoordinator: NSObject, MKMapViewDelegate {
        var entireMapViewController: ResultsRawMapView
        var points: [Annotations]
        var selected: (_ Annotations: Annotations, _ Cluster: Bool, _ Address: String) -> Void
        var deselected: () -> Void
        init(_ control: ResultsRawMapView, points: [Annotations], selected: @escaping (_ Annotations: Annotations, _ Cluster: Bool, _ Address: String) -> Void, deselected: @escaping () -> Void) {
            self.entireMapViewController = control
            self.points = points
            self.selected = selected
            self.deselected = deselected
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String(describing: annotation.title))
            let annotationDetails = points.first { annotate in
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(annotate.address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }

                    // Use your location
                    location.coordinate.latitude = annotation.coordinate.latitude
                    location.coordinate.longitude = annotation.coordinate.longitude
                }
            }
            annotationView.glyphImage = UIImage(systemName: annotationDetails?.glyphImage)
            annotationView.glyphTintColor = annotationDetails?.glyphTintColor
            annotationView.markerTintColor = annotationDetails?.markerTintColor
            annotationView.tintColor = annotationDetails?.pointTint
            annotationView.displayPriority = annotationDetails?.displayPriority
            annotationView.clusteringIdentifier = "test"
            return annotationView
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if mapView.selectedAnnotations.count > 0 {
                mapView.deselectAnnotation(view as? MKAnnotation, animated: true)
            }
            let annotation = points.first { Annotations in
                Annotations.name == view.annotation?.title
            }!
            print("tapped annotation, annotation = \(annotation)")
            if let cluster = view.annotation as? MKClusterAnnotation {
                //*** Need array list of annotation inside cluster here ***
                let arrayList = cluster.memberAnnotations
//                print("cluster list = \(arrayList)")
                // If you want the map to display the cluster members
                if arrayList.count > 1 {
                    entireMapViewController.zoom = entireMapViewController.zoom / 3
//                    entireMapViewController.selected(annotation, true)
                    entireMapViewController.address = annotation.location
                }else {
                    entireMapViewController.selected(annotation, false)
                    entireMapViewController.address = annotation.location
                }
            }else {
                entireMapViewController.selected(annotation, false)
                entireMapViewController.address = annotation.location
            }
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            deselected()
        }
    }
}
#endif
