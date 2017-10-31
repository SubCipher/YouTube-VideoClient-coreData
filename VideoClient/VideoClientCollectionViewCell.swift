//
//  VideoClientCollectionViewCell.swift
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
//setup collection cells imageView

class VideoClientCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoClientImageView: UIImageView!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexpath: IndexPath) -> CGSize{
        
        let itemWidth = collectionView.bounds.height / 120
        let itemHeight = collectionView.bounds.width / 120
        
        return CGSize(width: itemWidth,height: itemHeight)
    }
    
}
