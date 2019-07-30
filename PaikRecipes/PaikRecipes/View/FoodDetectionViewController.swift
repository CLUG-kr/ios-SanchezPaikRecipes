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

    @IBOutlet weak private var previewView: UIView!    
    private let captureSession = AVCaptureSession()

    // 재료 추가 시 알림
    @IBOutlet weak var animateAddImageView: UIImageView!

    // Image Classifier 결과 출력
    @IBOutlet weak var classificationLabel: UILabel!

    var currentIngredient:String = ""
    var currentConfidence:Float = 0.0

    // 카메라에 보이는 식재료를 담는 Set (중복 제거)
    private var ingredients:Set<String> = []

    var hanguelIngredient:String = ""

    @IBAction func addIngredient(_ sender: Any) {

        // 재료 모음에 추가
        ingredients.insert(hanguelIngredient)

        // 재료를 추가했습니다! 알림 주기
        animateAddIngredient()
    }

    @IBAction func findRecipe(_ sender: Any) {
        captureSession.stopRunning()
    }

    // 애니메이션 효과 지정
    func animateAddIngredient() {
        // fade in 속도
        UIView.animate(withDuration: 0.5, animations: {
            self.animateAddImageView.alpha = 1.0
        }, completion: {
            (Completed: Bool) -> Void in
            // fade out 속도
            UIView.animate(withDuration: 0.5, delay: 1.0, options: UIView.AnimationOptions.curveLinear, animations: {
                self.animateAddImageView.alpha = 0
            }, completion: nil
                // 반복하려면 (무한히 깜빡거리기?)
                /*{(Completed:Bool) -> Void in
                 self.animateAlarm()
                 }*/)
        })
    }

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
        previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = previewView.frame

        // 카메라 Output 데이터로 사용하기
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }

    @objc func updateClassificationLabel() {
        switch currentIngredient {
        case "egg":
            if currentConfidence >= 1.0 {
                hanguelIngredient = "달걀"
            } else {
                hanguelIngredient = ""
            }
        case "carrot":
            hanguelIngredient = "당근"
        case "pork":
            hanguelIngredient = "돼지고기"
        case "onion":
            hanguelIngredient = "양파"
        case "greenOnion":
            hanguelIngredient = "대파"
        default:
            hanguelIngredient = ""
        }
        self.classificationLabel.text = hanguelIngredient
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // AVCaptureSession 사용
        capture()

//        DispatchQueue.global().async(execute: {
//            DispatchQueue.main.async {
//                self.classificationLabel.text = self.currentIngredient
//            }
//        })

        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.updateClassificationLabel)), userInfo: nil, repeats: true)

        animateAddImageView.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {

        // 담았던 재료 초기화
        ingredients = []

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

//     IngredientsClassifier.mlmodel
//     Delegate 메소드 : AVCaptureVideoDataOutputSampleBufferDelegate
//     Camera의 각 frame에 대해서 동작
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // CoreML 모델 선택하기 - Resnet50
        guard let model = try? VNCoreMLModel(for: IngredientsClassifier().model) else {
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

            // self.classificationLabel.text = firstObservation.identifier
            self.currentIngredient = firstObservation.identifier
            self.currentConfidence = firstObservation.confidence

            print(firstObservation.identifier, firstObservation.confidence)
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        var matchRecipe:Recipe?
        var maxMatchCount:Int = 0
        var matchCount = 0
        for recipe in dataCenter.recipe {
            for ingredient in ingredients {
                if recipe.ingredientsName.contains(ingredient) {
                    matchCount += 1
                }
            }
            if maxMatchCount < matchCount {
                maxMatchCount = matchCount
                matchRecipe = recipe
                matchCount = 0
            }
        }

        dataCenter.foundRecipe = matchRecipe

//        if let recipeTVC = segue.destination as? RecipeTableViewController {
//            recipeTVC.segueRecipe = matchRecipe
//        }
    }
}
