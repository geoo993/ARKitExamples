// Metal is a tripple buffer by default, you will be drawing things
// on one buffer and swap to another.

import UIKit
import MetalKit
import ARKit

protocol Renderable {
    var pipelineState: MTLRenderPipelineState! { get set }
    var samplerState: MTLSamplerState! { get set }
    var depthStencilState: MTLDepthStencilState! { get set }
    var vertexFunctionName: VertexFunction { get }
    var fragmentFunctionName: FragmentFunction { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
    var uniform: Uniform { get set }
    var drawType: MTLPrimitiveType { get set }
    func doRender(commandBuffer: MTLCommandBuffer,
                  commandEncoder: MTLRenderCommandEncoder,
                  modelMatrix: matrix_float4x4,
                  camera: Camera,
                  currentFrame: ARFrame)
}

extension Renderable {

    func buildPipelineState(device: MTLDevice,
                            renderDestination: RenderDestinationProvider) -> MTLRenderPipelineState {

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
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        pipelineDescriptor.sampleCount = renderDestination.sampleCount
        pipelineDescriptor.depthAttachmentPixelFormat = renderDestination.depthStencilPixelFormat // .depth32Float
        pipelineDescriptor.stencilAttachmentPixelFormat = renderDestination.depthStencilPixelFormat
        pipelineDescriptor.colorAttachments[0].pixelFormat = renderDestination.colorPixelFormat //.bgra8Unorm // unorm means that the value falls between 0 and 255
        
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            fatalError("Failed to create pipeline state, error \(error.localizedDescription)")
        }

        return pipelineState
    }

    // MARK: - Setup sampler state
    func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.normalizedCoordinates = true
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: descriptor)!
    }

    func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        // in order to move to 3D we need a depth buffer.
        // rendering triangles that are facing us still does not take into account Depth.
        // we have to tell the GPU how to measure Depth and we do this using a depth stencil state.
        // the word Stencil in graphics language means, which fragments are drawn or not drawn.
        // you can create stencil buffer to mask out areas of your rendered image.
        // The depth stencil masks out fragments that are behind other fragments.
        // during rendering the rasterizer creates fragments for the blue squares, and for the yellow square.
        // each fragment can be depth tested with another fragment in the same position.
        
        //We create the depth stencil state using a descriptor.
        let depthStencilDescriptor = MTLDepthStencilDescriptor()

        //When the depth compared function is set to less, any fragment further away are discarded.
        // The depthCompareFunction is used to determine whether a fragment passes the so-called depth test.
        // In our case, we want to keep the fragment that is closest to the camera for each pixel, so we use a
        // compare function of .less, which replaces the depth value in the depth buffer whenever
        // a fragment closer to the camera is processed.
        depthStencilDescriptor.depthCompareFunction = .less

        // we record the depth value for testing against other fragments when isDepthWriteEnabled is enabled.
        // We also set isDepthWriteEnabled to true, so that the depth values of passing fragments are actually
        // written to the depth buffer. Without this flag set, no writes to the depth buffer would occur,
        // and it would essentially be useless. There are circumstances in which we want to prevent depth
        // buffer writes (such as particle rendering), but for opaque geometry, we almost always want it enabled.
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!


    }

}
