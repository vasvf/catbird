import Foundation
import CatbirdAPI
import Nest

public let currentDirectoryPath: String = {
    #if Xcode
    return #file.components(separatedBy: "/Sources")[0]
    #else
    return FileManager.default.currentDirectoryPath
    #endif
}()

/// Catbird server apllication.
public class App: Server {

    public static func read(at url: URL) -> App {
        return ReaderApp()
    }

    let configuration = Nest.Application.Configuration(
        logger: Logger(label: "com.redmadrobot.catbird")
    )

    func routes(_ router: inout Router) {
        router.middlewares = [
            ErrorMiddleware(),
            LoggerMiddleware(logger: configuration.logger),
            FileMiddleware(
                directory: URL(string: "/\(currentDirectoryPath)/Public")!,
                fileIO: configuration.fileIO)
        ]
    }

    // MARK: - Server

    public final func start(_ address: SocketAddress) throws {
        let app = Nest.Application(configuration: configuration, routes: routes)
        try app.start(address)
    }
}

final class ReaderApp: App {

    override func routes(_ router: inout Router) {
        super.routes(&router)
    }
}
