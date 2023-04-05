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
    
    @EnvironmentObject var controller: Controller

    var body: some View {
        switch self.controller.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .login:
            Login(loginBehavior: self.controller.loginBehavior)
        case .home:
            Home(shoppingBehavior: self.controller.shoppingBehavior)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Controller())
    }
}
