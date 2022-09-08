import Foundation
import MapKit
import SwiftUI
import CoreLocation
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

struct rawMutableAnnotationMap: UIViewRepresentable {
    var zoom: Double
    var address: String
    var coordinates: LocationCoordinate
    var modifierMap: MKMapView
    
//    var annotationSelected: MKAnnotationView
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
        if address != "" {
            var coordinates = CLLocationCoordinate2D()
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
                coordinates.latitude = location.coordinate.latitude
                coordinates.longitude = location.coordinate.longitude
                let region = MKCoordinateRegion(center: coordinates, span: span)
                mapView.setRegion(region, animated: true)
            }
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let region = MKCoordinateRegion(center: coordinates, span: span)
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
     address: .address("Seattle, Wa")
 )
 ```
 */
public struct MutableMapView: View {
    @Binding public var zoom: Double
    @Binding public var address: String
    @Binding public var coordinates: LocationCoordinate
    @Binding public private(set) var isFirstResponder: Bool
    @State public var modifierMap: MKMapView
    
    public init(zoom: Binding<Double>, address: Binding<String>) {
        self._zoom = zoom
        self._address = address
        self._coordinates = Binding(get: {
            LocationCoordinate(latitude: 0, longitude: 0)
        }, set: { _ in
        })
        self.modifierMap = MKMapView()
        self._isFirstResponder = .constant(false)
    }
    public init(zoom: Binding<Double>, address: Binding<String>, advancedModifiers: () -> MKMapView) {
        self._zoom = zoom
        self._address = address
        self._coordinates = Binding(get: {
            LocationCoordinate(latitude: 0, longitude: 0)
        }, set: { _ in
        })
        self._isFirstResponder = .constant(false)
        self.modifierMap = advancedModifiers()
    }
    public init(zoom: Binding<Double>, address: Binding<String>, isFirstResponder: Binding<Bool>) {
        self._zoom = zoom
        self._address = address
        self._coordinates = Binding(get: {
            LocationCoordinate(latitude: 0, longitude: 0)
        }, set: { _ in
        })
        self.modifierMap = MKMapView()
        self._isFirstResponder = isFirstResponder
        self.checkInfo()
    }
    public init(zoom: Binding<Double>, address: Binding<String>, isFirstResponder: Binding<Bool>, advancedModifiers: () -> MKMapView) {
        self._zoom = zoom
        self._address = address
        self._coordinates = Binding(get: {
            LocationCoordinate(latitude: 0, longitude: 0)
        }, set: { _ in
        })
        self._isFirstResponder = isFirstResponder
        self.modifierMap = advancedModifiers()
        self.checkInfo()
    }
    public init(zoom: Binding<Double>, coordinates: Binding<LocationCoordinate>) {
        self._zoom = zoom
        self._coordinates = coordinates
        self._address = Binding(get: {
            ""
        }, set: { _ in
        })
        self.modifierMap = MKMapView()
        self._isFirstResponder = .constant(false)
    }
    public init(zoom: Binding<Double>, coordinates: Binding<LocationCoordinate>, advancedModifiers: () -> MKMapView) {
        self._zoom = zoom
        self._coordinates = coordinates
        self._address = Binding(get: {
            ""
        }, set: { _ in
        })
        self._isFirstResponder = .constant(false)
        self.modifierMap = advancedModifiers()
    }
    public init(zoom: Binding<Double>, coordinates: Binding<LocationCoordinate>, isFirstResponder: Binding<Bool>) {
        self._zoom = zoom
        self._coordinates = coordinates
        self._address = Binding(get: {
            ""
        }, set: { _ in
        })
        self.modifierMap = MKMapView()
        self._isFirstResponder = isFirstResponder
        self.checkInfo()
    }
    public init(zoom: Binding<Double>, coordinates: Binding<LocationCoordinate>, isFirstResponder: Binding<Bool>, advancedModifiers: () -> MKMapView) {
        self._zoom = zoom
        self._coordinates = coordinates
        self._address = Binding(get: {
            ""
        }, set: { _ in
        })
        self._isFirstResponder = isFirstResponder
        self.modifierMap = advancedModifiers()
        self.checkInfo()
    }
    
    func checkInfo() {
        DispatchQueue.main.async {
            self.isFirstResponder = self.modifierMap.isFirstResponder
            checkInfo()
        }
    }
    
    public var body: some View {
        rawMutableAnnotationMap(zoom: zoom, address: address, coordinates: coordinates, modifierMap: modifierMap)
    }
    // MARK: Modifiers
    /**
    Select the pointOfInterestCategories
    - parameter include: An array including all the point of interest types you want to show on your map.
     
    # Example #
    ```
     .pointOfInterestCategories(include: [.airport])
    ```
    */
    public func pointOfInterestCategories(include points: [MKPointOfInterestCategory]) -> MutableMapView {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(including: points)
        return self
    }
    /**
    Select the pointOfInterestCategories
    - parameter include: An array excluding all the point of interest types you don't want to show on your map.
     
    # Example #
    ```
     .pointOfInterestCategories(exclude: [.airport])
    ```
    */
    public func pointOfInterestCategories(exclude points: [MKPointOfInterestCategory]) -> MutableMapView {
        modifierMap.pointOfInterestFilter = MKPointOfInterestFilter(excluding: points)
        return self
    }
    /**
    Select the pointsOfInterestFilter
    - parameter filter: A class that allows you to include or exclude all points of interest
     
    # Example #
    ```
     .pointsOfInterest(.includeAll)
    ```
    */
    public func pointsOfInterest(_ filter: MKPointOfInterestFilter) -> MutableMapView {
        modifierMap.pointOfInterestFilter = filter
        return self
    }
    /**
    Whether you want the compass to show.
    - parameter show: A boolean for if you want to show the compass or not.
     
    # Example #
    ```
     .showCompass(true)
    ```
    */
    public func showCompass(_ show: Bool) -> MutableMapView {
        modifierMap.showsCompass = show
        return self
    }
    /**
    Whether you want the scale to show.
    - parameter show: A boolean for if you want to show the scale or not.
     
    # Example #
    ```
     .showScale(true)
    ```
    */
    public func showScale(_ show: Bool) -> MutableMapView {
        modifierMap.showsScale = show
        return self
    }
    /**
    Whether you want to show the traffic.
    - parameter show: A boolean for if you want to show the traffic or not.
     
    # Example #
    ```
     .showTraffic(true)
    ```
    */
    public func showTraffic(_ show: Bool) -> MutableMapView {
        modifierMap.showsTraffic = show
        return self
    }
    /**
    Whether you want to show the buildings.
    - parameter show: A boolean for if you want to show the buildings or not.
     
    # Example #
    ```
     .showTraffic(true)
    ```
    */
    public func showBuildings(_ show: Bool) -> MutableMapView {
        modifierMap.showsBuildings = show
        return self
    }
    /**
    What type of map you show.
    - parameter type: The type of map that is shown.
     
    # Example #
    ```
     .mapType(.standard)
    ```
    */
    public func mapType(_ type: MKMapType) -> MutableMapView {
        modifierMap.mapType = type
        return self
    }
    /**
    Settings for the camera angle.
    - parameter camera: A `MKMapCamera` variable with all the settings for the camera viewing the map .
     
    # Example #
    ```
     .camera(MKMapCamera(lookingAtCenter: loc, fromDistance: 4, pitch: 4, heading: 4))
    ```
    */
    public func camera(_ camera: MKMapCamera) -> MutableMapView {
        modifierMap.camera = camera
        return self
    }
    /**
    Whether or not zoom is enabled.
    - parameter enabled: A boolean for if you want zoom to be enabled.
     
    # Example #
    ```
     .isZoomEnabled(true)
    ```
    */
    public func isZoomEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isZoomEnabled = enabled
        return self
    }
    /**
     A boundary of an area within which the map's center must remain.
    - parameter boundary: The camera boundary and all the settings that are availible.
     
    # Example #
    ```
     .cameraBoundary(MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4))))
    ```
    */
    public func cameraBoundary(_ boundary: MKMapView.CameraBoundary?) -> MutableMapView {
        modifierMap.cameraBoundary = boundary
        return self
    }
    /**
     Select the zoom range for your map.
    - parameter range: The camera range and all the settings that are availible.
     
    # Example #
    ```
     .cameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: CLLocationDistance(600)))
    ```
    */
    public func cameraZoomRange(_ range: MKMapView.CameraZoomRange!) -> MutableMapView {
        modifierMap.cameraZoomRange = range
        return self
    }
    /**
    Whether or not pitch is enabled.
    - parameter enabled: A boolean for if you want pitch to be enabled.
     
    # Example #
    ```
     .isPitchEnabled(true)
    ```
    */
    public func isPitchEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isPitchEnabled = enabled
        return self
    }
    /**
    Whether or not rotate is enabled.
    - parameter enabled: A boolean for if you want rotate to be enabled.
     
    # Example #
    ```
     .isRotateEnabled(true)
    ```
    */
    public func isRotateEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isRotateEnabled = enabled
        return self
    }
    /**
    Whether or not scroll is enabled.
    - parameter enabled: A boolean for if you want scroll to be enabled.
     
    # Example #
    ```
     .isScrollEnabled(true)
    ```
    */
    public func isScrollEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isScrollEnabled = enabled
        return self
    }
    /**
    Whether or not multiple touch is enabled.
    - parameter enabled: A boolean for if you want multiple touch to be enabled.
     
    # Example #
    ```
     .isMultipleTouchEnabled(true)
    ```
    */
    public func isMultipleTouchEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isMultipleTouchEnabled = enabled
        return self
    }
    /**
    Whether or not user interaction is enabled.
    - parameter enabled: A boolean for if you want user interaction to be enabled.
     
    # Example #
    ```
     .isUserInteractionEnabled(true)
    ```
    */
    public func isUserInteractionEnabled(_ enabled: Bool) -> MutableMapView {
        modifierMap.isUserInteractionEnabled = enabled
        return self
    }
    /**
    The type of user tracking mode shown on the map.
    - parameter mode: Decide the user tracking mode for the map.
     
    # Example #
    ```
     .userTrackingMode(.follow)
    ```
    */
    public func userTrackingMode(_ mode: MKUserTrackingMode) -> MutableMapView {
        modifierMap.userTrackingMode = mode
        return self
    }
}
#endif
