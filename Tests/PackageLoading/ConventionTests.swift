/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest

import Basic
import PackageDescription
import PackageModel
import Utility

@testable import PackageLoading

/// Tests for the handling of source layout conventions.
class ConventionTests: XCTestCase {
    
    // MARK:- Valid Layouts Tests

    func testDotFilesAreIgnored() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/.Bar.swift",
                                "/Foo.swift")

        let name = "DotFilesAreIgnored"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .library, isTest: false)
                moduleResult.checkSources(root: "/", paths: "Foo.swift")
            }
        }
    }

    func testResolvesSingleSwiftLibraryModule() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Foo.swift")

        let name = "SingleSwiftModule"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .library, isTest: false)
                moduleResult.checkSources(root: "/", paths: "Foo.swift")
            }
        }

        // Single swift module inside Sources.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/Foo.swift",
                                "/Sources/Bar.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "Foo.swift", "Bar.swift")
            }
        }

        // Single swift module inside its own directory.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/lib/Foo.swift",
                                "/Sources/lib/Bar.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule("lib") { moduleResult in
                moduleResult.check(c99name: "lib", type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources/lib", paths: "Foo.swift", "Bar.swift")
            }
        }
    }

    func testResolvesSystemModulePackage() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/module.modulemap")

        let name = "SystemModulePackage"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .systemModule, isTest: false)
                moduleResult.checkSources(root: "/", paths: "module.modulemap")
            }
        }
    }

    func testResolvesSingleClangLibraryModule() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Foo.h",
                                "/Foo.c")

        let name = "SingleClangModule"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .library, isTest: false)
                moduleResult.checkSources(root: "/", paths: "Foo.c")
            }
        }

        // Single clang module inside Sources.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/Foo.h",
                                "/Sources/Foo.c")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "Foo.c")
            }
        }

        // Single clang module inside its own directory.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/lib/Foo.h",
                                "/Sources/lib/Foo.c")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule("lib") { moduleResult in
                moduleResult.check(c99name: "lib", type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources/lib", paths: "Foo.c")
            }
        }
    }

    func testSingleExecutableSwiftModule() throws {
        // Single swift executable module.
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/main.swift",
                                "/Bar.swift")

        let name = "SingleExecutable"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/", paths: "main.swift", "Bar.swift")
            }
        }

        // Single swift executable module inside Sources.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/main.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "main.swift")
            }
        }

        // Single swift executable module inside its own directory.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/exec/main.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule("exec") { moduleResult in
                moduleResult.check(c99name: "exec", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/exec", paths: "main.swift")
            }
        }
    }

    func testSingleExecutableClangModule() throws {
        // Single swift executable module.
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/main.c",
                                "/Bar.c")

        let name = "SingleExecutable"
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/", paths: "main.c", "Bar.c")
            }
        }

        // Single swift executable module inside Sources.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/main.cpp")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "main.cpp")
            }
        }

        // Single swift executable module inside its own directory.
        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/c/main.c")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule("c") { moduleResult in
                moduleResult.check(c99name: "c", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/c", paths: "main.c")
            }
        }
    }

    func testDotSwiftSuffixDirectory() throws {
        var fs = InMemoryFileSystem()
        try fs.createDirectory(AbsolutePath("/hello.swift"))
        try fs.createEmptyFiles("/main.swift",
                                "/Bar.swift")

        let name = "pkg"
        // FIXME: This fails currently, it is a bug.
        #if false
        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/", paths: "main.swift", "Bar.swift")
            }
        }
        #endif

        fs = InMemoryFileSystem()
        try fs.createDirectory(AbsolutePath("/hello.swift"))
        try fs.createEmptyFiles("/Sources/main.swift",
                                "/Sources/Bar.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule(name) { moduleResult in
                moduleResult.check(c99name: name, type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "main.swift", "Bar.swift")
            }
        }

        fs = InMemoryFileSystem()
        try fs.createDirectory(AbsolutePath("/Sources/exe/hello.swift"), recursive: true)
        try fs.createEmptyFiles("/Sources/exe/main.swift",
                                "/Sources/exe/Bar.swift")

        PackageBuilderTester(name, in: fs) { result in
            result.checkModule("exe") { moduleResult in
                moduleResult.check(c99name: "exe", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/exe", paths: "main.swift", "Bar.swift")
            }
        }
    }

    func testMultipleSwiftModules() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/A/main.swift",
                                "/Sources/A/foo.swift",
                                "/Sources/B/main.swift",
                                "/Sources/C/Foo.swift")

        PackageBuilderTester("MultipleModules", in: fs) { result in
            result.checkModule("A") { moduleResult in
                moduleResult.check(c99name: "A", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/A", paths: "main.swift", "foo.swift")
            }

            result.checkModule("B") { moduleResult in
                moduleResult.check(c99name: "B", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/B", paths: "main.swift")
            }

            result.checkModule("C") { moduleResult in
                moduleResult.check(c99name: "C", type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources/C", paths: "Foo.swift")
            }
        }
    }

    func testMultipleClangModules() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/A/main.c",
                                "/Sources/A/foo.h",
                                "/Sources/A/foo.c",
                                "/Sources/B/include/foo.h",
                                "/Sources/B/foo.c",
                                "/Sources/B/bar.c",
                                "/Sources/C/main.cpp")

        PackageBuilderTester("MultipleModules", in: fs) { result in
            result.checkModule("A") { moduleResult in
                moduleResult.check(c99name: "A", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/A", paths: "main.c", "foo.c")
            }

            result.checkModule("B") { moduleResult in
                moduleResult.check(c99name: "B", type: .library, isTest: false)
                moduleResult.checkSources(root: "/Sources/B", paths: "foo.c", "bar.c")
            }

            result.checkModule("C") { moduleResult in
                moduleResult.check(c99name: "C", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/C", paths: "main.cpp")
            }
        }
    }

    func testTestsLayouts() throws {
        // Single module layout.
        for singleModuleSource in ["/", "/Sources/", "/Sources/Foo/"].lazy.map(AbsolutePath.init) {
            var fs = InMemoryFileSystem()
            try fs.createEmptyFiles(singleModuleSource.appending(component: "Foo.swift").asString,
                                    "/Tests/Foo/FooTests.swift",
                                    "/Tests/Foo/BarTests.swift",
                                    "/Tests/Bar/BazTests.swift")

            PackageBuilderTester("Foo", in: fs) { result in
                result.checkModule("Foo") { moduleResult in
                    moduleResult.check(c99name: "Foo", type: .library, isTest: false)
                    moduleResult.checkSources(root: singleModuleSource.asString, paths: "Foo.swift")
                }

                result.checkModule("FooTestSuite") { moduleResult in
                    moduleResult.check(c99name: "FooTestSuite", type: .library, isTest: true)
                    moduleResult.checkSources(root: "/Tests/Foo", paths: "FooTests.swift", "BarTests.swift")
                    moduleResult.check(dependencies: ["Foo"])
                    moduleResult.check(recursiveDependencies: ["Foo"])
                }

                result.checkModule("BarTestSuite") { moduleResult in
                    moduleResult.check(c99name: "BarTestSuite", type: .library, isTest: true)
                    moduleResult.checkSources(root: "/Tests/Bar", paths: "BazTests.swift")
                    moduleResult.check(dependencies: [])
                    moduleResult.check(recursiveDependencies: [])
                }
            }
        }

       var fs = InMemoryFileSystem()
       try fs.createEmptyFiles("/Sources/A/main.swift", // Swift exec
                               "/Sources/B/Foo.swift",  // Swift lib
                               "/Sources/D/Foo.c",      // Clang lib
                               "/Sources/E/main.c",     // Clang exec
                               "/Tests/A/Foo.swift",
                               "/Tests/B/Foo.swift",
                               "/Tests/D/Foo.swift",
                               "/Tests/E/Foo.swift")

       PackageBuilderTester("Foo", in: fs) { result in
           result.checkModule("A") { moduleResult in
               moduleResult.check(c99name: "A", type: .executable, isTest: false)
               moduleResult.checkSources(root: "/Sources/A", paths: "main.swift")
           }

           result.checkModule("B") { moduleResult in
               moduleResult.check(c99name: "B", type: .library, isTest: false)
               moduleResult.checkSources(root: "/Sources/B", paths: "Foo.swift")
           }

           result.checkModule("D") { moduleResult in
               moduleResult.check(c99name: "D", type: .library, isTest: false)
               moduleResult.checkSources(root: "/Sources/D", paths: "Foo.c")
           }

           result.checkModule("E") { moduleResult in
               moduleResult.check(c99name: "E", type: .executable, isTest: false)
               moduleResult.checkSources(root: "/Sources/E", paths: "main.c")
           }

           result.checkModule("ATestSuite") { moduleResult in
               moduleResult.check(c99name: "ATestSuite", type: .library, isTest: true)
               moduleResult.checkSources(root: "/Tests/A", paths: "Foo.swift")
               moduleResult.check(dependencies: ["A"])
               moduleResult.check(recursiveDependencies: ["A"])
           }

           result.checkModule("BTestSuite") { moduleResult in
               moduleResult.check(c99name: "BTestSuite", type: .library, isTest: true)
               moduleResult.checkSources(root: "/Tests/B", paths: "Foo.swift")
               moduleResult.check(dependencies: ["B"])
               moduleResult.check(recursiveDependencies: ["B"])
           }

           result.checkModule("DTestSuite") { moduleResult in
               moduleResult.check(c99name: "DTestSuite", type: .library, isTest: true)
               moduleResult.checkSources(root: "/Tests/D", paths: "Foo.swift")
               moduleResult.check(dependencies: ["D"])
               moduleResult.check(recursiveDependencies: ["D"])
           }

           result.checkModule("ETestSuite") { moduleResult in
               moduleResult.check(c99name: "ETestSuite", type: .library, isTest: true)
               moduleResult.checkSources(root: "/Tests/E", paths: "Foo.swift")
               moduleResult.check(dependencies: ["E"])
               moduleResult.check(recursiveDependencies: ["E"])
           }
       }
    }

    func testNoSources() throws {
        PackageBuilderTester("MixedSources", in: InMemoryFileSystem()) { _ in }
    }

    func testMixedSources() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/main.swift",
                                "/Sources/main.c")
        PackageBuilderTester("MixedSources", in: fs) { result in
            result.checkDiagnostic("the module at /Sources contains mixed language source files fix: use only a single language within a module")
        }
    }

    func testTwoModulesMixedLanguage() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/ModuleA/main.swift",
                                "/Sources/ModuleB/main.c",
                                "/Sources/ModuleB/foo.c")

        PackageBuilderTester("MixedLanguage", in: fs) { result in
            result.checkModule("ModuleA") { moduleResult in
                moduleResult.check(c99name: "ModuleA", type: .executable)
                moduleResult.check(isTest: false)
                moduleResult.checkSources(root: "/Sources/ModuleA", paths: "main.swift")
            }

            result.checkModule("ModuleB") { moduleResult in
                moduleResult.check(c99name: "ModuleB", type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources/ModuleB", paths: "main.c", "foo.c")
            }
        }
    }

    func testCInTests() throws {
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/main.swift",
                                "/Tests/MyPackage/abc.c")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkModule("MyPackage") { moduleResult in
                moduleResult.check(type: .executable, isTest: false)
                moduleResult.checkSources(root: "/Sources", paths: "main.swift")
            }

            result.checkModule("MyPackageTestSuite") { moduleResult in
                moduleResult.check(type: .library, isTest: true)
                moduleResult.checkSources(root: "/Tests/MyPackage", paths: "abc.c")
            }

          #if os(Linux)
            result.checkDiagnostic("warning: Ignoring MyPackageTestSuite as C language in tests is not yet supported on Linux.")
          #endif
        }
    }

    // MARK:- Invalid Layouts Tests

    func testMultipleRoots() throws {

        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Foo.swift",
                                "/main.swift",
                                "/src/FooBarLib/FooBar.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /Foo.swift, /main.swift fix: move the file(s) inside a module")
        }

        fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/BarExec/main.swift",
                                "/Sources/BarExec/Bar.swift",
                                "/src/FooBarLib/FooBar.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, multiple source roots found: /src, /Sources fix: remove the extra source roots, or add them to the source root exclude list")
        }
    }

    func testInvalidLayout1() throws {
        /*
         Package
         ├── main.swift   <-- invalid
         └── Sources
             └── File2.swift
        */
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/Files2.swift",
                                "/main.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /main.swift fix: move the file(s) inside a module")
        }
    }

    func testInvalidLayout2() throws {
        /*
         Package
         ├── main.swift  <-- invalid
         └── Bar
             └── Sources
                 └── File2.swift
        */
        // FIXME: We should allow this by not making modules at root and only inside Sources/.
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Bar/Sources/Files2.swift",
                                "/main.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /main.swift fix: move the file(s) inside a module")
        }
    }

    func testInvalidLayout3() throws {
        /*
         Package
         └── Sources
             ├── main.swift  <-- Invalid
             └── Bar
                 └── File2.swift
        */
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/Sources/main.swift",
                                "/Sources/Bar/File2.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /Sources/main.swift fix: move the file(s) inside a module")
        }
    }

    func testInvalidLayout4() throws {
        /*
         Package
         ├── main.swift  <-- Invalid
         └── Sources
             └── Bar
                 └── File2.swift
        */
        var fs = InMemoryFileSystem()
        try fs.createEmptyFiles("/main.swift",
                                "/Sources/Bar/File2.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /main.swift fix: move the file(s) inside a module")
        }
    }

    func testInvalidLayout5() throws {
        /*
         Package
         ├── File1.swift
         └── Foo
             └── Foo.swift  <-- Invalid
        */
        var fs = InMemoryFileSystem()
        // for the simplest layout it is invalid to have any
        // subdirectories. It is the compromise you make.
        // the reason for this is mostly performance in
        // determineTargets() but also we are saying: this
        // layout is only for *very* simple projects.
        try fs.createEmptyFiles("/File1.swift",
                                "/Foo/Foo.swift")

        PackageBuilderTester("MyPackage", in: fs) { result in
            result.checkDiagnostic("the package has an unsupported layout, unexpected source file(s) found: /File1.swift fix: move the file(s) inside a module")
        }
    }

    static var allTests = [
        ("testCInTests"                        , testCInTests),
        ("testDotFilesAreIgnored"              , testDotFilesAreIgnored),
        ("testDotSwiftSuffixDirectory"         , testDotSwiftSuffixDirectory),
        ("testMixedSources"                    , testMixedSources),
        ("testMultipleClangModules"            , testMultipleClangModules),
        ("testMultipleSwiftModules"            , testMultipleSwiftModules),
        ("testNoSources"                       , testNoSources),
        ("testResolvesSingleClangLibraryModule", testResolvesSingleClangLibraryModule),
        ("testResolvesSingleSwiftLibraryModule", testResolvesSingleSwiftLibraryModule),
        ("testResolvesSystemModulePackage"     , testResolvesSystemModulePackage),
        ("testSingleExecutableClangModule"     , testSingleExecutableClangModule),
        ("testSingleExecutableSwiftModule"     , testSingleExecutableSwiftModule),
        ("testTestsLayouts"                    , testTestsLayouts),
        ("testTwoModulesMixedLanguage"         , testTwoModulesMixedLanguage),
        ("testMultipleRoots"                   , testMultipleRoots),
        ("testInvalidLayout1"                  , testInvalidLayout1),
        ("testInvalidLayout2"                  , testInvalidLayout2),
        ("testInvalidLayout3"                  , testInvalidLayout3),
        ("testInvalidLayout4"                  , testInvalidLayout4),
        ("testInvalidLayout5"                  , testInvalidLayout5),
    ]
}

// FIXME: These test Utilities can/should be moved to test-specific library when we start supporting them.
private extension FileSystem {
    /// Create a file on the filesystem while recursively creating the parent directory tree.
    ///
    /// - Parameters:
    ///     - file: Path of the file to create.
    ///     - contents: Contents of the file. Empty by default.
    ///
    /// - Throws: FileSystemError
    mutating func create(_ file: AbsolutePath, contents: ByteString = ByteString()) throws {
        // Auto create the tree.
        try createDirectory(file.parentDirectory, recursive: true)
        try writeFileContents(file, bytes: contents)
    }

    /// Create multiple empty files on the filesystem while recursively creating the parent directory tree.
    ///
    /// - Parameters:
    ///     - files: Paths of empty files to create.
    ///
    /// - Throws: FileSystemError
    mutating func createEmptyFiles(_ files: String ...) throws {
        // Auto create the tree.
        for filePath in files {
            let file = AbsolutePath(filePath)
            try createDirectory(file.parentDirectory, recursive: true)
            try writeFileContents(file, bytes: ByteString())
        }
    }
}

/// Loads a package using PackageBuilder at the given path.
///
/// - Parameters:
///     - package: PackageDescription instance to use for loading this package.
///     - path: Directory where the package is located.
///     - in: FileSystem in which the package should be loaded from.
///     - warningStream: OutputByteStream to be passed to package builder.
///
/// - Throws: ModuleError, ProductError
private func loadPackage(_ package: PackageDescription.Package, path: AbsolutePath, in fs: FileSystem, warningStream: OutputByteStream) throws -> PackageModel.Package {
    let manifest = Manifest(path: path.appending(component: Manifest.filename), url: "", package: package, products: [], version: nil)
    let builder = PackageBuilder(manifest: manifest, path: path, fileSystem: fs, warningStream: warningStream)
    return try builder.construct(includingTestModules: true)
}

extension PackageModel.Package {
    var allModules: [Module] {
        return modules + testModules
    }
}

final class PackageBuilderTester {
    private enum Result {
        case package(PackageModel.Package)
        case error(String)
    }

    /// Contains the result produced by PackageBuilder.
    private let result: Result

    /// Contains the diagnostics which have not been checked yet.
    private var uncheckedDiagnostics = Set<String>()

    /// Setting this to true will disable checking for any unchecked diagnostics prodcuted by PackageBuilder during loading process.
    var ignoreDiagnostics: Bool = false

    /// Contains the modules which have not been checked yet.
    private var uncheckedModules = Set<Module>()

    /// Setting this to true will disable checking for any unchecked module.
    var ignoreOtherModules: Bool = false

    @discardableResult
   convenience init(_ name: String, path: AbsolutePath = .root, in fs: FileSystem, file: StaticString = #file, line: UInt = #line, _ body: @noescape (PackageBuilderTester) -> Void) {
       let package = Package(name: name)
       self.init(package, path: path, in: fs, file: file, line: line, body)
    }

    @discardableResult
    init(_ package: PackageDescription.Package, path: AbsolutePath = .root, in fs: FileSystem, file: StaticString = #file, line: UInt = #line, _ body: @noescape (PackageBuilderTester) -> Void) {
        do {
            let warningStream = BufferedOutputByteStream()
            let loadedPackage = try loadPackage(package, path: path, in: fs, warningStream: warningStream)
            result = .package(loadedPackage)
            uncheckedModules = Set(loadedPackage.allModules)
            // FIXME: Find a better way. Maybe Package can keep array of warnings.
            uncheckedDiagnostics = Set(warningStream.bytes.asReadableString.characters.split(separator: "\n").map(String.init))
        } catch {
            let errorStr = String(error)
            result = .error(errorStr)
            uncheckedDiagnostics.insert(errorStr)
        }
        body(self)
        validateDiagnostics(file: file, line: line)
        validateCheckedModules(file: file, line: line)
    }

    private func validateDiagnostics(file: StaticString, line: UInt) {
        guard !ignoreDiagnostics && !uncheckedDiagnostics.isEmpty else { return }
        XCTFail("Unchecked diagnostics: \(uncheckedDiagnostics)", file: file, line: line)
    }

    private func validateCheckedModules(file: StaticString, line: UInt) {
        guard !ignoreOtherModules && !uncheckedModules.isEmpty else { return }
        XCTFail("Unchecked modules: \(uncheckedModules)", file: file, line: line)
    }

    func checkDiagnostic(_ str: String, file: StaticString = #file, line: UInt = #line) {
        if uncheckedDiagnostics.contains(str) {
            uncheckedDiagnostics.remove(str)
        } else {
            XCTFail("\(result) did not have error: \(str) or is already checked")
        }
    }

    func checkModule(_ name: String, file: StaticString = #file, line: UInt = #line, _ body: (@noescape (ModuleResult) -> Void)? = nil) {
        guard case .package(let package) = result else {
            return XCTFail("Expected package did not load \(self)", file: file, line: line)
        }
        guard let module = package.allModules.first(where: {$0.name == name}) else {
            return XCTFail("Module: \(name) not found", file: file, line: line)
        }
        uncheckedModules.remove(module)
        body?(ModuleResult(module))
    }

    final class ModuleResult {
        private let module: Module
        private lazy var sources: Set<RelativePath> = { Set(self.module.sources.relativePaths) }()

        private init(_ module: Module) {
            self.module = module
        }

        func check(c99name: String? = nil, type: ModuleType? = nil, isTest: Bool? = nil, file: StaticString = #file, line: UInt = #line) {
            if let c99name = c99name {
                XCTAssertEqual(module.c99name, c99name, file: file, line: line)
            }
            if let type = type {
                XCTAssertEqual(module.type, type, file: file, line: line)
            }
            if let isTest = isTest {
                XCTAssertEqual(module.isTest, isTest, file: file, line: line)
            }
        }

        func checkSources(root: String? = nil, sources paths: [String], file: StaticString = #file, line: UInt = #line) {
            if let root = root {
                XCTAssertEqual(module.sources.root, AbsolutePath(root), file: file, line: line)
            }
            var sources = self.sources

            for path in paths.lazy.map(RelativePath.init) {
                let contains = sources.contains(path)
                XCTAssert(contains, "\(path) not found in module \(module.name)", file: file, line: line)
                if contains {
                    sources.remove(path)
                }
            }

            guard sources.isEmpty else {
                return XCTFail("Unchecked sources in package \(self): \(sources)", file: file, line: line)
            }
        }

        func checkSources(root: String? = nil, paths: String..., file: StaticString = #file, line: UInt = #line) {
            checkSources(root: root, sources: paths, file: file, line: line)
        }

        func check(dependencies depsToCheck: [String], file: StaticString = #file, line: UInt = #line) {
            let dependencies = Set(module.dependencies.map{$0.name})
            var uncheckedDeps = dependencies

            for depToCheck in depsToCheck {
                let contains = dependencies.contains(depToCheck)
                XCTAssert(contains, "\(depToCheck) dependency not found in \(module.name)", file: file, line: line)
                if contains {
                    uncheckedDeps.remove(depToCheck)
                }
            }

            guard uncheckedDeps.isEmpty else {
                return XCTFail("Unchecked dependencies in \(self)'s module '\(module.name)':  \(uncheckedDeps)", file: file, line: line)
            }
        }

        func check(recursiveDependencies: [String], file: StaticString = #file, line: UInt = #line) {
            // We need to check in build order here.
            XCTAssertEqual(module.recursiveDependencies.map { $0.name }, recursiveDependencies, file: file, line: line)
        }
    }
}
