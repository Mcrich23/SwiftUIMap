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

public struct Annotations: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let address: String
    public let glyphImage: String
    public let tintColor: UIColor
    public let markerTintColor: UIColor
    public let glyphTintColor: UIColor
    public let displayPriority: MKFeatureDisplayPriority
    
    public init(title: String, subtitle: String, address: String, glyphImage: String, tintColor: UIColor, markerTintColor: UIColor, glyphTintColor: UIColor, displayPriority: MKFeatureDisplayPriority) {
        self.title = title
        self.subtitle = subtitle
        self.address = address
        self.glyphImage = glyphImage
        self.tintColor = tintColor
        self.markerTintColor = markerTintColor
        self.glyphTintColor = glyphTintColor
        self.displayPriority = displayPriority
    }
    
}
#endif
