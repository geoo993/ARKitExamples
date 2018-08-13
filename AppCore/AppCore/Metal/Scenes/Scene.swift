import MetalKit
import ARKit

open class Scene: Node {
    
    var rootNode: Node!
    var camera: Camera!
    var time: Float = 0

    private let sceneOrigin = matrix_identity_float4x4

    public init(mtkView: MTKView, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        super.init(name: "Untitled")
        rootNode = Node(name: "Root")
        add(childNode: rootNode)
        self.camera = camera
        setup(view: mtkView)
    }

    override public func add(childNode: Node) {
        super.add(childNode: childNode)
    }

    open func setup(view: MTKView) {

    }

    open func update(deltaTime: Float) {
        
    }

    open func sceneSizeWillChange(to size: CGSize) {
        camera.setPerspectiveProjectionMatrix(screenSize: size)
    }

    func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesCancelled(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}

    func render(commandBuffer: MTLCommandBuffer, commandEncoder: MTLRenderCommandEncoder, deltaTime: Float, frame: ARFrame) {
        update(deltaTime: deltaTime)

        let view = frame.camera.viewMatrix(for: .landscapeRight)
        camera.setViewMatrix(matrix: view)
        camera.setPerspectiveProjectionMatrix(frame: frame, orientation: .landscapeRight)

        // fire ball edge
        //var fireBallConstant = FireBallConstants(time: time * 0.2, frequency: fireBallFreq, explosion: fireBallExplo)
        //commandEncoder.setVertexBytes(&fireBallConstant, length: MemoryLayout<FireBallConstants>.stride,
        //                              index: BufferIndex.fireBall.rawValue)

        // Camera
        /*
        var cameraInfo = CameraInfo(position: camera.position, front: camera.front)
        commandEncoder.setFragmentBytes(&cameraInfo, length: MemoryLayout<CameraInfo>.stride,
                                        index: BufferIndex.cameraInfo.rawValue)
        */
        for child in children {
            child.render(commandBuffer: commandBuffer, commandEncoder: commandEncoder,
                         parentModelMatrix: sceneOrigin,
                         camera: camera, frame: frame)
        }
    }

    func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.get(childNode: name)
        }
    }

}
