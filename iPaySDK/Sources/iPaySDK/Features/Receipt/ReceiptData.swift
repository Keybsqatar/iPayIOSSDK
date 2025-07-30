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
}
