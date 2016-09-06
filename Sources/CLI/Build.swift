import SpeltKit
import Commandant
import Result

struct PathOptions: OptionsType {
    let sourcePath: String
    let destinationPath: String
    
    static func create(sourcePath: String) -> String -> PathOptions {
        return { destinationPath in
            return PathOptions(sourcePath: sourcePath.stringByStandardizingPath.absolutePath, destinationPath: destinationPath.stringByStandardizingPath.absolutePath);
        }
    }
    
    static func evaluate(m: CommandMode) -> Result<PathOptions, CommandantError<SpeltError>> {
        return create
            <*> m <| Option(key: "source", defaultValue: BuildCommand.currentDirectoryPath, usage: "Source directory (defaults to ./)")
            <*> m <| Option(key: "destination", defaultValue: BuildCommand.currentDirectoryPath.stringByAppendingPathComponent("_build"), usage: "Destination directory (defaults to ./_build)")
    }
}

struct BuildCommand: CommandType {
    typealias Options = PathOptions
    
    static let currentDirectoryPath = NSFileManager().currentDirectoryPath
    
    let verb = "build"
    let function = "Build your site"
    
    func run(options: Options) -> Result<(), SpeltError> {
        print("Source: \(options.sourcePath)")
        print("Destination: \(options.destinationPath)")
        
        do {
            print("Generating...")
            let site = try SiteReader(sitePath: options.sourcePath).read()
            let siteBuilder = SiteBuilder(site: site, buildPath: options.destinationPath)
            try siteBuilder.build()
            print("Done")
        }
        catch {
            // FIXME: fix error handling
            return Result.Failure(SpeltError.defaultError)
        }
        
        return Result.Success()
    }
}