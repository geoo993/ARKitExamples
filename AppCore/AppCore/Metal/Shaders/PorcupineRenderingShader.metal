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


// Anchor geometry vertex function
vertex VertexOut vertex_porcupine_shader(device Vertex * vertexIn  [[ buffer(BufferIndexVertices) ]],
                                         constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                         ushort vertexId [[vertex_id]],
                                         ushort instanceId [[instance_id]]) {
    VertexOut vertexOut;

    Uniform uniform = instanceUniforms[instanceId].uniform;
    //MaterialInfo material = instanceUniforms[instanceId].material;

    // Make position a float4 to perform 4x4 matrix math on it
    float3 inPosition = vertexIn[vertexId].position;
    float4 position = float4(inPosition.x, inPosition.y, inPosition.z, 1.0f);

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    //float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    vertexOut.position = projectionMatrix * modelViewMatrix * position;
    vertexOut.textureCoordinates = vertexIn[vertexId].texture;

    return vertexOut;
}

// gives us the interpolated texture coordinates
fragment float4 fragment_porcupine_shader(VertexOut vertexIn [[ stage_in ]],
                                          constant Uniform &uniform [[ buffer(BufferIndexUniforms) ]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexBaseMap) ]],
                                          sampler sampler2d [[sampler(SamplerIndexMain)]])
{

    return float4(1.0, 1.0, 1.0, 1.0);
}
