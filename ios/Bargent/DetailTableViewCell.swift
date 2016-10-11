//
//  DetailTableViewCell.swift
//  Nessie-iOS-Wrapper
//
//  Created by Ivan Chau on 10/9/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var goods : UILabel!
    @IBOutlet weak var price : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
