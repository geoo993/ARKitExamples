//
//  Model.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 01/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// in 2015 Apple intoduced the Model IO framework
// using this framework we can import 3D assets of various types and describe how they should be rendered
// You can alos describe realistic lighting and materials.
// We use Model IO to process 3D model files.
// The .OBJ Format was developed many years ago by wavefront technologies.
// Its a format thta describes geometry in 3D.
// Model IO is an easy way of importing OBJ files, The WWDC 2015 video on Model IO is a recommened watch
// to see the posibilies of realistic rendering.
// To import a model you use a model url and a VertexDescriptor to define what attributes you
// need to create an MDLAsset. this MDLAsset is a container for objects, the objects could be lights for
// cameras or even matrix transform heirachy. The MDLAssets contains MDLMesh objects which have vertex buffers
// Using this MDLMesh you can generate stuff like, normals, or lighting information.
// We create MTKMesh for these Model IO Mesh objects and we are going to be able to send the MTK vertex buffers
// to the GPU

// http://metalbyexample.com/modern-metal-1/

import MetalKit
import ARKit

class Model: Node {

    //MARK: - Renderable
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState!
    var depthStencilState: MTLDepthStencilState!
    var vertexFunctionName: VertexFunction = .vertex_shader
    var fragmentFunctionName: FragmentFunction = .fragment_shader

    var vertexDescriptor: MTLVertexDescriptor {
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
        vertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = 0

        // describe the color data
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].format = .float4
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].offset = MemoryLayout<Float>.stride * 5
        vertexDescriptor.attributes[VertexAttribute.color.rawValue].bufferIndex = 0

        // describe the normal data
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = .float3
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = MemoryLayout<Float>.stride * 9
        vertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = 0

        // tell the vertex descriptor the size of the information held for each vertex
        // An object that configures how vertex data and attributes are fetched by a vertex function.
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = MemoryLayout<Float>.stride * 12
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        vertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        return vertexDescriptor
    }

    var uniform = Uniform()

    var drawType: MTLPrimitiveType = .triangle


    //MARK: - Properties
    var meshes: [AnyObject]?

    var texture: MTLTexture?
    var imageTextureCache: CVMetalTextureCache!
    var imageTextureY: CVMetalTexture?
    var imageTextureCbCr: CVMetalTexture?

    //MARK: - initialise the Renderer with a device
    init(mtkView: MTKView, renderDestination: RenderDestinationProvider, modelName: String, vertexShader: VertexFunction = .vertex_shader, fragmentShader: FragmentFunction) {
        super.init(name: modelName)
        self.vertexFunctionName = vertexShader
        self.fragmentFunctionName = fragmentShader
        let imageName = modelName + ".png"
        setupBuffers(mtkView: mtkView, renderDestination: renderDestination, modelName: modelName, imageName: imageName)
    }

    init(mtkView: MTKView, renderDestination: RenderDestinationProvider, modelName: String, imageName: String, vertexShader: VertexFunction = .vertex_shader, fragmentShader: FragmentFunction) {
        super.init(name: modelName)
        self.vertexFunctionName = vertexShader
        self.fragmentFunctionName = fragmentShader
        setupBuffers(mtkView: mtkView, renderDestination: renderDestination, modelName: modelName, imageName: imageName)
    }

    func setupBuffers(mtkView: MTKView, renderDestination: RenderDestinationProvider, modelName: String, imageName: String) {
        guard let device = mtkView.device else { fatalError("No Device Found") }
        loadModel(device: device, renderDestination: renderDestination, modelName: modelName)

        if let texture = setTexture(device: device, imageName: imageName, bundle: renderDestination.bundle) {
            self.texture = texture
        }
        pipelineState = buildPipelineState(device: device, renderDestination: renderDestination)
        samplerState = buildSamplerState(device: device)
        depthStencilState = buildDepthStencilState(device: device)
    }


    func loadModel(device: MTLDevice, renderDestination: RenderDestinationProvider, modelName: String) {
        guard let assetURL = renderDestination.bundle.url(forResource: modelName, withExtension: "obj") else {
            fatalError("Asset \(modelName) does not exist.")
        }

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

        // to load the asset we need to create a MeshBuffer allocator
        // this handles all the loading and managing on the GPU of the vertex and index data
        let bufferAllocator = MTKMeshBufferAllocator(device: device)

        // load asset using the asset URL
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: descriptor,
                             bufferAllocator: bufferAllocator)

        // asset bounding box
        let boundingBox = asset.boundingBox
        width = boundingBox.maxBounds.x - boundingBox.minBounds.x
        height = boundingBox.maxBounds.y - boundingBox.minBounds.y

        do {
            meshes = try MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
        } catch {
            print("mesh error")
        }
    }


}

extension Model: Renderable {

    func doRender(commandBuffer: MTLCommandBuffer, commandEncoder: MTLRenderCommandEncoder, modelMatrix: matrix_float4x4,
                  camera: Camera, currentFrame: ARFrame) {

        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)

        commandEncoder.setCullMode(.back)
        commandEncoder.setFrontFacing(.counterClockwise)
        commandEncoder.setDepthStencilState(depthStencilState)

        // setup the matrices attributes
        // projection matrix
        // the projecttion matrix will project all the vertices back into clipping space
        uniform.projectionMatrix = camera.perspectiveProjectionMatrix

        // view matrix
        uniform.viewMatrix = camera.viewMatrix

        // model matrix
        uniform.modelMatrix = modelMatrix

        // normal matrix
        uniform.normalMatrix = camera.computeNormalMatrix(modelMatrix: modelMatrix)


        // to set up the buffer that contains the uniform data. Because this data is so small, we would like to avoid creating a dedicated buffer for it. Fortunately, the render command encoder has a method called setVertexBytes(_:length:index:) that enables exactly this. This method takes a pointer to some data that will be written into a buffer that is managed internally by Metal. In this case, the buffer index specified by the last parameter matches the index of the [[buffer()]] attribute in the parameter list of the vertex function. In this sample app, we dedicate buffer index 1 to our uniform buffer.
        commandEncoder.setVertexBytes(&uniform,
                                      length: MemoryLayout<Uniform>.stride,
                                      index: BufferIndex.uniforms.rawValue)

        commandEncoder.setFragmentBytes(&material, length: MemoryLayout<MaterialInfo>.stride,
                                        index: BufferIndex.materialInfo.rawValue)

        if texture != nil {
            commandEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
        }


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
                drawType = submesh.primitiveType
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: submesh.indexBuffer.offset)
            }
            
        }

    }

}


extension Model: Texturable {
}
