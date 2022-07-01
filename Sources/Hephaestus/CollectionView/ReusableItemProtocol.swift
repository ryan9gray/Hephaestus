//
//  ReusableItemProtocol.swift
//  
//
//  Created by Сергей Каменский on 13.08.2021.
//

public protocol ReusableItem: AnyObject {
	static var identifier: String { get }
}

public extension ReusableItem {
	static var identifier: String {
		String(describing: self)
	}
}
