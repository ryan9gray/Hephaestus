//
//  LogService.swift
//  Mems
//
//  Created by Evgeny Ivanov on 04.05.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

final class LogService {
	static var log: URL {
		let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		return URL(fileURLWithPath: documentsPath).appendingPathComponent("log.txt")
	}

	/// Log size in MB
	private static var logSize: Double {
		let attributes = try? FileManager.default.attributesOfItem(atPath: log.path)
		let size = attributes?[FileAttributeKey.size] as? Double
		let sizeMB = (size ?? 0)/1024/1024
		return sizeMB
	}

	/// Log size threshold in MB
	private static var logSizeThreshold: Double {
		return 5.0
	}

	/// Returns log text
	static func lastLog() -> String? {
		guard FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil else { return nil }
		return try? String(contentsOf: log)
	}

	private static var queue = DispatchQueue(label: "hefestos.log.queue", attributes: .concurrent)

	static func appendLog(with string: String) {
		queue.async {
			var fullLog: String = ""
			if let lastLog = lastLog() {
				if logSize > logSizeThreshold {
					let index = lastLog.index(lastLog.startIndex, offsetBy: lastLog.count / 2)
					let abridgedLastLog = String(lastLog[index...])
					fullLog.append(abridgedLastLog + "\n")
				} else {
					fullLog.append(lastLog + "\n")
				}
				do {
					fullLog.append(string)
					try fullLog.write(to: log, atomically: true, encoding: .utf8)
				}
				catch let error {
					print(error)
				}
			} else {
				do {
					fullLog.append(string)
					try fullLog.write(to: log, atomically: true, encoding: .utf8)
				}
				catch let error {
					print(error)
				}
			}
		}
	}
}
