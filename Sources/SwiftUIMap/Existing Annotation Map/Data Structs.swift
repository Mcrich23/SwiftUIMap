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
    public let glyphImage: UIImage
//    public let tintColor: UIColor
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
        case .named(let string):
            self.glyphImage = UIImage(systemName: string) ?? UIImage()
        case .defaultIcon:
            self.glyphImage = UIImage()
        }
//        self.tintColor = tintColor
        self.markerTintColor = markerTintColor
        self.glyphTintColor = glyphTintColor
        self.displayPriority = displayPriority
    }
}
public enum glyphImage {
    case systemImage(String)
    case named(String)
    case defaultIcon
}
#endif
