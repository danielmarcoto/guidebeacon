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
                let origin = self.rootViewController?.beacons.closest
                
                print("Destination: \(destination.beacon.name) \(destination.beacon.connections.count)")
                print("origin: \(origin!.name) \(origin!.connections.count)")
                
                print("Dest isVisited: \(destination.beacon.visited)")
                print("Orig isVisited: \(origin!.visited)")
                
                if let path = self.rootViewController?.environment
                    .shortestPath(source: origin!, destination: destination.beacon) {
                    // Sum of the estimated distance
                    /*
                    let distance = path.reduce(0, { (result, item) -> Int in
                        return result + item.distance
                    })
                    */
                    tableViewCell.detailTextLabel?.text = "Distância estimada de \(path.cumulativeWeight)m"
                } else {
                    tableViewCell.detailTextLabel?.text = "Não foi possível calcular"
                }
                tableViewCell.textLabel?.text = destination.title
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
            self.rootViewController?.beaconDest = destination
            
            dismiss(animated: true, completion: nil)
        }
    }
    
}
