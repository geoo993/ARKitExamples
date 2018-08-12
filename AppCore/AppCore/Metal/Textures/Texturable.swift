
// ------ Textures -------
// The Metal sampler state, tells the GPU how to use the texture.
// just like building the pipelineState, we build the sampler state using an MTLSamplerDescriptor,
// and then describe its properties.
// The filetring mode describes how the missing pixels are filled when you resize an image.
// This can be either linear or nearest, when you make an image bigger, if its an photo you want
// the missing pixels to be averaged from neabouring pixels.
// This smooths the missing data, this filtering mode is Linear.
// However if you are doing pixel art, you probably want to repeat each pixels,
// and this filtering mode is Nearest.
// Mipmapping is used for the Level Of Detail. Mipmaps are images of different sizes.
// If your model is at the front of the scene, you probably want a detailed smooth texture.
// And if that texture is at the back of the scene, you might get unwanted artifacs when the image is resized
// The sampler state has some properties where you can set the filtering mode for resizing between mipmap levels
// We address our texturing coordinates using values between 0 and 1, but you can mipmap outside 0 and 1.
// Which you can map outside 0 and 1, and the sampler state has properties
// where you can describe what happens outside those limits. you just repeat the edges of the texture,
// or repeat the whole texture.


import MetalKit

protocol Texturable {
  var texture: MTLTexture? { get set }
}

extension Texturable {

    // MARK: - Setup texture with bundle resource
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        // Loading texure
        var texture: MTLTexture? = nil
        let textureLoaderOptions: [MTKTextureLoader.Option: Any]

        if #available(iOS 10.0, *) {
            textureLoaderOptions = [.origin : MTKTextureLoader.Origin.bottomLeft,
                                    .generateMipmaps : true,
                                    .SRGB : true,
                                    .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                                    .textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
            ]
        } else {
            textureLoaderOptions = [:]
        }

        // load texture using the passed in image name
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                print("texture not created")
            }
        }

        // when you notice that the image is pixelated, this is becuase the default sampler uses filter mode Nearest
        return texture
    }

    func loadTexture(device: MTLDevice, textureName: String) -> MTLTexture? {
        /// Load texture data with optimal parameters for sampling

        let textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]

        // load texture using the passed in image name
        do {
            return try textureLoader.newTexture(name: textureName,
                                                scaleFactor: 1.0,
                                                bundle: nil,
                                                options: textureLoaderOptions)
        } catch {
            print("texture not created")
            return nil
        }

    }

    // MARK: - Setup texture with uiimage
    func setTexture(device: MTLDevice, image: UIImage) -> MTLTexture? {
        // https://stackoverflow.com/questions/29835537/metal-mtltexture-replaces-semi-transparent-areas-with-black-when-alpha-values-th
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let bounds = CGRect(x:0, y:0, width: CGFloat(width), height: CGFloat(height))

        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        let context = CGContext(data: nil, width: width, height: height,
                                bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
                                space: colorSpace, bitmapInfo: info)

        context?.clear(bounds)
        context?.translateBy(x: CGFloat(width), y: CGFloat(height))
        context?.scaleBy(x: -1.0, y: -1.0)
        context?.draw(image.cgImage!, in: bounds)
        let pixelsData = context?.data

        let textureDescriptor = MTLTextureDescriptor
            .texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)

        let texture = device.makeTexture(descriptor: textureDescriptor)
        let region = MTLRegionMake2D(0, 0, width, height)
        texture?.replace(region: region, mipmapLevel: 0, withBytes: pixelsData!, bytesPerRow: bytesPerRow)

        return texture
    }
}
