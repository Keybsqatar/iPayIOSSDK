import SwiftUI

public struct CountryPicker: View {
    @Environment(\.presentationMode) private var mode
    @ObservedObject var vm: TopUpViewModel
    @State private var search = ""
    public var onSelect: ((CountryItem) -> Void)?
    
    public init(vm: TopUpViewModel,
                onSelect: ((CountryItem) -> Void)? = nil)
    {
        self.vm = vm
        self.onSelect = onSelect
    }
    
    public var body: some View {
        NavigationView {
            List(vm.filteredCountries) { c in
                HStack {
                    SVGImageView(url: c.flagUrl)
                        .frame(width: 32, height: 32)
                        .scaledToFit()
                        .cornerRadius(16)
                    
                    Text(c.name)
                        .font(.custom("VodafoneRg-Regular", size: 16.0))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("+\(c.prefix)")
                        .font(.custom("VodafoneRg-Regular", size: 16.0))
                        .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect?(c)
                    mode.wrappedValue.dismiss()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.white)
            }
            //            .listStyle(PlainListStyle()) // Use plain style
            .searchable(text: $search)
            .onChange(of: search) { _, newValue in
                vm.filterCountries(by: newValue)
            }
            .onAppear {
                Task { vm.filterCountries(by: "") }
            }
            // .navigationTitle("Select Country")
            .navigationTitle("Select Country")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { mode.wrappedValue.dismiss() }
                }
            }
            .background(Color.white)
            .scrollContentBackground(.hidden)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

struct CountryPicker_Previews: PreviewProvider {
    static let sampleCountries: [CountryItem] = [
        CountryItem(countryIso: "IN", name: "India", prefix: "91",
                    minimumLength: "9", maximumLength: "12",
                    flagUrl: URL(string:
                                    "https://upload.wikimedia.org/wikipedia/en/4/41/Flag_of_India.svg"
                                )!),
        CountryItem(countryIso: "CA", name: "Canada", prefix: "1",
                    minimumLength: "10", maximumLength: "10",
                    flagUrl: URL(string:
                                    "https://upload.wikimedia.org/wikipedia/commons/c/cf/Flag_of_Canada.svg"
                                )!),
        CountryItem(countryIso: "EG", name: "Egypt", prefix: "20",
                    minimumLength: "10", maximumLength: "12",
                    flagUrl: URL(string:
                                    "https://upload.wikimedia.org/wikipedia/commons/f/fe/Flag_of_Egypt.svg"
                                )!)
    ]
    
    // Pre–configure both countries and filteredCountries
    static var previewVM: TopUpViewModel = {
        let vm = TopUpViewModel(
            serviceCode: "INT_TOP_UP",
            mobileNumber: "12345",
            iPayCustomerID: "13"
        )
        vm.countries           = sampleCountries
        vm.filteredCountries   = sampleCountries        // ← updated
        return vm
    }()
    
    static var previews: some View {
        Group {
            CountryPicker(
                vm: previewVM
            )
            .previewDisplayName("Empty Selection")
        }
    }
}
