

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

        for direction in directionalLightsDirections {
            var base = BaseLight()
            base.color = float3(1, 1, 1)
            base.intensity = 0
            base.ambient = 0.5
            base.diffuse = 0.4
            base.specular = 0.5
            let directionalLight = DirectionalLight(base: base, direction: direction)
            dirLights.append(directionalLight)
        }

    }

    override public func update(deltaTime: Float) {
        super.update(deltaTime: deltaTime)

        if let frame = session.currentFrame {
            var ambientIntensity: Float = 1.0

            if let lightEstimate = frame.lightEstimate {
                ambientIntensity = Float(lightEstimate.ambientIntensity) / 1000.0
            }

            for i in 0..<dirLights.count {
                dirLights[i].direction = frame.camera.transform.back
                dirLights[i].base.color = float3(0.6, 0.6, 0.6)
                dirLights[i].base.intensity = ambientIntensity
            }
        }
    }

    public override func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        guard let mtkView = view as? MTKView  else { return }

        /*
        let mushroom = Model(mtkView: mtkView, renderDestination: mtkView, model: [ObjectType.model: "mushroom"],
                             imageName: "mushroom.png", vertexShader: .vertex_porcupine_shader, fragmentShader: .fragment_porcupine_shader)
        mushroom.position = float3(0, 0, -0.2) // Create a transform with a translation of 0.2 meters in front of the camera
        mushroom.scale = float3(0.01, 0.01, 0.01)
        //mushroom.rotation = float3(20, 0, 0)
        let rand = UIColor.random
        mushroom.material.color = float4(rand.redValue.toFloat, rand.greenValue.toFloat, rand.blueValue.toFloat, 1)
        mushroom.material.shininess = 32
        mushroom.material.useTexture = true
        add(childNode: mushroom)
         */

        let fireball = Model(mtkView: mtkView, renderDestination: mtkView, model: [ObjectType.sphere: "Sphere"],
                           imageName: "explosion.png", vertexShader: .vertex_fireball_shader,
                           fragmentShader: .fragment_fireball_shader)
        fireball.material.useTexture = true
        fireball.scale = float3(0.1, 0.1, 0.1)
        fireball.material.color = float4(0, 1, 0, 1)
        fireball.material.shininess = 32
        add(childNode: fireball)

        /*
        let box = Model(mtkView: mtkView, renderDestination: mtkView,
                        model: [ObjectType.cube: "Box"],
                        imageName: "checkerboard",
                        vertexShader: .vertex_porcupine_shader,
                        fragmentShader: .fragment_porcupine_shader)
        box.material.useTexture = true
        box.scale = float3(0.1, 0.1, 0.1)
        box.material.color = float4(1, 1, 0, 1)
        box.material.shininess = 32
        add(childNode: box)
        */
    }

    public override func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {
        //guard let touch = touches.first else { return }
        //let touchLocation = touch.location(in: view)
    }

}

