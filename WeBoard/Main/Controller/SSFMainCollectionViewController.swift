//
//  SSFMainCollectionViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/12.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

class SSFMainCollectionViewController: UICollectionViewController {

    var allData = Array(repeating: 1, count: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "MainCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tem = allData[sourceIndexPath.row]
        allData.remove(at: sourceIndexPath.row)
        allData.insert(tem, at: destinationIndexPath.row)
    }
}
