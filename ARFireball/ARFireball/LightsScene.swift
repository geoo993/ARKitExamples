

import MetalKit
import ARKit
import AppCore

public final class LightsScene: Scene {

    override init(mtkView: MTKView, session: ARSession, camera: Camera) {
        super.init(mtkView: mtkView, session: session, camera: camera)

    }

    override public func setup(view: MTKView) {
        super.setup(view: view)
        self.name = "Lights scene"

    }

    override public func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

    }

    public override func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let mtkView = view as? MTKView  else { return }

        /*
        let mushroom = Model(mtkView: mtkView, renderDestination: mtkView, modelName: "mushroom",
                             imageName: "mushroom.png", fragmentShader: .fragment_anchor_shader)
        mushroom.name = "Mushroom"
        mushroom.position = float3(0, 0, -0.2) // Create a transform with a translation of 0.2 meters in front of the camera
        mushroom.scale = float3(0.01, 0.01, 0.01)
        //mushroom.rotation = float3(20, 0, 0)
        add(childNode: mushroom)
 */
        
    }

    public override func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        //guard let touch = touches.first else { return }
        //let touchLocation = touch.location(in: view)
    }

}

