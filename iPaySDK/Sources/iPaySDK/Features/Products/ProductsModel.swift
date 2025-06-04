import Foundation

public struct ProductsRequest: Codable {
    public let mobileNumber: String
    public let serviceCode:  String
    public let countryCode:  String
    public let providerCode: String
}

public struct ProductItem: Identifiable, Codable, Sendable {
    public var id: UUID = .init()
    
    public let skuCode: String
    public let providerCode: String
    public let countryIso: String
    public let displayText: String
    public let sendValue: String
    public let sendCurrencyIso: String
    
    enum CodingKeys: String, CodingKey {
        case skuCode, providerCode, countryIso, displayText, sendValue, sendCurrencyIso
    }

    public init(
        id: UUID = .init(),
        skuCode: String,
        providerCode: String,
        countryIso: String,
        displayText: String,
        sendValue: String,
        sendCurrencyIso: String
    ) {
        self.id = id
        self.skuCode = skuCode
        self.providerCode = providerCode
        self.countryIso = countryIso
        self.displayText = displayText
        self.sendValue = sendValue
        self.sendCurrencyIso = sendCurrencyIso
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        skuCode = try container.decode(String.self, forKey: .skuCode)
        providerCode = try container.decode(String.self, forKey: .providerCode)
        countryIso = try container.decode(String.self, forKey: .countryIso)
        displayText = try container.decode(String.self, forKey: .displayText)
        sendCurrencyIso = try container.decode(String.self, forKey: .sendCurrencyIso)
        
        // Try to decode as Float, Int, or String, then convert to String
        if let floatValue = try? container.decode(Float.self, forKey: .sendValue) {
            if floatValue.truncatingRemainder(dividingBy: 1) == 0 {
                sendValue = String(format: "%.0f", floatValue)
            } else {
                sendValue = String(floatValue)
            }
        } else if let intValue = try? container.decode(Int.self, forKey: .sendValue) {
            sendValue = String(intValue)
        } else {
            sendValue = try container.decode(String.self, forKey: .sendValue)
        }
    }
}

public struct ProductsResponse: Codable {
    public let status: String
    public let items:  [ProductItem]
}
