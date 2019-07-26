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
import AVFoundation
import Vision

class FoodDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil

    @IBOutlet weak private var previewView: UIView!    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }

    @IBAction func findRecipeAction(_ sender: Any) {
        session.stopRunning() // 레시피 찾기 버튼을 누르면 AVCaptureSession을 중지한다.
        // 디버깅 결과 Memory Usage만 줄어들지 않는다.
    }

//    func capture() { // Food Detection을 위한 AVCaptureSession 사용
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            return
//        }
//
//        let captureDeviceInput:AVCaptureDeviceInput
//        do {
//            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
//        } catch {
//            print("Could not create video device input: \(error)")
//            return
//        }
//
//        // captureSession.beginConfiguration()
//        captureSession.sessionPreset = .vga640x480  // 카메라로 비치는 모습이 아이폰 화면에서 차지하는 비율? .photo
//                                                    // Vision이 효과적으로 작동하려면 lower resolution을 선택
//                                                    // YOLOv3에서 train을 위한 input images scale을 몇으로 했는지 알아보기
//
//        guard captureSession.canAddInput(captureDeviceInput) else {
//            print("Could not add video device input to the session")
//            // captureSession.commitConfiguration()
//            return
//        }
//        captureSession.addInput(captureDeviceInput)
//
//        captureSession.startRunning()
//
//        // 카메라 Output 보여주기
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.frame
//
//        // 카메라 Output 데이터로 사용하기
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        captureSession.addOutput(dataOutput)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // AVCaptureSession 사용
        setupAVCapture()
    }

    override func viewWillAppear(_ animated: Bool) {
        // 네비게이션 바 숨기기
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    // 해당 navigationController로 묶인 하위의 뷰들도 다 숨겨지므로 viewWillDisappear에서 다시 나타나게 해주어야 한다.
    override func viewWillDisappear(_ animated: Bool) {
        // 네비게이션 바 숨기기
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!

        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.

        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }

    func startCaptureSession() {
        session.startRunning()
    }

    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }

    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }

    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

    // Resnet50.mlmodel
    // Delegate 메소드 : AVCaptureVideoDataOutputSampleBufferDelegate
    // Camera의 각 frame에 대해서 동작
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
////        print("Camera was able to capture a frame:", Date())
//
//        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        // CoreML 모델 선택하기 - Resnet50
//        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
//            return
//        }
//
//        // CoreML request
//        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
//
//            // perhaps check the err
//
//            guard let results = finishReq.results as? [VNClassificationObservation] else {
//                return
//            }
//
//            guard let firstObservation = results.first else {
//                return
//            }
//
//            print(firstObservation.identifier, firstObservation.confidence)
//        }
//
//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
