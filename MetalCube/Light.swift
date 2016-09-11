//
//  Light.swift
//  MetalCube
//
//  Created by Michał Garmulewicz on 10.09.2016.
//  Copyright © 2016 Klaudyna Marciniak. All rights reserved.
//

import Foundation

struct Light {
    
    var color: (Float, Float, Float)  
    var ambientIntensity: Float
    var direction: (Float, Float, Float)
    var diffuseIntensity: Float
    var shininess: Float
    var specularIntensity: Float
    
    static func size() -> Int {
        return sizeof(Float) * 12
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity, shininess, specularIntensity]
        return raw
    }
}
