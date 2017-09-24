/**
 
 Dijkstra's algorithm in Swift 3
 
 The idea is to create a more protocol oriented implementation.
 
 Note: It could use some optimizations, if you wish to use in production.
 
 From: https://gist.githubusercontent.com/marciok/6585da91a6967ad92f5b6ee2183c9552/raw/dc35047ff3da20cab2f887a03042c0780bac6828/dijkstra.swift
 
 */
import Foundation

protocol Vertex {
    var id: String { get }
    var edges: [Edge] { get set}
}

protocol Edge {
    var weight: Int { get set}
    var destination: Vertex { get set}
}

final class Path {
    let distance: Int
    let destination: Vertex
    var previousPath: Path?
    
    init(distance: Int, destination: Vertex, previousPath: Path?) {
        self.distance = distance
        self.destination = destination
        self.previousPath = previousPath
    }
}

protocol Graph {
    func add<V: Vertex, E: Edge>(edge: E, from source: inout V)
    
    // Returns the shortest Path from an origin to a destination
    func shortestPathDijkstra(from origin: Vertex, to destination: Vertex) -> Path?
    
    // Returns the shortest Paths from an orgin to all reachable Vertexes
    func shortestPathDijkstra(from origin: Vertex) -> [Path]
}

extension Graph {
    func add<V: Vertex, E: Edge>(edge: E, from source: inout V) {
        source.edges.append(edge)
    }
    
    func shortestPathDijkstra(from origin: Vertex, to destination: Vertex) -> Path? {
        return self.shortestPathDijkstra(from: origin).filter { $0.destination.id == destination.id }.first
    }
    
    func shortestPathDijkstra(from origin: Vertex) -> [Path] {
        var frontier = [Path]()
        var finalPath = [Path]()
        var bestPath: Path? = nil
        
        // 1. Create a Path for every `edge` on the `origin`
        for edge in origin.edges {
            let path = Path(
                distance: edge.weight,
                destination: edge.destination,
                previousPath: nil
            )
            // 2. Add the path to the `frontier`
            frontier.append(path)
        }
        
        // 3. Look into every Vertexes while there is a `frontier`
        while frontier.count > 0 {
            var bestPathIndex = 0
            
            for index in 0..<frontier.count {
                bestPath = nil
                let path = frontier[index]
                
                // 4. Find & store the `bestPath`
                if bestPath == nil || path.distance < bestPath!.distance  {
                    bestPath = path
                    bestPathIndex = index
                }
            }
            
            // 5. Add to the frontier each `destination.edges` inside `bestPath`
            for edge in bestPath!.destination.edges {
                let path = Path(
                    distance: edge.weight + bestPath!.distance,
                    destination: edge.destination,
                    previousPath: bestPath
                )
                frontier.append(path)
            }
            
            // 6. Add to the `finalPath` the `bestPath`,
            // if it's lower than Path to the same destination on `finalPath`
            let pathsToLocation = finalPath.filter { $0.destination.id == bestPath?.destination.id }
            if pathsToLocation.count == 0 {
                finalPath.append(bestPath!)
            } else {
                for path in pathsToLocation {
                    
                    //if bestPath?.distance < path.distance {
                    if (bestPath?.distance)! < path.distance {
                        finalPath.append(bestPath!)
                    }
                }
            }
            
            // 8. Remove `bestPath` from `frontier`
            frontier.remove(at: bestPathIndex)
        }
        
        return finalPath
    }
}
/*

struct Neighborhood: Graph { }

final class PointOfInterest: Vertex {
    let name: String
    
    var id: String
    var edges: [Edge]
    
    init(name: String) {
        self.name = name
        self.id = name
        self.edges = []
    }
}

struct Route: Edge {
    var weight: Int
    var destination: Vertex
    
    init(distance: Int, destination: PointOfInterest) {
        self.weight = distance
        self.destination = destination
    }
}

*/
