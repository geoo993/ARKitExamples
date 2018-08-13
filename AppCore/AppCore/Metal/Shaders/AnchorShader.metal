//
//  Shaders.metal
//  ARFireball
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>

// Include header shared between this Metal shader code and C code executing Metal API commands
#include "Shader.h"

// Anchor geometry vertex function
vertex VertexOut vertex_anchor_shader(const VertexIn vertexIn [[stage_in]],
                                      constant Uniform &uniform [[ buffer(BufferIndexUniforms) ]],
                                      constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                      ushort vertexId [[vertex_id]],
                                      ushort instanceId [[instance_id]]) {
    VertexOut vertexOut;

    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(vertexIn.position.x, vertexIn.position.y, vertexIn.position.z, 1.0f);

    float4x4 modelMatrix = instanceUniforms[instanceId].modelMatrix;
    float3x3 normalMatrix = instanceUniforms[instanceId].normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = uniform.projectionMatrix * modelViewMatrix * position;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    // Color each face a different color
    ushort colorID = vertexId / 4 % 6;
    vertexOut.color = colorID == 0 ? float4(0.0, 1.0, 0.0, 1.0) // Right face
    : colorID == 1 ? float4(1.0, 0.0, 0.0, 1.0) // Left face
    : colorID == 2 ? float4(0.0, 0.0, 1.0, 1.0) // Top face
    : colorID == 3 ? float4(1.0, 0.5, 0.0, 1.0) // Bottom face
    : colorID == 4 ? float4(1.0, 1.0, 0.0, 1.0) // Back face
    : float4(1.0, 1.0, 1.0, 1.0); // Front face

    vertexOut.fragPosition = (modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = normalMatrix * vertexIn.normal; // model world normal in the scene
    vertexOut.eyePosition = (modelViewMatrix * position);
    vertexOut.eyeNormal  = modelViewMatrix * float4(vertexIn.normal.x, vertexIn.normal.y, vertexIn.normal.z, 0.0f);

    return vertexOut;
}

// Anchor geometry fragment function
fragment float4 fragment_anchor_shader(VertexOut vertexIn [[stage_in]],
                                       texture2d<float> texture [[ texture(TextureIndexColor) ]],
                                       sampler sampler2d [[ sampler(0) ]]) {

    return texture.sample(sampler2d, vertexIn.textureCoordinates);
}
