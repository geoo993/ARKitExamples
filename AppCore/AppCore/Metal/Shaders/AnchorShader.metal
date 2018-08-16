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
                                      device Vertex *vertexes  [[ buffer(BufferIndexMeshVertices) ]],
                                      constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                      ushort vertexId [[vertex_id]],
                                      ushort instanceId [[instance_id]]) {
    VertexOut vertexOut;

    Uniform uniform = instanceUniforms[instanceId].uniform;
    MaterialInfo material = instanceUniforms[instanceId].material;

    // Make position a float4 to perform 4x4 matrix math on it
    float3 pos =  vertexIn.position; //vertexes[vertexId].position;
    float4 position = float4(pos.x, pos.y, pos.z, 1.0f);
    float2 texture = vertexIn.textureCoordinates;
    float3 normal = vertexIn.normal;

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = projectionMatrix * modelViewMatrix * position;
    vertexOut.textureCoordinates = texture;

    vertexOut.color = material.color;
    vertexOut.useTexture = material.useTexture;
    vertexOut.shininess = material.shininess;

    vertexOut.fragPosition = (modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = normalMatrix * normal; // model world normal in the scene
    vertexOut.eyePosition = (modelViewMatrix * position);
    vertexOut.eyeNormal  = modelViewMatrix * float4(normal.x, normal.y, normal.z, 0.0f);

    return vertexOut;
}

// Anchor geometry fragment function
fragment float4 fragment_anchor_shader(VertexOut fragmentIn [[stage_in]],
                                       device DirectionalLight *dirLights [[buffer(BufferIndexDirectionalLightInfo)]],
                                       texture2d<float> texture [[ texture(TextureIndexBaseMap) ]],
                                       sampler sampler2d [[ sampler(SamplerIndexMain) ]]) {
    float4 texColor = texture.sample(sampler2d, fragmentIn.textureCoordinates);
    float4 materialColor = fragmentIn.useTexture ? texColor : fragmentIn.color;
    DirectionalLight light = dirLights[0];
    float3 lightColor = light.base.color * light.base.intensity;
    float3 normal = float3(fragmentIn.normal);

    // Calculate the contribution of the directional light as a sum of diffuse and specular terms
    float3 directionalContribution = float3(0);
    {
        // Light falls off based on how closely aligned the surface normal is to the light direction
        float nDotL = saturate(dot(normal, -light.direction));

        // The diffuse term is then the product of the light color, the surface material
        // reflectance, and the falloff
        float3 diffuseTerm = lightColor * nDotL;

        // Apply specular lighting...

        // 1) Calculate the halfway vector between the light direction and the direction they eye is looking
        float3 halfwayVector = normalize(-light.direction - float3(fragmentIn.eyePosition));

        // 2) Calculate the reflection angle between our reflection vector and the eye's direction
        float reflectionAngle = saturate(dot(normal, halfwayVector));

        // 3) Calculate the specular intensity by multiplying our reflection angle with our object's
        //    shininess
        float specularIntensity = saturate(powr(reflectionAngle, fragmentIn.shininess));

        // 4) Obtain the specular term by multiplying the intensity by our light's color
        float3 specularTerm = lightColor * specularIntensity;

        // Calculate total contribution from this light is the sum of the diffuse and specular values
        directionalContribution = diffuseTerm + specularTerm;
    }

    // The ambient contribution, which is an approximation for global, indirect lighting, is
    // the product of the ambient light intensity multiplied by the material's reflectance
    float3 ambientContribution = light.base.ambient * light.base.intensity;

    // Now that we have the contributions our light sources in the scene, we sum them together
    // to get the fragment's lighting value
    float3 lightContributions = ambientContribution + directionalContribution;

    // We compute the final color by multiplying the sample from our color maps by the fragment's
    // lighting value
    float3 color = materialColor.rgb * lightContributions;

    // We use the color we just computed and the alpha channel of our
    // colorMap for this fragment's alpha value
    return float4(color, materialColor.w);
}

