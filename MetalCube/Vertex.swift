//
//  Vertex.swift
//  MetalCube
//
//  Created by Michał Garmulewicz on 10.09.2016.
//  Copyright © 2016 Klaudyna Marciniak. All rights reserved.
//

import Foundation

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    var s,t: Float       // texture coordinates
    var nX,nY,nZ: Float  // normals
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,s,t,nX,nY,nZ]
    }
    
};
