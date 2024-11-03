//
//  CameraManager.swift
//  iSimCameraTool
//
//  Created by akidon0000 on 2024/10/07.
//

import AppKit
import AVFoundation

final class CameraCapture: NSObject {
    private let captureSession = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "camera.capture.queue")
    private let filePath = "/tmp/iSimCameraTool_captured_photo.jpg"
    
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
            print("エラー: カメラが利用できません。")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: captureQueue)
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(output) {
                captureSession.addInput(input)
                captureSession.addOutput(output)
            } else {
                print("エラー: キャプチャセッションに入力または出力を追加できませんでした。")
            }
        } catch let error {
            print("エラー: AVCaptureDeviceInputの作成に失敗しました。詳細: \(error.localizedDescription)")
            return
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
        
        guard let jpegData = context.jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]) else {
            return
        }
        let fileManager = FileManager.default
        fileManager.createFile(atPath: filePath, contents: jpegData, attributes: nil)
    }
    
}
