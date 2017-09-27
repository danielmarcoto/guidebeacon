//
//  Beacon.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 18/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import Foundation

class Beacon : Node {
    
    let name : String
    
    private var _rssi : NSNumber
    
    init(name: String) {
        self.name = name
        _rssi = 0
        super.init()
    }
    
    var rssi : NSNumber {
        get {
            return _rssi
        }
        set {
            _rssi = newValue
        }
    }
    
    var beaconDistance : BeaconDistance {
        get {
            // Calculate the current distance
            // https://docs.google.com/spreadsheets/d/1PDEBNIB60DG1XX7VuAJOg5P3n28jLxiNWdxBW3_f2ms/edit#gid=0
            
            if(_rssi.intValue >= 0) {
                return BeaconDistance.unknown
            } else if(_rssi.intValue >= -60) { // 50cm
                return BeaconDistance.close
            } else if(_rssi.intValue >= -72) { // 50cm - 150cm
                return BeaconDistance.near
            } else if(_rssi.intValue >= -87) { // 150cm - 300cm
                return BeaconDistance.distant
            } else if(_rssi.intValue >= -89) { // 300cm - 400cm
                return BeaconDistance.longDistante
            }else {
                return BeaconDistance.unknown
            }
        }
    }    
}

enum BeaconDistance {
    case close
    case near
    case distant
    case longDistante
    case unknown
    
    func imageName() -> String{
        switch self {
        case .close:
            return "wifi-100-512x512.png"
        case .near:
            return "wifi-080-512x512.png"
        case .distant:
            return "wifi-060-512x512.png"
        case .longDistante:
            return "wifi-040-512x512.png"
        default:
            return "wifi-000-512x512.png"
        }
    }
}

