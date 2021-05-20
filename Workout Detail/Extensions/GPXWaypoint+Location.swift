import CoreLocation
import CoreGPX

extension GPXWaypoint {
    var coreLocation: CLLocation? {
        guard let lat = self.latitude,
              let lng = self.longitude,
              let date = self.time
        else {
            return nil
        }
        
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                          altitude: self.elevation ?? 0,
                          horizontalAccuracy: self.horizontalDilution ?? 0,
                          verticalAccuracy: self.verticalDilution ?? 0,
                          timestamp: date)
        
        return location
        
    }
}

