import Foundation
import Yams

extension NSDictionary: NodeRepresentable {
    public func represented() throws -> Node {
        if let dict = self as? Dictionary<String, String> {
            return try dict.represented()
        }
        return try (self as? Dictionary<String, Any>).represented()
    }
}

public struct YasonConverter {
    public init() {
        
    }
    
    public func convert(yaml yamlPath: String, toJson jsonPath: String) throws {
        let yamlString = try String(contentsOfFile: yamlPath)
        let loadedYaml = try Yams.load(yaml: yamlString) as! [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject:loadedYaml, options: .prettyPrinted)
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))
    }
    
    public func convert(json jsonPath: String, toYaml yamlPath: String) throws {
        let createdJsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        let dictFromJson = try JSONSerialization.jsonObject(with: createdJsonData, options: []) as? [String: Any]
        let yaml: String = try Yams.dump(object: dictFromJson)
        try yaml.write(toFile: yamlPath, atomically: true, encoding: .utf8)
    }
}

