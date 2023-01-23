
import MetalKit
import ARKit

open class Node {
    public var name = "Untitled"
    public var uuid = "Untitled"
    weak var parent: Node?
    public var children: [Node] = []
    public var position = SIMD3<Float>(repeating: 0)
    public var rotation = SIMD3<Float>(repeating: 0)
    public var scale = SIMD3<Float>(repeating: 1)
    public var material = MaterialInfo()
    public var overrideModelMatrix = false

    public var modelMatrix: matrix_float4x4 {
        var matrix = matrix_float4x4(translationX: position.x, y: position.y, z: position.z)
        matrix = matrix.rotatedBy(rotationAngle: rotation.x.toRadians, x: 1, y: 0, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.y.toRadians, x: 0, y: 1, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.z.toRadians, x: 0, y: 0, z: 1)
        matrix = matrix.scaledBy(x: scale.x, y: scale.y, z: scale.z)
        return matrix
    }

    public init(name: String) {
        self.name = name
    }
    
    public func add(childNode: Node) {
        children.append(childNode)
    }

    public func get(childNode name: String) -> Node? {
        for node in children {
            if node.name == name {
                return node
            } else if let matchingGrandchild = node.get(childNode: name) {
                return matchingGrandchild
            }
        }
        return nil
    }

    func render(commandBuffer: MTLCommandBuffer,
                commandEncoder: MTLRenderCommandEncoder,
                parentModelMatrix: matrix_float4x4,
                camera: Camera, renderUniform: RenderUniformProvider) {

        let originAndModel = matrix_multiply(parentModelMatrix, modelMatrix)
        for child in children {
            child.render(commandBuffer: commandBuffer,
                         commandEncoder: commandEncoder,
                         parentModelMatrix: originAndModel,
                         camera: camera, renderUniform: renderUniform)
        }
        
        if let renderable = self as? Renderable {
            commandEncoder.pushDebugGroup(name)
            renderable.doRender(commandBuffer: commandBuffer,
                                commandEncoder: commandEncoder,
                                camera: camera, renderUniform: renderUniform)
            commandEncoder.popDebugGroup()
        }

    }
}
