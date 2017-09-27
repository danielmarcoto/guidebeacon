// https://medium.com/swiftly-swift/dijkstras-algorithm-in-swift-15dce3ed0e22
// https://gist.githubusercontent.com/zntfdr/9b31bb2c38be1fea4d63ee4bc4f7bde3/raw/d441619a46f8af997a4df3ec10ee4804c042aeb1/DijkstraComplete.swift

class Node {
    var visited = false
    var connections: [Connection] = []
}

class Connection {
    public let to: Node
    public let weight: Int
    
    public init(to node: Node, weight: Int) {
        assert(weight >= 0, "weight has to be equal or greater than zero")
        self.to = node
        self.weight = weight
    }
}

class Path {
    public let cumulativeWeight: Int
    public let node: Node
    public let previousPath: Path?
    
    init(to node: Node, via connection: Connection? = nil, previousPath path: Path? = nil) {
        if
            let previousPath = path,
            let viaConnection = connection {
            self.cumulativeWeight = viaConnection.weight + previousPath.cumulativeWeight
        } else {
            self.cumulativeWeight = 0
        }
        
        self.node = node
        self.previousPath = path
    }
}

extension Path {
    var array: [Node] {
        var array: [Node] = [self.node]
        
        var iterativePath = self
        while let path = iterativePath.previousPath {
            array.append(path.node)
            
            iterativePath = path
        }
        
        return array
    }
}

