//
//  Camera.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 30/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import MetalKit
import AppCore

class Camera {

    var position: float3       // The position of the camera's centre of projection
    private var rotation: float3

    //view and projection matrix
    var perspectiveProjectionMatrix: matrix_float4x4 // Perspective projection matrix
    var orthographicProjectionMatrix: matrix_float4x4 // Orthographic projection matrix
    var viewMatrix: matrix_float4x4

    var view: float3 // The camera's viewpoint (point where the camera is looking)

    var strafe: float3        // The camera's strafe vector

    var front: float3               // The camera's forward vector
    var back: float3                // The camera's backward vector
    var left: float3               // The camera's left vector
    var right: float3               // The camera's right vector
    var up: float3                  // The camera's up vector
    var down: float3                // The camera's down vector

    var worldUp: float3            // The worlds up vector, the original position of the world

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

    init(fov: Float, size: CGSize, zNear: Float, zFar: Float) {
        screenSize = size
        perspectiveProjectionMatrix = matrix_identity_float4x4
        orthographicProjectionMatrix = matrix_identity_float4x4
        viewMatrix = matrix_identity_float4x4
        view = float3(0.0)
        front = float3(0.0, 0.0, -1.0)
        back = float3(0.0, 0.0, 1.0)
        left = float3(-1.0, 0.0, 0.0)
        right = float3(1.0, 0.0, 0.0)
        up = float3(0.0, 1.0, 0.0)
        down = float3(0.0, -1.0, 0.0)
        worldUp = float3( 0.0, 1.0, 0.0)
        pitch = 0.1
        yaw = -90
        fieldOfView = fov
        nearPlane = zNear
        farPlane = zFar
        strafe = float3( 0.0, 0.0, 0.0)
        speed = 5.0 // between 0 and 1
        sensitivity = 0.6 // between 0 and 1
        screenSize = size
        position = float3(0)
        rotation = float3(0)

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
        //let xRotation = rota

    }

    // Set the camera at a specific position, looking at the view point, with a given up vector
    func set(position: float3, viewpoint: float3, up: float3) {
        self.position = position
        self.front = normalize(viewpoint - position) // finding front vector
        self.up = up
        self.worldUp = float3( 0.0, 1.0, 0.0 )

        updateCameraVectors()
    }


    // Rotate the camera view point -- this effectively rotates the camera since it is looking at the view point
    func rotateViewPoint(angle: Float, axis: float3) {

        let vView = view - position;// direction vector
        
        let rotation = rotate(m: matrix_identity_float4x4, angle: radians(degrees: angle), axis: axis)
        let newView = rotation * float4(vView, 1)

        self.front = normalize(float3(newView))

        updateCameraVectors()
    }

    func rotateAroundPoint(distance: Float, viewpoint: float3, angle: Float, y: Float) {

        let radian = radians(degrees: angle)

        let camX = viewpoint.x + (distance * cosf(radian))
        let camY = y
        let camZ = viewpoint.z + (distance * sinf(radian))

        // Set the camera position and lookat point
        let position = float3(camX, camY, camZ)   // Camera position
        let look = viewpoint // Look at point
        let upV = float3(0.0, 1.0, 0.0) // Up vector

        set(position: position, viewpoint: look, up: upV);

    }

    func positionInFrontOfCamera(distance: Float) -> float3 {
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
                let vPoint: float3 = cross(view - position, up)
                let axis: float3 = normalize(vPoint)
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
    func updateMovement(deltaTime: Float, angle: Float, displacement: Float)
    {
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
        self.screenSize = screenSize
        self.perspectiveProjectionMatrix = matrix_float4x4(projectionFov: radians(degrees: fieldOfView),
                                                           aspect: Float(screenSize.width / screenSize.height),
                                                           nearZ: nearPlane,
                                                           farZ: farPlane)

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

}
