import Foundation

public struct ApiError: Decodable, Sendable {
    public let status:  Int?
    public let error:   String?
    public let message: String?
    public let messages: Messages?
    
    public struct Messages: Decodable, Sendable {
        public let error: String?
    }
    
    public init(
        status: Int?,
        error: String?,
        message: String?,
        messages: Messages?
    ) {
        self.status   = status
        self.error    = error
        self.message  = message
        self.messages = messages
    }
    
    enum CodingKeys: String, CodingKey {
        case status, error, message, messages
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        // decode status normally
        self.status = try? c.decodeIfPresent(Int.self, forKey: .status)
        
        // top-level "error" might be String _or_ Int
        if let s = try? c.decodeIfPresent(String.self,  forKey: .error) {
            self.error = s
        } else if let i = try? c.decodeIfPresent(Int.self,     forKey: .error) {
            self.error = String(i)
        } else {
            self.error = nil
        }
        
        // decode "message" if present
        self.message = try? c.decodeIfPresent(String.self, forKey: .message)
        
        // decode nested messages container
        self.messages = try? c.decodeIfPresent(Messages.self, forKey: .messages)
    }
    
    /// your original logic, but now `messages.error` will live on
    public func userMessage() -> String {
        return message
        ?? messages?.error
        ?? error
        ?? "Unknown error (status=\(status ?? -1))"
    }
}

//public struct ApiError: Codable {
//  public let status:   Int?
//  public let error:    String?
//  public let message:  String?
//  public let messages: ErrorMessages?
//
//  public struct ErrorMessages: Codable {
//    public let error: String?
//  }
//
//  public func userMessage() -> String {
//    return message
//        ?? messages?.error
//        ?? error
//        ?? "Unknown error (status=\(status ?? -1))"
//  }
//}
