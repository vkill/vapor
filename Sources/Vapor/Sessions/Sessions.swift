/// Capable of managing CRUD operations for `Session`s.
public protocol Sessions {
    func createSession(
        _ data: SessionData,
        for request: Request
    ) -> EventLoopFuture<SessionID>
    
    func readSession(
        _ sessionID: SessionID,
        for request: Request
    ) -> EventLoopFuture<SessionData?>
    
    func updateSession(
        _ sessionID: SessionID,
        to data: SessionData,
        for request: Request
    ) -> EventLoopFuture<SessionID>
    
    func deleteSession(
        _ sessionID: SessionID,
        for request: Request
    ) -> EventLoopFuture<Void>
}
