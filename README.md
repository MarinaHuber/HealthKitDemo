# Workout Detail App

The goal of the project is to make a route map with an overlay with charts which show more detail of a trip.

## Stories

### Phase 1
- As a user I can import a GPX file into Apple Health. The file will be included in the project
- As a user I can see a route of my session. All data should be read from Apple Health
### Phase 2
- As a user I can a chart of my speed across the session
- As a user I can see a chart of my pace across the session
- As a user I can see a chart of my heart rate across the session

![Wireframes - the app can be quite "vanilla" and should not need be a pixel perfect from these wireframes. That said, the "cards" paradigm is important](https://cln.sh/DaBD8f/download)

## Notes

- App can be either UIKit, SwiftUI or a hybrid
- You can use any third party dependencies you see fit, but be prepared to explain why you chose them
    - We use [PanModal](https://github.com/slackhq/PanModal) for the popover cards at the moment
    - I have included [CoreGPX](https://github.com/vincentneo/CoreGPX) 
- Remember to include time for demoing your app and other communications that may come up
- You don't need to worry about presenting errors or feedback to the user, you can just use `print` or `os_log`

## Milestones

- Provide quote for completing each project
    - Should be broken down for: 
        - Phase 1: Doing the import and drawing the map
        - Phase 2: Drawing the charts
    - Should include estimated start and end dates
    - Should include range of estimated hours
    - Should include cost per hour

- Paddle Logger sign off on quote
- Complete import and map - demo app, get paid
- Complete charts - demo app, get paid
