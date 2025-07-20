import Foundation

public struct ProductsRequest: Codable {
    public let mobileNumber: String
    public let serviceCode:  String
    public let countryCode:  String
    public let providerCode: String
}

public struct SettingDefinition: Codable, Sendable {
    public let Name: String
    public let Description: String
    public let IsMandatory: Bool
}

public struct ProductItem: Identifiable, Codable, Sendable {
    public var id: UUID = .init()
    
    public let skuCode: String
    public let providerCode: String
    public let countryIso: String
    public let displayText: String
    public let sendValue: String
    public let sendCurrencyIso: String
    public let sendValueMax: String
    public let settingDefinitions: [SettingDefinition]
    
    enum CodingKeys: String, CodingKey {
        case skuCode, providerCode, countryIso, displayText, sendValue, sendCurrencyIso, sendValueMax, settingDefinitions
    }

    public init(
        id: UUID = .init(),
        skuCode: String,
        providerCode: String,
        countryIso: String,
        displayText: String,
        sendValue: String,
        sendCurrencyIso: String,
        sendValueMax: String,
        settingDefinitions: [SettingDefinition]
    ) {
        self.id = id
        self.skuCode = skuCode
        self.providerCode = providerCode
        self.countryIso = countryIso
        self.displayText = displayText
        self.sendValue = sendValue
        self.sendCurrencyIso = sendCurrencyIso
        self.sendValueMax = sendValueMax
        self.settingDefinitions = settingDefinitions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        skuCode = try container.decode(String.self, forKey: .skuCode)
        providerCode = try container.decode(String.self, forKey: .providerCode)
        countryIso = try container.decode(String.self, forKey: .countryIso)
        displayText = try container.decode(String.self, forKey: .displayText)
        sendCurrencyIso = try container.decode(String.self, forKey: .sendCurrencyIso)
        settingDefinitions = try container.decodeIfPresent([SettingDefinition].self, forKey: .settingDefinitions) ?? []
        
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
        
        // Try to decode as Float, Int, or String, then convert to String
        if let floatValueMax = try? container.decode(Float.self, forKey: .sendValueMax) {
            if floatValueMax.truncatingRemainder(dividingBy: 1) == 0 {
                sendValueMax = String(format: "%.0f", floatValueMax)
            } else {
                sendValueMax = String(floatValueMax)
            }
        } else if let intValue = try? container.decode(Int.self, forKey: .sendValueMax) {
            sendValueMax = String(intValue)
        } else {
            sendValueMax = try container.decode(String.self, forKey: .sendValueMax)
        }
    }
}

public struct ProductsResponse: Codable {
    public let status: String
    public let items:  [ProductItem]
}
