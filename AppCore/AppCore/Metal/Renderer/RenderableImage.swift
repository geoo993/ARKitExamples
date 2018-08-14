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
    var imageVertexDescriptor: MTLVertexDescriptor { get }
}

extension RenderableImage {

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
                                 descriptor: MTLVertexDescriptor,
                                 vertexFunctionName: VertexFunction,
                                 fragmentFunctionName: FragmentFunction) -> MTLRenderPipelineState {
        //1) all our shader functions will be stored in a library
        // so we setup a new library and set the vertex and fragment shader created
        guard let library = try? device.makeDefaultLibrary(bundle: renderDestination.bundle)
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
        pipelineDescriptor.vertexDescriptor = descriptor
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
