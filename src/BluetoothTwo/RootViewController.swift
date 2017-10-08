//
//  ViewController.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 13/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import CoreBluetooth
import UIKit
import AVFoundation

class RootViewController: UITableViewController, CBCentralManagerDelegate, LocationTrackerEvents {
    
    let synth = AVSpeechSynthesizer()
    
    var manager : CBCentralManager?
    
    var beaconDest : Destination? {
        didSet {
            if (beaconDest != nil) {
                print("StartRouterTo: \(String(describing: beaconDest?.beacon.name))")
                self.locationTracker.startRouterTo(beacon: (beaconDest?.beacon)!)
                self.tableView.reloadData()
            }
        }
    }
    
    var environment = Environment()
    
    var locationTracker : LocationTracker = LocationTracker()
    
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
            self.locationTracker.stopRouter()
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
        
        self.locationTracker.delegate = self
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
                self.locationTracker.stopTracking()
            } else {
                if(!bluetoothManager.isScanning){
                    bluetoothManager.scanForPeripherals(
                        withServices: nil,
                        options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)]);
                    self.locationTracker.startTracking()
                }
            }
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
    
    // LocationTrackerEvents
    func didStartedRouter() {
        print("didStartedRouter")
        
        let utterance = AVSpeechUtterance.init(string: "Rota iniciada, siga em frente")
        
        self.synth.speak(utterance)
    }
    
    // LocationTrackerEvents
    func didGoWrongDirection() {
        print("didGoWrongDirection")
        
        let utterance = AVSpeechUtterance.init(string: "Você está na direção errada")
        
        self.synth.speak(utterance)
    }
    
    // LocationTrackerEvents
    func didPassedOnCheckpoint() {
        print("didPassedOnCheckpoint")
        
        let utterance = AVSpeechUtterance.init(string: "Você está no caminho")
        
        self.synth.speak(utterance)
    }
    
    // LocationTrackerEvents
    func didGotToDestination() {
        print("didGotToDestination")
        
        let utterance = AVSpeechUtterance.init(string: "Chegou ao destino")
        
        self.synth.speak(utterance)
        
        self.navigationItem.leftBarButtonItem = nil
        self.beaconDest = nil
        self.tableView.reloadData()
        
        let alert = UIAlertController(
            title: "Sucesso",
            message: "Você chegou ao seu destino",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true)
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
        
        locationTracker.update(by: beacon)
        
        tableView.reloadData()
    }
    
    // UITableViewController
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let beacons = self.locationTracker.hasPath ?
            self.locationTracker.getBeaconsSortedByDestination() :
            self.locationTracker.getBeaconsSortedByDistance()
        
        let beacon = beacons[indexPath.item]
        
        var identifier = beacon.rssi != 0 ? "tableViewItem" : "tableViewUnupdated"
        
        // Changes if is the closest
        if let closest = self.locationTracker.closest {
            if (closest.name == beacon.name) {
                identifier = "tableViewClosest"
            }
        }
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        tableViewCell.textLabel?.text = beacon.name
        tableViewCell.detailTextLabel?.text = "RSSI: \(beacon.rssi.intValue)"
        tableViewCell.imageView?.image =
            UIImage(named: beacon.beaconDistance.imageName())
                
        return tableViewCell
    }
    
    // UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationTracker.count
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

