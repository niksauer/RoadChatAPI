# RoadChatAPI

<a href="https://app.swaggerhub.com/apis/niksauer/RoadChat/1.0.0">
    <img src="http://img.shields.io/badge/read_the-docs-92A8D1.svg" alt="Documentation">
</a>
<a href="license">
    <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
</a>
<a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
</a>

### Swift Toolchain
**Warning:** Vapor 3 now depends on Swift 4.1. Please follow this [tutorial](https://gist.github.com/tanner0101/cdb77c7f58d53af2ba2da5d39415389a) to build and run the app locally in Xcode.

Also, in order to support command line development you will have to set the Swift version to be used via [swiftenv](https://github.com/kylef/swiftenv): 
1. `swiftenv version`
2. `swiftenv local <choose swift 4.1 snapshot here>`

### Working with Xcode
Please use the Swift Package Manager to create an Xcode project file, since this repository purposefully ***excludes*** it to preserve a developer's individual IDE settings. Again, [Vapor Toolbox](https://github.com/vapor/toolbox) will not be necessary or required for setup.

1. `swift package generate-xcodeproj`
2. `Product > Scheme > Run`
3. `Xcode > Toolchains > <choose swift 4.1 snapshot here>`

### Developing with Docker 
The theory here is that you will build and run a Swift container, mounting your project directory, then keep it open during development using command-line Swift to build, test and run your project ([see tutorial](https://bygri.github.io/2018/01/25/vapor-3-with-docker.html)).

Using Xcode? Then by all means build as you go in Xcode (it’s faster than building in Linux) but don’t forget to build and test in your container from time to time, and you should ***always run from it***. Xcode and Linux use different build directories, so always swift build before you swift run to ensure your Linux build is up-to-date.

**Workflow**

1. Build & run the development docker container: ```docker build -t roadchat:dev -f Dockerfile-dev . && docker run -it -p 8080:8080 -v "$PWD":/app --privileged --rm roadchat:dev```
2. For any source code changes made, rebuild the project binary: `swift build`
3. To start the server: `swift run Run serve --hostname 0.0.0.0`

Typing out the command to build and launch the development container ***is really*** annoying: ```alias dockerdev='eval "`head -n 1 Dockerfile-dev | cut -c 2-`"'```
