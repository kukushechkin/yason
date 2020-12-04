import Foundation
import ArgumentParser
import yasonLib

enum ConvertMode: String, Codable, ExpressibleByArgument {
    case yamlToJson
    case jsonToYaml
}

struct ConverterCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "jsonToYaml | yamlToJson")
    var mode: ConvertMode
    
    @Option(name: .shortAndLong, help: "path to a yaml file")
    var yamlPath: String

    @Option(name: .shortAndLong, help: "path to a json file")
    var jsonPath: String

    func run() throws {
        switch mode {
            case .jsonToYaml:
                let converter = YasonConverter()
                do {
                    try converter.convert(json: jsonPath, toYaml: yamlPath)
                } catch {
                    print("Error while converting \(jsonPath) to \(yamlPath):\n\(error)")
                    throw ExitCode(1)
                }
            case .yamlToJson:
                let converter = YasonConverter()
                do {
                    try converter.convert(yaml: yamlPath, toJson: jsonPath)
                } catch {
                    print("Error while converting \(yamlPath) to \(jsonPath):\n\(error)")
                    throw ExitCode(1)
                }
        }
    }
}

ConverterCommand.main()
