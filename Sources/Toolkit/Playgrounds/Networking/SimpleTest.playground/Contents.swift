import UIKit
import Toolkit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let server = Server(serviceName: "Test", port: 1234)
let client1 = Client(serviceName: "Test")

server?.startListening()
client1.discoverAndConnect(networkProtocol: .tcp)





