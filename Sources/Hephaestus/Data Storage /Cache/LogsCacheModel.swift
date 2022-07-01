
import Foundation

final class LogsCacheModel {
    var dataBaseRowId: Int64?
    var requestMethod: String
    var responseText: String
    var requestText: String
    var requestTime: Date
    var responseTime: Date
    
    init(requestMethod: String, responseText: String, requestText: String, requestTime: Date, responseTime: Date) {
        self.requestMethod = requestMethod
        self.responseText = responseText
        self.requestText = requestText
        self.requestTime = requestTime
        self.responseTime = responseTime
    }
    
    init(dataBaseRowId: Int64, requestMethod: String, responseText: String, requestText: String, requestTime: Date, responseTime: Date) {
        self.dataBaseRowId = dataBaseRowId
        self.requestMethod = requestMethod
        self.responseText = responseText
        self.requestText = requestText
        self.requestTime = requestTime
        self.responseTime = responseTime
    }
    
    var requestTimeString: String {
        return convertDateToString(date: requestTime)
    }
    
    var responseTimeString: String {
        return convertDateToString(date: responseTime)
    }
    
    var duration: String  {
        return String(format: "%.3f", responseTime.timeIntervalSince(requestTime))
    }
    
    private func convertDateToString(date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone.current
        outputFormatter.dateFormat = "dd.MM.yy, HH:mm:ss"
        return outputFormatter.string(from: date)
    }
}
