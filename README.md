# SwiftUIMap

<img src="https://github.com/Mcrich23/SwiftUIMap/blob/92f1b2a4040ccdd7eead54acdbaaada4da0b697d/README%20Images/Map.png" width="142.5" height="300">

SwiftUIMap is the best UIKit wrapper for MapKit!

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
