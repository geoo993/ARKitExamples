//
//  Camera.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 30/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://developer.apple.com/library/archive/samplecode/AdoptingMetalII/Listings/ObjectsExample_Utils_swift.html

import MetalKit
import ARKit

public class Camera {

    var position: SIMD3<Float>       // The position of the camera's centre of projection
    private var rotation: SIMD3<Float>

    //view and projection matrix
    var perspectiveProjectionMatrix: matrix_float4x4 // Perspective projection matrix
    var orthographicProjectionMatrix: matrix_float4x4 // Orthographic projection matrix
    var viewMatrix: matrix_float4x4

    var view: SIMD3<Float> // The camera's viewpoint (point where the camera is looking)

    var strafe: SIMD3<Float>        // The camera's strafe vector

    var front: SIMD3<Float>               // The camera's forward vector
    var back: SIMD3<Float>                // The camera's backward vector
    var left: SIMD3<Float>               // The camera's left vector
    var right: SIMD3<Float>               // The camera's right vector
    var up: SIMD3<Float>                  // The camera's up vector
    var down: SIMD3<Float>                // The camera's down vector

    var worldUp: SIMD3<Float>            // The worlds up vector, the original position of the world

    // Eular Angles
    var fieldOfView: Float           // The view from the camera
    var nearPlane: Float
    var farPlane: Float
    var yaw: Float
    var pitch: Float

    // Camera options
    var speed: Float         // How fast the camera moves
    var sensitivity: Float      // How sensitive rotation is

    // Screen
    var screenSize: CGSize           // size of the screen window

    var viewportSizeDidChange: Bool = false

    public init(fov: Float, size: CGSize, zNear: Float, zFar: Float) {
        screenSize = size
        perspectiveProjectionMatrix = matrix_identity_float4x4
        orthographicProjectionMatrix = matrix_identity_float4x4
        viewMatrix = matrix_identity_float4x4
        view = SIMD3<Float>(repeating: 0.0)
        front = SIMD3<Float>(0.0, 0.0, -1.0)
        back = SIMD3<Float>(0.0, 0.0, 1.0)
        left = SIMD3<Float>(-1.0, 0.0, 0.0)
        right = SIMD3<Float>(1.0, 0.0, 0.0)
        up = SIMD3<Float>(0.0, 1.0, 0.0)
        down = SIMD3<Float>(0.0, -1.0, 0.0)
        worldUp = SIMD3<Float>( 0.0, 1.0, 0.0)
        pitch = 0.1
        yaw = -90
        fieldOfView = fov
        nearPlane = zNear
        farPlane = zFar
        strafe = SIMD3<Float>( 0.0, 0.0, 0.0)
        speed = 5.0 // between 0 and 1
        sensitivity = 0.6 // between 0 and 1
        screenSize = size
        position = SIMD3<Float>(repeating: 0)
        rotation = SIMD3<Float>(repeating: 0)

        setPerspectiveProjectionMatrix(fieldOfView: fov, aspectRatio: Float(screenSize.width / screenSize.height),
                                       nearClippingPlane: zNear, farClippingPlane: zFar)
        setOrthographicProjectionMatrix(width: Float(screenSize.width), height: Float(screenSize.height), zNear: zNear, zFar: zFar)

        updateCameraVectors()
    }


    // Calculates the front vector from the Camera's (updated) Eular Angles
    func updateCameraVectors()
    {

        back = normalize(front) * -1.0

        // Also re-calculate the Right and Up vector
        right = normalize(cross(front, worldUp))  // Normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
        left = normalize(right) * -1.0

        // Up vector : perpendicular to both direction and right
        up = normalize( cross(right, front ) )
        down = normalize(up) * -1.0

        view = position + front
        viewMatrix = lookAt(
            eye: position, // what position you want the camera to be at when looking at something in World Space
            center: view, // // what position you want the camera to be  looking at in World Space, meaning look at what(using vec3) ?  // meaning the camera view point
            up: up  //which direction is up, you can set to (0,-1,0) to look upside-down
        )

        // https://gamedev.stackexchange.com/questions/50963/how-to-extract-euler-angles-from-transformation-matrix

    }

    // Set the camera at a specific position, looking at the view point, with a given up vector
    func set(position: SIMD3<Float>, viewpoint: SIMD3<Float>, up: SIMD3<Float>) {
        self.position = position
        self.front = normalize(viewpoint - position) // finding front vector
        self.up = up
        self.worldUp = SIMD3<Float>( 0.0, 1.0, 0.0 )

        updateCameraVectors()
    }


    // Rotate the camera view point -- this effectively rotates the camera since it is looking at the view point
    func rotateViewPoint(angle: Float, axis: SIMD3<Float>) {

        let vView = view - position;// direction vector
        
        let rotation = rotate(m: matrix_identity_float4x4, angle: radians(degrees: angle), axis: axis)
        let newView = rotation * SIMD4<Float>(vView, 1)

        self.front = normalize(SIMD3<Float>(newView))

        updateCameraVectors()
    }

    func rotateAroundPoint(distance: Float, viewpoint: SIMD3<Float>, angle: Float, y: Float) {

        let radian = radians(degrees: angle)

        let camX = viewpoint.x + (distance * cosf(radian))
        let camY = y
        let camZ = viewpoint.z + (distance * sinf(radian))

        // Set the camera position and lookat point
        let position = SIMD3<Float>(camX, camY, camZ)   // Camera position
        let look = viewpoint // Look at point
        let upV = SIMD3<Float>(0.0, 1.0, 0.0) // Up vector

        set(position: position, viewpoint: look, up: upV);

    }

    func positionInFrontOfCamera(distance: Float) -> SIMD3<Float> {
        return position + front * distance
    }

    // Strafe the camera (side to side motion) (Left - Right Motion)
    func strafe(direction: Float)
    {
        position.x = position.x + strafe.x * direction;
        position.z = position.z + strafe.z * direction;

        updateCameraVectors();
    }

    // Advance the camera (forward / backward motion)
    func advance(direction: Float)
    {
        let forwardView = normalize(view - position)
        position = position + forwardView * direction

        updateCameraVectors()
    }

    // Update the camera for rotation
    func setRotation(angle: Float, displacement: Float, enabled: Bool) {
        if (enabled) {

            let horizontalAngle: Float = sin(angle.toRadians) * displacement * sensitivity
            let verticalAngle: Float = cos(angle.toRadians) * displacement * sensitivity

            //let axisX: Float = sin(verticalAngle) * sin(horizontalAngle)
            //let axisY = cos(verticalAngle)
            //let axisZ: Float = sin(verticalAngle) * cos(horizontalAngle)
            //print("angle:", angle, ", hori:", horizontalAngle, "vert:", verticalAngle, ", axis:", axisX, axisY, axisZ)


            //rotation.x = horizontalAngle

            let maxAngle: Float = 1.56 // Just a little bit below PI / 2

            if (horizontalAngle < maxAngle && horizontalAngle > -maxAngle) {
                let vPoint: SIMD3<Float> = cross(view - position, up)
                let axis: SIMD3<Float> = normalize(vPoint)
                rotateViewPoint(angle: -verticalAngle, axis: axis)
            }

            rotateViewPoint(angle: -horizontalAngle, axis: worldUp);

        }
    }

    // Update the camera for translation
    func setTranslation(deltaTime: Float, angle: Float, displacement: Float)
    {
        let vector = cross(view - position, up);
        strafe = normalize(vector);

        var isAdvancing = false

        if angle != 0 {
            // Going forward
            if (angle > 150 && angle < 180) || angle < -150 && angle > -180 {
                advance(direction: speed * deltaTime)
                isAdvancing = true
            }

            // Going backward
            if angle < 30 && angle > -30 {
                advance(direction: -speed * deltaTime)
                isAdvancing = true
            }

            // Going left
            if angle < 0 && angle > -180 && isAdvancing == false {
                strafe(direction: -speed * deltaTime)
            }

            // Going right
            if angle > 0 && angle < 180 && isAdvancing == false {
                strafe(direction: speed * deltaTime)
            }
        }
        updateCameraVectors()
    }


    func updateRotation(angle: Float, displacement: Float, enabled: Bool = true) {
        setRotation(angle: angle, displacement: displacement, enabled: enabled)
    }

    // Update the camera to respond to mouse motion for rotations and keyboard for translation
    func updateMovement(deltaTime: Float, angle: Float, displacement: Float) {
        setTranslation(deltaTime: deltaTime, angle: angle, displacement: displacement)
    }


    // Set the camera perspective projection matrix to produce a view frustum with a specific field of view, aspect ratio,
    // and near / far clipping planes
    func setPerspectiveProjectionMatrix(fieldOfView: Float, aspectRatio: Float, nearClippingPlane: Float, farClippingPlane: Float){
        self.fieldOfView = fieldOfView
        self.perspectiveProjectionMatrix = matrix_float4x4(projectionFov: radians(degrees: fieldOfView),
                                                           aspect: aspectRatio, nearZ: nearClippingPlane,
                                                           farZ: farClippingPlane)

    }

    func setPerspectiveProjectionMatrix(screenSize: CGSize){
        self.viewportSizeDidChange = true
        self.screenSize = screenSize
        self.perspectiveProjectionMatrix = matrix_float4x4(projectionFov: radians(degrees: fieldOfView),
                                                           aspect: Float(screenSize.width / screenSize.height),
                                                           nearZ: nearPlane,
                                                           farZ: farPlane)

    }

    func setPerspectiveProjectionMatrix(frame: ARFrame, orientation: UIInterfaceOrientation){
        self.perspectiveProjectionMatrix = frame.camera.projectionMatrix(for: orientation,
                                                                         viewportSize: screenSize, zNear: nearPlane.toCGFloat, zFar: farPlane.toCGFloat)

    }

    // The the camera orthographic projection matrix to match the width and height passed in
    func setOrthographicProjectionMatrix(width: Float, height: Float, zNear: Float, zFar: Float){
        orthographicProjectionMatrix = ortho(left: 0, right: width, bottom: 0, top: height, zNear: zNear, zFar: zFar)
    }

    func setOrthographicProjectionMatrix(value: Float, zNear: Float, zFar: Float)
    {
        orthographicProjectionMatrix = ortho(left: -value, right: value, bottom: -value, top: value, zNear: zNear, zFar: zFar)
    }


    // The normal matrix is used to transform normals to eye coordinates -- part of lighting calculations
    func computeNormalMatrix(modelMatrix: matrix_float4x4) -> matrix_float3x3
    {
        return modelMatrix.upperLeft3x3().transpose.inverse
    }

    func setViewMatrix(matrix: matrix_float4x4) {
        // http://larc.unt.edu/ian/classes/fall11/csce4215/notes/4%20Rotation.pdf
        // https://www.opengl.org/discussion_boards/showthread.php/175515-Get-Direction-from-Transformation-

        /*
         RT = right
         UP = up
         BK = back
         POS = position/translation
         US = uniform scale
         
        [0] [4] [8 ] [12]
        [1] [5] [9 ] [13]
        [2] [6] [10] [14]
        [3] [7] [11] [15]

        [RT.x] [UP.x] [BK.x] [POS.x]
        [RT.y] [UP.y] [BK.y] [POS.y]
        [RT.z] [UP.z] [BK.z] [POS.Z]
        [    ] [    ] [    ] [US   ]

        x [ m11 m12 m13 m14 ]
        y | m21 m22 m23 m24 |
        z | m31 m32 m33 m34 |
        w [ m41 m42 m43 m44 ]
        */

        back = matrix.back
        front = matrix.front

        up = matrix.up
        down = matrix.down

        right = matrix.right
        left = matrix.left

        position = matrix.position

        view = position + front
        viewMatrix = lookAt(
            eye: position, // what position you want the camera to be at when looking at something in World Space
            center: view, // // what position you want the camera to be  looking at in World Space, meaning look at what(using vec3) ?  // meaning the camera view point
            up: up  //which direction is up, you can set to (0,-1,0) to look upside-down
        )

    }

    func createViewmatrix() -> matrix_float4x4 {
        var m = matrix_float4x4()
        right = cross(up, front)
        m.columns.0 = SIMD4<Float>(right.x, right.y, right.z, 0.0)
        m.columns.1 = SIMD4<Float>(up.x, up.y, up.z, 0.0)
        m.columns.2 = SIMD4<Float>(back.x, back.y, back.z, 0.0)
        m.columns.3 = SIMD4<Float>(position.x, position.y, position.z, 1.0)
        return m.inverse
    }

}
