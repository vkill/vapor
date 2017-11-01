import Async
import HTTP

/// Middleware that adds support for CORS settings in request responses.
/// For configuration of this middleware please use the `CORSMiddleware.Configuration` object.
///
/// - Note: Make sure this middleware is inserted before all your error/abort middlewares,
///         so that even the failed request responses contain proper CORS information.
public final class CORSMiddleware: Middleware {
    /// Configuration used for populating headers in response for CORS requests.
    public let configuration: Configuration
    
    /// Creates a CORS middleware with the specified configuration.
    ///
    /// - Parameter configuration: Configuration used for populating headers in
    ///                            response for CORS requests.
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Check if it's valid CORS request
        guard request.headers["Origin"] != nil else {
            return try next.respond(to: request)
        }
        
        // Determine if the request is pre-flight.
        // If it is, create empty response otherwise get response from the responder chain.
        let response = request.isPreflight ? Future(Response()) : try next.respond(to: request)
        
        return response.map { response in
            // Modify response headers based on CORS settings
            response.headers[.accessControlAllowOrigin] = self.configuration.allowedOrigin.header(forRequest: request)
            response.headers[.accessControlAllowHeaders] = self.configuration.allowedHeaders
            response.headers[.accessControlAllowMethods] = self.configuration.allowedMethods
            
            if let exposedHeaders = self.configuration.exposedHeaders {
                response.headers["Access-Control-Expose-Headers"] = exposedHeaders
            }
            
            if let cacheExpiration = self.configuration.cacheExpiration {
                response.headers["Access-Control-Max-Age"] = String(cacheExpiration)
            }
            
            if self.configuration.allowCredentials {
                response.headers["Access-Control-Allow-Credentials"] = "true"
            }
            
            return response
        }
    }
}

extension Request {
    /// Returns `true` if the request is a pre-flight CORS request.
    var isPreflight: Bool {
        return method == .options && headers[.accessControlRequestHeaders] != nil
    }
}
