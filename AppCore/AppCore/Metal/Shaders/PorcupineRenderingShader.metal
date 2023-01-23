//
//  PorcupineRenderingShader.metal
//  AppCore
//
//  Created by GEORGE QUENTIN on 15/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "Shader.h"
using namespace metal;

// --------- Vertex Data --------
// Structure defining the layout of each vertex.  Shared between C code filling in the vertex data
//   and Metal vertex shader consuming the vertices
// The Vertex struct defines the layout and memory of each vertex in a vertex array passes into a vertex_shader
struct Vertex
{
    float3 position;
    half3 normal;
    float2 textureCoordinate;
};

// --------- Materials Argument Buffer --------
struct Material
{
    vector_float4 color;
    texture2d<float> surfaceTexture;
    texture2d<float> specularTexture;
    sampler textureSampler;
    float intensity; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    float roughness;
    bool useTexture;
};

// https://stackoverflow.com/questions/50557224/metal-emulate-geometry-shaders-using-compute-shaders
vertex VertexOut vertex_porcupine_shader(device Vertex *vertices  [[ buffer(BufferIndexMeshVertices) ]],
                                        // device const uint *indexes [[buffer(BufferIndexMeshIndices)]],
                                         constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                         uint vertexId [[vertex_id]],
                                         uint instanceId [[instance_id]]) {
    VertexOut vertexOut;

    Uniform uniform = instanceUniforms[instanceId].uniform;
    MaterialInfo material = instanceUniforms[instanceId].material;

    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(vertices[vertexId].position.x, vertices[vertexId].position.y, vertices[vertexId].position.z, 1.0f);
    //float3 normal = SIMD3<Float>(vertices[vertexId].normal.x, vertices[vertexId].normal.y, vertices[vertexId].normal.z);
    float2 texture =  vertices[vertexId].textureCoordinate;

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    //float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 viewMatrix = uniform.viewMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = projectionMatrix * viewMatrix * modelMatrix * position;
    vertexOut.textureCoordinate = texture;

    vertexOut.color = material.color;
    vertexOut.useTexture = material.useTexture;
    vertexOut.shininess = material.shininess;

    vertexOut.fragPosition = (modelMatrix * position).xyz; // model world position in the scene
    //vertexOut.normal = normalMatrix * normal; // model world normal in the scene
    vertexOut.eyePosition = (viewMatrix * modelMatrix * position);
    //vertexOut.eyeNormal = viewMatrix * modelMatrix * float4(normal.x, normal.y, normal.z, 0.0f);
    return vertexOut;
}

fragment float4 fragment_porcupine_shader(VertexOut fragmentIn [[ stage_in ]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexBaseMap) ]],
                                          sampler sampler2d [[sampler(SamplerIndexMain)]])
{
    return texture.sample(sampler2d, fragmentIn.textureCoordinate);
}
