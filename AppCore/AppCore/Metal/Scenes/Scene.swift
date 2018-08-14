import MetalKit
import ARKit

open class Scene: Node {
    
    public var camera: Camera!
    public var session: ARSession!
    public var time: Float = 0

    private let sceneOrigin = matrix_identity_float4x4

    public init(mtkView: MTKView, session: ARSession, camera: Camera) {

        //1) Create a reference to the GPU, which is the Device
        super.init(name: "Untitled")
        self.session = session
        self.camera = camera
        setup(view: mtkView)
    }

    override public func add(childNode: Node) {
        super.add(childNode: childNode)
        if let currentFrame = session.currentFrame {
            let currnetOrigin = currentFrame.camera.transform
            let transform = simd_mul(currnetOrigin, childNode.modelMatrix)

            let anchor = ARAnchor(transform: transform)
            session.add(anchor: anchor)
        }
    }

    open func setup(view: MTKView) {

    }

    open func update(deltaTime: Float) {
        
    }

    open func sceneSizeWillChange(to size: CGSize) {
        camera.setPerspectiveProjectionMatrix(screenSize: size)
    }

    open func touchesBegan(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesMoved(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesEnded(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}
    open func touchesCancelled(_ view: UIView, touches: Set<UITouch>, with event: UIEvent?) {}

    func render(commandBuffer: MTLCommandBuffer, commandEncoder: MTLRenderCommandEncoder,
                renderUniform: RenderUniformProvider, frame: ARFrame, deltaTime: Float) {
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
                         camera: camera, renderUniform: renderUniform)
        }
    }


}
