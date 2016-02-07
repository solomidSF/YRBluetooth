[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/solomidSF/yrbluetooth/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

# YRBluetooth
Have you ever tried to setup communication between iOS devices using Apple's CoreBluetooth technology? Well, you're lucky, because YRBluetooth already did it for you! It hides all complexity and pitfalls of Apple's CoreBluetooth framework, so you can sit back in your chair and let YRBluetooth do the rest.

## Supported versions
YRBluetooth is designed to run on iOS 8 and later.

## Features
- Scanning
- Connecting 
- Sending 
- Receiving

## Installation
// TODO:
## Architecture Overview
// TODO:
## Example usage
// TODO:

## Current state
YRBluetooth is in development state and currently it will produce a lot of debug output into console. Basic features like scanning/connecting/sending/receiving are implemented.

## Future improvements
- Create dependency mechanism for operations like in NSOperationQueue.
- Create logging with log levels.

## Version history
### v0.3.0-alpha
- Component refactored
- Remote request is now Remote operation.
- Improved errors for bluetooth state changes.

### v0.2.0-alpha
- Added bluetooth state for both peers.
- Code for bluetooth server improved.

### v0.1.3-alpha
- Fixed issue with peer invalidation while receiving message from remote.
- Fixed issue with chunk parsing.

### v0.1.2-alpha
Resolved several issues in component:

- Fixed issue with cleanup for scanning service.
- Fixed chunk provider stall if operation failed due to timeout.
- Fixed receiving issue for failed operation.
- Fixed issue with chunk generation.

### v0.1.1-alpha
First release. Scanning/Connecting/Sending/Receiving/Errors functionality.

### v0.1.0-alpha
First pre-release. Scanning/Connecting/Sending/Receiving functionality. Don't use errors produced by framework.

#### Tags
Core Bluetooth, Bluetooth Low Energy, iOS

#### More info coming soon.
