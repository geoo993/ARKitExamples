//
//  ARImage.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 13/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit
import ARKit

// The max number of command buffers in flight
let kMaxBuffersInFlight: Int = 3

// The max number anchors our uniform buffer will hold
let kMaxAnchorInstanceCount: Int = 64

// The 16 byte aligned size of our uniform structures
var kAlignedSharedUniformsSize: Int = (MemoryLayout<Uniform>.size & ~0xFF) + 0x100

var kAlignedInstanceUniformsSize: Int = ((MemoryLayout<InstanceUniform>.size * kMaxAnchorInstanceCount) & ~0xFF) + 0x100


open class ARImage: Node {

    //MARK: - Renderable
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var vertexFunctionName: VertexFunction = .vertex_shader
    var fragmentFunctionName: FragmentFunction = .fragment_shader

    // Vertex data for an image plane
    let imagePlaneVertexData: [Float] = [
        -1.0, -1.0,  0.0, 1.0,  // position + texture coord
        1.0, -1.0,  1.0, 1.0,   // position + texture coord
        -1.0,  1.0,  0.0, 0.0,  // position + texture coord
        1.0,  1.0,  1.0, 0.0,   // position + texture coord
    ]

    var vertexDescriptor: MTLVertexDescriptor {
        // Create a vertex descriptor for our image plane vertex buffer
        let imagePlaneVertexDescriptor = MTLVertexDescriptor()

        // Positions.
        imagePlaneVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float2
        imagePlaneVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        imagePlaneVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

        // Texture coordinates.
        imagePlaneVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        imagePlaneVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 8
        imagePlaneVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

        // Buffer Layout
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 16
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        imagePlaneVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = .perVertex
        return imagePlaneVertexDescriptor
    }

    var uniform = Uniform()

    var drawType: MTLPrimitiveType = .triangleStrip

    var texture: MTLTexture?

    //MARK: - RenderableImage
    var imagePlaneVertexBuffer: MTLBuffer!
    var imageTextureY: CVMetalTexture?
    var imageTextureCbCr: CVMetalTexture?
    var imageTextureCache: CVMetalTextureCache!

    let inFlightSemaphore = DispatchSemaphore(value: kMaxBuffersInFlight)

    //MARK: - initialise the Renderer with a device
    public init(mtkView: MTKView, renderDestination: RenderDestinationProvider,
                vertexShader: VertexFunction = .image_vertex_shader, fragmentShader: FragmentFunction) {
        super.init(name: "ARFrame")
        self.vertexFunctionName = vertexShader
        self.fragmentFunctionName = fragmentShader

        guard let device = mtkView.device else { fatalError("No Device Found") }

        // Create a vertex buffer with our image plane vertex data.
        let imagePlaneVertexDataCount = imagePlaneVertexData.count * MemoryLayout<Float>.size
        imagePlaneVertexBuffer = device.makeBuffer(bytes: imagePlaneVertexData, length: imagePlaneVertexDataCount, options: [])
        imagePlaneVertexBuffer.label = "ImagePlaneVertexBuffer"

        pipelineState = buildImagePipelineState(device: device, renderDestination: renderDestination,
                                                descriptor: vertexDescriptor,
                                                vertexFunctionName: vertexShader,
                                                fragmentFunctionName: fragmentShader)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildImageDepthStencilState(device: device)
        imageTextureCache = createImageTextureCache(device: device)
    }

    public func updateCapturedImageTextures(frame: ARFrame) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage

        if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) {
            return
        }

        imageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.r8Unorm, planeIndex:0)
        imageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.rg8Unorm, planeIndex:1)
    }

    public func updateImagePlane(frame: ARFrame, camera: Camera) {
        // Update the texture coordinates of our image plane to aspect fill the viewport
        let displayToCameraTransform = frame.displayTransform(for: .landscapeRight, viewportSize: camera.screenSize).inverted()

        let vertexData = imagePlaneVertexBuffer.contents().assumingMemoryBound(to: Float.self)
        for index in 0...3 {
            let textureCoordIndex = 4 * index + 2
            let textureCoord = CGPoint(x: CGFloat(imagePlaneVertexData[textureCoordIndex]), y: CGFloat(imagePlaneVertexData[textureCoordIndex + 1]))
            let transformedCoord = textureCoord.applying(displayToCameraTransform)
            vertexData[textureCoordIndex] = Float(transformedCoord.x)
            vertexData[textureCoordIndex + 1] = Float(transformedCoord.y)
        }
    }

    public func drawCapturedImage(commandEncoder: MTLRenderCommandEncoder) {
        guard let textureY = imageTextureY, let textureCbCr = imageTextureCbCr else {
            return
        }

        // Set render command encoder state
        commandEncoder.setCullMode(.none)
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)

        // Set mesh's vertex buffers
        commandEncoder.setVertexBuffer(imagePlaneVertexBuffer, offset: 0, index: BufferIndex.meshPositions.rawValue)

        // Set any textures read/sampled from our render pipeline
        commandEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureY), index: TextureIndex.Y.rawValue)
        commandEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureCbCr), index: TextureIndex.cbCr.rawValue)

        // Draw each submesh of our mesh
        commandEncoder.drawPrimitives(type: drawType, vertexStart: 0, vertexCount: 4)

    }

}

extension ARImage: RenderableImage {

}

extension ARImage: Renderable {
    public func doRender(commandBuffer: MTLCommandBuffer, commandEncoder: MTLRenderCommandEncoder,
                         modelMatrix: matrix_float4x4,
                         camera: Camera, currentFrame: ARFrame) {

        // Wait to ensure only kMaxBuffersInFlight are getting proccessed by any stage in the Metal
        //   pipeline (App, Metal, Drivers, GPU, etc)
        let _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        // Add completion hander which signal _inFlightSemaphore when Metal and the GPU has fully
        //   finished proccessing the commands we're encoding this frame.  This indicates when the
        //   dynamic buffers, that we're writing to this frame, will no longer be needed by Metal
        //   and the GPU.
        // Retain our CVMetalTextures for the duration of the rendering cycle. The MTLTextures
        //   we use from the CVMetalTextures are not valid unless their parent CVMetalTextures
        //   are retained. Since we may release our CVMetalTexture ivars during the rendering
        //   cycle, we must retain them separately here.
        var textures = [imageTextureY, imageTextureCbCr]
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inFlightSemaphore.signal()
            }
            textures.removeAll()
        }

        updateCapturedImageTextures(frame: currentFrame)

        if camera.viewportSizeDidChange {
            camera.viewportSizeDidChange = false
            print("orientation changed")
            updateImagePlane(frame: currentFrame, camera: camera)
        }

        drawCapturedImage(commandEncoder: commandEncoder)
    }

}

extension ARImage: Texturable {
}
