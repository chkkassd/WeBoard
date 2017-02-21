//
//  MainCollectionViewCell.swift
//  WeBoard
//
//  Created by 赛峰 施 on 2016/12/12.
//  Copyright © 2016年 赛峰 施. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let completion = deleteCompletion else { return }
        completion()
    }
    
    var deleteCompletion: (() -> Void)?
}
