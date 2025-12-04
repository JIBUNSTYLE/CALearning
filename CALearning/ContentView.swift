//
//  ContentView.swift
//  CALearning
//
//  Created by 斉藤 祐輔 on 2022/01/25.
//

import SwiftUI

enum Views {
    case splash, tutorial, signIn, home
}

struct ContentView: View {
    @EnvironmentObject var service: FrontendService

    var body: some View {
        switch self.service.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .signIn:
            SignIn(signInStore: self.service.signInState)
        case .home:
            Home(shoppingStore: self.service.shoppingState)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FrontendService())
    }
}
