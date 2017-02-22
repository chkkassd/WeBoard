//
//  SSFMainCollectionViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/12.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

class SSFMainCollectionViewController: UICollectionViewController ,RecordPathProtocol {

    var allData: [SSFWeBoard]? {
        
        let path = pathOfArchivedWeBoard()
        guard let arr = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Array<SSFWeBoard> else {
            return nil
        }
        if arr.count == 0, isEdited { isEdited = false }
        return arr
    }
    
    var selectedWeboard: SSFWeBoard?
    
    ///Whether is edited model,default is false
    var isEdited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: DefaultUpdateWeBoardList), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Present to record
    
    @IBAction func recordButtonPressed(_ sender: UIBarButtonItem) {
        if !isEdited {
            self.performSegue(withIdentifier: "showRecordController", sender: self)
        }
    }
    
    // MARK: Edite and animation
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        isEdited = !isEdited
        if isEdited {
            self.collectionView?.visibleCells.forEach { cell in
                let mainCell = cell as! MainCollectionViewCell
                mainCell.deleteButton.isHidden = false
                shakeAnimation(mainCell)
            }
        } else {
            self.collectionView?.visibleCells.forEach { cell in
                let mainCell = cell as! MainCollectionViewCell
                mainCell.deleteButton.isHidden = true
                endShakeAnimation(cell)
            }
        }
    }
    
    private func shakeAnimation(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [angle2Radian(-1.0), angle2Radian(1.0), angle2Radian(-1.0)]
        animation.duration = 0.25
        animation.repeatCount = MAXFLOAT
        animation.fillMode = kCAFillModeForwards
        view.layer.add(animation, forKey: "shake")
    }
    
    private func endShakeAnimation(_ view: UIView) {
        view.layer.removeAllAnimations()
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifierString = segue.identifier else { return }
        if identifierString == "showPlayerController" {
            let vc = segue.destination as! SSFPlayerViewController
            vc.weBoard = selectedWeboard
        }
    }
    
    // MARK: Update the list view
    @objc func updateList() {
        self.collectionView?.reloadData()
    }
    
    // MARK: Delete a weboard and reload collection view
    
    private func delete(_ weboard: SSFWeBoard) -> Bool {
        try? FileManager.default.removeItem(at: weboard.directoryURL)
        guard let weboards = allData else { return false }
        let newBoards = weboards.reject { $0.directoryURL == weboard.directoryURL }
        return NSKeyedArchiver.archiveRootObject(newBoards, toFile: pathOfArchivedWeBoard())
    }
    
    private func deleteAndReload(_ weboard: SSFWeBoard, _ index: IndexPath) {
        if delete(weboard) {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let all = allData else {
            return 0
        }
        return all.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "MainCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        
        guard let allWeBoards = allData else { return cell }
        let weBoard = allWeBoards[indexPath.row]
        // Configure the cell
        cell.titleLabel.text = weBoard.title
        cell.timeLabel.text = weBoard.time.timeFormatString()
        if FileManager.default.fileExists(atPath: weBoard.coverImagePath) {
            cell.coverImageView.image = UIImage(contentsOfFile: weBoard.coverImagePath)
        } else {
        }
        
        cell.deleteCompletion = { //[unowned self] in
            //Delete operation
            cell.layer.removeAllAnimations()
            self.deleteAndReload(weBoard, indexPath)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var allWeBoards = allData else { return }
        let tem = allWeBoards[sourceIndexPath.row]
        allWeBoards.remove(at: sourceIndexPath.row)
        allWeBoards.insert(tem, at: destinationIndexPath.row)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEdited {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedWeboard = allData?[indexPath.row]
            self.performSegue(withIdentifier: "showPlayerController", sender: self)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isEdited {
            let mainCell = cell as! MainCollectionViewCell
            mainCell.deleteButton.isHidden = false
            shakeAnimation(mainCell)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isEdited {
            let mainCell = cell as! MainCollectionViewCell
            mainCell.deleteButton.isHidden = true
            endShakeAnimation(mainCell)
        }
    }
}
