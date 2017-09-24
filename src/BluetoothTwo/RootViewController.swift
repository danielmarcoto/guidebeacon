//
//  ViewController.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 13/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import CoreBluetooth
import UIKit

class RootViewController: UITableViewController, CBCentralManagerDelegate, LocationTrackerEvents {
    
    var manager : CBCentralManager?
    
    var beaconDest : Destination?
    
    var environment = Environment()
    
    var beacons : LocationTracker = LocationTracker()
    
    var isBluetoothAvailable : Bool = false
    
    var updatesPropagation : [() -> Void] = []
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelCurrentRoute(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "Questão",
            message: "Deseja interromper a rota atual?",
            preferredStyle: UIAlertControllerStyle.alert)
        // Confirmation of Canceling
        let confirm = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (uiAlert) -> Void in
            self.navigationItem.leftBarButtonItem = nil
            self.beaconDest = nil
            self.tableView.reloadData()
        })
        alert.addAction(confirm)
        
        let cancel = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        if (self.beaconDest == nil) {
            self.navigationItem.leftBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem = self.cancelButton
        }
        
        self.beacons.delegate = self
    }
    
    override func viewDidLoad() {
        if let bluetoothManager = manager {
            isBluetoothAvailable = bluetoothManager.state == CBManagerState.poweredOn
        }
        
        startScanIfAvailable()
    }
    
    func startScanIfAvailable() {
        if let bluetoothManager = manager {
            if(!isBluetoothAvailable) {
                alertIfNoBluetooth()
                if(bluetoothManager.isScanning){
                    bluetoothManager.stopScan()
                }
            } else {
                bluetoothManager.scanForPeripherals(
                    withServices: nil,
                    options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)]);
            }
            print("Scanning: \(bluetoothManager.isScanning)")
        }
    }
    
    func alertIfNoBluetooth() {
        let alert = UIAlertController(
            title: "Alerta",
            message: "Ative o bluetooth para continuar o uso",
            preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    // LocationTrackerEvents
    func didUpdate(_ locationTracker: LocationTracker) {
        //print("didUpdate : \(updatesPropagation.count)")
        for update in updatesPropagation {
            update()
        }
    }
    
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Initial state of availability
        isBluetoothAvailable = manager!.state == CBManagerState.poweredOn
        
        startScanIfAvailable()
    }
    
    // CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let beacon = Beacon(name: peripheral.name ?? "Unmamed")
        beacon.rssi = RSSI
        
        beacons.update(by: beacon)
        
        tableView.reloadData()
    }
    
    // UITableViewController
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let beacon = beacons.getBeaconsSortedByDistance()[indexPath.item]
        
        let identifier = beacon.rssi != 0 ? "tableViewItem" : "tableViewUnupdated"
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        tableViewCell.textLabel?.text = beacon.name
        tableViewCell.detailTextLabel?.text = "RSSI: \(beacon.rssi.intValue)"
        tableViewCell.imageView?.image =
            UIImage(named: beacon.beaconDistance.imageName())
                
        return tableViewCell
    }
    
    // UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentDest = self.beaconDest {
            return "Destino: \(currentDest.title)"
        }else {
            return "Destino não selecionado"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is RouteViewControler) {
            
            let routeViewController = segue.destination as! RouteViewControler
            
            routeViewController.rootViewController = self
        }
    }
}

