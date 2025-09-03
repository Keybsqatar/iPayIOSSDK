//
//  DeleteTipView.swift
//  iPaySDK
//
//  Created by Loay Abdullah on 01/09/2025.
//

import SwiftUI

public struct DeleteTipView: View {
    @EnvironmentObject private var coord: SDKCoordinator
    @Binding var isPresented: Bool
    var onHomepage: (() -> Void)? = nil

    public var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            // Content
            VStack (spacing: 10){
                ZStack {
                        

                        VStack() {
                            LottieView(name: "input_swipe", bundle: .module)
                                .frame(height: 50)
                        }
                        //.padding(.horizontal, 80)
                        VStack() {
                        LottieView(name: "hand_swipe", bundle: .module)
                            .frame(height: 100)
                            //.position(x:50,y:0)
                        
                        }
                        .padding(.vertical, -90)
                        .padding(.trailing, -100)



                }

                Text("Swipe to delete")
                        .font(.custom("VodafoneRg-Bold", size: 18))
                        .foregroundColor(Color("keyBs_white", bundle: .module))
                        .multilineTextAlignment(.leading)
            }

        }
        
        // Make the entire overlay tappable
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture().onEnded {
                withAnimation(.easeOut(duration: 0.2)) { isPresented = false }
            }
        )
        // (Optional) also dismiss on any drag
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in
                withAnimation(.easeOut(duration: 0.2)) { isPresented = false }
            }
        )
    }
}


