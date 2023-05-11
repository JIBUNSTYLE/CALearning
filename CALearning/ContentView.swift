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
    @EnvironmentObject var dispatcher: Dispatcher

    var body: some View {
        switch self.dispatcher.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .signIn:
            SignIn(signInStore: self.dispatcher.signInStore)
        case .home:
            Home(shoppingStore: self.dispatcher.shoppingStore)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Dispatcher())
    }
}
