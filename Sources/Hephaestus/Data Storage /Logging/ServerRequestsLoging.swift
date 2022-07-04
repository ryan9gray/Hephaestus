
import Foundation

protocol ServerRequestsLoging {

}

extension ServerRequestsLoging where Self: CachableRequeste {

    func saveLogToCache(
        requestLogModel: RequestLogModel,
        responseText: String,
        responseTime: Date
    ) {
        LogsCacher.common.addLog(
            logModel: LogsCacheModel(
                requestMethod: requestLogModel.requestMethod,
                responseText: responseText,
                requestText: requestLogModel.requestText,
                requestTime: requestLogModel.requestTime,
                responseTime: responseTime
            )
        )
	}
}

final class RequestLogModel {
	var requestMethod: String
	var requestText: String
	var requestTime: Date

	init(requestMethod: String, requestText: String, requestTime: Date) {
		self.requestMethod = requestMethod
		self.requestText = requestText
		self.requestTime = requestTime
	}
}
