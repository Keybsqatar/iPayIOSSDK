import SwiftUI

public struct OpenSavedTopupView: View {
    // @EnvironmentObject private var coordinator: SDKCoordinator
    @EnvironmentObject private var coord: SDKCoordinator
    @ObservedObject private var vm: OpenSavedTopupViewModel
    @State private var navigate = false
    
    @State private var showAlert = false
    
    public init(vm: OpenSavedTopupViewModel) {
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
                
                NavigationLink(
                    destination: vm.item != nil ?
                    AnyView(
                        ProductsView(
                            saveRecharge:         "0",
                            receiverMobileNumber: vm.item!.targetIdentifier,
                            
                            countryIso:           vm.item!.countryIso2,
                            countryFlagUrl:       vm.item!.countryFlagUrl,
                            countryName:          vm.item!.countryName,
                            
                            providerCode:         vm.item!.providerCode,
                            providerLogoUrl:      vm.item!.providerImgUrl,
                            providerName:         vm.item!.providerName,
                            
                            productSku:           vm.item!.productSku,
                            
                            mobileNumber:         vm.mobileNumber,
                            serviceCode:          vm.serviceCode,
                            iPayCustomerID:       vm.iPayCustomerID,
                            
                            dismissMode:          "closeSDK"
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
}
