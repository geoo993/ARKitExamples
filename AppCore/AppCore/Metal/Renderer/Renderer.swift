//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
// https://academy.realm.io/posts/3d-graphics-metal-swift/
// 

import Metal
import MetalKit
import ARKit

// The max number of command buffers in flight
let kMaxBuffersInFlight: Int = 3

// The max number anchors our uniform buffer will hold
let kMaxAnchorInstanceCount: Int = 64

// The 16 byte aligned size of our uniform structures
var kAlignedSharedUniformsSize: Int = (MemoryLayout<Uniform>.size & ~0xFF) + 0x100

var kAlignedInstanceUniformsSize: Int = ((MemoryLayout<InstanceUniform>.size * kMaxAnchorInstanceCount) & ~0xFF) + 0x100

public class Renderer: NSObject {


    let session: ARSession
    let device: MTLDevice
    var renderDestination: RenderDestinationProvider
    // create device scene
    public var scene: Scene!

    // the commandQueue is just a serial queue that dispatches work to the gpu in an organised manner
    // becase the gpu is going to be busy with a bunch of different tasks on the system
    // and in order for your work to get on to the gpu and run, it need tombe submitted through a this
    // commandQueue, and you would summit your work using command encoders.
    // you can submit to command queue across multiple threads, it is and inherently thread safe object
    //
    let commandQueue: MTLCommandQueue
    let inFlightSemaphore = DispatchSemaphore(value: kMaxBuffersInFlight)

    //MARK: - Renderable States
    var imagePipelineState: MTLRenderPipelineState!
    var imageDepthStencilState: MTLDepthStencilState!

    //MARK: - Renderable Image
    public var imagePlaneVertexBuffer: MTLBuffer!
    var imageTextureY: CVMetalTexture?
    var imageTextureCbCr: CVMetalTexture?
    var imageTextureCache: CVMetalTextureCache!

    // Vertex data for an image plane
    var imagePlaneVertexData: [Float] {
        return [
        -1.0, -1.0,  0.0, 1.0,  // position + texture coord
        1.0, -1.0,  1.0, 1.0,   // position + texture coord
        -1.0,  1.0,  0.0, 0.0,  // position + texture coord
        1.0,  1.0,  1.0, 0.0,   // position + texture coord
        ]
    }

    var imageVertexDescriptor: MTLVertexDescriptor {
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

    //MARK: - Render Uniform Provider
    public var sharedUniformBuffer: MTLBuffer!
    public var anchorUniformBuffer: MTLBuffer!
    public var uniformBufferIndex: Int = 0
    public var sharedUniformBufferOffset: Int = 0
    public var anchorUniformBufferOffset: Int = 0
    public var sharedUniformBufferAddress: UnsafeMutableRawPointer!
    public var anchorUniformBufferAddress: UnsafeMutableRawPointer!
    public var anchorInstanceCount: Int = 0

    var meshes: [AnyObject]?

    //MARK: - initialise the Renderer with a device
    public init(mtkView: MTKView, session: ARSession, renderDestination: RenderDestinationProvider) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the MTKView and Device
        self.device = mtkView.device!

        //2) Create a command Queue
        // The command queue stores a sequence of command buffers, which we will create and write GPU commands into.
        // Commands consist of things like state-setting operations (which describe how things should be drawn and what
        // resources they should be drawn with) as well as draw calls, which tell the GPU to actually draw geometry,
        // causing our vertex and fragment functions to be called and producing the pixels that wind up on the screen.
        self.commandQueue = device.makeCommandQueue()!

        //self.scene = scene

        self.session = session

        self.renderDestination = renderDestination

        // set the scene
        super.init()

        // we need to tell Metal to store the depth of each fragment as we process it,
        // keeping the closest depth value and only replacing it if we see a fragment that is closer to the camera.
        // This is called depth buffering, and fortunately, it’s not too hard to configure.
        // Depth buffering requires the use of an additional texture called, naturally, the depth buffer.
        // This texture is a lot like the color texture we’re already presenting to the screen when we’re done drawing,
        // but instead of storing color, it stores depth, which is basically the distance from the camera to the surface.
        self.renderDestination.depthStencilPixelFormat = .depth32Float_stencil8

        // we need to tell the view the format of the color texture we will be drawing to. We will choose bgra8Unorm, which is a format that uses one byte per color channel (red, green, blue, and alpha (transparency)), laid out in blue, green, red, alpha order. The Unorm portion of the name signifies that the components are stored as unsigned 8-bit values, so that the values 0-255 map to 0-100% intensity (or 0-100% opacity, in the case of the alpha channel).
        self.renderDestination.colorPixelFormat = .bgra8Unorm
        self.renderDestination.sampleCount = 1


        guard let device = mtkView.device else { fatalError("No Device Found") }

        createBuffers(device: device)
        
        // Create a vertex buffer with our image plane vertex data.
        let imagePlaneVertexDataCount = imagePlaneVertexData.count * MemoryLayout<Float>.size
        imagePlaneVertexBuffer = device.makeBuffer(bytes: imagePlaneVertexData, length: imagePlaneVertexDataCount, options: [])
        imagePlaneVertexBuffer.label = "ImagePlaneVertexBuffer"

        imagePipelineState = buildImagePipelineState(device: device, renderDestination: renderDestination,
                                                descriptor: imageVertexDescriptor,
                                                vertexFunctionName: .image_vertex_shader,
                                                fragmentFunctionName: .fragment_image_shader)
        imageDepthStencilState = buildImageDepthStencilState(device: device)
        imageTextureCache = buildImageTextureCache(device: device)

    }

    private func createBuffers(device: MTLDevice) {

        // Calculate our uniform buffer sizes. We allocate kMaxBuffersInFlight instances for uniform
        //   storage in a single buffer. This allows us to update uniforms in a ring (i.e. triple
        //   buffer the uniforms) so that the GPU reads from one slot in the ring wil the CPU writes
        //   to another. Anchor uniforms should be specified with a max instance count for instancing.
        //   Also uniform storage must be aligned (to 256 bytes) to meet the requirements to be an
        //   argument in the constant address space of our shading functions.
        let sharedUniformBufferSize = kAlignedSharedUniformsSize * kMaxBuffersInFlight
        let anchorUniformBufferSize = kAlignedInstanceUniformsSize * kMaxBuffersInFlight

        // Create and allocate our uniform buffer objects. Indicate shared storage so that both the
        //   CPU can access the buffer
        sharedUniformBuffer = device.makeBuffer(length: sharedUniformBufferSize, options: .storageModeShared)
        sharedUniformBuffer.label = "SharedUniformBuffer"

        anchorUniformBuffer = device.makeBuffer(length: anchorUniformBufferSize, options: .storageModeShared)
        anchorUniformBuffer.label = "AnchorUniformBuffer"
    }

    private func updateBufferStates() {
        // Update the location(s) to which we'll write to in our dynamically changing Metal buffers for
        //   the current frame (i.e. update our slot in the ring buffer used for the current frame)

        uniformBufferIndex = (uniformBufferIndex + 1) % kMaxBuffersInFlight

        sharedUniformBufferOffset = kAlignedSharedUniformsSize * uniformBufferIndex
        anchorUniformBufferOffset = kAlignedInstanceUniformsSize * uniformBufferIndex

        sharedUniformBufferAddress = sharedUniformBuffer.contents().advanced(by: sharedUniformBufferOffset)
        anchorUniformBufferAddress = anchorUniformBuffer.contents().advanced(by: anchorUniformBufferOffset)
    }

    public func updateCapturedImageTextures(frame: ARFrame) {
        // Create two textures (Y and CbCr) from the provided frame's captured image
        let pixelBuffer = frame.capturedImage

        if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) {
            return
        }

        imageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .r8Unorm, planeIndex:0)
        imageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: .rg8Unorm, planeIndex:1)
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
        commandEncoder.setRenderPipelineState(imagePipelineState)
        commandEncoder.setDepthStencilState(imageDepthStencilState)

        // Set mesh's vertex buffers
        commandEncoder.setVertexBuffer(imagePlaneVertexBuffer, offset: 0, index: BufferIndex.meshPositions.rawValue)

        // Set any textures read/sampled from our render pipeline
        commandEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureY), index: TextureIndex.Y.rawValue)
        commandEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureCbCr), index: TextureIndex.cbCr.rawValue)

        // Draw each submesh of our mesh
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }

    private func updateSharedUniforms(frame: ARFrame, camera: Camera) {
        // Update the shared uniforms of the frame

        let uniforms = sharedUniformBufferAddress.assumingMemoryBound(to: Uniform.self)

//        uniforms.pointee.projectionMatrix = camera.perspectiveProjectionMatrix
//        uniforms.pointee.viewMatrix = camera.viewMatrix
        uniforms.pointee.viewMatrix = frame.camera.viewMatrix(for: .landscapeRight)
        uniforms.pointee.projectionMatrix = frame.camera
            .projectionMatrix(for: .landscapeRight, viewportSize: camera.screenSize,
                              zNear: camera.nearPlane.toCGFloat, zFar: camera.farPlane.toCGFloat)

    }

    private func updateAnchors(frame: ARFrame) {
        // Update the anchor uniform buffer with transforms of the current frame's anchors
        anchorInstanceCount = min(frame.anchors.count, kMaxAnchorInstanceCount)

        var anchorOffset: Int = 0
        if anchorInstanceCount == kMaxAnchorInstanceCount {
            anchorOffset = max(frame.anchors.count - kMaxAnchorInstanceCount, 0)
        }

        for index in 0..<anchorInstanceCount {
            let anchor = frame.anchors[index + anchorOffset]

            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = matrix_identity_float4x4
            coordinateSpaceTransform.columns.2.z = -1.0

            let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)

            // model matrix
            let anchorUniforms = anchorUniformBufferAddress.assumingMemoryBound(to: InstanceUniform.self).advanced(by: index)
            anchorUniforms.pointee.modelMatrix = modelMatrix

            // normal matrix
            anchorUniforms.pointee.normalMatrix = modelMatrix.upperLeft3x3().transpose.inverse
        }
    }
    
}

// MARK: - MTKViewDelegate
extension Renderer: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let scene = self.scene else {
            fatalError("A scene was not set")
        }
        scene.sceneSizeWillChange(to: size.half)

    }

    // MARK: - Draw object
    public func draw(in view: MTKView) {

        //1) The MTKView view has a drawable, which is not an object that is displayed in the screen and
        // we issue our drawing command to this drawable.
        // The MTKView also has a render pass descriptor, which describes how the buffers are to be rendered,
        // we use this descriptor to create the command encoder.
        // Metla uses descriptor to setup Metal objects.
        // descriptors are like blueprints, a descriptor allows you to set requirement and spec about your object
        // when you setup a descriptor, you are setting up the list of properties you want your object to have.
        // then you create your object from that descriptor, if you subsequently change the desciptor properties,
        // you're only changing the list and not the original object.

        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
            else { return }

        //2) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "Main Command buffer"


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

        //3) Encode all the commands
        // the command encoder is the thing that translates form humaan to gpu speak.
        // you might say draw this triangle, and that get taken by the command encoder and write
        // in byte code in a compressed format,
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.label = "Primary Render Encoder"

        updateBufferStates()
        
        if let currentFrame = session.currentFrame, let scene = scene {

            updateSharedUniforms(frame: currentFrame, camera: scene.camera)
            updateAnchors(frame: currentFrame)
            updateCapturedImageTextures(frame: currentFrame)

            if scene.camera.viewportSizeDidChange {
                scene.camera.viewportSizeDidChange = false
                updateImagePlane(frame: currentFrame, camera: scene.camera)
            }

            drawCapturedImage(commandEncoder: commandEncoder)

            let deltaTime = 1 / Float(view.preferredFramesPerSecond)
            scene.time += 1 / Float(view.preferredFramesPerSecond)

            // set the scene
            scene.render(commandBuffer: commandBuffer,
                         commandEncoder: commandEncoder,
                         renderUniform: self,
                         frame: currentFrame, deltaTime: deltaTime)
        }

        // Once we’re done drawing, we need to call endEncoding() on our render command encoder to end the pass—and the frame:
        // Ending encoding signifies that we won’t be doing any more drawing with this render command encoder. If we wanted to draw additional objects, we would need to do that before calling endEncoding.
        commandEncoder.endEncoding()

        // In order to get our rendered content on the screen, we have to expressly present the drawable
        // whose texture we’ve be drawing into. We do this with a call on the command buffer, rather than the command encoder:
        commandBuffer.present(drawable)

        //4) send command buffer to the GPU when you finish encoding all the commands
        // Once we’re done encoding commands into the command buffer, we commit it,
        // so its queue knows that it should ship the commands over to the GPU.
        commandBuffer.commit()

    }
}

extension Renderer: RenderableImage {

}

extension Renderer: RenderUniformProvider {

}
