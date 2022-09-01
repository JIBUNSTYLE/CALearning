//
//  ContentView.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

enum Views {
    case splash, tutorial, login, home
}

struct ContentView: View {
    
    @EnvironmentObject var presenter: Presenter

    var body: some View {
        switch self.presenter.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .login:
            Login(localStore: self.presenter.loginStore)
        case .home:
            TermsOfService()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Presenter())
    }
}
