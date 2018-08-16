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
    var vertexDescriptor: MTLVertexDescriptor! { get set }
    var uniform: Uniform { get set }
    var meshes: [AnyObject]? { get set}
    func doRender(commandBuffer: MTLCommandBuffer,
                  commandEncoder: MTLRenderCommandEncoder,
                  camera: Camera,
                  renderUniform: RenderUniformProvider)
}

extension Renderable {

    func buildVertexDescriptor() -> MTLVertexDescriptor {
        // Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render
        //   pipeline and how we'll layout our Model IO vertices
        let descriptor = MTLVertexDescriptor()

        // describe the position data
        descriptor.attributes[VertexAttribute.position.rawValue].format = .float3
        descriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        descriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshVertices.rawValue

        // describe the texture data
        descriptor.attributes[VertexAttribute.texcoord.rawValue].format = .float2
        descriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
        descriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // describe the color data
        descriptor.attributes[VertexAttribute.color.rawValue].format = .float4
        descriptor.attributes[VertexAttribute.color.rawValue].offset = MemoryLayout<Float>.stride * 2 // float2  = 8 in buffer size
        descriptor.attributes[VertexAttribute.color.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // describe the normal data
        descriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        descriptor.attributes[VertexAttribute.normal.rawValue].offset = MemoryLayout<Float>.stride * 6 // float2 + float4 = 8 + 16 in buffer size
        descriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        // tell the vertex descriptor the size of the information held for each vertex
        // An object that configures how vertex data and attributes are fetched by a vertex function.
        // Position Buffer Layout
        descriptor.layouts[BufferIndex.meshVertices.rawValue].stride = MemoryLayout<Float>.stride * 3 // 12 in stride
        descriptor.layouts[BufferIndex.meshVertices.rawValue].stepRate = 1
        descriptor.layouts[BufferIndex.meshVertices.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        // Generic Attribute Buffer Layout
        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = MemoryLayout<Float>.stride * 9 // 36 in stride
        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        return descriptor
    }

    func loadModel(device: MTLDevice, renderDestination: RenderDestinationProvider,
                   vertexDescriptor: MTLVertexDescriptor, model: [ObjectType: String]) -> [AnyObject]? {
        guard let modelObject = model.first else { fatalError("model is not set.") }


        // to load the asset we need to create a MeshBuffer allocator
        // this handles all the loading and managing on the GPU of the vertex and index data
        let bufferAllocator = MTKMeshBufferAllocator(device: device)

        // Model IO requires a special Model IO vertex descriptor, we can use the MTKModel vertex descriptor
        let descriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)

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

        do {
            switch modelObject.key {
            case .model:
                guard let assetURL = renderDestination.bundle.url(forResource: modelObject.value, withExtension: "obj")
                    else { fatalError("Asset does not exist") }

                // load asset using the asset URL
                let asset = MDLAsset(url: assetURL,
                                     vertexDescriptor: descriptor,
                                     bufferAllocator: bufferAllocator)
                return try MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
            case .cube:
                // Use ModelIO to create a box mesh as our object
                let mesh = MDLMesh(boxWithExtent: vector3(1, 1, 1), segments: vector3(1, 1, 1),
                                   inwardNormals: false, geometryType: .triangles, allocator: bufferAllocator)
                // Perform the format/relayout of mesh vertices by setting the new vertex descriptor in our
                //   Model IO mesh
                mesh.vertexDescriptor = descriptor
                return try [MTKMesh(mesh: mesh, device: device)]
            case .sphere:
                let mesh = MDLMesh(sphereWithExtent: float3(1, 1, 1),
                                   segments: vector_uint2(40, 40), inwardNormals: false,
                                   geometryType: MDLGeometryType.triangles, allocator: bufferAllocator)
                mesh.vertexDescriptor = descriptor
                return try [MTKMesh(mesh: mesh, device: device)]
            }
        } catch let error {
            fatalError("Error creating MetalKit mesh, error \(error)")
        }
    }

    func buildPipelineState(device: MTLDevice,
                            renderDestination: RenderDestinationProvider,
                            vertexDescriptor: MTLVertexDescriptor,
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
