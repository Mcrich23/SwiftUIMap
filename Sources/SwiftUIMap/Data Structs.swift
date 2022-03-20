//
//  Data Structs.swift
//  
//
//  Created by Morris Richman on 3/20/22.
//

import Foundation
import SwiftUI
import MapKit

struct Annotations: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let address: String
    let tintColor: Color
    let markerTintColor: Color
    let glyphTintColor: Color
    let glyphImage: String
    let displayPriority: MKFeatureDisplayPriority
}
