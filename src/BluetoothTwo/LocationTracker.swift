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
    
    var isBluetoothActive = false
    
    var timer : Timer?
    
    init() {
        beacons = environment.beacons!
        
        closest = beacons.first!
        
        restartLocationScore()
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
                        if let localClosest = closest {
                            if(value.name == localClosest.name){
                                indexNew = index
                            }
                        }
                    }
                    
                    let distance = list?.distance(from: indexOld, to: indexNew)
                    if(distance! < 0) {
                        delegate?.didGoWrongDirection()
                    }
                    if(distance! == 1) {
                        delegate?.didPassedOnCheckpoint()
                    }
                    
                    // Restart the table of score
                    // restartLocationScore()
                }
            }
        }
    }
    
    var delegate : LocationTrackerEvents?
    
    var locationScore = [String:Int]()
    
    var destination : Beacon?
    
    var count : Int {
        get {
            return hasPath ? getBeaconsSortedByDestination().count : getBeaconsSortedByDistance().count
        }
    }
    
    var hasPath : Bool {
        get {
            return self.pathToDestination != nil
        }
    }
    
    private func restartLocationScore(){
        for key in self.beacons.map({ (beacon) -> String in
            return beacon.name
        }) {
            self.locationScore[key] = 0
        }
    }
    
    func startRouterTo(beacon destination: Beacon){
        self.destination = destination
        
        // Gets the origin and the destination
        if let origin = closest {
            print("SOURCE: \(origin.name)")
            print("DESTINATION: \(destination.name)")
            
            let tempEnv = Environment()
            
            let source = tempEnv.beacons!.first(where: { (beacon) -> Bool in
                origin.name == beacon.name
            })
            
            let dest = tempEnv.beacons!.first(where: { (beacon) -> Bool in
                destination.name == beacon.name
            })
            
            if let path = tempEnv.shortestPath(source: source!, destination: dest!) {
                self.pathToDestination = path
                
                print("Rota:")
                for beacon in (tempEnv.history(from: path))! {
                    print("\(beacon.name)")
                }
                print("distância: \(path.cumulativeWeight)")
                
            }
            
            delegate?.didStartedRouter()
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
                // Updates the closest beacon if greater than the current
                //if(beaconFound.rssi.intValue > closest!.rssi.intValue) {
                    //closest = beaconFound
                //}
            }
        }
 
        // Score according the distance of each beacon
        if let score = self.locationScore[beacon.name] {
            self.locationScore[beacon.name] = score + beacon.distanceNumber
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
    
    func stopTracking() {
        self.isBluetoothActive = false
    }
    
    func startTracking(){
        self.isBluetoothActive = true
        
        // Restart the timer
        if let localTimer = self.timer {
            if (localTimer.isValid) {
                localTimer.invalidate()
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (localTimer) in
            
            localTimer.tolerance = 1
            
            // Show the table -------
            for (index, item) in self.locationScore.enumerated() {
                print("\(index) - \(item.key): \(item.value)")
            }
            // ----------------------
            
            var greater : (key : String, value : Int) = ("", 0)
            for (_, item) in self.locationScore.enumerated() {
                if (item.value > greater.value) {
                    greater = item
                }
            }
            
            // Update the closest
            if(!greater.key.isEmpty) {
                self.closest = self.beacons.filter({ (beacon) -> Bool in
                    return beacon.name == greater.key
                }).first
            }
            
            if (!self.isBluetoothActive) {
                localTimer.invalidate()
            }
            
            // Test for restarting
            self.restartLocationScore()
            
            print("Tracking: \(greater.key)")
            print("Closest: \(String(describing: self.closest?.name))")
        }
    }
    
    func getBeaconsSortedByDestination() -> Array<Beacon> {
        if let path = self.pathToDestination {
            var beacons = [Beacon]()
            
            for beaconHist in environment.history(from: path)! {
                for beacon in environment.beacons! {
                    if(beaconHist.name == beacon.name) {
                        beacons.append(beacon)
                    }
                }
            }
            return beacons
        }
        return getBeaconsSortedByDistance()
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
    
    func didStartedRouter() -> Void
    func didGoWrongDirection() -> Void
    func didPassedOnCheckpoint() -> Void
    func didGotToDestination() -> Void
    
}
