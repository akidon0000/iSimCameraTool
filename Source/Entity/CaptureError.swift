//
//  CaptureError.swift
//  iSimCameraTool
//
//  Created by akidon0000 on 2024/10/07.
//

enum CaptureError: Error, CustomStringConvertible {
    case cameraNotFound
    case inputDeviceCreationFailed(Error)
    case photoDataUnavailable
    case photoSavingFailed(Error)
    
    var description: String {
        switch self {
        case .cameraNotFound:
            return "カメラが見つかりませんでした。"
        case .inputDeviceCreationFailed(let error):
            return "カメラの入力デバイス作成に失敗しました: \(error)"
        case .photoDataUnavailable:
            return "写真データが取得できませんでした。"
        case .photoSavingFailed(let error):
            return "写真の保存中にエラーが発生しました: \(error)"
        }
    }
    
    func log() {
        print(self.description)
    }
}
