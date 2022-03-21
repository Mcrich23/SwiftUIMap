//
//  ContentView.swift
//  SwiftUIMap Example
//
//  Created by Morris Richman on 3/20/22.
//

import SwiftUI
import SwiftUIMap
import MapKit

struct ContentView: View {
    var body: some View {
        MutableAnnotationMap(zoom: 0.4, address: "Seattle, Wa", pointsOfInterestFilter: .excludingAll) { Address, Cluster in
            print("tapped \(Address)")
        } deselected: {
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
