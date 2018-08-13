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
    var imagePlaneVertexBuffer: MTLBuffer!
    var imageTextureY: CVMetalTexture?
    var imageTextureCbCr: CVMetalTexture?
    var imageTextureCache: CVMetalTextureCache!

    // Vertex data for an image plane
    let imagePlaneVertexData: [Float] = [
        -1.0, -1.0,  0.0, 1.0,  // position + texture coord
        1.0, -1.0,  1.0, 1.0,   // position + texture coord
        -1.0,  1.0,  0.0, 0.0,  // position + texture coord
        1.0,  1.0,  1.0, 0.0,   // position + texture coord
    ]

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

    //MARK: - Renderable
    var modelPipelineState: MTLRenderPipelineState!
    var modelSamplerState: MTLSamplerState!
    var modelDepthStencilState: MTLDepthStencilState!

    var modelVertexDescriptor: MTLVertexDescriptor {
        // Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render
        //   pipeline and how we'll layout our Model IO vertices

        let vertexDescriptor = MTLVertexDescriptor()

        // describe the position data
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        vertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

        // describe the texture data
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = MemoryLayout<Float>.stride * 3
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // describe the color data
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].format = .float4
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].offset = MemoryLayout<Float>.stride * 5
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // describe the normal data
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = MemoryLayout<Float>.stride * 9
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // tell the vertex descriptor the size of the information held for each vertex
        // An object that configures how vertex data and attributes are fetched by a vertex function.
        // Position Buffer Layout
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<Float>.stride * 12
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        // Generic Attribute Buffer Layout
        vertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = MemoryLayout<Float>.stride * 18
        vertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
        vertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        return vertexDescriptor
    }

    //MARK: - Anchors

    var sharedUniformBuffer: MTLBuffer!
    var anchorUniformBuffer: MTLBuffer!
    // Used to determine _uniformBufferStride each frame.
    //   This is the current frame number modulo kMaxBuffersInFlight
    var uniformBufferIndex: Int = 0

    // Offset within _sharedUniformBuffer to set for the current frame
    var sharedUniformBufferOffset: Int = 0

    // Offset within _anchorUniformBuffer to set for the current frame
    var anchorUniformBufferOffset: Int = 0

    // Addresses to write shared uniforms to each frame
    var sharedUniformBufferAddress: UnsafeMutableRawPointer!

    // Addresses to write anchor uniforms to each frame
    var anchorUniformBufferAddress: UnsafeMutableRawPointer!

    // The number of anchor instances to render
    var anchorInstanceCount: Int = 0

    var meshes: [AnyObject]?

    var texture: MTLTexture?

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


        texture = setTexture(device: device, imageName: "mushroom.png", bundle: renderDestination.bundle)
        modelPipelineState = buildModelPipelineState(device: device,
                                                     renderDestination: renderDestination,
                                                     vertexFunctionName: .vertex_anchor_shader,
                                                     fragmentFunctionName: .fragment_anchor_shader)
        modelSamplerState = buildModelSamplerState(device: device)
        modelDepthStencilState = buildModelDepthStencilState(device: device)
        loadModel(device: device, renderDestination: renderDestination, modelName: "mushroom")
    }

    // MARK: - Setup texture with bundle resource
    func setTexture(device: MTLDevice, imageName: String, bundle: Bundle) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        // Loading texure
        var texture: MTLTexture? = nil
        let textureLoaderOptions: [MTKTextureLoader.Option: Any]

        if #available(iOS 10.0, *) {
            textureLoaderOptions = [.origin : MTKTextureLoader.Origin.bottomLeft,
                                    .generateMipmaps : true,
                                    .SRGB : true,
                                    .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                                    .textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
            ]
        } else {
            textureLoaderOptions = [:]
        }

        // load texture using the passed in image name
        if let textureURL = bundle.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                fatalError("texture not created with error: \(error.localizedDescription)")
            }
        }

        // when you notice that the image is pixelated, this is becuase the default sampler uses filter mode Nearest
        return texture
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


    // MARK: - Setup stencil state
    func buildImageDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let capturedImageDepthStateDescriptor = MTLDepthStencilDescriptor()
        capturedImageDepthStateDescriptor.depthCompareFunction = .always
        capturedImageDepthStateDescriptor.isDepthWriteEnabled = false
        return device.makeDepthStencilState(descriptor: capturedImageDepthStateDescriptor)!
    }

    // MARK: - Setup Image Cache
    func buildImageTextureCache(device: MTLDevice) -> CVMetalTextureCache {
        // Create captured image texture cache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        return textureCache!
    }

    func buildModelPipelineState(device: MTLDevice,
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
        pipelineDescriptor.vertexDescriptor = modelVertexDescriptor
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
    func buildModelSamplerState(device: MTLDevice) -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.normalizedCoordinates = true
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: descriptor)!
    }

    func buildModelDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }

    private func loadModel(device: MTLDevice, renderDestination: RenderDestinationProvider, modelName: String) {
        guard let assetURL = renderDestination.bundle.url(forResource: modelName, withExtension: "obj") else {
            fatalError("Asset \(modelName) does not exist.")
        }

        // Model IO requires a special Model IO vertex descriptor, we can use the MTKModel vertex descriptor
        let descriptor = MTKModelIOVertexDescriptorFromMetal(modelVertexDescriptor)

        // Model IO needs some further details about the model
        // these are description of the attributes
        // this is the position attributes
        let attributePosition = descriptor.attributes[VertexAttribute.position.rawValue] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        descriptor.attributes[VertexAttribute.position.rawValue] = attributePosition

        // here is the texture attributes
        let attributeTexture = descriptor.attributes[VertexAttribute.texcoord.rawValue] as! MDLVertexAttribute
        attributeTexture.name = MDLVertexAttributeTextureCoordinate
        descriptor.attributes[VertexAttribute.texcoord.rawValue] = attributeTexture

        // here is the color attributes
        let attributeColor = descriptor.attributes[VertexAttribute.color.rawValue] as! MDLVertexAttribute
        attributeColor.name = MDLVertexAttributeColor
        descriptor.attributes[VertexAttribute.color.rawValue] = attributeColor

        // here is the normals attributes
        let attributeNormal = descriptor.attributes[VertexAttribute.normal.rawValue] as! MDLVertexAttribute
        attributeNormal.name = MDLVertexAttributeNormal
        descriptor.attributes[VertexAttribute.normal.rawValue] = attributeNormal

        // to load the asset we need to create a MeshBuffer allocator
        // this handles all the loading and managing on the GPU of the vertex and index data
        let bufferAllocator = MTKMeshBufferAllocator(device: device)

        // Use ModelIO to create a box mesh as our object
        let mesh = MDLMesh(boxWithExtent: vector3(0.075, 0.075, 0.075), segments: vector3(1, 1, 1),
                           inwardNormals: false, geometryType: .triangles, allocator: bufferAllocator)
        // Perform the format/relayout of mesh vertices by setting the new vertex descriptor in our
        //   Model IO mesh
        mesh.vertexDescriptor = descriptor

        // load asset using the asset URL
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: descriptor,
                             bufferAllocator: bufferAllocator)

        do {
            meshes = try MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
            //meshes = try [MTKMesh(mesh: mesh, device: device)]
        } catch let error {
            fatalError("Error creating MetalKit mesh, error \(error)")
        }
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

        imageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.r8Unorm, planeIndex:0)
        imageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.rg8Unorm, planeIndex:1)
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

    func drawAnchorGeometry(commandEncoder: MTLRenderCommandEncoder) {
        guard anchorInstanceCount > 0 else {
            return
        }

        // Set render command encoder state
        commandEncoder.setCullMode(.back)
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setRenderPipelineState(modelPipelineState)
        commandEncoder.setDepthStencilState(modelDepthStencilState)
        commandEncoder.setFragmentSamplerState(modelSamplerState, index: 0)


        if texture != nil {
            commandEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
        }

        // Set any buffers fed into our render pipeline
        commandEncoder.setVertexBuffer(anchorUniformBuffer, offset: anchorUniformBufferOffset, index: BufferIndex.instances.rawValue)
        commandEncoder.setVertexBuffer(sharedUniformBuffer, offset: sharedUniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        commandEncoder.setFragmentBuffer(sharedUniformBuffer, offset: sharedUniformBufferOffset, index: BufferIndex.uniforms.rawValue)

        guard let meshes = meshes as? [MTKMesh], meshes.count > 0 else { return }

        // Each MLKMesh will have one or more sub meshes with the index information.
        // To render the object we loop through MetalKit meshes, we get the VertexBuffer from the mesh
        // and set that as the GPU vertex buffer.
        for mesh in meshes {
            for (index, element) in mesh.vertexDescriptor.layouts.enumerated() {
                guard let layout = element as? MDLVertexBufferLayout else {
                    return
                }
                if layout.stride != 0 {
                    // To tell our vertex function where to get data from, we need to tell it which buffers contain the data. We will accomplish this in two separate ways, depending on the type of data.
                    //First, we will set up the buffer that contains our vertex data with the setVertexBuffer(_:offset:index:) method. The offset parameter indicates where in the buffer the data starts, while the at parameter specifies the buffer index. The buffer index corresponds to the bufferIndex property of the attributes specified in our vertex descriptor; this is what creates the linkage between how the data is laid out in the buffer and how it is laid out in the struct taken as a parameter by our vertex function.
                    let vertexBuffer = mesh.vertexBuffers[index]
                    commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: index)
                }
            }


            // then we loop through the MTLMesh sub meshes, and draw the group of meshes that belongs to the MTLMesh
            // using the submesh indicies.
            for submesh in mesh.submeshes {
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: submesh.indexBuffer.offset,
                                                     instanceCount: anchorInstanceCount)

            }
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
            drawAnchorGeometry(commandEncoder: commandEncoder)

            let deltaTime = 1 / Float(view.preferredFramesPerSecond)
            scene.time += 1 / Float(view.preferredFramesPerSecond)

            // set the scene
            scene.render(commandBuffer: commandBuffer,
                         commandEncoder: commandEncoder,
                         deltaTime: deltaTime, frame: currentFrame)
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
