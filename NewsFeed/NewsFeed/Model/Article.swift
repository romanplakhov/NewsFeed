//
//  Article.swift
//  NewsFeed
//
//  Created by Роман Плахов on 26/09/2019.
//  Copyright © 2019 Роман Плахов. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import UIKit

class Article: Object {
	@objc dynamic var author: String = ""
	@objc dynamic var title: String = ""
	@objc dynamic var articleDescription: String = ""
	@objc dynamic var url: String = ""
	@objc dynamic var urlToImage: String = ""
	@objc dynamic var publishedAt: String = ""
	@objc dynamic var content: String = ""
	
	var parsedDate: Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		let date = dateFormatter.date(from: publishedAt)!
		return date
	}
	
	override static func primaryKey() -> String? {
		return "url"
	}
	
	convenience init(author: String,
					 title: String,
					 articleDescription: String,
					 url: String,
					 urlToImage: String,
					 publishedAt: String,
					 content: String) {
		self.init()

		self.author = author
		self.title = title
		self.articleDescription = articleDescription
		self.url = url
		self.urlToImage = urlToImage
		self.publishedAt = publishedAt
		self.content = content
	}
	
	static func from(_ json: JSON) -> Article {
		
		return Article(author: json["author"].stringValue,
					   title: json["title"].stringValue,
					   articleDescription: json["description"].stringValue,
					   url: json["url"].stringValue,
					   urlToImage: json["urlToImage"].stringValue,
					   publishedAt: json["publishedAt"].stringValue,
					   content: json["content"].stringValue)
	}
}
