import SwiftUI

public struct OpenSavedTopupView: View {
    @EnvironmentObject private var coordinator: SDKCoordinator
    
    // @StateObject private var vm: OpenSavedTopupViewModel
    @ObservedObject private var vm: OpenSavedTopupViewModel
    
    @State private var navigate = false
    
    @State private var showAlert = false
    
    public init(vm: OpenSavedTopupViewModel) {
        // _vm = StateObject(wrappedValue: vm)
        self.vm = vm
    }
    
    public var body: some View {
        // NavigationStack {
        NavigationView {
            ZStack {
                // Color.white.ignoresSafeArea()
                Color.white.edgesIgnoringSafeArea(.all)
                
                
                //                                if vm.isLoading {
                //                                    ProgressView("Loading…")
                //                                }
                //                                else
                if let err = vm.error {
                    Text("")
                        .padding()
                    // .alert("Error",
                    //        isPresented: $showAlert,
                    //        actions: {
                    //     Button("Close") {
                    //         coordinator.closeSDK()
                    //     }
                    // },
                    //        message: { Text(err) }
                    // )
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Error"),
                                message: Text(err),
                                dismissButton: .default(Text("Close")) {
                                    coordinator.closeSDK()
                                }
                            )
                        }
                        .onAppear {
                            showAlert = true
                        }
                    
                    //                     Text(err)
                    //                         .foregroundColor(.red)
                    //                         .multilineTextAlignment(.center)
                    //                         .padding(16)
                }
                // Hidden NavigationLink for navigation
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
                        .navigationBarHidden(true)
                        .environmentObject(coordinator)
                    )
                    : AnyView(EmptyView()),
                    isActive: $navigate,
                    label: { EmptyView() }
                )
                .hidden()
            }
            //            .toolbar {
            //                ToolbarItem(placement: .cancellationAction) {
            //                    Button { coordinator.closeSDK() } label: {
            //                        Image(systemName: "xmark")
            //                    }
            //                }
            //            }
            // .task { await vm.load() }
            .onAppear {
                // If vm.load() is async, wrap in Task
                Task {
                    await vm.load()
                }
            }
            // .onChange(of: vm.item?.id) { id in
            //     if id != nil {
            //         navigate = true
            //     }
            // }
            // .navigationDestination(isPresented: $navigate) {
            //     if let bill = vm.item {
            //         ProductsView(
            //             saveRecharge:         "0",
            //             receiverMobileNumber: bill.targetIdentifier,
            //             countryIso:           bill.countryIso2,
            //             countryFlagUrl:       bill.countryFlagUrl,
            //             countryName:          bill.countryName,
            //             providerCode:         bill.providerCode,
            //             providerLogoUrl:      bill.providerImgUrl,
            //             providerName:         bill.providerName,
            //             productSku:           bill.productSku,
            
            //             mobileNumber:         vm.mobileNumber,
            //             serviceCode:          vm.serviceCode,
            //             iPayCustomerID:       vm.iPayCustomerID,
            
            //             dismissMode:          "closeSDK"
            //         )
            //         .toolbar(.hidden, for: .navigationBar)
            //         .environmentObject(coordinator)
            //     }
            // }
        }
    }
}
