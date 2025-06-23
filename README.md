# VoiAssignment

### Setup ###
The app has been built and compiled using Xcode 16.2, Swift version 5.0.
Minimum deployment target is 16.0.

### Output ###
The application scope 
- Displays info label and start button on the main screen.
- Start button action: Opens the camera in the bottom sheet.
- Scans the QR code.
- Fetches vehicle information based on scanned QR code.
- Displays the fetched data in the details screen.

### Design ###
The app uses the MVVM design pattern along with Combine framework.


Below are the classes used in the project as described:

#### Components: ####
- `VehicleInfo` represents the data **model** which holds the vehicle info.
- `VehicleLookupViewModel` represents the **view model**.
- `VehicleLookupViewController`, `VehicleDetailsViewController` represents the **view** which displays UI elements.
- `QRScanViewController` provides access to the device camera which performs QR scanning and extracts the QR code.

#### Services: ####
- `NetworkService` performs HTTP GET service.
- `NetworkServiceError` encapsulates different errors.
- `VehicleInfoService` uses `NetworkService` to fetch vehicle information based on the scanned QR code.

#### Sample Unit tests: ####
- `NetworkServiceTests` represents unit tests for `NetworkService` protocol.
- `VehicleInfoServiceTests` represents unit tests for `VehicleInfoService` protocol.
- `VehicleLookupViewModelTests` represents unit tests for `VehicleLookupViewModel` protocol.

#### Sample UI tests: ####
- `VehicleLookupViewControllerUITests` represents ui tests for `VehicleLookupViewController`.

