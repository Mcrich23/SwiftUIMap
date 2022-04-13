//
//  Mutable.swift
//  SwiftUIMap Example
//
//  Created by Morris Richman on 4/12/22.
//

import SwiftUI
import SwiftUIMap
import MapKit

struct Mutable: View {
    @State var search = false
    @State var zoom = 0.2
    @State var address = "Seattle, Wa"
    var body: some View {
        MutableAnnotationMap(zoom: $zoom, address: $address)
            .pointOfInterestCategories(exclude: [.airport])
            .showCompass(false)
            .showScale(false)
            .showTraffic(false)
            .showBuildings(true)
            .overlay(alignment: .topTrailing, content: {
                Button(action: {search = true}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                }
                .padding(2)
                .background(.white)
                .cornerRadius(10)
                .opacity(0.8)
                .padding()
            })
            .sheet(isPresented: $search) {
                MapSearchView { address in
                    zoom = 0.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650), execute: {
                        self.address = address
                    })
                }
            }
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct Mutable_Previews: PreviewProvider {
    static var previews: some View {
        Mutable()
    }
}
