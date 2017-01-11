//
//  SSFRecordViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/20.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

class SSFRecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: Action
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        presentImagePickerViewController(withSourceType: UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        presentImagePickerViewController(withSourceType: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func backgroundImageButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func revokeAStrokeButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func revokeAllButtonPressed(_ sender: UIButton) {
        
    }
    
    //MARK: Methods
    
    private func presentImagePickerViewController(withSourceType sourcetype: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourcetype
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .popover
                
        if UIImagePickerController.isSourceTypeAvailable(sourcetype) {
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: Property
    
    @IBOutlet var canvasView: SSFCanvasView!
    
    //MARK: Set to landscape
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}

extension SSFRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] else { picker.dismiss(animated: true, completion: nil); return}
        picker.dismiss(animated: true) { 
           self.addElement(image: image as! UIImage)
        }
    }
    
    private func addElement(image: UIImage) {
        let elementView = SSFElementView(image: image)
        self.canvasView.addSubview(elementView)
    }
}
