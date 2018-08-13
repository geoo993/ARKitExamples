
import MetalKit
import ARKit

open class Node {
    public var name = "Untitled"
    weak var parent: Node?
    public var children: [Node] = []
    public var position = float3(0)
    public var rotation = float3(0)
    public var scale = float3(1)
    public var width: Float = 1
    public var height: Float = 1
    public var material = MaterialInfo()
    public var overrideModelMatrix = false

    private var makeModelMatrix: matrix_float4x4 {
        var matrix = matrix_float4x4(translationX: position.x,
                                     y: position.y, z: position.z)
        matrix = matrix.rotatedBy(rotationAngle: rotation.x,
                                  x: 1, y: 0, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.y,
                                  x: 0, y: 1, z: 0)
        matrix = matrix.rotatedBy(rotationAngle: rotation.z,
                                  x: 0, y: 0, z: 1)
        matrix = matrix.scaledBy(x: scale.x, y: scale.y, z: scale.z)
        return matrix
    }

    public var modelMatrix: matrix_float4x4!

    public init(name: String) {
        self.name = name
        self.modelMatrix = makeModelMatrix
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
                camera: Camera, frame: ARFrame) {
        if overrideModelMatrix == false {
            self.modelMatrix = makeModelMatrix
        }
        let originAndModel = matrix_multiply(parentModelMatrix, modelMatrix)
        for child in children {
            child.render(commandBuffer: commandBuffer,
                         commandEncoder: commandEncoder,
                         parentModelMatrix: originAndModel,
                         camera: camera, frame: frame)
        }

        if let renderable = self as? Renderable {
            commandEncoder.pushDebugGroup(name)
            renderable.doRender(commandBuffer: commandBuffer,
                                commandEncoder: commandEncoder,
                                modelMatrix: originAndModel,
                                camera: camera, currentFrame: frame)
            commandEncoder.popDebugGroup()
        }

    }
}
