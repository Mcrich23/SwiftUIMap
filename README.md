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
ExistingMapView(
    zoom: 0.4, // Starting Zoom of Map (Range: 0-1, Lower is closer in)
    address: "Seattle, Wa", // Starting Address in the Center of the Map
    points: [
        Annotations(
            title: "Townhall", // Top line on map
            subtitle: "Newly Remodeled", // Underneath top line when clicked
            address: "1119 8th Ave, Seattle, WA, 98101, United States", // Address for point
            glyphImage: .defaultIcon, // Glyph icon on map point
            markerTintColor: .red, // Marker background
            glyphTintColor: .white, // Glyph icon color
            displayPriority: .required // How markers are shown
        )
    ],
    selected: { Title, Subtitle, Address, isCluster in // Action When Marker is Selected (Returns title, subtitle, and address in annotation along with if it's in a cluster)
        print("tapped \(Address)")
    }, deselected: { // Action When Marker is Deselceted
        print("deselected annotation")
})
```
### **MutableMapView**

```
MutableMapView(
    zoom: 0.4, // Starting Zoom of Map (Range: 0-1, Lower is closer in)
    address: "Seattle, Wa") // Starting Address in the Center of the Map
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
```

### **MapSearchView**

```
MapSearchView { address in //Address passed back
    zoom = 0.2 // Zooms out
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650), execute: { // Wait to go to the new place
        self.address = address // Change central address
    })
}
```
