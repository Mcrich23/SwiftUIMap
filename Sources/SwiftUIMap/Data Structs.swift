//
//  Data Structs.swift
//  
//
//  Created by Morris Richman on 3/20/22.
//

import Foundation
import SwiftUI
import MapKit
#if os(iOS) || os(tvOS) || os(watchOS)// || os(macOS)

/**
 An annotation point structure, used in map views
 
 - parameter title: Top line on map
 - parameter subtitle: Underneath top line when clicked
 - parameter addess: Address for point
 - parameter glyphImage: Glyph icon on map point
 - parameter markerTintColor: Marker background
 - parameter glyphTintColor: Glyph icon color
 - parameter displayPriority: How markers are shown
 - warning: Requires MapKit to be imported 

 # Example #
 ```
 Annotations(
    title: "Townhall",
    subtitle: "Newly Remodeled",
    address: "1119 8th Ave, Seattle, WA, 98101, United States",
    glyphImage: .defaultIcon,
    markerTintColor: .red,
    glyphTintColor: .white,
    displayPriority: .required
 )
 ```
 
 */
public struct Annotations: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let address: String
    public let glyphImage: UIImage
    public let markerTintColor: UIColor
    public let glyphTintColor: UIColor
    public let displayPriority: MKFeatureDisplayPriority
    
    public init(title: String, subtitle: String, address: String, glyphImage: glyphImage, markerTintColor: UIColor, glyphTintColor: UIColor, displayPriority: MKFeatureDisplayPriority) {
        self.title = title
        self.subtitle = subtitle
        self.address = address
        switch glyphImage {
        case .systemImage(let string):
            self.glyphImage = UIImage(systemName: string) ?? UIImage()
        case .assetImage(let string):
            self.glyphImage = UIImage(systemName: string) ?? UIImage()
        case .defaultIcon:
            self.glyphImage = UIImage()
        }
        self.markerTintColor = markerTintColor
        self.glyphTintColor = glyphTintColor
        self.displayPriority = displayPriority
    }
    
    public init(title: String, subtitle: String, address: String, glyphImage: glyphImage) {
        self.title = title
        self.subtitle = subtitle
        self.address = address
        switch glyphImage {
        case .systemImage(let string):
            self.glyphImage = UIImage(systemName: string) ?? UIImage()
        case .assetImage(let string):
            self.glyphImage = UIImage(systemName: string) ?? UIImage()
        case .defaultIcon:
            self.glyphImage = UIImage()
        }
        self.markerTintColor = .systemRed
        self.glyphTintColor = .white
        self.displayPriority = .defaultLow
    }
}
/**
 Different types of glyphs, whether it be icons, or images. one variable for all the types.
 */
public enum glyphImage {
    case systemImage(String)
    case assetImage(String)
    case defaultIcon
}

public class SwiftUIMap {
    
    /// Get the default camera angle
    /// - Parameters:
    ///   - location: Center coordinates.
    ///   - zoom: How far zoomed the camera is.
    public static func defaultCameraAngle(location: CLLocationCoordinate2D, zoom: Double) -> MKMapCamera {
        MKMapCamera(lookingAtCenter: location, fromDistance: zoom*252555, pitch: 0, heading: 0)
    }
}
#endif
