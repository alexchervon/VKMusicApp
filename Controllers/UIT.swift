//
//  UIT.swift
//  tableview
//
//  Created by Алексей  Червон  on 25.12.17.
//  Copyright © 2017 eInternetFunAlexChervon. All rights reserved.
//

import UIKit

class UIT: UITableViewCell {
    
    var buttons = [UIButton]()
    var clickBTN = [UIButton]()
    @IBOutlet weak var btns: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
      
    }
    
    override func prepareForReuse() {
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
       
    }
    
    @IBAction func Play(_ sender: UIButton) {
    
    }

    
    
}
