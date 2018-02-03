/*
See LICENSE folder for this sample’s licensing information.

Abstract:
SceneKit node wrapper for plane geometry detected in AR.
*/

import Foundation
import ARKit

public class Plane: SCNNode {
    
    // MARK: - Properties
    
	var anchor: ARPlaneAnchor
	//var focusSquare: FocusSquare?
    
    // MARK: - Initialization
    
	public init(_ anchor: ARPlaneAnchor) {
		self.anchor = anchor
		super.init()
    }
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    // MARK: - ARKit
	
	public func update(_ anchor: ARPlaneAnchor) {
		self.anchor = anchor
	}
		
}

