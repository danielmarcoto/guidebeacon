//
//  Destination.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 24/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import Foundation

struct Destination {
    let title : String
    var beacon : Beacon
    
    init(title : String, beacon: Beacon){
        self.title = title
        self.beacon  = beacon
    }
}
