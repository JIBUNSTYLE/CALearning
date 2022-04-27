//
//  ContentView.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

enum Views {
    case splash, tutorial, login
}

struct ContentView: View {
    
    @EnvironmentObject var sharedPresenter: SharedPresenter

    var body: some View {
        switch self.sharedPresenter.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .login:
            Login(localPresenter: self.sharedPresenter.loginPresenter)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SharedPresenter())
    }
}
