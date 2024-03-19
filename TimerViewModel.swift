//
//  TimerViewModel.swift
//  Focal
//
//  Created by Niek van de Pas on 12/03/2024.
//

import SwiftUI
import Combine
import UserNotifications

class TimerViewModel: ObservableObject {
    static let shared = TimerViewModel()
    @Published var timeRemaining = 2
    @Published var timerIsRunning = false
    @Published var timerState: TimerState = .work

    private var timer: AnyCancellable?

    init() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard self.timerIsRunning else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.scheduleNotification(self.timerState)
                    self.timerState.toggle()
                    self.pauseTimer()

                    switch self.timerState {
                    case .work:
                        self.timeRemaining = 25 * 60
                    case .rest:
                        self.timeRemaining = 5 * 60
                    }
                }
            }
    }
    
    func toggleTimer() {
        timerIsRunning.toggle()
    }
    
    func startTimer() {
        timerIsRunning = true
    }
    
    func pauseTimer() {
        timerIsRunning = false
    }
    
    func resetTimer() {
        timerState = .work
        timeRemaining = 25 * 60
        timerIsRunning = false
    }

    var timerIsFull: Bool {
        switch self.timerState {
        case .work:
            return timeRemaining == 25 * 60
        case .rest:
            return timeRemaining == 5 * 60
        }
    }

    private func scheduleNotification(_ finishedTimerState: TimerState) {
        let content = createNotificationContent(for: finishedTimerState)
        let category = createNotificationCategory()
        UNUserNotificationCenter.current().setNotificationCategories([category])

        content.userInfo = ["timerState": finishedTimerState.description]
        let request = createNotificationRequest(for: content)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }

    private func createNotificationContent(for finishedTimerState: TimerState) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        switch finishedTimerState {
        case .work:
            content.title = "Time for a break!"
            content.body = "Your Pomodoro session has ended. Time to take a break!"
        case .rest:
            content.title = "Break's over!"
            content.body = "Time to get back to work!"
        }
        content.sound = .default
        content.categoryIdentifier = "TIMER_EXPIRED"
        return content
    }

    private func createNotificationCategory() -> UNNotificationCategory {
        let startNextTimerAction = UNNotificationAction(identifier: "START_NEXT_TIMER",
                                                         title: "Start Next Timer",
                                                         options: .foreground)
        let category = UNNotificationCategory(identifier: "TIMER_EXPIRED",
                                              actions: [startNextTimerAction],
                                              intentIdentifiers: [],
                                              options: [])
        return category
    }

    private func createNotificationRequest(for content: UNMutableNotificationContent) -> UNNotificationRequest {
        let deliveryDate = Date()
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: deliveryDate), repeats: false)
        let request = UNNotificationRequest(identifier: "com.niekvdpas.FocalTimeUp", content: content, trigger: trigger)
        return request
    }


}
