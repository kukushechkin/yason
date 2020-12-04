import XCTest
import class Foundation.Bundle

import Yams
import yasonLib

final class yasonTests: XCTestCase {
    let expectedObject: [String: Any] = [
        "object1": [
            "more": [
                "key1": "value11",
                "key2": "value12"
            ]
        ],
        "object2": [
            "key1": "value21",
            "key2": "value22"
        ]
    ]
    
    func testYamlToJsonCommand() throws {
        let fooBinary = productsDirectory.appendingPathComponent("yason")
        guard let testYamlPath = Bundle.module.path(forResource: "test", ofType: "yaml") else {
            print("failed to read test.yaml")
            XCTFail()
            return
        }
        let tempResultFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = [
            "--mode",      "yamlToJson",
            "--yaml-path", testYamlPath,
            "--json-path", tempResultFileUrl.path,
        ]

        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempResultFileUrl.path))
        guard let createdJsonData = try? Data(contentsOf: tempResultFileUrl) else {
            print("failed to read created json")
            XCTFail()
            return
        }
        
        guard let dictFromJson = try? JSONSerialization.jsonObject(with: createdJsonData, options: []) as? [String: Any] else {
            print("failed to decode created json")
            XCTFail()
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: dictFromJson).isEqual(to: expectedObject))
    }
    
    func testJsonToYaml() throws {
        guard let testJsonPath = Bundle.module.path(forResource: "test", ofType: "json") else {
            print("failed to read test.json")
            XCTFail()
            return
        }
        let tempResultFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let converter = YasonConverter()
        try! converter.convert(json: testJsonPath, toYaml: tempResultFileUrl.path)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempResultFileUrl.path))
        guard let createdYamlString = try? String(contentsOf: tempResultFileUrl) else {
            print("failed to read created yaml")
            XCTFail()
            return
        }
        
        guard let dictFromYaml = try? Yams.load(yaml: createdYamlString) as? [String: Any] else {
            print("failed to decode created yaml")
            XCTFail()
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: dictFromYaml).isEqual(to: expectedObject))
    }
    
    func testJsonToYamlCommand() throws {
        let fooBinary = productsDirectory.appendingPathComponent("yason")
        guard let testJsonPath = Bundle.module.path(forResource: "test", ofType: "json") else {
            print("failed to read test.json")
            XCTFail()
            return
        }
        let tempResultFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = [
            "--mode",      "jsonToYaml",
            "--yaml-path", tempResultFileUrl.path,
            "--json-path", testJsonPath,
        ]

        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)

        XCTAssertTrue(FileManager.default.fileExists(atPath: tempResultFileUrl.path))
        guard let createdYamlString = try? String(contentsOf: tempResultFileUrl) else {
            print("failed to read created yaml")
            XCTFail()
            return
        }
        
        guard let dictFromYaml = try? Yams.load(yaml: createdYamlString) as? [String: Any] else {
            print("failed to decode created yaml")
            XCTFail()
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: dictFromYaml).isEqual(to: expectedObject))
    }
    
    func testNonExistingSourceFile() throws {
        let fooBinary = productsDirectory.appendingPathComponent("yason")
        let tempSourceFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let tempResultFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = [
            "--mode",      "jsonToYaml",
            "--yaml-path", tempResultFileUrl.path,
            "--json-path", tempSourceFileUrl.path,
        ]

        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempResultFileUrl.path))
    }
    
    func testCorruptedSourceFile() throws {
        let fooBinary = productsDirectory.appendingPathComponent("yason")
        guard let corruptedJsonPath = Bundle.module.path(forResource: "corrupted", ofType: "json") else {
            print("failed to read corrupted.json")
            XCTFail()
            return
        }
        let tempResultFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = [
            "--mode",      "jsonToYaml",
            "--yaml-path", tempResultFileUrl.path,
            "--json-path", corruptedJsonPath,
        ]

        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempResultFileUrl.path))
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
    }
}
