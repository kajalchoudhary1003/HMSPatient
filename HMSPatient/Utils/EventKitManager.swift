import EventKit

class EventKitManager: NSObject, ObservableObject {
    @Published var events: [EKEvent] = []

    private let eventStore = EKEventStore()

    func requestCalendarAccessAndAddEvent(title: String, startDate: Date, endDate: Date, notes: String?, completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard granted, error == nil else {
                completion(false)
                return
            }
            
            let newEvent = EKEvent(eventStore: self!.eventStore)
            newEvent.title = title
            newEvent.startDate = startDate
            newEvent.endDate = endDate
            newEvent.notes = notes
            newEvent.calendar = self!.eventStore.defaultCalendarForNewEvents

            do {
                try self!.eventStore.save(newEvent, span: .thisEvent)
                DispatchQueue.main.async {
                    self?.events.append(newEvent)
                }
                completion(true)
            } catch {
                print("Error saving event: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
