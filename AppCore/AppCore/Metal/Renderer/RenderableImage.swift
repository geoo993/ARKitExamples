//
//  RenderableImage.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 13/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Metal
import MetalKit
import ARKit

protocol RenderableImage {
    var imagePlaneVertexBuffer: MTLBuffer! { get set }
    var imagePlaneVertexData: [Float] { get }
    var imageTextureY: CVMetalTexture? { get set }
    var imageTextureCbCr: CVMetalTexture? { get set }
    var imageTextureCache: CVMetalTextureCache! { get set }
}

extension RenderableImage {

    var imageVertexDescriptor: MTLVertexDescriptor {
        // Create a vertex descriptor for our image plane vertex buffer
        let imagePlaneVertexDescriptor = MTLVertexDescriptor()

        // Positions.
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.position.rawValue].format = .float2
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.position.rawValue].offset = 0
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshVertices.rawValue

        // Texture coordinates.
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.texcoord.rawValue].format = .float2
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.texcoord.rawValue].offset = MemoryLayout<Float>.stride * 2 // float2  = 8 in buffer size
        imagePlaneVertexDescriptor.attributes[ImageVertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshVertices.rawValue

        // Buffer Layout
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshVertices.rawValue].stride = MemoryLayout<Float>.stride * 4 //float2*2  = 16 in buffer size
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshVertices.rawValue].stepRate = 1
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshVertices.rawValue].stepFunction = .perVertex

        return imagePlaneVertexDescriptor
    }

    // MARK: - Setup Image Cache
    func buildImageTextureCache(device: MTLDevice) -> CVMetalTextureCache {
        // Create captured image texture cache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        return textureCache!
    }

    // MARK: - Setup stencil state
    func buildImageDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let capturedImageDepthStateDescriptor = MTLDepthStencilDescriptor()
        capturedImageDepthStateDescriptor.depthCompareFunction = .always
        capturedImageDepthStateDescriptor.isDepthWriteEnabled = false
        return device.makeDepthStencilState(descriptor: capturedImageDepthStateDescriptor)!
    }

    // MARK: - Setup pipeline state
    func buildImagePipelineState(device: MTLDevice,
                                 renderDestination: RenderDestinationProvider,
                                 vertexFunctionName: VertexFunction,
                                 fragmentFunctionName: FragmentFunction) -> MTLRenderPipelineState {
        let appCoreBundle = Bundle(identifier: "com.geo-games.AppCore")!
        //1) all our shader functions will be stored in a library
        // so we setup a new library and set the vertex and fragment shader created
        guard let library = try? device.makeDefaultLibrary(bundle: appCoreBundle)
            else { fatalError("could not create default library")}

        //2) xcode will compile these function when we compile the project,
        // we load all the shader files with a metal file extension in the project
        let vertexFunction = library.makeFunction(name: vertexFunctionName.rawValue)
        let fragmentFunction = library.makeFunction(name: fragmentFunctionName.rawValue)

        //3) create pipeline descriptor
        // the descriptor contains the reference to the shader functions and
        // we could create the pipeline state from the descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.vertexDescriptor = imageVertexDescriptor
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        pipelineDescriptor.sampleCount = renderDestination.sampleCount
        pipelineDescriptor.depthAttachmentPixelFormat = renderDestination.depthStencilPixelFormat // .depth32Float
        pipelineDescriptor.stencilAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        pipelineDescriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat //.bgra8Unorm // unorm means that the value falls between 0 and 255

        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            fatalError("Failed to create pipeline state, error \(error.localizedDescription)")
        }
        return pipelineState
    }

    func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, imageTextureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)

        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }

}
