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
                                      //constant Uniform &sharedUniform [[ buffer(BufferIndexUniforms) ]],
                                      constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                      ushort vertexId [[vertex_id]],
                                      ushort instanceId [[instance_id]]) {
    VertexOut vertexOut;

    Uniform uniform = instanceUniforms[instanceId].uniform;
    MaterialInfo material = instanceUniforms[instanceId].material;

    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(vertexIn.position.x, vertexIn.position.y, vertexIn.position.z, 1.0f);

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = projectionMatrix * modelViewMatrix * position;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    vertexOut.color = material.color;

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
