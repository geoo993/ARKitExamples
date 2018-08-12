//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
// https://academy.realm.io/posts/3d-graphics-metal-swift/
// 

import MetalKit

class Renderer: NSObject {
    let device: MTLDevice

    // the commandQueue is just a serial queue that dispatches work to the gpu in an organised manner
    // becase the gpu is going to be busy with a bunch of different tasks on the system
    // and in order for your work to get on to the gpu and run, it need tombe submitted through a this
    // commandQueue, and you would summit your work using command encoders.
    // you can submit to command queue across multiple threads, it is and inherently thread safe object
    //
    let commandQueue: MTLCommandQueue

    // create device scene
    let scene: Scene

    //MARK: - initialise the Renderer with a device
    init(mtkView: MTKView, scene: Scene) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the MTKView and Device
        self.device = mtkView.device!

        //2) Create a command Queue
        // The command queue stores a sequence of command buffers, which we will create and write GPU commands into.
        // Commands consist of things like state-setting operations (which describe how things should be drawn and what
        // resources they should be drawn with) as well as draw calls, which tell the GPU to actually draw geometry,
        // causing our vertex and fragment functions to be called and producing the pixels that wind up on the screen.
        self.commandQueue = device.makeCommandQueue()!

        self.scene = scene

        // set the scene
        super.init()

    }

}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(to: size.half)
    }

    // MARK: - Draw object
    func draw(in view: MTKView) {
        //1) The MTKView view has a drawable, which is not an object that is displayed in the screen and
        // we issue our drawing command to this drawable.
        // The MTKView also has a render pass descriptor, which describes how the buffers are to be rendered,
        // we use this descriptor to create the command encoder.
        // Metla uses descriptor to setup Metal objects.
        // descriptors are like blueprints, a descriptor allows you to set requirement and spec about your object
        // when you setup a descriptor, you are setting up the list of properties you want your object to have.
        // then you create your object from that descriptor, if you subsequently change the desciptor properties,
        // you're only changing the list and not the original object.
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
           // let pipelineState = self.pipelineState
            //let indexBuffer = self.indexBuffer
            else { return }


        //2) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!

        //3) Encode all the commands
        // the command encoder is the thing that translates form humaan to gpu speak.
        // you might say draw this triangle, and that get taken by the command encoder and write
        // in byte code in a compressed format,
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.label = "Primary Render Encoder"


        let deltaTime = 1 / Float(view.preferredFramesPerSecond)

        // set the scene
        scene.time += 1 / Float(view.preferredFramesPerSecond)
        scene.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        
        // Once we’re done drawing, we need to call endEncoding() on our render command encoder to end the pass—and the frame:
        // Ending encoding signifies that we won’t be doing any more drawing with this render command encoder. If we wanted to draw additional objects, we would need to do that before calling endEncoding.
        commandEncoder.endEncoding()

        // In order to get our rendered content on the screen, we have to expressly present the drawable
        // whose texture we’ve be drawing into. We do this with a call on the command buffer, rather than the command encoder:
        commandBuffer.present(drawable)

        //4) send command buffer to the GPU when you finish encoding all the commands
        // Once we’re done encoding commands into the command buffer, we commit it,
        // so its queue knows that it should ship the commands over to the GPU.
        commandBuffer.commit()

    }
}
