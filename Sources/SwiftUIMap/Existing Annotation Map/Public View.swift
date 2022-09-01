//
//  File.swift
//  
//
//  Created by Morris Richman on 5/24/22.
//

import Foundation
import MapKit
import SwiftUI

/**
 A map that has annotations and is usable by the user, but cannot add annotations.
 
 - parameter zoom: Starting zoom of map (range: 0-1, lower is closer in)
 - parameter address: Starting address in the center of the map
 - parameter points: How markers are shown
 - parameter selected: Action when marker is selected
 - parameter deselected: Action when marker is deselected
 - parameter isFirstResponder: An `@Binding` variable that tells you if the map is the first reponder
 - parameter advancedModifiers: Advanced modifiers for the map, gives you full access to `MKMapView`
 - warning: Requires MapKit to be imported
 
 # Example #
 ```
 AnnotationMapView (
     zoom: 0.4,
     address: "Seattle, Wa",
     points: [
         Annotations(
            title: "Townhall",
            subtitle: "Newly Remodeled",
            address: "1119 8th Ave, Seattle, WA, 98101, United States",
            glyphImage: .defaultIcon,
            markerTintColor: .red,
            glyphTintColor: .white,
            displayPriority: .required
         )
     ],
     selected: { Title, Subtitle, Address, isCluster in // Returns title, subtitle, and address in annotation along with if it's in a cluster
         print("tapped \(Address)")
     }, deselected: {
         print("deselected annotation")
    }, advancedModifiers: {
        let modifiers = MKMapView(frame: .zero)
        modifiers.isPitchEnabled = true
        return modifiers
    }
)
 ```
 
 */

public struct AnnotationMapView: View {
    @Binding public var zoom: Double {
        didSet {
            print("update zoom")
        }
    }
    @Binding public var address: String {
        didSet {
            print("update address")
        }
    }
    @Binding var isUserLocationVisible: Bool
    @State var refresh = false {
        didSet {
            if refresh {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                    refresh = false
                }
            }
        }
    }
    @Binding public var points: [Annotations]
    @State public var modifierMap: MKMapView
    @State public var selected: (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void
    @State public var deselected: () -> Void
    public init(zoom: Binding<Double>, address: Binding<String>, points: Binding<[Annotations]>, selected: @escaping (_ Title: String, _ Subtitle: String, _ Address: String, _ Cluster: Bool) -> Void, deselected: @escaping () -> Void) {
        self._zoom = zoom
        self._address = address
        self._points = points
        self.selected = selected
        self.deselected = deselected
        self._isUserLocationVisible = .constant(false)
        self.modifierMap = MKMapView(frame: .zero)
        modifierMap.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0)
        setDefaultCamera(self.modifierMap)
    }
    public init(zoom: Binding<Double>, address: Binding<String>, points: Binding<[Annotations]>) {
        self._zoom = zoom
        self._address = address
        self._points = points
        self.selected = {}
        self.deselected = {}
        self._isUserLocationVisible = .constant(false)
        self.modifierMap = MKMapView(frame: .zero)
        modifierMap.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0)
        setDefaultCamera(self.modifierMap)
    }
    public init(zoom: Binding<Double>, address: Binding<String>, points: Binding<[Annotations]>, selected: @escaping (_ Title: String, _ Subtitle: String, _ Address: String, _ isCluster: Bool) -> Void, deselected: @escaping () -> Void, advancedModifiers: @escaping (_ map: MKMapView) -> Void) {
        self._zoom = zoom
        self._address = address
        self._points = points
        self.selected = selected
        self.deselected = deselected
        self._isUserLocationVisible = .constant(false)
        let finalMap: () -> MKMapView = {
            let map = MKMapView()
            map.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0)
            advancedModifiers(map)
            return map
        }
        self.modifierMap = finalMap()
        self.setDefaultCamera(self.modifierMap)
    }
    public init(zoom: Binding<Double>, address: Binding<String>, points: Binding<[Annotations]>, isUserLocationVisible: Binding<Bool>, selected: @escaping (_ Title: String, _ Subtitle: String, _ Address: String, _ isCluster: Bool) -> Void, deselected: @escaping () -> Void) {
        self._zoom = zoom
        self._address = address
        self._points = points
        self.selected = selected
        self.deselected = deselected
        self._isUserLocationVisible = isUserLocationVisible
        self.modifierMap = MKMapView(frame: .zero)
        modifierMap.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0)
        self.setDefaultCamera(self.modifierMap)
    }
    public init(zoom: Binding<Double>, address: Binding<String>, points: Binding<[Annotations]>, isUserLocationVisible: Binding<Bool>, isFirstResponder: Binding<Bool>, selected: @escaping (_ Title: String, _ Subtitle: String, _ Address: String, _ isCluster: Bool) -> Void, deselected: @escaping () -> Void, advancedModifiers: @escaping (_ map: MKMapView) -> Void) {
        self._zoom = zoom
        self._address = address
        self._points = points
        self.selected = selected
        self.deselected = deselected
        self._isUserLocationVisible = isUserLocationVisible
        let finalMap: () -> MKMapView = {
            let map = MKMapView()
            map.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0)
            advancedModifiers(map)
            return map
        }
        self.modifierMap = finalMap()
        self.setDefaultCamera(self.modifierMap)
    }
    
    func setDefaultCamera(_ map: MKMapView) {
        if map == MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(), fromDistance: CLLocationDistance(), pitch: 0, heading: 0) {
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
                let loc = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                map.camera = MKMapCamera(lookingAtCenter: loc, fromDistance: zoom*252555, pitch: 0, heading: 0)
            }
        }
    }
    
    public var body: some View {
        VStack {
            if !refresh {
                RawExistingAnnotationMap(zoom: zoom, address: address, points: points, modifierMap: modifierMap, selected: { Title, Subtitle, Address, Cluster in
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
        .onChange(of: points, perform: { _ in
            print("points changed. points = \(points)")
            NotificationCenter.default.post(name: NSNotification.Name("SwiftUIMap.updateAnnotations"), object: true)
//            refresh = true
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//                refresh = true
            }
        }
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
    public func pointOfInterestCategories(include points: [MKPointOfInterestCategory]) -> AnnotationMapView {
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
    public func pointOfInterestCategories(exclude points: [MKPointOfInterestCategory]) -> AnnotationMapView {
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
    public func pointsOfInterest(_ filter: MKPointOfInterestFilter) -> AnnotationMapView {
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
    public func showCompass(_ show: Bool) -> AnnotationMapView {
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
    public func showScale(_ show: Bool) -> AnnotationMapView {
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
    public func showTraffic(_ show: Bool) -> AnnotationMapView {
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
    public func showBuildings(_ show: Bool) -> AnnotationMapView {
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
    public func mapType(_ type: MKMapType) -> AnnotationMapView {
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
    public func camera(_ camera: MKMapCamera) -> AnnotationMapView {
        print("set current camera (\(modifierMap.camera)) to \(camera)")
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
    public func isZoomEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func cameraBoundary(_ boundary: MKMapView.CameraBoundary?) -> AnnotationMapView {
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
    public func cameraZoomRange(_ range: MKMapView.CameraZoomRange!) -> AnnotationMapView {
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
    public func isPitchEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func isRotateEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func isScrollEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func isMultipleTouchEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func isUserInteractionEnabled(_ enabled: Bool) -> AnnotationMapView {
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
    public func userTrackingMode(_ mode: MKUserTrackingMode) -> AnnotationMapView {
        modifierMap.userTrackingMode = mode
        return self
    }
}
