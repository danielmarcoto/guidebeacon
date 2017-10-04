//
//  RouteViewController.swift
//  BluetoothTwo
//
//  Created by Daniel Marcoto on 13/06/17.
//  Copyright © 2017 Daniel Marcoto. All rights reserved.
//

import UIKit

class RouteViewControler : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var rootViewController : RootViewController?;
    
    var destinations : [Destination]?
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: {
            print("Fechando...")
        })
        
        rootViewController?.updatesPropagation.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Sets the destinations available
        destinations = self.rootViewController?.environment.destinations
    }
    
    override func viewDidLoad() {
        if let destination = self.rootViewController?.beaconDest {
            print("Destino atual: \(destination.beacon.name)")
        }
        
        rootViewController?.updatesPropagation.append {
            self.tableView.reloadData()
            //print("route, current closest: \(String(describing: self.rootViewController?.beacons.closest?.name))")
        }
    }
    
    // UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewDestination")!
        
        // The list of destinations
        if (indexPath.section == 1) {            
            if let destination = destinations?[indexPath.item] {
                //let origin = self.rootViewController?.beacons.closest
                
                /*
                if let path = self.rootViewController?.environment
                    .shortestPath(source: beaconOrig, destination: beaconDest) {
                    
                    tableViewCell.detailTextLabel?.text = "Distância estimada de \(path.cumulativeWeight)m"
                } */
                tableViewCell.textLabel?.text = destination.title
                tableViewCell.detailTextLabel?.text = ""
            }
            return tableViewCell
        } else {
            if let beacon = rootViewController?.beacons.closest {
                tableViewCell.textLabel?.text = beacon.name
                tableViewCell.detailTextLabel?.text = "RSSI: \(beacon.rssi.intValue)"
                tableViewCell.imageView?.image =
                    UIImage(named: beacon.beaconDistance.imageName())
            }
            return tableViewCell
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If the list of destinations
        if( section == 1) {
            return destinations?.count ?? 0
        } else {
            return 1
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Destinos"
        } else {
            return "Mais Próximo atualmente"
        }
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            return
        }
        
        if let destination = destinations?[indexPath.item] {
            // Gets the origin and the destination
            self.rootViewController?.beaconDest = destination
            let origin = self.rootViewController?.beacons.closest
            
            //destination.beacon.visited = false
            //origin?.visited = false
            print("SOURCE: \(origin!.name)")
            print("DESTINATION: \(destination.beacon.name)")
            
            // Restart visited property
            let environment = Environment()
            
            let source = environment.beacons!.first(where: { (beacon) -> Bool in
                origin!.name == beacon.name
            })
            
            let dest = environment.beacons!.first(where: { (beacon) -> Bool in
                destination.beacon.name == beacon.name
            })
            
            if let path = environment.shortestPath(source: source!, destination: dest!) {
                print("Rota:")
                for beacon in (environment.history(from: path))! {
                    print("\(beacon.name)")
                }
                print("distância: \(path.cumulativeWeight)")
                
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
}
