//
//  MapAutoComplete.swift
//
//  Created by Morris Richman on 2/12/22.
//

import Foundation
import SwiftUI
import Combine
import MapKit

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var onCommit: (_ value: String) -> Void

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        var onCommit: (_ value: String) -> Void

        init(text: Binding<String>, onCommit: @escaping (_ value: String) -> Void) {
            _text = text
            self.onCommit = onCommit
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("resign keyboard")
            searchBar.resignFirstResponder()
            onCommit(searchBar.text ?? "")
        }
        
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, onCommit: onCommit)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = .search
        return searchBar
    }
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

public struct MapSearchView: View {
//    @ObservedObject var locationSearchService: LocationSearchService
    @StateObject private var mapSearch = MapSearch()
    @Environment(\.presentationMode) var presentationMode
    @State var onSelect: (_ address: String) -> Void = {address in }
    
    @State private var btnHover = false
    @State private var isBtnActive = false

    @State var address = "" {
        didSet {
            print("didSet address = \(address)")
            onSelect(address)
            presentationMode.wrappedValue.dismiss()
        }
    }
    @State var completion = MKLocalSearchCompletion()
    
    public init(onSelect: @escaping (_ address: String) -> Void) {
        self.onSelect = onSelect
    }

// Main UI

    public var body: some View {
            VStack {
                SearchBar(text: $mapSearch.searchTerm, onCommit: {text in })
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
                                    
                                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                                    address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName) \(reversedGeoLocation.city) \(reversedGeoLocation.state) \(reversedGeoLocation.zipCode) \(reversedGeoLocation.country)"
                                    print("in button address = \(address)")
                                }
                            }
                        }
                    } label: {
                        VStack {
                            Text(completion.title)
                                .foregroundColor(.primary)
                            Text(completion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onAppear {
                print("onSelect = \(String(describing: onSelect))")
            }
    }
}
class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        
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

struct ReversedGeoLocation {
    let streetNumber: String    // eg. 1
    let streetName: String      // eg. Infinite Loop
    let city: String            // eg. Cupertino
    let state: String           // eg. CA
    let zipCode: String         // eg. 95014
    let country: String         // eg. United States
    let isoCountryCode: String  // eg. US

    var formattedAddress: String {
        return """
        \(streetNumber) \(streetName),
        \(city), \(state) \(zipCode)
        \(country)
        """
    }

    // Handle optionals as needed
    init(with placemark: CLPlacemark) {
        self.streetName     = placemark.thoroughfare ?? ""
        self.streetNumber   = placemark.subThoroughfare ?? ""
        self.city           = placemark.locality ?? ""
        self.state          = placemark.administrativeArea ?? ""
        self.zipCode        = placemark.postalCode ?? ""
        self.country        = placemark.country ?? ""
        self.isoCountryCode = placemark.isoCountryCode ?? ""
    }
}
