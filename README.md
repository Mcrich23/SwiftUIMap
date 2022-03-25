# SwiftUIMap

<img src="https://github.com/Mcrich23/SwiftUIMap/blob/92f1b2a4040ccdd7eead54acdbaaada4da0b697d/README%20Images/Map.png" width="142.5" height="300">

SwiftUIMap is the best UIKit wrapper for MapKit!

Currently, we only support set annotations, but are working on a user addable marker map.

## Installation
### **Swift Package Manager**

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. It is in early development, but SwiftUIMap does support its use on supported platforms.

Once you have your Swift package set up, adding SwiftUIMap as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```
dependencies: [
    .package(url: "https://github.com/Mcrich23/SwiftUIMap.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

Note: To use SwiftUIMap, you need to import MapKit

### **ExistingAnnotationMap**

```
ExistingAnnotationMap(
    zoom: 0.4, //Starting Zoom of Map (Range: 0-1, Lower is closer in)
    address: "Seattle, Wa", //Starting Address in the Center of the Map
    points: [Annotations(title: "Townhall", //Top Line on Map
        subtitle: "Newly Remodeled", //Underneath Top Line When Clicked
        address: "1119 8th Ave, Seattle, WA, 98101, United States", //Address for Point
        glyphImage: .defaultIcon, //Glyph Icon on Map Point
        markerTintColor: .red, //Marker Background
        glyphTintColor: .white, //Glyph Icon Color
        displayPriority: .required)], //How Markers are Shown
    pointsOfInterestFilter: .excludingAll, //Wether or Not Other Things Show on the Map
    selected: { Title, Subtitle, Address, Cluster in //Action When Marker is Selected
        print("tapped \(Address)")
    }, deselected: { //Action When Marker is Deselceted
        print("deselected annotation")
})
```

### **MapSearchView**

```
.sheet(isPresented: $search) { //Sheet for Presenting MapSearchView
    MapSearchView { address in //Callback When Search Result is Tapped
        zoom = 0.2 //Change Zoom
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650), execute: { //Wait for Zoom
            self.address = address //Change Address
        })
    }
}
```
