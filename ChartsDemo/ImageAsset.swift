//
//  ImageAsset.swift
//  ChartsDemo
//
//  Created by Prateek Sharma on 7/23/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


enum ImageAsset: String {
    case diamond
}

extension UIImage {
    
    convenience init?(asset: ImageAsset) {
        self.init(named: asset.rawValue)
    }
    
}
