//
//  UIT.swift
//  tableview
//
//  Created by Алексей  Червон  on 25.12.17.
//  Copyright © 2017 eInternetFunAlexChervon. All rights reserved.
//  Представление ячейки

import UIKit

class TableCell: UITableViewCell {
    

    @IBOutlet weak var SongName: UILabel!
    @IBOutlet weak var SongArtist: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
   

    override func awakeFromNib() {
        buttonPlay.layer.cornerRadius = 0.5 * buttonPlay.bounds.size.width
        buttonPlay.clipsToBounds = true
        buttonPlay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    override func prepareForReuse() {
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }

}
