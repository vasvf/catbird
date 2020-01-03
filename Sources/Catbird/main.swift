import CatbirdApp
import Foundation

// TODO: CLI
let enviroment = ProcessInfo.processInfo.environment
let mocksDir = enviroment["CATBIRD_MOCKS_DIR", default: currentDirectoryPath + "/Mocks"]

let app: App = {
    if let path = enviroment["CATBIRD_PROXY_URL"], let url = URL(string: path) {
        fatalError("TODO \(url)")
    }
    return App.read(at: URL(string: mocksDir)!)
}()

try app.start(port: 8080)
