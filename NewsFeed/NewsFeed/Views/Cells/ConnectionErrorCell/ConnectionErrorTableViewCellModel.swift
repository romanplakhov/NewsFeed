//
//  ConnectionErrorTableViewCellModel.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import RxSwift

class ConnectionErrorTableViewCellModel {
	var retryAction: ()->()
	
	var retryButtonTapped = PublishSubject<Void>()
	
	let bag = DisposeBag()
	
	init(retryAction: @escaping ()->()) {
		self.retryAction = retryAction
		
		retryButtonTapped.subscribe(onNext: {
			self.retryAction()
		}).disposed(by: bag)
	}
}
