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
    
    static func size() -> Int {
        return sizeof(Float) * 4
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity] 
        return raw
    }
}
