import Foundation
import SwiftUI

public struct ReceiptData {
    public let status: String
    
    public let amount: String
    public let dateTime: String
    public let type: String
    public let number: String
    public let operatorName: String
    public let refId: String
    
    public let countryName: String
    public let countryFlagUrl: URL
    public let providerName: String
    public let providerLogoUrl: URL
    public let product: ProductItem
    
    public let readMoreMarkdown: String
    public let descriptionMarkdown: String
    
    public let textPin: String
    public let valuePin: String
    
    public let isPending: Bool
    
    public init(
        status: String,

        amount: String,
        dateTime: String,
        type: String,
        number: String,
        operatorName: String,
        refId: String,

        countryName: String,
        countryFlagUrl: URL,
        providerName: String,
        providerLogoUrl: URL,
        product: ProductItem,

        readMoreMarkdown: String,
        descriptionMarkdown: String,

        textPin: String,
        valuePin: String,
        
        isPending: Bool = false
    ) {
        self.status = status

        self.amount = amount
        self.dateTime = dateTime
        self.type = type
        self.number = number
        self.operatorName = operatorName
        self.refId = refId

        self.countryName = countryName
        self.countryFlagUrl = countryFlagUrl
        self.providerName = providerName
        self.providerLogoUrl = providerLogoUrl
        self.product = product

        self.readMoreMarkdown = readMoreMarkdown
        self.descriptionMarkdown = descriptionMarkdown

        self.textPin = textPin
        self.valuePin = valuePin

        self.isPending = isPending
    }
}
