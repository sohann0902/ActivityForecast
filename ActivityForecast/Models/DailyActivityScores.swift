import Foundation

struct ActivityResult: Identifiable {
    var id: Activity { activity }
    let activity: Activity
    let score: ActivityScore
}

struct DailyActivityRanking: Identifiable {
    var id: String { date }
    let date: String
    let activities: [ActivityResult]
}
