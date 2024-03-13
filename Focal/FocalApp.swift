//
//  FocalApp.swift
//  Focal
//
//  Created by Niek van de Pas on 11/03/2024.
//

import SwiftUI

@main
struct FocalApp: App {
    @StateObject var timerViewModel = TimerViewModel()

    var body: some Scene {
        let menuBarImage = timerViewModel.timerIsRunning ? "clock" : "pause.circle";

        MenuBarExtra("Focal", systemImage: menuBarImage) {
            AppMenu(viewModel: timerViewModel)
        }
        WindowGroup {
            TimerView(viewModel: timerViewModel)
        }
        .defaultSize(width: 300, height: 200)
    }
}

