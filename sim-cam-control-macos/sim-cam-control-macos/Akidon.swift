//
//  main.swift
//  sim-cam-control-macos
//
//  Created by akidon0000 on 2024/10/06.
//

import AVFoundation
import Cocoa

@main
class Akidon: NSObject, AVCapturePhotoCaptureDelegate {
    
    static func main() {
        let akidonInstance = Akidon()
        akidonInstance.startCaptureSession()
    }
    
    func startCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("カメラが見つかりませんでした。")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("カメラの入力デバイス作成に失敗しました: \(error)")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // セッションの開始
        captureSession.startRunning()
        
        let photoSettings = AVCapturePhotoSettings()
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        // RunLoopで保持する
        RunLoop.main.run()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("写真の処理中にエラーが発生しました: \(error)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            print("写真データが取得できませんでした。")
            return
        }
        
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let fileURL = desktopPath.appendingPathComponent("captured_photo.jpg")
        
        do {
            try photoData.write(to: fileURL)
            print("写真がデスクトップに保存されました: \(fileURL.path)")
        } catch {
            print("写真の保存中にエラーが発生しました: \(error)")
        }
        performAdditionalProcessing()
    }
    
    func performAdditionalProcessing() {
        // ここに保存後に行いたい処理を記述します
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "addmedia", "booted", "/Users/akidon0000/Desktop/captured_photo.jpg"]
        
        do {
            try task.run()
            task.waitUntilExit()
            print("xcrun simctl addmedia コマンドが実行されました。")
        } catch {
            print("追加処理の実行中にエラーが発生しました: \(error)")
        }
        
        print("追加の処理が完了しました。")
    }
}
