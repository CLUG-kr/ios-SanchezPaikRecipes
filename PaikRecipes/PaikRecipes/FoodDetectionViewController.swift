//
//  FoodDetectionViewController.swift
//  PaikRecipes
//
//  Created by Tars on 7/18/19.
//  Copyright © 2019 sspog. All rights reserved.
//
// Reference(0) : CoreML: Real Time Camera Object Detection with Machine Learning - Swift 4
// Reference(1) : https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture

import UIKit
import AVKit
import Vision

class FoodDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let captureSession = AVCaptureSession()

    func capture() { // Food Detection을 위한 AVCaptureSession 사용

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let captureDeviceInput:AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        // captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480  // 카메라로 비치는 모습이 아이폰 화면에서 차지하는 비율? .photo
                                                    // Vision이 효과적으로 작동하려면 lower resolution을 선택
                                                    // YOLOv3에서 train을 위한 input images scale을 몇으로 했는지 알아보기

        guard captureSession.canAddInput(captureDeviceInput) else {
            print("Could not add video device input to the session")
            // captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(captureDeviceInput)

        captureSession.startRunning()

        // 카메라 Output 보여주기
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        // 카메라 Output 데이터로 사용하기
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // AVCaptureSession 사용
        capture()
    }

    // Delegate 메소드 : AVCaptureVideoDataOutputSampleBufferDelegate
    // Camera의 각 frame에 대해서 동작
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // CoreML 모델 선택하기 - Resnet50
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            return
        }

        // CoreML request
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in

            // perhaps check the err

            guard let results = finishReq.results as? [VNClassificationObservation] else {
                return
            }

            guard let firstObservation = results.first else {
                return
            }

            print(firstObservation.identifier, firstObservation.confidence)
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
