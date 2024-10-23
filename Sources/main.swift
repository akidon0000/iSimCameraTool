//
//  main.swift
//  iSimCameraTool
//
//  Created by akidon0000 on 2024/10/07.
//

import Foundation

func main() {
    let captureTimeout: TimeInterval = 300 // 5分
    
    let cameraManager = CameraCapture()
    cameraManager.startCapturing()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + captureTimeout) {
        cameraManager.stopCapturing()
        exit(0)
    }

    RunLoop.main.run()
}

main()
