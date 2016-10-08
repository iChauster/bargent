//
//  BargentTableViewCell.swift
//  Nessie-iOS-Wrapper
//
//  Created by Ivan Chau on 10/8/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit

class BargentTableViewCell: UITableViewCell {
    @IBOutlet weak var percentageIncrease : UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var merchant : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 10;
        view.clipsToBounds = true;
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
