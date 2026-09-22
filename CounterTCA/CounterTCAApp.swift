//
//  CounterTCAApp.swift
//  CounterTCA
//
//  Created by 677131 on 20/9/2569 BE.
//

import SwiftUI
import ComposableArchitecture

@main
struct CounterTCAApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: .init(
          initialState: .init(),
          reducer: {
            ContentFeature()
          }
        )
      )
    }
  }
}
