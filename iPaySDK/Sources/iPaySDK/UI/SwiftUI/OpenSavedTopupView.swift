import SwiftUI

public struct OpenSavedTopupView: View {
    @EnvironmentObject private var coordinator: SDKCoordinator
    @StateObject private var vm: OpenSavedTopupViewModel
    @State private var navigate = false
    
    @State private var showAlert = false
    
    public init(vm: OpenSavedTopupViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                //                                if vm.isLoading {
                //                                    ProgressView("Loading…")
                //                                }
                //                                else
                if let err = vm.error {
                    Text("")
                        .padding()
                        .alert("Error",
                               isPresented: $showAlert,
                               actions: {
                            Button("Close") {
                                coordinator.closeSDK()
                            }
                        },
                               message: { Text(err) }
                        )
                        .onAppear {
                            showAlert = true
                        }
                    
                    //                     Text(err)
                    //                         .foregroundColor(.red)
                    //                         .multilineTextAlignment(.center)
                    //                         .padding(16)
                }
            }
            //            .toolbar {
            //                ToolbarItem(placement: .cancellationAction) {
            //                    Button { coordinator.closeSDK() } label: {
            //                        Image(systemName: "xmark")
            //                    }
            //                }
            //            }
            .task { await vm.load() }
            .onChange(of: vm.item?.id) { id in
                if id != nil {
                    navigate = true
                }
            }
            .navigationDestination(isPresented: $navigate) {
                if let bill = vm.item {
                    ProductsView(
                        saveRecharge:         "0",
                        receiverMobileNumber: bill.targetIdentifier,
                        countryIso:           bill.countryIso2,
                        countryFlagUrl:       bill.countryFlagUrl,
                        countryName:          bill.countryName,
                        providerCode:         bill.providerCode,
                        providerLogoUrl:      bill.providerImgUrl,
                        providerName:         bill.providerName,
                        productSku:           bill.productSku,
                        
                        mobileNumber:         vm.mobileNumber,
                        serviceCode:          vm.serviceCode,
                        iPayCustomerID:       vm.iPayCustomerID,
                        
                        dismissMode:          "closeSDK"
                    )
                    .toolbar(.hidden, for: .navigationBar)
                    .environmentObject(coordinator)
                }
            }
        }
    }
}
