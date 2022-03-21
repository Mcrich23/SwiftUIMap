//
//  ContentView.swift
//  SwiftUIMap Example
//
//  Created by Morris Richman on 3/20/22.
//

import SwiftUI
import SwiftUIMap

struct ContentView: View {
    var body: some View {
        ExistingAnnotationMap(zoom: 0.05, address: "Seattle, Wa", points: [Annotations], pointsOfInterestFilter: <#T##MKPointOfInterestFilter#>, selected: <#T##(Annotations, Bool) -> Void##(Annotations, Bool) -> Void##(_ Annotations: Annotations, _ Cluster: Bool) -> Void#>, deselected: <#T##() -> Void#>)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
