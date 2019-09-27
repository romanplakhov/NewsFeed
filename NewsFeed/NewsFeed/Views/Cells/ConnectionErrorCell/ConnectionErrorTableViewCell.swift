//
//  ConnectionErrorTableViewCell.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ConnectionErrorTableViewCell: UITableViewCell {

	@IBOutlet weak var retryButton: UIButton!
	var viewModel: ConnectionErrorTableViewCellModel! {
		didSet {
			retryButton.rx
				.tap
				.bind(to: viewModel.retryButtonTapped)
				.disposed(by: bag)
		}
	}
	
	let bag = DisposeBag()
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
