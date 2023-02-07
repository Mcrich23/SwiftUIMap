//
//  MapAutoComplete.swift
//
//  Created by Morris Richman on 2/12/22.
//

import Foundation
import SwiftUI
import Combine
import MapKit

/**
 "Search for a location and then pass that back with a dismissal of the search view"
 
 - parameter onSelect: On address selected.
 - returns: An address
 
 # Example #
 ```
 MapSearchView { address in //Address passed back
     zoom = 0.2 // Zooms out
     DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650), execute: { // Wait to go to the new place
         self.address = address // Change central address
     })
 }
 ```
 
 */
public struct MapSearchView: View {
    @StateObject private var mapSearch: MapSearch
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (_ title: String, _ address: String, _ placemark: CLPlacemark) -> Void
    
    @State private var btnHover = false
    @State private var isBtnActive = false
    @State var completion = MKLocalSearchCompletion()
    
    public init(resultTypes: MKLocalSearchCompleter.ResultType, onSelect: @escaping (_ title: String, _ address: String) -> Void) {
        self.onSelect = { title, address, _ in
            onSelect(title, address)
        }
        self._mapSearch = StateObject(wrappedValue: MapSearch(resultTypes: resultTypes))
    }
    public init(resultTypes: MKLocalSearchCompleter.ResultType, onSelectAdvanced: @escaping (_ title: String, _ placemark: CLPlacemark) -> Void) {
        self.onSelect = { title, _, placemark in
            onSelectAdvanced(title, placemark)
        }
        self._mapSearch = StateObject(wrappedValue: MapSearch(resultTypes: resultTypes))
    }
//    public init(address: Binding<String>) {
//        self._address = address
//    }

// Main UI

    public var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            VStack {
                SearchBar(text: $mapSearch.searchTerm, onCommit: {text in })
                if self.mapSearch.locationResults.isEmpty {
                    Spacer()
                } else {
                    List(mapSearch.locationResults, id: \.self) { completion in
                        // Show auto-complete results
                        Button {
                            let searchRequest = MKLocalSearch.Request(completion: completion)
                            let search = MKLocalSearch(request: searchRequest)
                            var coordinateK : CLLocationCoordinate2D?
                            search.start { (response, error) in
                                if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                                    coordinateK = coordinate
                                }
                                
                                if let c = coordinateK {
                                    let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                                    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                                        
                                        guard let placemark = placemarks?.first else {
                                            let errorString = error?.localizedDescription ?? "Unexpected Error"
                                            print("Unable to reverse geocode the given location. Error: \(errorString)")
                                            return
                                        }
                                        
                                        let reversedGeoLocation = ReversedGeoLocation(with: placemark).formattedAddress
                                        self.onSelect(completion.title, reversedGeoLocation, placemark)
                                    }
                                }
                            }
                        } label: {
                            VStack {
                                HStack {
                                    Text(completion.title)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                HStack {
                                    Text(completion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
//            .onDisappear(perform: {
//                onSelect(address)
//            })
    }
}
class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?

    init(resultTypes: MKLocalSearchCompleter.ResultType) {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = resultTypes
        
        $searchTerm
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                self.locationResults = results//.filter { $0.subtitle.contains("United States") } // This parses the subtitle to show only results that have United States as the country. You could change this text to be Germany or Brazil and only show results from those countries.
            })
            .store(in: &cancellables)
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            currentPromise?(.success(completer.results))
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        //currentPromise?(.failure(error))
    }
}
