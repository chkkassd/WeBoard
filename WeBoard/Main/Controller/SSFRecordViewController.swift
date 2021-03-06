//
//  SSFRecordViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/20.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

let DefaultUpdateWeBoardList = "DefaultUpdateWeBoardList"

class SSFRecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.isiPhoneX() {
            self.startButton.frame = self.startButton.frame.offsetBy(dx: 30, dy: 0)
        }
    }
    //MARK: Action
    
    deinit {
        print("record vc deinit")
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion:{
            self.clearAll()
            self.canvasView.endAndFree()
        })
    }
    
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            canvasView.brushColor = UIColor.red
        case 101:
            canvasView.brushColor = UIColor.black
        case 102:
            canvasView.brushColor = UIColor.blue
        case 103:
            canvasView.brushWidth = 15.0
        case 104:
            canvasView.brushWidth = 10.0
        case 105:
            canvasView.brushWidth = 5.0
        default: break
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        if !SSFRecorder.sharedInstance.isRecording {
            presentImagePickerViewController(withSourceType: UIImagePickerController.SourceType.camera)
        }
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if !SSFRecorder.sharedInstance.isRecording {
            presentImagePickerViewController(withSourceType: UIImagePickerController.SourceType.photoLibrary)
        }
    }
    
    @IBAction func backgroundImageButtonPressed(_ sender: UIButton) {
        if !SSFRecorder.sharedInstance.isRecording {
            self.performSegue(withIdentifier: "showBackgroundCollectionViewController", sender: self)
        }
    }
    
    @IBAction func revokeAStrokeButtonPressed(_ sender: UIButton) {
        var points: [SSFPoint] = []
        if SSFRecorder.sharedInstance.isRecording {
            guard allRecordingDrawingLines.count > 0 else { return }
            allRecordingDrawingLines = Array(allRecordingDrawingLines.dropLast())
            points = allRecordingDrawingLines.flatMap{ return $0.pointsOfLine }
        } else {
            guard allBackgroundDrawingLines.count > 0 else { return }
            allBackgroundDrawingLines = Array(allBackgroundDrawingLines.dropLast())
            points = allBackgroundDrawingLines.flatMap{ return $0.pointsOfLine }
        }
        
        if points.count >= 0 {
            if SSFRecorder.sharedInstance.isRecording {
                canvasView.drawBackground(withImage: backgroundImage!)
            } else {
                canvasView.drawBackground(withColor: backgroundColor)
            }
            canvasView.drawLines(withPoints: points, withPriviousPoint: points.first ?? SSFPoint.defaultZeroPoint)
        }
    }
    
    @IBAction func revokeAllButtonPressed(_ sender: UIButton) {
        if !SSFRecorder.sharedInstance.isRecording {
            showClearAllAlert()
        }
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected,!SSFRecorder.sharedInstance.isRecording, SSFRecorder.sharedInstance.audioRecoder == nil {
            startRecord()
        } else if !sender.isSelected, SSFRecorder.sharedInstance.isRecording {
            pauseRecord()
            showActionSheet()
        }
    }
    
    //MARK: Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier?.isEqual("showBackgroundCollectionViewController"))! {
            let vc = segue.destination as! SSFBackgroundCollectionViewController
            vc.delegate = self
        }
    }
    
    func getScaledCoverImage() -> UIImage? {
        guard let image = SSFScreenShot.screenShot(withView: canvasView) else { return nil }
        let ratio = image.size.height / image.size.width
        let scaledRect = CGRect(x: 0, y: 0, width: 100.0, height: 100.0 * ratio)
        return image.scaledImage(scaledRect, 0.8)
    }
    
    //MARK: Property
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var canvasView: SSFCanvasView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    var timer: Timer?
    
    ///The drawing lines in recording
    var allRecordingDrawingLines: [SSFLine] = []
    
    ///The drawing lines before recording,it's used to background
    var allBackgroundDrawingLines: [SSFLine] = []
    
    ///The background image of start time
    var backgroundImage: UIImage?
    
    ///The small cover image of end time,then this image is used to display when listting all weboards
    var coverImage: UIImage?
    
    ///All points of a line which is drawing
    var pointsOfCurrentLine: [SSFPoint] = []
    
    ///All elements view which used to configure background
    var allElements: [SSFElementView] = []
    
    ///Background color
    var backgroundColor: UIColor = UIColor.white
    
    //MARK: Set to landscape
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}

extension SSFRecordViewController {
    
    private func presentImagePickerViewController(withSourceType sourcetype: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourcetype
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .popover
        
        if UIImagePickerController.isSourceTypeAvailable(sourcetype) {
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    private func showActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let resumeAction = UIAlertAction(title: "继续", style: UIAlertAction.Style.default) {  _ in
            self.startButton.isSelected = !self.startButton.isSelected
            self.resumeRecord()
        }
        let clearAction = UIAlertAction(title: "废弃", style: UIAlertAction.Style.default) { _ in
            self.clearAll()
        }
        let saveAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default) { _ in
            self.endAndSaveRecord()
        }
        alert.addAction(resumeAction)
        alert.addAction(clearAction)
        alert.addAction(saveAction)
        
        if case .pad = checkDevice() {
            let popover = alert.popoverPresentationController
            popover?.sourceView = self.startButton
            popover?.sourceRect = self.startButton.bounds
            popover?.permittedArrowDirections = .left
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showClearAllAlert() {
        let alert = UIAlertController(title: nil, message: "确认清除所有绘制?", preferredStyle: UIAlertController.Style.alert)
        let sureAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { _ in
            self.clearAll()
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(sureAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Recorder control
    
    private func startRecord() {
        //1.Crop the canvas view and use to draw backgroundimage
        backgroundImage = SSFScreenShot.screenShot(withView: canvasView)
        canvasView.drawBackground(withImage: (backgroundImage !! "crop backgroundImage fail"))
        allElements.forEach { $0.removeFromSuperview() }
        
        //2.start to record sound
        SSFRecorder.sharedInstance.startAudioRecord()
        
        //3.timelabel start to work
        startTimer()
    }
    
    private func pauseRecord() {
        SSFRecorder.sharedInstance.pauseAudioRecord()
        endTimer()
    }
    
    private func resumeRecord() {
        SSFRecorder.sharedInstance.resumeAudioRecorder()
        startTimer()
    }
    
    private func endAndSaveRecord() {
        coverImage = getScaledCoverImage()
        SSFRecorder.sharedInstance.endAndSave(penLines: allRecordingDrawingLines, backgroundImage: backgroundImage!, coverImage: coverImage!) { result in
            switch result {
            case .success(_):
                SwiftNotice.showNoticeWithText(.success, text: "保存成功", autoClear: true, autoClearTime: 2)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DefaultUpdateWeBoardList), object: nil)
                self.perform(#selector(self.backButtonPressed), with: nil, afterDelay: 2.0)
            case .failure(let error):
                let recordError = error as! RecordError
                SwiftNotice.showNoticeWithText(.success, text: recordError.errorDescription!, autoClear: true, autoClearTime: 2)
            }
        }
    }
    
    private func clearAll() {
        //1.clear canvas
        canvasView.drawBackground(withColor: UIColor.white)
        allRecordingDrawingLines = []
        allBackgroundDrawingLines = []
        pointsOfCurrentLine = []
        backgroundImage = nil
        coverImage = nil
        allElements.forEach { $0.removeFromSuperview() }
        allElements = []
        backgroundColor = UIColor.white
        
        //2.clear audiorecorder
        SSFRecorder.sharedInstance.endAudioRecord()
        endTimer()
        
        //3.clear view
        timeLabel.text = "00:00"
        startButton.isSelected = false
    }
    
    // MARK: timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFinished(timer:)), userInfo: nil, repeats: true)
    }
    
    private func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFinished(timer: Timer) {
        self.timeLabel.text = SSFRecorder.sharedInstance.currentTime.timeFormatString()
    }
}

extension SSFRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] else { picker.dismiss(animated: true, completion: nil)
            return}
        picker.dismiss(animated: true) { 
           self.addElement(image: image as! UIImage)
        }
    }
    
    private func addElement(image: UIImage) {
        let elementView = SSFElementView(image: image)
        allElements.append(elementView)
        self.canvasView.addSubview(elementView)
    }
}

extension SSFRecordViewController: SSFBackgroundCollectionViewControllerDelegate {
    func backgroundCollectionViewController(_ controller: SSFBackgroundCollectionViewController, didSelectColor color: UIColor) {
        self.canvasView.drawBackground(withColor: color)
        self.backgroundColor = color
    }
}

extension SSFRecordViewController: SSFCanvasViewDelegate {
    func canvasView(touchBeganAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool) {
        pointsOfCurrentLine = []
        let ssfPoint = SSFPoint(point: point, time: SSFRecorder.sharedInstance.currentTime, color: color, width: width, isStartOfLine: isStart)
        pointsOfCurrentLine.append(ssfPoint)
    }
    
    func canvasView(touchMoveAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool) {
        let ssfPoint = SSFPoint(point: point, time: SSFRecorder.sharedInstance.currentTime, color: color, width: width, isStartOfLine: isStart)
        pointsOfCurrentLine.append(ssfPoint)
    }
    
    func canvasView(touchEndAt point: CGPoint, withLineColor color: UIColor, withLineWidth width: Double, isStartOfLine isStart: Bool) {
        let ssfPoint = SSFPoint(point: point, time: SSFRecorder.sharedInstance.currentTime, color: color, width: width, isStartOfLine: isStart)
        pointsOfCurrentLine.append(ssfPoint)
        let currentLine = SSFLine(pointsOfLine: pointsOfCurrentLine, color: color, width: width)
        
        if SSFRecorder.sharedInstance.isRecording {
            allRecordingDrawingLines.append(currentLine)
        } else {
            allBackgroundDrawingLines.append(currentLine)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
