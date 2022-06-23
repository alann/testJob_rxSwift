//
//  TopicCell.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit

class TopicCell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var topicLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {        super.setSelected(selected, animated: animated)
        
        if selected {
            selectedButton.setImage(UIImage(named: "selected"), for: .normal)
        } else {
            selectedButton.setImage(UIImage(named: "unselected"), for: .normal)
        }
    }
}
