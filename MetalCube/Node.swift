//
//  Node.swift
//  MetalCube
//
//  Created by Michał Garmulewicz on 10.09.2016.
//  Copyright © 2016 Klaudyna Marciniak. All rights reserved.
//

import Foundation

import Metal
import QuartzCore

class Node {
    
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var uniformBuffer: MTLBuffer?
    var bufferPool: BufferPool
    var device: MTLDevice
    
    var texture: MTLTexture
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(self.device)
    let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (1.0, 1.0, 1.0), diffuseIntensity: 0.8, shininess: 2, specularIntensity: 1)
    
    var positionX:Float = 0.0
    var positionY:Float = 0.0
    var positionZ:Float = 0.0
    
    var rotationX:Float = 0.0
    var rotationY:Float = 0.0
    var rotationZ:Float = 0.0
    var scale:Float     = 1.0
    
    var time:CFTimeInterval = 0.0
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture) {
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: [])
        
        self.name = name
        self.device = device
        self.vertexCount = vertices.count
        self.texture = texture
        self.bufferPool = BufferPool(device: device, inflightBuffersCount: 3)
    }
    
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?){
        dispatch_semaphore_wait(bufferPool.avaliableResourcesSemaphore, DISPATCH_TIME_FOREVER)

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            dispatch_semaphore_signal(self.bufferPool.avaliableResourcesSemaphore)
        }
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setCullMode(MTLCullMode.Front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        if let samplerState = samplerState{
            renderEncoder.setFragmentSamplerState(samplerState, atIndex: 0)
        }
        
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        uniformBuffer = bufferPool.nextUniformsBuffer(projectionMatrix, modelViewMatrix: nodeModelMatrix, light: light)
        renderEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, atIndex: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, atIndex: 1)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
    
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState
    {
        let pSamplerDescriptor:MTLSamplerDescriptor? = MTLSamplerDescriptor();
        
        if let sampler = pSamplerDescriptor
        {
            sampler.minFilter             = MTLSamplerMinMagFilter.Nearest
            sampler.magFilter             = MTLSamplerMinMagFilter.Nearest
            sampler.mipFilter             = MTLSamplerMipFilter.Nearest
            sampler.maxAnisotropy         = 1
            sampler.sAddressMode          = MTLSamplerAddressMode.ClampToEdge
            sampler.tAddressMode          = MTLSamplerAddressMode.ClampToEdge
            sampler.rAddressMode          = MTLSamplerAddressMode.ClampToEdge
            sampler.normalizedCoordinates = true
            sampler.lodMinClamp           = 0
            sampler.lodMaxClamp           = FLT_MAX
        }
        else
        {
            print(">> ERROR: Failed creating a sampler descriptor!")
        }
        return device.newSamplerStateWithDescriptor(pSamplerDescriptor!)
    }
}
