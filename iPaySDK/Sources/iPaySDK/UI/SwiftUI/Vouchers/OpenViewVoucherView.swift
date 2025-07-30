import SwiftUI

public struct OpenViewVoucherView: View {
    // @EnvironmentObject private var coordinator: SDKCoordinator
    @EnvironmentObject private var coord: SDKCoordinator
    @ObservedObject private var vm: OpenViewVoucherViewModel
    @State private var navigate = false
    
    @State private var showAlert = false
    
    public init(vm: OpenViewVoucherViewModel) {
        self.vm = vm
    }
    
    public var body: some View {
        // NavigationView {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if let err = vm.error {
                Text("")
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(err),
                            dismissButton: .default(Text("Close")) {
                                coord.dismissSDK()
                            }
                        )
                    }
                    .onAppear {
                        showAlert = true
                    }
            }
            
            let (textPin, valuePin) = extractPinParams(from: vm.item?.reciptParams)
            
            NavigationLink(
                destination: vm.item != nil ?
                AnyView(
                    ViewVoucherView(
                        close: true,
                        
                        displayText: vm.item!.productDisplayText,
                        
                        countryFlagUrl: vm.item!.countryFlagUrl,
                        countryName: vm.item!.countryName,
                        
                        providerName: vm.item!.providerName,
                        providerLogoUrl: vm.item!.providerImgUrl,
                        
                        dateTime: vm.item!.dateTime,
                        refId: vm.item!.billingRef,
                        
                        descriptionMarkdown: vm.item!.descriptionMarkdown,
                        readMoreMarkdown: vm.item!.readMoreMarkdown,
                        
                        textPin: textPin,
                        valuePin: valuePin
                    )
                    .environmentObject(coord)
                    .navigationBarHidden(true)
                )
                : AnyView(EmptyView()),
                isActive: $navigate,
                label: { EmptyView() }
            )
            .hidden()
        }
        .onAppear {
            Task {
                await vm.load()
            }
        }
        .onReceive(vm.$item.compactMap { $0?.id }) { id in
            navigate = true
        }
        // }
    }
    
    private func extractPinParams(from receiptParams: String?) -> (textPin: String, valuePin: String) {
        guard
            let receiptParamsString = receiptParams,
            let data = receiptParamsString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let (key, value) = json.first
        else {
            return ("", "")
        }
        return ("\(key)", "\(value)")
    }
}
