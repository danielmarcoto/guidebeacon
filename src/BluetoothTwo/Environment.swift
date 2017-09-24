//
//  Environment.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 25/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import Foundation

struct Environment {
    
    let beacons : [Beacon]?
    
    let destinations : [Destination]?
    
    private let environment : Map
    
    private let map : Map
    
    init() {
        environment = Map()
        
        let beacon054 = Beacon(name: "BMBEACON_00054")
        var beacon162 = Beacon(name: "BMBEACON_00162")
        let beacon342 = Beacon(name: "BMBEACON_00342")
        let beacon373 = Beacon(name: "BMBEACON_00373")
        
        map = Map()
        
        map.add(edge: Route(distance: 8, destination: beacon054), from: &beacon162)
        map.add(edge: Route(distance: 5, destination: beacon342), from: &beacon162)
        map.add(edge: Route(distance: 5, destination: beacon373), from: &beacon162)
        
        // Beacons initialized
        beacons = [beacon054, beacon162, beacon342, beacon373]
        
        // Destinations
        destinations = [
            Destination(title: "A - beacon054", beacon: beacon054),
            Destination(title: "B - beacon162", beacon: beacon162),
            Destination(title: "C - beacon342", beacon: beacon342),
            Destination(title: "D - beacon373", beacon: beacon373)
        ]
    }
    
    func history(from origin: Vertex, path: Path) -> [Path] {
        var history = [Path]()
        history.append(path)
        
        var previousPath = path.previousPath
        while previousPath != nil {
            history.append(previousPath!)
            previousPath = previousPath!.previousPath
        }
        
        history.append(Path(distance: 0, destination: origin, previousPath: nil))
        
        return history.reversed()
    }
    
    func path(from origin: Beacon, to destination : Beacon) -> [Path] {
        
        
        let path = map.shortestPathDijkstra(from: origin, to: destination)
        if(path == nil) {
            return []
        }
        return history(from: origin, path: path!) 
    }
}
