//
//  Mesh.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 16/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import ModelIO

public class Mesh {
    var vertexBuffer: MTLBuffer
    var vertexDescriptor: MTLVertexDescriptor
    var primitiveType: MTLPrimitiveType
    var indexBuffer: MTLBuffer
    var indexCount: Int
    var indexType: MTLIndexType

    public init?(cubeWithSize size: Float, device: MTLDevice)
    {
        let allocator = MTKMeshBufferAllocator(device: device)

        let mdlMesh = MDLMesh(boxWithExtent: vector_float3(size, size, size),
                              segments: vector_uint3(10, 10, 10),
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: allocator)

        do {
            let mtkMesh = try MTKMesh(mesh: mdlMesh, device: device)
            let mtkVertexBuffer = mtkMesh.vertexBuffers[0]
            let submesh = mtkMesh.submeshes[0]
            let mtkIndexBuffer = submesh.indexBuffer

            vertexBuffer = mtkVertexBuffer.buffer
            vertexBuffer.label = "Mesh Vertices"

            vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)!
            primitiveType = submesh.primitiveType
            indexBuffer = mtkIndexBuffer.buffer
            indexBuffer.label = "Mesh Indices"

            indexCount = submesh.indexCount
            indexType = submesh.indexType
        } catch _ {
            return nil // Unable to create MTK mesh from MDL mesh
        }
    }
}

