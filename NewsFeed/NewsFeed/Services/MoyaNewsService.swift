//
//  MoyaNewsService.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import Moya

enum MoyaNewsService {
    case getNews(page: Int)
}

extension MoyaNewsService: TargetType {
	var headers: [String : String]? {
		return nil
	}
	
    var baseURL: URL { return URL(string: "https://newsapi.org/v2")! }
	
    var path: String {
        switch self {
        case .getNews:
            return "/everything"
		}
	}
		
	var method: Moya.Method {
		return .get
	}
		
	var sampleData: Data {
		return Data()
	}
		
	var task: Task {
		var params: [String: Any] = ["q" : "android",
									 "from" : "2019-04-00",
									 "sortBy" : "publishedAt",
									 "apiKey" : "26eddb253e7840f988aec61f2ece2907"]
		
		switch self {
		case .getNews(let page):
			params["page"] = page
		}
		
		return .requestParameters(parameters: params, encoding: URLEncoding.default)
	}
}
