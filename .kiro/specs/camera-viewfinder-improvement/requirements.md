# Requirements Document

## Introduction

The current camera functionality immediately captures a photo when the user selects "Tomar foto", without showing a live camera feed (viewfinder). Users should be able to see what the camera is focusing on before taking the photo, similar to standard camera apps. This improvement will enhance the user experience by allowing them to frame their shots properly before capturing.

## Requirements

### Requirement 1

**User Story:** As a user, I want to see a live camera feed before taking a photo, so that I can properly frame my shot and ensure the image quality before capturing.

#### Acceptance Criteria

1. WHEN the user selects "Tomar foto" THEN the system SHALL display a live camera viewfinder screen
2. WHEN the viewfinder is displayed THEN the system SHALL show real-time camera feed from the device camera
3. WHEN the viewfinder is active THEN the system SHALL provide a capture button to take the photo
4. WHEN the user taps the capture button THEN the system SHALL capture the current frame and proceed to preview confirmation

### Requirement 2

**User Story:** As a user, I want intuitive camera controls in the viewfinder, so that I can easily capture photos and navigate back if needed.

#### Acceptance Criteria

1. WHEN the viewfinder is displayed THEN the system SHALL show a prominent capture button (typically circular)
2. WHEN the viewfinder is displayed THEN the system SHALL show a back/cancel button to return to the previous screen
3. WHEN the user taps the back button THEN the system SHALL close the viewfinder and return to the image selection options
4. WHEN the capture button is pressed THEN the system SHALL provide visual feedback (animation or flash effect)

### Requirement 3

**User Story:** As a user, I want the camera viewfinder to work consistently across different devices, so that I have a reliable photo-taking experience.

#### Acceptance Criteria

1. WHEN the camera viewfinder is opened THEN the system SHALL handle camera permissions appropriately
2. IF camera permissions are denied THEN the system SHALL show an appropriate error message and fallback to gallery selection
3. WHEN the camera is not available THEN the system SHALL gracefully fallback to the current image picker behavior
4. WHEN the viewfinder is displayed THEN the system SHALL maintain proper aspect ratio for the camera feed

### Requirement 4

**User Story:** As a user, I want the photo capture process to be smooth and responsive, so that I don't miss the moment I want to capture.

#### Acceptance Criteria

1. WHEN the viewfinder loads THEN the system SHALL initialize the camera within 3 seconds
2. WHEN the capture button is pressed THEN the system SHALL capture the photo within 1 second
3. WHEN a photo is captured THEN the system SHALL immediately show the preview confirmation screen
4. WHEN the camera is initializing THEN the system SHALL show a loading indicator to the user