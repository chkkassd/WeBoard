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
        return arr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: DefaultUpdateWeBoardList), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Update the list view
    @objc func updateList() {
        self.collectionView?.reloadData()
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
            print("=======\(weBoard.coverImagePath)")
        } else {
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
}
