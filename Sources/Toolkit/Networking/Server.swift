//
//  Server.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 16..
//

import Foundation
import Network

open class Server: @unchecked Sendable {
    public var serverId: UUID = UUID()
    public let serviceName: String
    public let serviceType: String
    public let port: NWEndpoint.Port
    
    public lazy var currentTimeWithMillis = {
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }()
    public var onDebugLog: ((String) -> Void)?

    private let dateFormatter = DateFormatter()
    private var listener: NWListener?
    private var clients: [ConnectedClient] = []
    private var clientQueues: [ConnectedClient: [Data]] = [:]

    public init?(serviceName: String, port: UInt16, protocol: NetworkProtocol = .tcp) {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            return nil
        }
        self.serviceName = serviceName
        self.serviceType = "_\(serviceName)._tcp"
        self.port = nwPort
        
        do {
            listener = try NWListener(using: .tcp, on: self.port)
        } catch {
            debugLog("Failed to create listener: \(error)")
        }
    }
    
    open func debugLog(_ message: String) {
        onDebugLog?(message)
        #if DEBUG
            print("[SERVER][DEBUG] \(message)")
        #endif
    }

    public func startListening() {
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.debugLog("Server ready on port \(self?.listener?.port?.rawValue ?? 0)")
            case .failed(let error):
                self?.debugLog("Listener failed with error: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.debugLog("New connection received")
            self?.handleConnection(ConnectedClient(connection: connection))
        }

        listener?.start(queue: .main)

        // Publish Bonjour service
        listener?.service = NWListener.Service(name: serviceName, type: serviceType)
    }
    
    public func stopListening() {
        sendMessage("Stopping server")
        clients.forEach { client in
            client.connection.cancel()
        }
        clients = []
    }
        
    public func sendMessage(_ message: String, to clientId: String? = nil) {
        guard let data = message.data(using: .utf8) else { return }
        sendData(data, to: clientId)
    }
    
    public func sendData(_ data: Data, to clientId: String? = nil) {
        if let clientId,
           let client = clients.first(where: { client in
               client.clientId.uuidString == clientId
           }) {
            sendData(data, to: client)
        } else {
            for client in clients {
                sendData(data, to: client)
            }
        }
    }
}

// Connection handling
private extension Server {
    func handleConnection(_ client: ConnectedClient) {
        client.connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                debugLog("Connection is ready. Flushing queued messages if any.")
                if let queuedPackets = self.clientQueues[client] {
                    for packet in queuedPackets {
                        client.connection.send(content: packet, completion: .contentProcessed { error in
                            if let error = error {
                                self.debugLog("Failed to send queued data: \(error)")
                            }
                        })
                    }
                    self.clientQueues[client] = []
                }
            case .failed(let error):
                self.debugLog("Connection failed: \(error)")
            default:
                break
            }
        }

        // Start connection
        client.connection.start(queue: .main)
        listenToStream(from: client)

        // Keep track of the connection
        clients.append(client)
        clientQueues[client] = []
        
        debugLog("Client count: \(clients.count)")

        // Send a welcome message
        sendMessage("Hello from server!", to: client.clientId.uuidString)
    }
}

// Sending data to clients
private extension Server {
    func sendData(_ data: Data, to client: ConnectedClient) {
        let length = UInt32(data.count).bigEndian // Get the size
        var header = withUnsafeBytes(of: length) { Data($0) } // Create a header
        let packet = header + data // Append it to the front
        let clientIndex = clients.firstIndex(of: client) ?? 0
        
        if client.connection.state == .ready {
            client.connection.send(content: packet, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.debugLog("Failed to send data: \(error)")
                } else {
                    self?.debugLog("Data sent successfully (\(packet.count) bytes) to Client #\(clientIndex)")
                }
            })
        } else {
            debugLog("Client is not ready. Queuing data (\(packet.count) bytes).")
            clientQueues[client, default: []].append(packet)
        }
    }
}

// Listening data from clients
private extension Server {
    func listenToStream(from client: ConnectedClient) {
        let clientIndex = clients.firstIndex(of: client) ?? 0
        client.connection.receive(minimumIncompleteLength: 1, maximumLength: 1000 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            
            if let data = data {
                client.dataBuffer.append(data)
                
                self.debugLog("Received: \(data.count) byte, total: \(client.dataBuffer.count) byte from Client #\(clientIndex)")
                while let data = NetworkHelper.completedData(from: &client.dataBuffer),
                      data != nil {
                    self.debugLog("Receive from Client #\(clientIndex) is complete, databuffer after cleanup: \(client.dataBuffer.count) byte")
                    
                    if let text = String(data: data, encoding: .utf8) {
                        debugLog("It's a text message: \(text)")
                    } else {
                        // Possibly detect file type (PNG, PDF, etc.) using your `mimeType(for:)` method
                        if let fileType = data.mimeType() {
                            debugLog("Received a \(fileType) file (\(data.count) bytes)")
                        } else {
                            debugLog("Unknown binary data (\(data.count) bytes)")
                        }
                    }

                }
            }
            
            if let error = error {
                self.debugLog("Connection error: \(error)")
            }
            if isComplete {
                self.debugLog("Connection to Client #\(clientIndex) closed")
                clients.removeAll { closedClient in
                    client.clientId == closedClient.clientId
                }
            } else {
                // Keep receiving
                self.listenToStream(from: client)
            }
        }
    }
}

extension Server: Hashable, Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(serverId)
    }

    public static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.serverId == rhs.serverId
    }
}

final class ConnectedClient: Hashable, @unchecked Sendable  {
    let clientId: UUID
    let connection: NWConnection
    var dataBuffer: Data = Data()

    init(connection: NWConnection) {
        self.clientId = UUID()
        self.connection = connection
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(clientId)
    }

    static func == (lhs: ConnectedClient, rhs: ConnectedClient) -> Bool {
        return lhs.clientId == rhs.clientId
    }
}

struct NetworkHelper {
    static func completedData(from buffer: inout Data) -> Data? {
        guard buffer.count >= 4 else {
            // Too small to have a header
            return nil }
        
        let lengthField = buffer[0..<4]
        let payloadLength = lengthField.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        guard buffer.count >= 4 + Int(payloadLength) else {
            // Not all received
            return nil
        }
        
        let messageData = buffer[4..<(4 + Int(payloadLength))]
        
        // 5) Remove it from the front of the buffer
        buffer.removeSubrange(0..<(4 + Int(payloadLength)))
        
        return messageData
    }
}

extension Data {
    func mimeType() -> String? {
        var bytes = [UInt8](repeating: 0, count: 1)
        self.copyBytes(to: &bytes, count: 1)
        
        switch bytes {
            // JPEG: FF D8 FF
            case _ where bytes.starts(with: [0xFF, 0xD8, 0xFF]):
                return "image/jpeg"
                
            // PNG: 89 50 4E 47
            case _ where bytes.starts(with: [0x89, 0x50, 0x4E, 0x47]):
                return "image/png"
                
            // GIF: 47 49 46 38 (GIF87a or GIF89a)
            case _ where bytes.starts(with: [0x47, 0x49, 0x46, 0x38]):
                return "image/gif"
                
            // PDF: 25 50 44 46
            case _ where bytes.starts(with: [0x25, 0x50, 0x44, 0x46]):
                return "application/pdf"
                
            // ZIP: 50 4B 03 04 (also used by .docx, .xlsx, .apk, etc.)
            case _ where bytes.starts(with: [0x50, 0x4B, 0x03, 0x04]):
                return "application/zip"
                
            // RAR: 52 61 72 21
            case _ where bytes.starts(with: [0x52, 0x61, 0x72, 0x21]):
                return "application/x-rar-compressed"
                
            // 7z: 37 7A BC AF 27 1C
            case _ where bytes.starts(with: [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C]):
                return "application/x-7z-compressed"
                
            // GZIP: 1F 8B 08
            case _ where bytes.starts(with: [0x1F, 0x8B, 0x08]):
                return "application/gzip"
                
            // BMP: 42 4D
            case _ where bytes.starts(with: [0x42, 0x4D]):
                return "image/bmp"
        default:   return nil
        }
    }
}
