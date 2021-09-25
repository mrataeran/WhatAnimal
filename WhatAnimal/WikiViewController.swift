//
//  WikiViewController.swift
//  WhatAnimal
//
//  Created by Ata Eran on 9/22/21.
//

import UIKit
import SDWebImage

class WikiViewController: UIViewController {
    
    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var animalDesctiptionLabel: UILabel!
    var imgUrl = ""
    var desc = ""
    
    override func viewDidLoad() {
        animalImageView.sd_setImage(with: URL(string: imgUrl))
        animalDesctiptionLabel.text = desc
    }
}
