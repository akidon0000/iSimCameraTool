//
//  CameraManager.swift
//  iSimCameraTool
//
//  Created by akidon0000 on 2024/10/07.
//

import AVFoundation

class CameraManager: NSObject {
    
    private var capturedPhotoPath: URL?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            CaptureError.photoSavingFailed(error).log()
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            CaptureError.photoDataUnavailable.log()
            return
        }
        
        // プロジェクトのパスを取得
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let projectDirectoryURL = currentDirectoryURL.deletingLastPathComponent() // プロジェクトの親ディレクトリを取得（必要に応じて変更）
        
        // プロジェクト内の保存先を指定
        let saveDirectory = projectDirectoryURL.appendingPathComponent("CapturedPhotos")
        
        // 保存先ディレクトリが存在しない場合は作成
        do {
            if !FileManager.default.fileExists(atPath: saveDirectory.path) {
                try FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true, attributes: nil)
                print("ディレクトリ 'CapturedPhotos' を作成しました: \(saveDirectory.path)")
            }
        } catch {
            print("ディレクトリの作成に失敗しました: \(error)")
            return
        }
        
        capturedPhotoPath = saveDirectory.appendingPathComponent("captured_photo.jpg")
        
        do {
            try photoData.write(to: capturedPhotoPath!)
            print("写真がデスクトップに保存されました: \(capturedPhotoPath!.path)")
        } catch {
            CaptureError.photoSavingFailed(error).log()
        }
        performAdditionalProcessing()
    }
    
    func performAdditionalProcessing() {
        guard let path = capturedPhotoPath else {
            print("capturedPhotoPathが見つかりません")
            return
        }
        // ここに保存後に行いたい処理を記述します
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "addmedia", "booted", path.path]
        
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

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func startCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            CaptureError.cameraNotFound.log()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            CaptureError.inputDeviceCreationFailed(error).log()
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
}
