//
//  NewsTableViewCell.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxKingfisher

class NewsTableViewCell: UITableViewCell {
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	let bag = DisposeBag()
	
	var viewModel: NewsTableViewCellModel! {
		didSet {
			viewModel.imageURLRelay
				.asObservable()
				.map{URL(string: $0)}
				.bind(to: pictureImageView.kf.rx.image(options: [.transition(.fade(0.2))]))
					.disposed(by: bag)
//				.map{imageUrl -> UIImage? in
//					DispatchQueue.global().async {
//						<#code#>
//					}
//					let image = UIImage() ?? UIImage(named: "image_placeholder")
//					return image
//				}
//				.bind(to: pictureImageView.rx.image)
//				.disposed(by: bag)
			
			viewModel.titleRelay
				.bind(to: titleLabel.rx.text)
				.disposed(by: bag)
			
			viewModel.descriptionRelay
				.bind(to: descriptionLabel.rx.text)
				.disposed(by: bag)
			
			viewModel.dateRelay
				.map {date -> String in
					let formatter = DateFormatter()
					formatter.dateFormat = "dd/MM/yyyy HH:mm"
					return (date != nil) ? formatter.string(from: date!) : ""
				}.bind(to: dateLabel.rx.text)
				.disposed(by: bag)
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
