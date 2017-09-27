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
    
    init() {
        
        let beacon054 = Beacon(name: "BMBEACON_00054")
        let beacon102 = Beacon(name: "BMBEACON_00102")
        let beacon162 = Beacon(name: "BMBEACON_00162")
        let beacon342 = Beacon(name: "BMBEACON_00342")
        let beacon373 = Beacon(name: "BMBEACON_00373")
        
        // Defining the environment
        beacon054.connections.append(Connection(to: beacon162, weight: 9))
        beacon162.connections.append(Connection(to: beacon342, weight: 5))
        beacon162.connections.append(Connection(to: beacon373, weight: 8))
        beacon342.connections.append(Connection(to: beacon102, weight: 9))
        
        beacon162.connections.append(Connection(to: beacon054, weight: 9))
        beacon342.connections.append(Connection(to: beacon162, weight: 5))
        beacon373.connections.append(Connection(to: beacon162, weight: 8))
        beacon102.connections.append(Connection(to: beacon342, weight: 9))
 
        // Beacons initialized
        beacons = [beacon054, beacon102, beacon162, beacon342, beacon373]
        
        // Destinations
        destinations = [
            Destination(title: "A - beacon054", beacon: beacon054),
            Destination(title: "B - beacon162", beacon: beacon162),
            Destination(title: "C - beacon342", beacon: beacon342),
            Destination(title: "D - beacon373", beacon: beacon373),
            Destination(title: "E - beacon102", beacon: beacon102)
        ]
    }
    
    func history(from path: Path) -> [Beacon]? {
        return path.array.reversed().flatMap({ $0 as? Beacon}).map({$0})
    }
    
    func shortestPath(source: Node, destination: Node) -> Path? {
        var frontier: [Path] = [] {
            didSet { frontier.sort { return $0.cumulativeWeight < $1.cumulativeWeight } } // the frontier has to be always ordered
        }
        
        frontier.append(Path(to: source)) // the frontier is made by a path that starts nowhere and ends in the source
        
        while !frontier.isEmpty {
            let cheapestPathInFrontier = frontier.removeFirst() // getting the cheapest path available
            guard !cheapestPathInFrontier.node.visited else { continue } // making sure we haven't visited the node already
            print("cumulativeWeight:\(cheapestPathInFrontier.cumulativeWeight)")
            if cheapestPathInFrontier.node === destination {
                return cheapestPathInFrontier // found the cheapest path 😎
            }
            
            cheapestPathInFrontier.node.visited = true
            
            for connection in cheapestPathInFrontier.node.connections where !connection.to.visited { // adding new paths to our frontier
                frontier.append(Path(to: connection.to, via: connection, previousPath: cheapestPathInFrontier))
            }
        } // end while
        print("we didn't find a path 😣")
        return nil // we didn't find a path 😣
    }
}
