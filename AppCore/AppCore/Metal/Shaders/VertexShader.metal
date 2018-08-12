//
//  VertexInOut.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 28/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//


// --------- What Are Shaders --------
// Shaders are small programs that run on the GPU.
// We use the term shader because of history.
// In the openGL pipeline shaders are used to control the shading.
// Now days we are able to program the shader in the pipeline and do a lot more than just shading.
// but the term shader is convenient to generically describe these GPU programs.
// There are three types of shader functions, and we use two of the shader functions in the graphics pipeline.
// 1- The vertex function, where we can manipulate the vertices jand their positions (graphics function)
// 2- The fragment function, where we can manipulate pixel colors (graphics function)
// 3- The kernel function, is used for parallel programming and operates on a grid or an array of data
// the graphics shader function created in the .metal file use Metal Shading Language.
// When we compile the project Xcode compiles thes .metal files into a special defualt library file.
// So unlike OpenGL, all our shader functions are compiled before the App even opens.


#include <metal_stdlib>
#include "Shader.h"
using namespace metal;


// --------- Vertex Shader --------
// this is a vertex function so we prefix it with vertex and we are going to
// return a float4 for the position of the vertex.
// The vertex function job is to position vertex in 3d space
// the parameters are the vertices array that you created in the Renderer,
// and the vertexId is the current vertex being processed on the GPU.
// here we could do all sorts of maths to change the position of the vertex.
// the output of this function is the input of the next stage in the pipeline.
// The GPU assembles the vertices into triagle primitives and the rasterizer
// then takes over and splits our triangle into fragments.

/*
 vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
 uint vertexId [[ vertex_id ]]) {
 return float4(vertices[vertexId], 1);
 }
 */

// we add the constants in the parameters to send data to the GPU, we give the constant the attribute
// buffer 1 which is the buffer number that we allocated in the Renderer
/*
 vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]],
 constant Constants &constants [[ buffer(1) ]],
 uint vertexId [[ vertex_id ]]) {

 float4 position = float4(vertices[vertexId], 1);
 position.x += constants.animateBy;

 return position;
 }
 */

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]],
                               constant Constants &constants [[ buffer(BufferIndexConstants) ]],
                               constant Uniform &uniform [[ buffer(BufferIndexUniforms) ]]) {
    VertexOut vertexOut;

    // there are three types of coordinate systems that are commoly defined
    // there is the model space (position of the vertices relative to the model),
    // world space (usually known as world position or fragment position in the scene)
    // and one more intermediate coordinate space that we need to move through
    // (variously called “eye space,” “view space,” or “camera space”)

    // Transform the vertex spatial position using
    float4 position = float4(vertexIn.position, 1.0f); // model local vertex postion
    float4x4 modelViewMatrix = uniform.viewMatrix * uniform.modelMatrix;

    // This moves the vertex position from model space to clip space, which is needed by the next stages of the pipeline
    vertexOut.position = uniform.projectionMatrix * modelViewMatrix * position; // // clip-space position
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;
    vertexOut.fragPosition = (uniform.modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = uniform.normalMatrix * vertexIn.normal; // model world normal in the scene

    // we multiply the object normal by just the model-view matrix, which leaves it in eye space.
    // We do this because we will want to calculate things like lighting and reflections in eye space instead of model space.
    // For the same reason, we also compute the eye space position of the vertex.
    vertexOut.eyePosition = modelViewMatrix * position; // eye position, relative to the camera
    vertexOut.eyeNormal = modelViewMatrix * float4(vertexIn.normal, 0);

    return vertexOut;
}

// vertex function for instances
vertex VertexOut vertex_instance_shader(const VertexIn vertexIn [[ stage_in ]],
                                        constant Constants &constants [[ buffer(BufferIndexConstants) ]],
                                        constant InstanceInfo *instances [[ buffer(BufferIndexInstances) ]],
                                        uint instanceId [[ instance_id ]]) {
    Uniform uniform = instances[instanceId].uniform;
    MaterialInfo material = instances[instanceId].material;

    VertexOut vertexOut;

    // Transform the vertex spatial position using
    float4 position = float4(vertexIn.position, 1.0); // model local vertex postion
    float4x4 modelViewMatrix = uniform.viewMatrix * uniform.modelMatrix;

    // This moves the vertex position from model space to clip space, which is needed by the next stages of the pipeline
    vertexOut.position = uniform.projectionMatrix * modelViewMatrix * position; // // clip-space position
    vertexOut.color = material.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;
    vertexOut.fragPosition = (uniform.modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = uniform.normalMatrix * vertexIn.normal; // model world normal in the scene

    // we multiply the object normal by just the model-view matrix, which leaves it in eye space.
    // We do this because we will want to calculate things like lighting and reflections in eye space instead of model space.
    // For the same reason, we also compute the eye space position of the vertex.
    vertexOut.eyePosition = modelViewMatrix * position; // eye position, relative to the camera
    vertexOut.eyeNormal = modelViewMatrix * float4(vertexIn.normal, 0);

    return vertexOut;
}


