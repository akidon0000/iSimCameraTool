//
//  CameraManager.swift
//  iSimCameraTool
//
//  Created by akidon0000 on 2024/10/07.
//

import AVFoundation
import AppKit

final class CameraCapture: NSObject {
    private let captureSession = AVCaptureSession()
    private var captureOutput = AVCaptureVideoDataOutput()
    private let captureQueue = DispatchQueue(label: "camera.capture.queue")
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func startCapturing() {
        captureSession.startRunning()
    }
    
    func stopCapturing() {
        captureSession.stopRunning()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .low
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Error: No camera available.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error: Unable to initialize camera input: \(error)")
            return
        }
        
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        captureOutput.setSampleBufferDelegate(self, queue: captureQueue)
        
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }
    }
}

extension CameraCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        let nsImage = NSImage(cgImage: cgImage, size: .zero)
        saveImage(nsImage)
    }
    
    private func saveImage(_ image: NSImage) {
        let fileManager = FileManager.default
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            return
        }
        let filePath = "/tmp/iSimCameraTool_captured_photo.jpg"
        fileManager.createFile(atPath: filePath, contents: jpegData, attributes: nil)
    }
}
