//
//  ContentView.swift
//  Uppgift4_CoreML
//
//  Created by Alexander Lins on 2023-11-14.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State var image: UIImage = UIImage()
    @State var showIntro: Bool = true
    @StateObject var AI = DoML()
    
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .imageScale(.large)
                .frame(width: 224, height: 224)
            HStack {
                Button {showIntro = false; image = UIImage(named: "shark")!; AI.predict = AI.doImage(image: image, predict: &AI.predict)} label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).frame(width:60,height: 50)
                        Text("Shark").foregroundStyle(.white)
                    }
                }
                
                Button {showIntro = false; image = UIImage(named: "stingray")!; AI.predict = AI.doImage(image: image, predict: &AI.predict)} label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).frame(width:75,height: 50)
                        Text("Stingray").foregroundStyle(.white)
                    }
                }
            }
            if showIntro {
                Text("Click on button to analyze").bold()
            } else {
                Text("\(AI.predict)").textCase(.uppercase).bold()
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//Class for analyzing the image
class DoML: ObservableObject {
    @Published var predict: String = ""
    
    func doImage(image: UIImage, predict: inout String) -> String {
        let config = MLModelConfiguration()
        let imageClassifier = try? MobileNetV2(configuration: config)
        
        let analyzedImg = image
        let bufferedImg = buffer(from: analyzedImg)
        
        var string: String = ""
        
        do {
            let output = try imageClassifier?.prediction(image: bufferedImg!)
            string = {
                let result = output?.classLabel ?? "Not found"
                let filteredResult = result.components(separatedBy: ",")
                let finalResult = filteredResult.first
                return finalResult ?? "Not found"
            }()
            return string
            
        } catch {
            
        }
        
        return string
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
}
