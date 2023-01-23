
// ------ Transforms-----
// Transforms are combination of translation, rotation and scale
// UIViews have a CGAffineTransform property whihc is actually the first three columns of a 3x3 matrix.
// The order of applying the transforms matters because the object would end up in different place when
// the tranformation order is not applied correctly.
// NOTE❕: this is what a matrix looks like internally.
// [[m00, m01, m02, m03], [m10, m11, m12, m13], [m20, m21, m22, m23], [m30, m31, m32, m33]]
//
// | m00, m10, m20, m30 |
// |                    |
// | m01, m11, m21, m31 |
// |                    |
// | m02, m12, m22, m32 |
// |                    |
// | m03, m13, m23, m33 |
// for a 4x4 matrix, there are 4 entries in the array, and each entry is four Floats.
// concptually, each entry is a column, the first four Floats is column 0, then column 1 etc...
// the magic thing about matrices is that, you can setup a marix with a particular translation,
// rotation and scale. you can then multiply this matrix with a position in space, or what we are
// calling a Vertex, and that vertex translates, rotates, and sales according to the matrix.
// So the thing to understand about matrices is that, to move a 3D object in space, you apply a 4x4 transformation
// matrix to all the object vertices and the object moves, rotates, and scales in 3d space.
// matrices allow us to transform models in different coordinate spaces.
// When you create a model, you create it in something called Model Space.
// When you load a model into a scene, we want to position the entire model at a point in the scene,
// This is called World Space, if we wanted to position this model in World Space, we would setup a
// matrix with translation, and rotation values and multiply all the model vertices by this matrix.
// This matrix is called the Model Matrix, because it transforms the models vertices from model space to
// world space. When we want to view the scene through the camera, we use a View Matrix to describe the camera
// position, but when we apply the view matrix to each Model Matrix, it will move the entire scene.
// each model will have a model matrix, which describes where it is in the scene.
// before we send model to the GPU, we will ultiply this Model Matrix by the camera View Matrix
// (viewMatrix * modelMadix) and this matrix is called the Model View Matrix and it will tell us
// where the model is in the scene and also in relation to the camera.
// The matrix that you would have to apply is the projection, when we look at a scene we expect objects
// that are further away to be smaller. Projection is describe when we look at things from a certain position
// partcularly when to look out to a far plane. The near and far planes describe what is viewable.
// anything infront of the near plane and anything behind the far plane will be clipped and not shown.
// The field of view is importatnt and it describes the extent of view, you can make this larger or smaller.
// The projection transfrorm is a bit different from all the other transformations.
// The model and view transformation are affine, this means that parrallel lines are preserved.
// but because the projection tries to make objects that are far behind smaller, it is therefore not affine.
// The final vertex transformation, takes place behind the scene, our vertex function outputs a position.
// This is inputed into the rasterizer, which takes the forth component of that position,
// that the w component and divides the other componenets by it.
// This has the effect of taking the projected scene, normalising all the coordinates,
// and flattening it to fit onto the screen.

import simd


class Transform {

    
    /*
    Transform(const glm::vec3 &position = glm::vec3(0.0f, 0.0f, 0.0f), 
              const glm::vec3 &rotation = glm::vec3(0.0f, 0.0f, 0.0f), 
              const glm::vec3 &scale = glm::vec3(1.0f, 1.0f, 1.0f)   
              ): 
    m_position(position), 
    m_rotation(rotation), 
    m_scale(scale) {}
    
    
    inline glm::mat4 GetModel() const { 
        
         // type 1
         glm::mat4 matx(1.0);
         matx = glm::translate(matx, m_position);
         matx = glm::rotate(matx, m_rotation.z, glm::vec3(0.0, 0.0, 1.0));
         matx = glm::rotate(matx, m_rotation.y, glm::vec3(0.0, 1.0, 0.0));
         matx = glm::rotate(matx, m_rotation.x, glm::vec3(1.0, 0.0, 0.0));
         matx = glm::scale(matx, m_scale);
         m_model = matx;
         //m_model = glm::mat4(1.0);
     
         // type 2
        //this generates a 4x4 matrix with a position vector
        glm::mat4 m_positionMatrix = glm::translate(m_position) ;//translation matrix
        
        //this generates a 4x4 matrix with a rotation vector, but these takes some angle
        //these are rotations to represent the axis and we use vec3(1,0,0) on x for suggesting the x axis
        glm::mat4 rotationXmatrix = glm::rotate(m_rotation.x, glm::vec3(1,0,0));
        glm::mat4 rotationYmatrix = glm::rotate(m_rotation.y, glm::vec3(0,1,0));
        glm::mat4 rotationZmatrix = glm::rotate(m_rotation.z, glm::vec3(0,0,1));
        
        //combining the rotation matrices into one rotion matrix, because of the way matrices are reepresented, you must write the multiplication in reverse order.
        glm::mat4 m_rotationMatrix = rotationZmatrix * rotationYmatrix * rotationXmatrix;
        
        //this generates a 4x4 matrix with a scale vector
        glm::mat4 m_scaleMatrix = glm::scale(m_scale);
        
        //must becareful with the order of multiplication, because you can get different result doing it differently
        return m_positionMatrix * m_rotationMatrix * m_scaleMatrix;
    }
   
    inline glm::vec3 * GetPositions() { return &m_position; }
    inline glm::vec3 * GetRotation() { return &m_rotation; }
    inline glm::vec3 * GetScale() { return &m_scale; }
    
    inline void SetPositions(const glm::vec3 & position) { this->m_position = position; }
    inline void SetRotation(const glm::vec3 & rotation) { this->m_rotation = rotation; }
    inline void SetScale(const glm::vec3 & scale) { this->m_scale = scale; }
     
     

    */
    
    
    /*
     The order or format of speciifying the model matrix is to do:
     
         1 - Translation
         2 - Rotation
         3 - Scale
     
     */


    var model: matrix_float4x4

    ///Initializes the matrix stack with the identity matrix.
    init() {
        model = matrix_identity_float4x4
    }

    ///Initializes the matrix stack with the given matrix.
    init(model: matrix_float4x4) {
        self.model = model
    }

    var modelMatrix: matrix_float4x4 {
        return model
    }
    
    ///Applies a rotation matrix about the given axis, with the given angle in degrees.
    func rotate(axis: SIMD3<Float>, angDegCCW: Float)
    {
        //let resul = matrix_
        //m_model = glm::rotate(m_model, angDegCCW, axis);
    }

    /*
    //Applies a rotation matrix about the +X axis, with the given angle in degrees.
    void RotateX( float angDegCCW )
    {
        Rotate(glm::vec3(1.0f, 0.0f, 0.0f), angDegCCW);
    }
    
    ///Applies a rotation matrix about the +Y axis, with the given angle in degrees.
    void RotateY( float angDegCCW )
    {
        Rotate(glm::vec3(0.0f, 1.0f, 0.0f), angDegCCW);
    }
    
    ///Applies a rotation matrix about the +Z axis, with the given angle in degrees.
    void RotateZ( float angDegCCW )
    {
        Rotate(glm::vec3(0.0f, 0.0f, 1.0f), angDegCCW);
    }
    
    ///Applies a rotation matrix about the given axis, with the given angle in radians.
    void RotateRadians( const glm::vec3 axisOfRotation, float angRadCCW )
    {
        float fCos = cosf(angRadCCW);
        float fInvCos = 1.0f - fCos;
        float fSin = sinf(angRadCCW);
        float fInvSin = 1.0f - fSin;
        
        glm::vec3 axis = glm::normalize(axisOfRotation);
        
        glm::mat4 theMat(1.0f);
        theMat[0].x = (axis.x * axis.x) + ((1 - axis.x * axis.x) * fCos);
        theMat[1].x = axis.x * axis.y * (fInvCos) - (axis.z * fSin);
        theMat[2].x = axis.x * axis.z * (fInvCos) + (axis.y * fSin);
        
        theMat[0].y = axis.x * axis.y * (fInvCos) + (axis.z * fSin);
        theMat[1].y = (axis.y * axis.y) + ((1 - axis.y * axis.y) * fCos);
        theMat[2].y = axis.y * axis.z * (fInvCos) - (axis.x * fSin);
        
        theMat[0].z = axis.x * axis.z * (fInvCos) - (axis.y * fSin);
        theMat[1].z = axis.y * axis.z * (fInvCos) + (axis.x * fSin);
        theMat[2].z = (axis.z * axis.z) + ((1 - axis.z * axis.z) * fCos);
        m_model *= theMat;
    }
    
    ///Applies a scale matrix, with the given glm::vec3 as the axis scales.
    void Scale( const glm::vec3 &scaleVec )
    {
        m_model = glm::scale(m_model, scaleVec);
    }
    
    ///Applies a scale matrix, with the given values as the axis scales.
    void Scale(float scaleX, float scaleY, float scaleZ) {
        Scale(glm::vec3(scaleX, scaleY, scaleZ));
        
    }
    
    ///Applies a uniform scale matrix.
    void Scale(float uniformScale) {
        Scale(glm::vec3(uniformScale));
    }
    
    ///Applies a translation matrix, with the given glm::vec3 as the offset.
    void Translate( const glm::vec3 &offsetVec )
    {
        m_model = glm::translate(m_model, offsetVec);
    }
    
    ///Applies a translation matrix, with the given X, Y and Z values as the offset.
    void Translate(float transX, float transY, float transZ) {
        Translate(glm::vec3(transX, transY, transZ));
    }
    
    
    void ApplyMatrix( const glm::mat4 &theMatrix )
    {
        m_model *= theMatrix;
    }
    
    ///The given matrix becomes the current matrix.
    void SetMatrix( const glm::mat4 &theMatrix )
    {
        m_model = theMatrix;
    }
    
    ///Sets the current matrix to the identity matrix.
    void SetIdentity()
    {
        m_model = glm::mat4(1.0f);
    }
    
    void LookAt( const glm::vec3 &myPosition, const glm::vec3 &lookatPosition, const glm::vec3 &upDir )
    {
        m_model *= glm::lookAt(myPosition, lookatPosition, upDir);
    }
    
    
    //virtual ~Transform(){}

//    Transform(const Transform &other){}
//    void operator=(const Transform &other){}

    Transform &operator*=(const glm::mat4 &theMatrix) {
        ApplyMatrix(theMatrix); 
        return *this;
    }
    
//    glm::vec3 m_position;
//    glm::vec3 m_rotation;
//    glm::vec3 m_scale;
    
    glm::mat4 m_model;
 */
}

