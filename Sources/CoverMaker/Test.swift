import CImageMagick

func processImageData(inputData: Data) -> Data? {
    MagickWandGenesis()
    defer { MagickWandTerminus() }

    let wand = NewMagickWand()
    defer { DestroyMagickWand(wand) }

    // 1. Load from Data (Blob)
    inputData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
        if let baseAddress = ptr.baseAddress {
            // Parameters: wand, pointer to data, length of data
            MagickReadImageBlob(wand, baseAddress, inputData.count)
        }
    }

    // 2. Setup Drawing (Same as your original logic)
    let drawingWand = NewDrawingWand()
    let pixelWand = NewPixelWand()
    defer {
        DestroyDrawingWand(drawingWand)
        DestroyPixelWand(pixelWand)
    }

    PixelSetColor(pixelWand, "white")
    DrawSetFillColor(drawingWand, pixelWand)
    DrawSetFont(drawingWand, "/path/to/YourJapaneseFont.ttf")
    DrawSetFontSize(drawingWand, 48)
    MagickSetOption(wand, "direction", "top-to-bottom")
    DrawSetGravity(drawingWand, CenterGravity)

    let title = "微熱の糸が灼きついて\nほどけないので"
    MagickAnnotateImage(wand, drawingWand, 0, 0, 0, title)

    // 3. Export back to Data (Blob)
    var length: Int = 0
    // MagickGetImageBlob returns an UnsafeMutablePointer<UInt8>
    if let blobPtr = MagickGetImageBlob(wand, &length) {
        // Create Swift Data by copying the bytes from the pointer
        let outputData = Data(bytes: blobPtr, count: length)

        // CRITICAL: ImageMagick allocated this memory, we must free it
        MagickRelinquishMemory(blobPtr)

        return outputData
    }

    return nil
}