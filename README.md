# SwiftUIMap

<img src="https://github.com/Mcrich23/SwiftUIMap/blob/92f1b2a4040ccdd7eead54acdbaaada4da0b697d/README%20Images/Map.png" width="142.5" height="300">

SwiftUIMap is the best UIKit wrapper for MapKit!

## Installation
### **Swift Package Manager**

Currently, we only support set annotations, but are working on a user addable marker map.

# Requirements 

- iOS 14, macOS 10.16, tvOS 14, or watchOS 67
- Swift 5.5+
- Xcode 13.0+

# Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).


1. In Xcode, open your project and navigate to **File** → **Add Packages...**
2. Paste the repository URL (`https://github.com/Mcrich23/SwiftUIMap`) and click **Next**.
3. For **Rules**, select **Up To Next Major Version** (With base version set to 1.1.0).
4. Click **Finish**.
5. Check **Mcrich23-Toolkit**
6. Click **Add To Project**

## Usage

Note: To use a map from SwiftUIMap, you need to import MapKit

### **AnnotationMapView**

```
ExistingMapView (
    zoom: 0.4, // Starting Zoom of Map (Range: 0-1, Lower is closer in)
    address: "Seattle, Wa", // Starting address in the Center of the Map (use this or coordinates)
    points: [
        Annotations(
            title: "Townhall", // Top line on map
            subtitle: "Newly Remodeled", // Underneath top line when clicked
            location: .address("1119 8th Ave, Seattle, WA, 98101, United States"), // Location for point
            glyphImage: .defaultIcon, // Glyph icon on map point
            markerTintColor: .red, // Marker background
            glyphTintColor: .white, // Glyph icon color
            displayPriority: .required // How markers are shown
        )
    ],
    isUserLocationVisible: $isUserLocationVisible, // Binding for if isUserLocationVisible
    selected: { Title, Subtitle, Address, isCluster in // Action When Marker is Selected (Returns title, subtitle, and address in annotation along with if it's in a cluster)
        print("tapped \(Address)")
    }, deselected: { // Action When Marker is Deselceted
        print("deselected annotation")
    }, advancedModifiers: { // Full access to MKMapView modifiers
        map.alpha = 0.4
    }
)
```
### **MutableMapView**

```
MutableMapView (
    zoom: 0.4, // Starting Zoom of Map (Range: 0-1, Lower is closer in)
    address: "Seattle, Wa", // Starting address in the Center of the Map (use this or coordinates)
    isFirstResponder: $isFirstResponder // Binding for if isFirstResponder
)
```

### **Modifiers**

```
...
    .pointsOfInterest(.excludingAll) // Filter Points of Interest (exclude or include all)
    .pointOfInterestCategories(include: [.atm]) // Filter Points of Interest to only include things in an array
    .pointOfInterestCategories(exclude: [.airport]) // Filter Points of Interest to include everything except things in an array
    .showCompass(false) // Show Compass (true or false)
    .showScale(false) // Show Scale (true or false)
    .showTraffic(false) // Show Traffic (true or false)
    .showBuildings(false) // Show Buildings (true or false)
    .mapType(.satellite) // Different types of map (Standard, MutedStandard, Hybrid, HybridFlyover, Satellite, SatelliteFlyover)
    .camera(MKMapCamera(lookingAtCenter: loc, fromDistance: .pi, pitch: 4, heading: .pi)) // Customize the camera angle
    .cameraBoundary(MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)))) // Customize the camera boundary
    .cameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: CLLocationDistance(600))) // Customize the zoom range (minCenterCoordinateDistance and maxCenterCoordinateDistance)
    .isPitchEnabled(true) // Enable or disable the use of pitch
    .isUserInteractionEnabled(true) // Enable or disable interaction
    .isZoomEnabled(true) // Enable or disable the use of zoom
    .isRotateEnabled(true) // Enable or disable the use of rotation
    .isScrollEnabled(true) // Enable or disable the use of scroll
    .isMultipleTouchEnabled(true) // Enable or disable the use of multi-touch
    .userTrackingMode(.none) // Sets the mode for user tracking (must have permission to track user)
```

### **MapSearchView**

```
MapSearchView { address in // Address passed back
    zoom = 0.2 // Zooms out
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650), execute: { // Wait to go to the new place
        self.address = address // Change central address
    })
}
```
### **defaultCameraAngle**

```
SwiftUIMap.defaultCameraAngle( // Get Default Camera Angle
    location: CLLocationCoordinate2D( // Center coordinates
        latitude: lat, // Latitude for center coordinate
        longitude: long // Longitude for center coordinate
    ), 
    zoom: zoom // How far zoomed in the camera is
)
```
