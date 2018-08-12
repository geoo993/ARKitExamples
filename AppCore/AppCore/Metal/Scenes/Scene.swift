import MetalKit

class Scene: Node {
    
    var rootNode: Node!
    var camera: Camera!
    var time: Float = 0

    private let sceneOrigin = matrix_identity_float4x4

    init(mtkView: MTKView, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        super.init(name: "Untitled")
        rootNode = Node(name: "Root")
        add(childNode: rootNode)
        self.camera = camera
        setup(view: mtkView)
    }

    override func add(childNode: Node) {
        super.add(childNode: childNode)
    }

    func setup(view: MTKView) {

    }

    func update(deltaTime: Float) {
        
    }

    func sceneSizeWillChange(to size: CGSize) {
        camera.setPerspectiveProjectionMatrix(screenSize: size)
    }

    func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    func touchesCancelled(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}

    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)


        // fire ball edge
        //var fireBallConstant = FireBallConstants(time: time * 0.2, frequency: fireBallFreq, explosion: fireBallExplo)
        //commandEncoder.setVertexBytes(&fireBallConstant, length: MemoryLayout<FireBallConstants>.stride,
        //                              index: BufferIndex.fireBall.rawValue)

        // Camera
        var cameraInfo = CameraInfo(position: camera.position, front: camera.front)
        commandEncoder.setFragmentBytes(&cameraInfo, length: MemoryLayout<CameraInfo>.stride,
                                        index: BufferIndex.cameraInfo.rawValue)
        for child in children {
            child.render(commandEncoder: commandEncoder,
                         parentModelMatrix: sceneOrigin,
                         camera: camera)
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
