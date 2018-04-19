//
//  SSFBackgroundCollectionViewController.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2017/1/12.
//  Copyright © 2017年 赛峰 施. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BackgroundCell"

class SSFBackgroundCollectionViewController: UICollectionViewController {

    var allColors = [UIColor.white,UIColor.red,UIColor.black,UIColor.green,UIColor.blue,UIColor.orange,UIColor.purple,UIColor.yellow,UIColor.darkGray]
    
    weak var delegate: SSFBackgroundCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return allColors.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.backgroundColor = allColors[indexPath.row]
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let color = allColors[indexPath.row]
        self.dismiss(animated: true) { 
            self.delegate?.backgroundCollectionViewController(self, didSelectColor: color)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tem = allColors[sourceIndexPath.row]
        allColors.remove(at: sourceIndexPath.row)
        allColors.insert(tem, at: destinationIndexPath.row)
    }
    
    //MARK: Set to landscape
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}

protocol SSFBackgroundCollectionViewControllerDelegate: class {
    func backgroundCollectionViewController(_ controller: SSFBackgroundCollectionViewController, didSelectColor color: UIColor)
}
