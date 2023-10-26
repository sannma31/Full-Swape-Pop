//
//  ContentView.swift
//  Full Swape Pop
//
//  Created by 笠井翔雲 on 2023/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isEnabled: Bool = false
    var body: some View {
        FullSwipeNavigationStack{
            List{
                Section("Sample Header"){
                    NavigationLink("Full Swipe Pop"){
                        List{
                            Toggle("Enble Full Swape Pop", isOn: $isEnabled)
                                .enableFullSwipePop(isEnabled)
                        }
                        .navigationTitle("Full Swipe View")
                    }
                    NavigationLink("Leading Swipe Pop"){
                        Text("")
                            .navigationTitle("Leading Swipe Pop")
                    }
                }
                
            }
            .navigationTitle("Full Swipe Pop")
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
