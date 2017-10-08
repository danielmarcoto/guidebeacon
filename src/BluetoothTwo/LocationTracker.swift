//
//  LocationTracker.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 24/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import Foundation

class LocationTracker {
    
    private var beacons : [Beacon]
    
    private let environment = Environment()
    
    private var pathToDestination : Path?
    
    init() {
        beacons = environment.beacons!
        
        closest = beacons.first!
    }
    
    var closest : Beacon? {
        didSet {
            // If there is path to destination
            if let path = pathToDestination {
                let list = environment.history(from: path)
                
                if let oldClosest = oldValue {
                    
                    var indexOld = 0
                    var indexNew = 0
                    
                    for (index, value) in (list?.enumerated())! {
                        if(value.name == oldClosest.name) {
                            indexOld = index
                        }
                        if(value.name == closest!.name){
                            indexNew = index
                        }
                    }
                    
                    let distance = list?.distance(from: indexOld, to: indexNew)
                    if(distance! < 0) {
                        delegate?.didGoWrongDirection()
                    }
                    if(distance! == 1) {
                        delegate?.didPassedOnCheckpoint()
                    }
                }
            }
        }
    }
    
    var delegate : LocationTrackerEvents?
    
    var locationScore = [String:Int]()
    
    var destination : Beacon?
    
    var count : Int {
        get {
            return beacons.count
        }
    }
    
    var hasPath : Bool {
        get {
            return self.pathToDestination != nil
        }
    }
    
    func startRouterTo(beacon destination: Beacon){
        self.destination = destination
        
        // Gets the origin and the destination
        if let origin = closest {
            print("SOURCE: \(origin.name)")
            print("DESTINATION: \(destination.name)")
            
            let source = environment.beacons!.first(where: { (beacon) -> Bool in
                origin.name == beacon.name
            })
            
            let dest = environment.beacons!.first(where: { (beacon) -> Bool in
                destination.name == beacon.name
            })
            
            if let path = environment.shortestPath(source: source!, destination: dest!) {
                self.pathToDestination = path
                
                print("Rota:")
                for beacon in (environment.history(from: path))! {
                    print("\(beacon.name)")
                }
                print("distância: \(path.cumulativeWeight)")
                
            }
        }
    }
    
    func stopRouter() {
        self.pathToDestination = nil
        self.destination = nil
        self.locationScore.removeAll()
    }
    
    func update(by beacon: Beacon) {
        
        for beaconFound in beacons {
            if beaconFound.name.isEqual(beacon.name) {
                // Update the new RSSI read
                beaconFound.rssi = beacon.rssi
                
                //let score = locationScore[beaconFound.name]
                //locationScore[beaconFound.name] = score! + beacon.distanceNumber
                
                // Updates the closest beacon if greater than the current
                if(beaconFound.rssi.intValue > closest!.rssi.intValue) {
                    closest = beaconFound
                }
            }
        }
        
        // Check if the destination was targeted
        if let closestLocal = closest {
            if let dest = destination {
                if (closestLocal.name == dest.name) {
                    delegate?.didGotToDestination()
                    stopRouter()
                }
            }
        }
        
        delegate?.didUpdate(self)
    }
    
    func getBeaconsSortedByDistance() -> Array<Beacon> {
        return beacons.sorted(by: { (beacon1, beacon2) -> Bool in
            // All the RSSI values are negative
            return beacon1.rssi.intValue > beacon2.rssi.intValue
        })
    }
    
}

protocol LocationTrackerEvents {
    func didUpdate(_ locationTracker: LocationTracker) -> Void
    //func didChangeClosest( _locationTracker: LocationTracker) -> Beacon
    
    func didGoWrongDirection() -> Void
    func didPassedOnCheckpoint() -> Void
    func didGotToDestination() -> Void
    
}
