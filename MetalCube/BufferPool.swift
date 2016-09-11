//
//  BufferPool.swift
//  MetalCube
//
//  Created by Michał Garmulewicz on 10.09.2016.
//  Copyright © 2016 Klaudyna Marciniak. All rights reserved.
//

import UIKit
import Metal

class BufferPool: NSObject {
    
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0
    var avaliableResourcesSemaphore:dispatch_semaphore_t

    
    init(device:MTLDevice, inflightBuffersCount: Int) {
        let sizeOfUniformsBuffer = sizeof(Float) * (2 * Matrix4.numberOfElements()) + Light.size()
        avaliableResourcesSemaphore = dispatch_semaphore_create(inflightBuffersCount)
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer = device.newBufferWithLength(sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer)
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4, light: Light) -> MTLBuffer {
        
        let buffer = uniformsBuffers[avaliableBufferIndex]
        
        let bufferPointer = buffer.contents()
        
        memcpy(bufferPointer, modelViewMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
        memcpy(bufferPointer + sizeof(Float)*Matrix4.numberOfElements(), projectionMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
        memcpy(bufferPointer + 2*sizeof(Float)*Matrix4.numberOfElements(), light.raw(), Light.size())
        
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
            avaliableBufferIndex = 0
        }
        
        return buffer
    }
    
    deinit{
        for _ in 0...self.inflightBuffersCount{
            dispatch_semaphore_signal(self.avaliableResourcesSemaphore)
        }
    }

}

