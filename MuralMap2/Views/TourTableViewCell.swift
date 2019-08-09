//
//  TourTableViewCell.swift
//  MuralMap2
//
//  Created by Colin Smith on 8/8/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit

class TourTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var tourNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func constrainStackView(){
        //        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        //        labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        //        labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 16).isActive = true
        //        labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -16).isActive = true
        //        labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
}
