
// https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-two-7b045fb1d7a1
// https://sites.math.washington.edu/~king/coursedir/m308a01/Projects/m308a01-pdf/yip.pdf
// http://mathforum.org/mathimages/index.php/Transformation_Matrix
// https://open.gl/transformations


import Foundation
import simd
import GLKit
import GLKit.GLKMatrix4
import SceneKit

/// Builds a translation 4 * 4 matrix created from a vector of 3 components.
public func translate(m: float4x4, v: float3) -> float4x4 {
    var result = m
    let vv = float4(v.x, v.y, v.z, 1)
    result[3] = m * vv
    return result
}

/// Builds a translation 4 * 4 matrix created from a vector of 3 components.
public func translate(m: double4x4, v: double3) -> double4x4 {
    var result = m
    let vv = double4(v.x, v.y, v.z, 1)
    result[3] = m * vv
    return result
}

/// Builds a rotation 4 * 4 matrix created from an axis vector and an angle.
public func rotate(m: float4x4, angle: Float, axis: float3) -> float4x4 {

    let a = angle
    let c = cos(a)
    let s = sin(a)
    
    let v = normalize(axis)
    let temp = (1 - c) * v
    
    var Rotate = float4x4(0)
    Rotate[0][0] = c + temp[0] * v[0]
    Rotate[0][1] = 0 + temp[0] * v[1] + s * v[2]
    Rotate[0][2] = 0 + temp[0] * v[2] - s * v[1]
    
    Rotate[1][0] = 0 + temp[1] * v[0] - s * v[2]
    Rotate[1][1] = c + temp[1] * v[1]
    Rotate[1][2] = 0 + temp[1] * v[2] + s * v[0]
    
    Rotate[2][0] = 0 + temp[2] * v[0] + s * v[1]
    Rotate[2][1] = 0 + temp[2] * v[1] - s * v[0]
    Rotate[2][2] = c + temp[2] * v[2]
    
    var Result = float4x4(0)
    Result[0] = m[0] * Rotate[0][0] + m[1] * Rotate[0][1] + m[2] * Rotate[0][2]
    Result[1] = m[0] * Rotate[1][0] + m[1] * Rotate[1][1] + m[2] * Rotate[1][2]
    Result[2] = m[0] * Rotate[2][0] + m[1] * Rotate[2][1] + m[2] * Rotate[2][2]
    Result[3] = m[3]
    return Result
}

/// Builds a rotation 4 * 4 matrix created from an axis vector and an angle.
public func rotate(m: double4x4, angle: Double, axis: double3) -> double4x4 {
    
    let a = angle
    let c = cos(a)
    let s = sin(a)
    
    let v = normalize(axis)
    let temp = (1 - c) * v
    
    var Rotate = double4x4(0)
    Rotate[0][0] = c + temp[0] * v[0]
    Rotate[0][1] = 0 + temp[0] * v[1] + s * v[2]
    Rotate[0][2] = 0 + temp[0] * v[2] - s * v[1]
    
    Rotate[1][0] = 0 + temp[1] * v[0] - s * v[2]
    Rotate[1][1] = c + temp[1] * v[1]
    Rotate[1][2] = 0 + temp[1] * v[2] + s * v[0]
    
    Rotate[2][0] = 0 + temp[2] * v[0] + s * v[1]
    Rotate[2][1] = 0 + temp[2] * v[1] - s * v[0]
    Rotate[2][2] = c + temp[2] * v[2]
    
    var Result = double4x4(0)
    Result[0] = m[0] * Rotate[0][0] + m[1] * Rotate[0][1] + m[2] * Rotate[0][2]
    Result[1] = m[0] * Rotate[1][0] + m[1] * Rotate[1][1] + m[2] * Rotate[1][2]
    Result[2] = m[0] * Rotate[2][0] + m[1] * Rotate[2][1] + m[2] * Rotate[2][2]
    Result[3] = m[3]
    return Result
}

/// Builds a scale 4 * 4 matrix created from 3 scalars.
public func scale(m: float4x4, v: float3) -> float4x4 {
    var Result = float4x4(0)
    Result[0] = m[0] * v[0];
    Result[1] = m[1] * v[1];
    Result[2] = m[2] * v[2];
    Result[3] = m[3];
    return Result;
}

/// Builds a scale 4 * 4 matrix created from 3 scalars.

public func scale(m: double4x4, v: double3) -> double4x4 {
    var Result = double4x4(0)
    Result[0] = m[0] * v[0];
    Result[1] = m[1] * v[1];
    Result[2] = m[2] * v[2];
    Result[3] = m[3];
    return Result;
}

/// Creates a matrix for an orthographic parallel viewing volume.
public func ortho(left: Float, right: Float, bottom: Float, top: Float, zNear: Float, zFar: Float) -> float4x4 {
    var Result = float4x4(1)
    Result[0][0] = Float(2) / (right - left)
    Result[1][1] = Float(2) / (top - bottom)
    Result[2][2] = -Float(2) / (zFar - zNear)
    Result[3][0] = -(right + left) / (right - left)
    Result[3][1] = -(top + bottom) / (top - bottom)
    Result[3][2] = -(zFar + zNear) / (zFar - zNear)
    return Result
}

/// Creates a matrix for projecting two-dimensional coordinates onto the screen.
public func ortho(left: Float, right: Float, bottom: Float, top: Float) -> float4x4 {
    var Result = float4x4(1)
    Result[0][0] = Float(2) / (right - left)
    Result[1][1] = Float(2) / (top - bottom)
    Result[2][2] = -Float(1)
    Result[3][0] = -(right + left) / (right - left)
    Result[3][1] = -(top + bottom) / (top - bottom)
    return Result
}

/// Creates a matrix for an orthographic parallel viewing volume.
public func ortho(left: Double, right: Double, bottom: Double, top: Double, zNear: Double, zFar: Double) -> double4x4 {
    var Result = double4x4(1)
    Result[0][0] = Double(2) / (right - left)
    Result[1][1] = Double(2) / (top - bottom)
    Result[2][2] = -Double(2) / (zFar - zNear)
    Result[3][0] = -(right + left) / (right - left)
    Result[3][1] = -(top + bottom) / (top - bottom)
    Result[3][2] = -(zFar + zNear) / (zFar - zNear)
    return Result
}

/// Creates a matrix for projecting two-dimensional coordinates onto the screen.
public func ortho(left: Double, right: Double, bottom: Double, top: Double) -> double4x4 {
    var Result = double4x4(1)
    Result[0][0] = Double(2) / (right - left)
    Result[1][1] = Double(2) / (top - bottom)
    Result[2][2] = -Double(1)
    Result[3][0] = -(right + left) / (right - left)
    Result[3][1] = -(top + bottom) / (top - bottom)
    return Result
}

/// Creates a frustum matrix.
public func frustum(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> float4x4 {
    var Result = float4x4(0)
    Result[0][0] = (Float(2) * near) / (right - left)
    Result[1][1] = (Float(2) * near) / (top - bottom)
    Result[2][0] = (right + left) / (right - left)
    Result[2][1] = (top + bottom) / (top - bottom)
    Result[2][2] = -(far + near) / (far - near)
    Result[2][3] = Float(-1)
    Result[3][2] = -(Float(2) * far * near) / (far - near)
    return Result
}

/// Creates a frustum matrix.
public func frustum(left: Double, right: Double, bottom: Double, top: Double, near: Double, far: Double) -> double4x4 {
    var Result = double4x4(0)
    Result[0][0] = (Double(2) * near) / (right - left)
    Result[1][1] = (Double(2) * near) / (top - bottom)
    Result[2][0] = (right + left) / (right - left)
    Result[2][1] = (top + bottom) / (top - bottom)
    Result[2][2] = -(far + near) / (far - near)
    Result[2][3] = Double(-1)
    Result[3][2] = -(Double(2) * far * near) / (far - near)
    return Result
}

/// Creates a matrix for a symetric perspective-view.
public func perspective(fovy: Float, aspect: Float, zNear: Float, zFar: Float) -> float4x4 {
    
    assert(abs(aspect) > Float(0), "")
    
    let tanHalfFovy = tan(fovy / Float(2))
    
    var Result = float4x4(0)
    Result[0][0] = Float(1) / (aspect * tanHalfFovy)
    Result[1][1] = Float(1) / (tanHalfFovy)
    Result[2][2] = -(zFar + zNear) / (zFar - zNear)
    Result[2][3] = -Float(1)
    Result[3][2] = -(Float(2) * zFar * zNear) / (zFar - zNear)
    return Result
}

/// Creates a matrix for a symetric perspective-view.
public func perspective(fovy: Double, aspect: Double, zNear: Double, zFar: Double) -> double4x4 {
    
    assert(abs(aspect) > Double(0), "")
    
    let tanHalfFovy = tan(fovy / Double(2))
    
    var Result = double4x4(0)
    Result[0][0] = Double(1) / (aspect * tanHalfFovy)
    Result[1][1] = Double(1) / (tanHalfFovy)
    Result[2][2] = -(zFar + zNear) / (zFar - zNear)
    Result[2][3] = -Double(1)
    Result[3][2] = -(Double(2) * zFar * zNear) / (zFar - zNear)
    return Result
}

/// Builds a perspective projection matrix based on a field of view.
public func perspectiveFov(fov: Float, width: Float, height: Float, zNear: Float, zFar: Float) -> float4x4 {
    assert(width > Float(0))
    assert(height > Float(0))
    assert(fov > Float(0))
    
    let rad = fov
    let h = cos(Float(0.5) * rad) / sin(Float(0.5) * rad)
    let w = h * height / width
    
    var Result = float4x4(0)
    Result[0][0] = w
    Result[1][1] = h
    Result[2][2] = -(zFar + zNear) / (zFar - zNear)
    Result[2][3] = -Float(1)
    Result[3][2] = -(Float(2) * zFar * zNear) / (zFar - zNear)
    return Result;
}

/// Builds a perspective projection matrix based on a field of view.
public func perspectiveFov(fov: Double, width: Double, height: Double, zNear: Double, zFar: Double) -> double4x4 {
    assert(width > Double(0))
    assert(height > Double(0))
    assert(fov > Double(0))
    
    let rad = fov
    let h = cos(Double(0.5) * rad) / sin(Double(0.5) * rad)
    let w = h * height / width
    
    var Result = double4x4(0)
    Result[0][0] = w
    Result[1][1] = h
    Result[2][2] = -(zFar + zNear) / (zFar - zNear)
    Result[2][3] = -Double(1)
    Result[3][2] = -(Double(2) * zFar * zNear) / (zFar - zNear)
    return Result;
}

/// Creates a matrix for a symmetric perspective-view frustum with far plane at infinite.
public func infinitePerspective(fovy : Float, aspect: Float, zNear : Float) -> float4x4 {
    let range = tan(fovy / Float(2)) * zNear;
    let left = -range * aspect;
    let right = range * aspect;
    let bottom = -range;
    let top = range;
    
    var Result = float4x4(0)
    Result[0][0] = (Float(2) * zNear) / (right - left);
    Result[1][1] = (Float(2) * zNear) / (top - bottom);
    Result[2][2] = -Float(1);
    Result[2][3] = -Float(1);
    Result[3][2] = -Float(2) * zNear;
    return Result;
}

/// Creates a matrix for a symmetric perspective-view frustum with far plane at infinite.
public func infinitePerspective(fovy : Double, aspect: Double, zNear : Double) -> double4x4 {
    let range = tan(fovy / Double(2)) * zNear;
    let left = -range * aspect;
    let right = range * aspect;
    let bottom = -range;
    let top = range;
    
    var Result = double4x4(0)
    Result[0][0] = (Double(2) * zNear) / (right - left);
    Result[1][1] = (Double(2) * zNear) / (top - bottom);
    Result[2][2] = -Double(1);
    Result[2][3] = -Double(1);
    Result[3][2] = -Double(2) * zNear;
    return Result;
}

/// Build a look at view matrix.
public func lookAt(eye: float3, center: float3, up: float3) -> float4x4 {
    
    let f = normalize(center - eye);
    let s = normalize(cross(f, up));
    let u = cross(s, f);
    
    var Result = float4x4(1);
    Result[0][0] = s.x;
    Result[1][0] = s.y;
    Result[2][0] = s.z;
    Result[0][1] = u.x;
    Result[1][1] = u.y;
    Result[2][1] = u.z;
    Result[0][2] = -f.x;
    Result[1][2] = -f.y;
    Result[2][2] = -f.z;
    Result[3][0] = -dot(s, eye);
    Result[3][1] = -dot(u, eye);
    Result[3][2] = dot(f, eye);
    return Result
}

/// Build a look at view matrix.
public func lookAt(eye: double3, center: double3, up: double3) -> double4x4 {
    
    let f = normalize(center - eye);
    let s = normalize(cross(f, up));
    let u = cross(s, f);
    
    var Result = double4x4(1);
    Result[0][0] = s.x;
    Result[1][0] = s.y;
    Result[2][0] = s.z;
    Result[0][1] = u.x;
    Result[1][1] = u.y;
    Result[2][1] = u.z;
    Result[0][2] = -f.x;
    Result[1][2] = -f.y;
    Result[2][2] = -f.z;
    Result[3][0] = -dot(s, eye);
    Result[3][1] = -dot(u, eye);
    Result[3][2] = dot(f, eye);
    return Result
}

extension matrix_float4x4 {
    init(translationX x: Float, y: Float, z: Float) {
        self.init()
        columns = (
            float4( 1,  0,  0,  0),
            float4( 0,  1,  0,  0),
            float4( 0,  0,  1,  0),
            float4( x,  y,  z,  1)
        )
    }

    func translatedBy(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        let translateMatrix = matrix_float4x4(translationX: x, y: y, z: z)
        return matrix_multiply(self, translateMatrix)
    }

    init(scaleX x: Float, y: Float, z: Float) {
        self.init()
        columns = (
            float4( x,  0,  0,  0),
            float4( 0,  y,  0,  0),
            float4( 0,  0,  z,  0),
            float4( 0,  0,  0,  1)
        )
    }

    func scaledBy(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        let scaledMatrix = matrix_float4x4(scaleX: x, y: y, z: z)
        return matrix_multiply(self, scaledMatrix)
    }

    // angle should be in radians
    init(rotationAngle angle: Float, x: Float, y: Float, z: Float) {
        let c = cos(angle)
        let s = sin(angle)

        var column0 = float4(0)
        column0.x = x * x + (1 - x * x) * c
        column0.y = x * y * (1 - c) - z * s
        column0.z = x * z * (1 - c) + y * s
        column0.w = 0

        var column1 = float4(0)
        column1.x = x * y * (1 - c) + z * s
        column1.y = y * y + (1 - y * y) * c
        column1.z = y * z * (1 - c) - x * s
        column1.w = 0.0

        var column2 = float4(0)
        column2.x = x * z * (1 - c) - y * s
        column2.y = y * z * (1 - c) + x * s
        column2.z = z * z + (1 - z * z) * c
        column2.w = 0.0

        let column3 = float4(0, 0, 0, 1)

        self.init()
        columns = (
            column0, column1, column2, column3
        )
    }

    func rotatedBy(rotationAngle angle: Float, x: Float, y: Float, z: Float) -> matrix_float4x4 {
        let rotationMatrix = matrix_float4x4(rotationAngle: angle,
                                             x: x, y: y, z: z)
        return matrix_multiply(self, rotationMatrix)
    }

    init(projectionFov fov: Float, aspect: Float, nearZ: Float, farZ: Float) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = farZ / (nearZ - farZ)
        self.init()
        columns = (
            float4( x,  0,  0,  0),
            float4( 0,  y,  0,  0),
            float4( 0,  0,  z, -1),
            float4( 0,  0,  z * nearZ,  0)
        )
    }

    func upperLeft3x3() -> matrix_float3x3 {
        return (matrix_float3x3(columns: (
            float3(columns.0.x, columns.0.y, columns.0.z),
            float3(columns.1.x, columns.1.y, columns.1.z),
            float3(columns.2.x, columns.2.y, columns.2.z)
        )))
    }

    public func transpose() -> matrix_float4x4 {
        return (matrix_float4x4(columns: (
            float4(columns.0.x, columns.1.x, columns.2.x, columns.3.x),
            float4(columns.0.y, columns.1.y, columns.2.y, columns.3.y),
            float4(columns.0.z, columns.1.z, columns.2.z, columns.3.z),
            float4(columns.0.w, columns.1.w, columns.3.w, columns.3.w)
        )))
    }


    // https://stackoverflow.com/questions/45463627/how-do-i-rotate-an-arkit-4x4-matrix-around-y-using-apples-simd-library
    func makeRotationYMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), 0, -sin(angle)),
            simd_float3(0, 1, 0),
            simd_float3(-sin(angle), 0, cos(angle))
        ]

        return float3x3(rows: rows)
    }
    // https://stackoverflow.com/questions/45463627/how-do-i-rotate-an-arkit-4x4-matrix-around-y-using-apples-simd-library
    func rotate(with angle: Float, axis: simd_float3) -> matrix_float4x4 {
        let angleInRadians = angle.toRadians
        return float4x4(simd_quaternion(angleInRadians, axis))
    }

    public var position: SCNVector3 {

        //    column 0  column 1  column 2  column 3
        //         1        0         0       X    
        //         0        1         0       Y    
        //         0        0         1       Z    
        //         0        0         0       1    
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }

    public func rotateAroundX(for degrees: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1      0         θ        0    
        //         0     cosθ      -sinθ     0    
        //         0     sinθ      cosθ      0    
        //         0      0         0        1    

        var matrix : matrix_float4x4 = self
        matrix.columns.1.y = cos(degrees)
        matrix.columns.1.z = sin(degrees)

        matrix.columns.2.x = -sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }

    public func rotateAroundY(for degrees: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //        cosθ      0       sinθ      0    
        //         0        1         0       0    
        //       −sinθ      0       cosθ      0    
        //         0        0         0       1    

        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)

        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }

    public func rotateAroundZ(for degrees: Float) -> matrix_float4x4 {
        //      column 0   column 1  column 2  column 3
        //        cosθ    -sinθ       θ        0    
        //        sinθ     cosθ       0        0    
        //         0        0         1        0    
        //         0        0         0        1    

        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.y = sin(degrees)

        matrix.columns.1.x = -sin(degrees)
        matrix.columns.1.y = cos(degrees)
        return matrix.inverse
    }

    public func translationMatrix(with translation : vector_float4) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1        0         0       X          x        x + X*w 
        //         0        1         0       Y      x   y    =   y + Y*w 
        //         0        0         1       Z          z        z + Z*w 
        //         0        0         0       1          w           w    
        var matrix = self
        matrix.columns.3 = translation
        return matrix
    }

    public func scale(by size: Float) -> matrix_float4x4 {
        //    column 0  column 1  column 2  column 3
        //         1        0       0      0    
        //         0        1       0      0    
        //         0        0       1      0    
        //         0        0       0      1    

        var matrix : matrix_float4x4 = self
        matrix.columns.0.x = size
        matrix.columns.1.y = size
        matrix.columns.2.z = size
        return matrix
    }
}


extension float4x4 {
    // https://gist.github.com/codelynx/908fd30c93e40ea6408b
    static func makeScale(_ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeScale(x, y, z), to: float4x4.self)
    }

    static func makeRotate(_ radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), to: float4x4.self)
    }

    static func makeTranslation(_ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeTranslation(x, y, z), to: float4x4.self)
    }

    static func makePerspective(fovyRadians: Float, _ aspect: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakePerspective(fovyRadians, aspect, nearZ, farZ), to: float4x4.self)
    }

    static func makeFrustum(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeFrustum(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
    }

    static func makeOrtho(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeOrtho(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
    }

    static func makeLookAt(eyeX: Float, _ eyeY: Float, _ eyeZ: Float, _ centerX: Float, _ centerY: Float, _ centerZ: Float, _ upX: Float, _ upY: Float, _ upZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ), to: float4x4.self)
    }


    func scale(x: Float, y: Float, z: Float) -> float4x4 {
        return self * float4x4.makeScale(x, y, z)
    }

    func rotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeRotate(radians, x, y, z)
    }

    func translate(x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeTranslation(x, y, z)
    }

    init(scaleBy s: Float) {
        self.init(float4(s, 0, 0, 0),
                  float4(0, s, 0, 0),
                  float4(0, 0, s, 0),
                  float4(0, 0, 0, 1))
    }

    init(rotationAbout axis: float3, by angleRadians: Float) {
        let a = normalize(axis)
        let x = a.x, y = a.y, z = a.z
        let c = cosf(angleRadians)
        let s = sinf(angleRadians)
        let t = 1 - c
        self.init(float4( t * x * x + c,     t * x * y + z * s, t * x * z - y * s, 0),
                  float4( t * x * y - z * s, t * y * y + c,     t * y * z + x * s, 0),
                  float4( t * x * z + y * s, t * y * z - x * s,     t * z * z + c, 0),
                  float4(                 0,                 0,                 0, 1))
    }

    init(translationBy t: float3) {
        self.init(float4(   1,    0,    0, 0),
                  float4(   0,    1,    0, 0),
                  float4(   0,    0,    1, 0),
                  float4(t[0], t[1], t[2], 1))
    }

    init() {
        self = unsafeBitCast(GLKMatrix4Identity, to: float4x4.self)
    }

    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    public var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }


    init(perspectiveProjectionFov fovRadians: Float, aspectRatio aspect: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange

        let xx = xScale
        let yy = yScale
        let zz = zScale
        let zw = Float(-1)
        let wz = wzScale

        self.init(float4(xx,  0,  0,  0),
                  float4( 0, yy,  0,  0),
                  float4( 0,  0, zz, zw),
                  float4( 0,  0, wz,  1))
    }

    public mutating func rotateAroundX(_ x: Float, y: Float, z: Float) {
        var rotationM = float4x4.makeRotate(x, 1, 0, 0)
        rotationM = rotationM * float4x4.makeRotate(y, 0, 1, 0)
        rotationM = rotationM * float4x4.makeRotate(z, 0, 0, 1)
        self = self * rotationM
    }

    public static var numberOfElements : Int {
        return 16
    }


    public mutating func multiplyLeft(_ matrix: float4x4) {
        let glMatrix1 = unsafeBitCast(matrix, to: GLKMatrix4.self)
        let glMatrix2 = unsafeBitCast(self, to: GLKMatrix4.self)
        let result = GLKMatrix4Multiply(glMatrix1, glMatrix2)
        self = unsafeBitCast(result, to: float4x4.self)
    }

}

extension matrix_float4x4: CustomReflectable {

    public var customMirror: Mirror {
        let c00 = String(format: "%  .4f", columns.0.x)
        let c01 = String(format: "%  .4f", columns.0.y)
        let c02 = String(format: "%  .4f", columns.0.z)
        let c03 = String(format: "%  .4f", columns.0.w)

        let c10 = String(format: "%  .4f", columns.1.x)
        let c11 = String(format: "%  .4f", columns.1.y)
        let c12 = String(format: "%  .4f", columns.1.z)
        let c13 = String(format: "%  .4f", columns.1.w)

        let c20 = String(format: "%  .4f", columns.2.x)
        let c21 = String(format: "%  .4f", columns.2.y)
        let c22 = String(format: "%  .4f", columns.2.z)
        let c23 = String(format: "%  .4f", columns.2.w)

        let c30 = String(format: "%  .4f", columns.3.x)
        let c31 = String(format: "%  .4f", columns.3.y)
        let c32 = String(format: "%  .4f", columns.3.z)
        let c33 = String(format: "%  .4f", columns.3.w)


        let children = DictionaryLiteral<String, Any>(dictionaryLiteral:
            (" ", "\(c00) \(c01) \(c02) \(c03)"),
                                                      (" ", "\(c10) \(c11) \(c12) \(c13)"),
                                                      (" ", "\(c20) \(c21) \(c22) \(c23)"),
                                                      (" ", "\(c30) \(c31) \(c32) \(c33)")
        )
        return Mirror(matrix_float4x4.self, children: children)
    }

}

extension float4: CustomReflectable {

    public var customMirror: Mirror {
        let sx = String(format: "%  .4f", x)
        let sy = String(format: "%  .4f", y)
        let sz = String(format: "%  .4f", z)
        let sw = String(format: "%  .4f", w)

        let children = DictionaryLiteral<String, Any>(dictionaryLiteral:
            (" ", "\(sx) \(sy) \(sz) \(sw)")
        )
        return Mirror(float4.self, children: children)
    }
}


