import Foundation
import MapKit
import SwiftUI
import CoreLocation
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct RawExistingAnnotationMap: UIViewRepresentable {
    var zoom: Double
    var address: String
    @Binding var points: [Annotations]
    var modifierMap: MKMapView
    var selected: (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void
    var deselected: () -> Void
    var addedPoints = [MKAnnotation]()
    var pointDict: [Annotations : CLLocationCoordinate2D] = [:]
    // isUserLocationVisible variables
    var userLocationBecomesVisible: () -> Void
    var userLocationBecomesInvisible: () -> Void
    
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
        
        let myMap = modifierMap
        self.addPoints(myMap: myMap)
        if myMap.delegate == nil {
            myMap.delegate = context.coordinator
        }
        return myMap
    }
    
    func addPoints(myMap: MKMapView) {
        myMap.removeAnnotations(addedPoints)
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
    }
    
    func makeCoordinator() -> rawExistingAnnotationMapCoordinator {
        return rawExistingAnnotationMapCoordinator(self, points: points) { title, subtitle, address, cluster  in
//            print("tapped passed back, annotation = \(annotation)")
            selected(title, subtitle, address, cluster)
        } deselected: {
            deselected()
        }
    }

    class rawExistingAnnotationMapCoordinator: NSObject, MKMapViewDelegate {
        var entireMapViewController: RawExistingAnnotationMap
        var selected: (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void
        var deselected: () -> Void
        init(_ control: RawExistingAnnotationMap, points: [Annotations], selected: @escaping (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void, deselected: @escaping () -> Void) {
            self.entireMapViewController = control
            self.selected = selected
            self.deselected = deselected
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String(describing: annotation.title))
            if self.entireMapViewController.points != [] && self.entireMapViewController.points.contains(where: {
                point in point.title == annotationView.annotation?.title
            }) {
                let annotationDetails = self.entireMapViewController.points.first { annotate in
                    annotate.title == annotationView.annotation?.title
                }!
                if annotationDetails.glyphImage != UIImage() {
                    annotationView.glyphImage = annotationDetails.glyphImage
                }
                annotationView.glyphTintColor = annotationDetails.glyphTintColor
                annotationView.markerTintColor = annotationDetails.markerTintColor
//                annotationView.tintColor = annotationDetails!.tintColor
                annotationView.displayPriority = annotationDetails.displayPriority
                annotationView.clusteringIdentifier = "test"
                self.entireMapViewController.pointDict[annotationDetails] = annotationView.annotation?.coordinate
                self.entireMapViewController.addedPoints.append(annotation)
            }
            return annotationView
        }
        
        func addressToLatLong(address: String, completion: @escaping (_ coordinate: CLLocationCoordinate2D) -> Void) {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { placemarks, error in
                if error == nil {
                    if let placemarks = placemarks,
                       let location = placemarks.first?.location {
                        completion(location.coordinate)
                    } else {
                        completion(CLLocationCoordinate2D())
                    }
                } else {
                    completion(CLLocationCoordinate2D())
                }
            }
        }
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("SwiftUIMap.updateAnnotations"), object: Bool(true), queue: .main) { _ in
                self.updateAnnotations(mapView: mapView)
            }
        }
        @objc func updateAnnotations(mapView: MKMapView) {
            print("points changed!")
            print("check, points.count = \(self.entireMapViewController.points.count)")
            for point in self.entireMapViewController.points {
                print("check point \(point)")
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
                    if !mapView.annotations.contains(where: { an in
                        an.coordinate.latitude == annotation.coordinate.latitude && an.coordinate.longitude == annotation.coordinate.longitude
                    }) {
                        print("add annotation \(annotation)")
                        self.entireMapViewController.pointDict[point] = annotation.coordinate
                        mapView.addAnnotation(annotation)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftUIMap.updateAnnotations"), object: Bool(false))
            }
            for annotation in mapView.annotations {
                if self.entireMapViewController.points.contains(where: { point in
                    self.entireMapViewController.pointDict[point]?.longitude != annotation.coordinate.longitude && self.entireMapViewController.pointDict[point]?.latitude != annotation.coordinate.latitude
                }) {
                    mapView.removeAnnotation(annotation)
                }
            }
        }
        func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
            entireMapViewController.userLocationBecomesVisible()
        }
        func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
            entireMapViewController.userLocationBecomesInvisible()
        }
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            entireMapViewController.userLocationBecomesInvisible()
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
                    let title: String = (view.annotation?.title!!)!
                    let subtitle: String = (view.annotation?.subtitle!!)!
                    let placemark = placemarks!.first
                    let location = String(describing: placemark!.location)
                    if let cluster = annotationCluster {
                        //*** Need array list of annotation inside cluster here ***
                        let arrayList = cluster.memberAnnotations
                        print("cluster list = \(arrayList)")
                        // If you want the map to display the cluster members
                        if arrayList.count > 1 {
                            self.entireMapViewController.selected(title, subtitle, location, true)
                        }else {
                            self.entireMapViewController.selected(title, subtitle, location, false)
                        }
                    }else {
                        self.entireMapViewController.selected(title, subtitle, location, false)
                    }
                    //            }else {
                    //                print("no annotation")
                    //            }
                }else {
                    print("error, \(String(describing: error))")
                }
            }
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            deselected()
        }
    }
}

struct ExistingAnnotationMapProxy: View {
    @Binding var zoom: Double {
        didSet {
            print("update zoom")
        }
    }
    @Binding public var address: String {
        didSet {
            print("update address")
        }
    }
    @State var refresh = false {
        didSet {
            if refresh {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                    refresh = false
                }
            }
        }
    }
    @State var points: [Annotations]
    @Binding var isUserLocationVisible: Bool
    @Binding var modifierMap: MKMapView
    @State var selected: (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void
    @State var deselected: () -> Void
    var body: some View {
        RawExistingAnnotationMap(zoom: zoom, address: address, points: $points, modifierMap: modifierMap, selected: { Title, Subtitle, Address, Cluster in
            address = Address
            if zoom > 0.05 {
                zoom = zoom/3
                if zoom < 0.05 {
                    zoom = 0.05
                }
            }
            selected(Title, Subtitle, Address, Cluster)
        }, deselected: deselected) {
            self.isUserLocationVisible = true
        } userLocationBecomesInvisible: {
            self.isUserLocationVisible = false
        }
    }
}
#endif
