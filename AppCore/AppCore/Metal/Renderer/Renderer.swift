//
//  Renderer.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 25/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
// https://academy.realm.io/posts/3d-graphics-metal-swift/
// 

import Metal
import MetalKit
import ARKit

public class Renderer: NSObject {
    let session: ARSession
    let bundle: Bundle
    let device: MTLDevice
    var renderDestination: RenderDestinationProvider

    // the commandQueue is just a serial queue that dispatches work to the gpu in an organised manner
    // becase the gpu is going to be busy with a bunch of different tasks on the system
    // and in order for your work to get on to the gpu and run, it need tombe submitted through a this
    // commandQueue, and you would summit your work using command encoders.
    // you can submit to command queue across multiple threads, it is and inherently thread safe object
    //
    let commandQueue: MTLCommandQueue

    // create device scene
    public var scene: Scene!

    // The max number of command buffers in flight
    let kMaxBuffersInFlight: Int = 3

    //MARK: - initialise the Renderer with a device
    public init(mtkView: MTKView, session: ARSession,
                bundle: Bundle, renderDestination: RenderDestinationProvider) {
        //⚠️ there should only be one device and one command queue per application

        //1) Create a reference to the GPU, which is the MTKView and Device
        self.device = mtkView.device!

        //2) Create a command Queue
        // The command queue stores a sequence of command buffers, which we will create and write GPU commands into.
        // Commands consist of things like state-setting operations (which describe how things should be drawn and what
        // resources they should be drawn with) as well as draw calls, which tell the GPU to actually draw geometry,
        // causing our vertex and fragment functions to be called and producing the pixels that wind up on the screen.
        self.commandQueue = device.makeCommandQueue()!

        //self.scene = scene

        self.session = session

        self.bundle = bundle

        self.renderDestination = renderDestination

        // set the scene
        super.init()

        // we need to tell Metal to store the depth of each fragment as we process it,
        // keeping the closest depth value and only replacing it if we see a fragment that is closer to the camera.
        // This is called depth buffering, and fortunately, it’s not too hard to configure.
        // Depth buffering requires the use of an additional texture called, naturally, the depth buffer.
        // This texture is a lot like the color texture we’re already presenting to the screen when we’re done drawing,
        // but instead of storing color, it stores depth, which is basically the distance from the camera to the surface.
        self.renderDestination.depthStencilPixelFormat = .depth32Float_stencil8

        // we need to tell the view the format of the color texture we will be drawing to. We will choose bgra8Unorm, which is a format that uses one byte per color channel (red, green, blue, and alpha (transparency)), laid out in blue, green, red, alpha order. The Unorm portion of the name signifies that the components are stored as unsigned 8-bit values, so that the values 0-255 map to 0-100% intensity (or 0-100% opacity, in the case of the alpha channel).
        self.renderDestination.colorPixelFormat = .bgra8Unorm_srgb
        self.renderDestination.sampleCount = 1
    }


}

extension Renderer: MTKViewDelegate {

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let scene = self.scene else {
            fatalError("A scene was not set")
        }
        scene.sceneSizeWillChange(to: size.half)
    }

    // MARK: - Draw object
    public func draw(in view: MTKView) {
        if scene == nil {
            fatalError("A scene was not set")
        }

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
            let descriptor = view.currentRenderPassDescriptor,
            let currentFrame = session.currentFrame
            else { return }


        //2) Create a command buffer to hold the command encoder
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "Main Command buffer"

        //3) Encode all the commands
        // the command encoder is the thing that translates form humaan to gpu speak.
        // you might say draw this triangle, and that get taken by the command encoder and write
        // in byte code in a compressed format,
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.label = "Primary Render Encoder"


        let deltaTime = 1 / Float(view.preferredFramesPerSecond)

        // set the scene
        scene.time += 1 / Float(view.preferredFramesPerSecond)
        scene.render(commandEncoder: commandEncoder, deltaTime: deltaTime, frame: currentFrame)
        
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
