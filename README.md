# ActivityForecast

ActivityForecast is a native iOS application that lets users search for a city and view a ranked list of activities for the next seven days based on the local weather forecast.
The activities currently ranked are:
- Skiing
- Surfing
- Outdoor sightseeing
- Indoor sightseeing

Each activity is scored independently from `0...100` for each forecast day and then ranked from most suitable to least suitable.
The goal of the project was not to find a single "good weather" score, but to model how different weather conditions affect different activities.

---

## Project Overview
The app allows a user to:
1. Search for a city.
2. Retrieve its seven-day weather forecast.
3. Calculate weather suitability scores for each supported activity.
4. Rank activities independently for each day.
5. View the ranking and corresponding suitability rating.

Example:
```markdown
2026-10-01

Outdoor Sightseeing   87
Surfing               74
Indoor Sightseeing    50
Skiing                 0
```

---

## Platform and Tooling Choices

### Platform
- iOS
- Swift
- SwiftUI
### Tooling
- Xcode
- Swift Concurrency / async-await
- XCTest
- Open-Meteo APIs
### APIs
- Open-Meteo Geocoding API for city search
- Open-Meteo Forecast API for weather forecast data

---

## Architecture and Technical Decisions
The app uses an MVVM-style architecture with clear separation between UI, state management, networking, and domain logic.
### Architecture
- **Views** are built with SwiftUI and are responsible only for presenting state and forwarding user actions.
- **ViewModels** manage screen state and coordinate service calls.
- **Services** handle communication with the Open-Meteo APIs.
- **Domain models** represent forecast data and ranked activity results.
- **Activity scorers** contain the recommendation logic for skiing, surfing, outdoor sightseeing, and indoor sightseeing.

### Technical Decisions

- Used **protocol-based dependency injection** so services and the scoring engine can be mocked in tests.
- Kept API DTOs separate from domain models to avoid coupling the UI directly to API response formats.
- Kept each activity scorer independent so recommendation logic remains isolated, testable, and easy to tune.
- Used `async/await` for asynchronous API requests.
- Used `XCTest` for business-logic and state-related tests.
- Chose a deterministic rule-based recommendation model because it is explainable, testable, and appropriate for the scope of the assignment.

---

## How to Build and Run the App

1. Clone the repository `git clone https://github.com/sohann0902/ActivityForecast`
2. Open the project in Xcode `ActivityForecast.xcodeproj`
3. Select the ActivityForecast scheme
4. Choose an iPhone Simulator or a connected iPhone running iOS 26 or later.
5. Build and run the app using: `⌘ + R`

---

## How to Run Tests & Testing Strategy

### Running Tests
Tests can be run directly from Xcode.
1. Open the project in Xcode.
2. Select the `ActivityForecast` scheme.
3. Run all tests using: `⌘ + U`
4. You can also open the Test Navigator in Xcode and run individual test cases or test suites.

### Testing Strategy
The main focus of testing is the activity recommendation logic, since this contains the most important business rules in the app.
Each activity scorer is tested independently:
- `SkiScorerTests`
- `SurfScorerTests`
- `OutdoorScorerTests`
- `IndoorScorerTests`

These tests focus mainly on expected behaviour rather than exact score values.

Other tests cover:
- `ActivityScoringEngineTests` to verify that all activities are scored for each day and returned in ranked order.
- ViewModel tests to verify loading, success, empty, and error states.
- Service tests using mocked API responses to verify that forecast and geocoding data are mapped correctly.
- Error-handling tests to verify that networking failures are surfaced correctly to the presentation layer.
- Boundary tests to ensure generated activity scores always remain within the `0...100` range.

---

## API Usage Notes
The app uses the Open-Meteo APIs for city search and weather forecast data.
### Geocoding API
The Open-Meteo Geocoding API is used to search for cities and retrieve the latitude and longitude required for forecast requests.

### Forecast API
The Open-Meteo Forecast API is used to retrieve weather data for the next seven days.

The app uses daily forecast fields including:
- Weather code
- Maximum and minimum temperature
- Maximum and minimum apparent temperature
- Snowfall sum
- Precipitation sum
- Precipitation hours
- Maximum precipitation probability
- Maximum wind speed
- Maximum wind gusts
- Dominant wind direction
- Maximum UV index
- Sunshine duration
- Daylight duration

### Snow Depth
Snow depth is requested as hourly forecast data.
For each day, the app averages snow depth during typical skiing hours from approximately `08:00` to `17:00`.
This produces one representative daily snow-depth value that is used by the skiing scorer.

### API Keys
No API key is required for the Open-Meteo endpoints used by the project.

---

## Activity Recommendation Logic

Each activity is scored independently for every forecast day on a scale from `0...100`.
The scores are not divided between activities. This means multiple activities can score highly on the same day if the weather is suitable for each of them.
After the individual scores are calculated, the activities are sorted in descending order to create the daily ranking.

Each activity has its own scorer:
- `SkiScorer`
- `SurfScorer`
- `OutdoorScorer`
- `IndoorScorer`

### Skiing

Skiing uses snow availability as the main entry condition.
If snow depth is below the minimum required threshold, the skiing score is `0`.

If sufficient snow is available, the score considers:
- Snow depth
- Fresh snowfall
- Apparent temperature
- Wind speed
- Wind gusts
- Severe weather conditions

Good snow, suitable temperatures and low wind increase the score, while extreme cold, warm temperatures, strong winds and severe weather reduce it.

### Surfing

Surfing is scored as weather suitability for surfing.

The score considers:
- Wind speed
- Wind gusts
- Apparent temperature
- Sunshine
- Precipitation
- UV index
- Severe weather

Wind has the strongest influence on the score.

### Outdoor Sightseeing

Outdoor sightseeing represents how suitable the weather is for comfortably spending time outside.

The score considers:
- Apparent temperature
- Wind
- Sunshine
- Precipitation amount
- Precipitation duration
- Wind gusts
- UV index
- Severe weather

Comfortable temperatures, calm wind and sunshine increase the score, while rain, extreme temperatures, strong winds and storms reduce it.

### Indoor Sightseeing

Indoor sightseeing uses a baseline score because indoor activities are generally possible in most weather conditions.
Poor outdoor conditions can increase the indoor score.

Examples include:
- Rain
- Long-duration precipitation
- Extreme heat
- Extreme cold
- Moderate wind
- Low sunshine

Severe weather such as thunderstorms, freezing rain or extreme wind reduces the score because travelling to an indoor venue may also become difficult or unsafe.

---

## Assumptions Made

The assignment intentionally leaves some product decisions open, so the following assumptions were made:

- Activity rankings represent **weather suitability**, not whether an activity is actually available in the selected city.
- Surfing assumes the selected location has access to surfable water and waves.
- Skiing assumes skiing may be available when sufficient snow depth is present.
- Each forecast day is evaluated independently.
- Apparent temperature is preferred where perceived outdoor comfort or wind chill is more relevant than raw temperature.

---

## Trade-offs and Omissions

### Surfing Data
A complete surfing recommendation would ideally consider wave height, wave period, swell direction, and tides.
The assignment specifies the Open-Meteo Forecast API, so these marine-specific conditions are not included. As a result, the surfing score represents weather suitability for surfing rather than actual surf quality.

### Activity Availability
The app does not verify whether a city actually contains ski resorts, surf beaches, museums, or outdoor attractions.
Supporting this would require additional geographic or activity-specific data sources outside the scope of the assignment.

### Forecast Granularity
Recommendations are primarily based on daily forecast values.
A more advanced implementation could generate recommendations for specific parts of the day, such as morning, afternoon, and evening.

### Rule-Based Scoring
The scoring thresholds and weights are heuristic rather than calibrated against real-world activity outcomes.
The rule-based approach was chosen because it is deterministic, explainable, easy to test, and easy to tune.

### Scope
The project prioritizes architecture, recommendation logic, state handling, and testability over feature volume.

---

## Production-Readiness Notes

Before releasing the app as a production product, I would consider the following improvements:

### Networking
- Request retry handling
- Timeout handling
- API response caching
- Offline support
- Rate-limit handling
- Improved response validation

### Recommendation Quality
- Tune scoring thresholds using more real-world data
- Add activity availability data for each location
- Add ski resort information
- Add marine data for surfing
- Support hourly activity recommendations
- Support user preferences and tolerance levels

### User Experience
- Improve loading and retry states
- Show clearer explanations for why an activity received a particular score

---

## Cross-Platform Delivery Notes

The project is implemented natively for iOS using Swift and SwiftUI.

Recommendation logic is separated from the UI layer, so the same scoring rules can be reproduced on another platform without depending on SwiftUI.

An Android implementation could use Kotlin, Jetpack Compose, MVVM, Coroutines, and equivalent unit-testing tools while preserving the same activity scoring rules and test scenarios.

No shared cross-platform layer was introduced because it would add unnecessary complexity for the scope of this assignment.

---

## AI Usage Disclosure

AI was used during development as a collaborative engineering tool.

It was used to help with:
- Researching weather factors relevant to each activity
- Reviewing scoring assumptions and edge cases
- Finding out test scenarios

AI-generated suggestions were reviewed and validated before being incorporated into the project.
Scoring behaviour was verified through unit tests, and the implementation was adjusted when testing exposed unrealistic results.
