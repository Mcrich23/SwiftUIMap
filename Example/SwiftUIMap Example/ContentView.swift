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
        NavigationView {
            List {
                NavigationLink {
                    Existing()
                } label: {
                    Text("ExistingAnnotationMap")
                }
                .padding()
                NavigationLink {
                    Mutable()
                } label: {
                    Text("MutableAnnotationMap")
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
