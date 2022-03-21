# SwiftUIMap

SwiftUIMap is the best UIKit wrapper for MapKit!

Currently, we only support set annotations, but are working on a mutatable map.

## Installation
### **Swift Package Manager**

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. It is in early development, but SwiftUIMap does support its use on supported platforms.

Once you have your Swift package set up, adding SwiftUIMap as a dependency is as easy as adding it to the dependencies value of your Package.swift.

dependencies: [
    .package(url: "https://github.com/Mcrich23/SwiftUIMap.git", .upToNextMajor(from: "1.0.0"))
]

## Usage

### **ExistingAnnotationMap**

```
MutableAnnotationMap(zoom: 0.4, address: "Seattle, Wa", pointsOfInterestFilter: .excludingAll) { Address, Cluster in
            print("tapped \(Address)")
        } deselected: {
        print("deselected point")
}
```
