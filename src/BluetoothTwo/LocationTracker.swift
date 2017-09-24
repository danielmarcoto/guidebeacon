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
    
    var closest : Beacon?
    
    var delegate : LocationTrackerEvents?
    
    init() {
        let environment = Environment()
        
        beacons = environment.beacons!
        
        closest = beacons.first!
    }
    
    var count : Int {
        get {
            return beacons.count
        }
    }
    
    func update(by beacon: Beacon) {
        
        for beaconFound in beacons {
            if beaconFound.name.isEqual(beacon.name) {
                // Update the new RSSI read
                beaconFound.rssi = beacon.rssi
                // Updates the closest beacon if greater than the current
                if(beaconFound.rssi.intValue > closest!.rssi.intValue) {
                    closest = beaconFound
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
}
