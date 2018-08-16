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

// https://stackoverflow.com/questions/50557224/metal-emulate-geometry-shaders-using-compute-shaders
vertex VertexOut vertex_porcupine_shader(device Vertex *vertices  [[ buffer(BufferIndexMeshVertices) ]],
                                        // device const uint *indexes [[buffer(BufferIndexMeshIndices)]],
                                         constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                         uint vertexId [[vertex_id]],
                                         uint instanceId [[instance_id]]) {
    VertexOut vertexOut;

    
    //const uint triangle_id = vertexId / 3;
    //const uint vertex_of_triangle = vertexId % 3;

    // indexes is for a triangle strip even though this shader is invoked for a triangle list.
    //const uint index[3] = { indexes[triangle_id], indexes[triangle_id + 1], indexes[triangle_id + 2] };
    //const Vertex vert[3] = { vertexes[index[0]], vertexes[index[1]], vertexes[index[2]] };

    /*
    //float3 p = abs(cross(vert[1].position - vert[0].position, vert[2].position - vert[0].position));

    vertexOut.position = float4(vert[vertex_of_triangle].position, 1);
    vertexOut.normal = vert[vertex_of_triangle].normal;
    vertexOut.textureCoordinates = vert[vertex_of_triangle].texture;
    */

    Uniform uniform = instanceUniforms[instanceId].uniform;
    MaterialInfo material = instanceUniforms[instanceId].material;

    // Make position a float4 to perform 4x4 matrix math on it
    float3 inPosition = vertices[vertexId].position;
    float4 position = float4(inPosition.x, inPosition.y, inPosition.z, 1.0f);
    //float2 texture =  vertices[vertexId].texture;
    //float3 normal = vertices[vertexId].normal;

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = projectionMatrix * modelViewMatrix * position;
    //vertexOut.textureCoordinates = texture;

    /*
    vertexOut.color = material.color;
    vertexOut.useTexture = material.useTexture;
    vertexOut.shininess = material.shininess;

    vertexOut.fragPosition = (modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = normalMatrix * normal; // model world normal in the scene
    vertexOut.eyePosition = (modelViewMatrix * position);
    vertexOut.eyeNormal  = modelViewMatrix * float4(normal.x, normal.y, normal.z, 0.0f);
*/
    return vertexOut;
}

fragment float4 fragment_porcupine_shader(VertexOut fragmentIn [[ stage_in ]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexBaseMap) ]],
                                          sampler sampler2d [[sampler(SamplerIndexMain)]])
{

    return float4(1.0, 0.0, 1.0, 1.0);
}
