import SwiftUI

public protocol CountryFilterable: ObservableObject {
    var filteredCountries: [CountryItem] { get }
    func filterCountries(by search: String)
}

extension TopUpViewModel: CountryFilterable {}
extension VouchersViewModel: CountryFilterable {}
extension UtilityViewModel: CountryFilterable {}

// public struct CountryPicker: View {
public struct CountryPicker<VM: CountryFilterable>: View {
    @Environment(\.presentationMode) private var mode
    // @ObservedObject var vm: TopUpViewModel
    @ObservedObject var vm: VM
    @State private var search = ""
    public var onSelect: ((CountryItem) -> Void)?
    
    public init(vm: VM,
                onSelect: ((CountryItem) -> Void)? = nil)
    {
        self.vm = vm as! VM
        self.onSelect = onSelect
    }
    
    private struct HideSeparatorAndBackground: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 15.0, *) {
                content
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)
            } else {
                content
            }
        }
    }
    
    public var body: some View {
        // NavigationView {
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 40.0, height: 4.0)
                    .background(Color("keyBs_bg_gray_1", bundle: .module))
                    .cornerRadius(4.0)
                    .padding(.vertical, 6)
                
                Text("Select Country")
                    .font(.custom("VodafoneRg-Bold", size: 18.0))
                    .foregroundColor(Color("keyBs_font_gray_2", bundle: .module))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 12)
                
                HStack {
                    Image("ic_search", bundle: .module)
                        .frame(width: 16, height: 16)
                        .scaledToFit()
                    
                    TextField("Search", text: $search, onEditingChanged: { _ in
                        vm.filterCountries(by: search)
                    })
                    .foregroundColor(.primary)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color("keyBs_white", bundle: .module))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("keyBs_bg_gray_1", bundle: .module), lineWidth: 1)
                )
                .padding([.horizontal, .top])
                
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
                    .modifier(HideSeparatorAndBackground())
                }
                .padding(.vertical, 12)
                .listStyle(.plain)
                .background(Color.white)
            }
            .background(Color.white)
            .onAppear {
                vm.filterCountries(by: "")
            }
        // }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

// MARK: - Modifiers for iOS 15+ and iOS 14+

private struct SearchableModifier: ViewModifier {
    @Binding var search: String
    var vm: TopUpViewModel
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .searchable(text: $search)
                .onChange(of: search) { newValue in
                    vm.filterCountries(by: newValue)
                }
        } else {
            content
        }
    }
}

private struct NavigationTitleAndToolbarModifier: ViewModifier {
    var mode: Binding<PresentationMode>
    
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content
                .navigationTitle("Select Country")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { mode.wrappedValue.dismiss() }
                    }
                }
        } else {
            content
        }
    }
}
