import SwiftUI

public struct UtilityTabView: View {
    public enum Tab { case new, saved }
    @Binding var selection: Tab
//    private let bundle = Bundle.mySwiftUIPackage
    
    public init(selection: Binding<Tab>) {
        self._selection = selection
    }
    
    public var body: some View {
        ZStack {
            Image(
                selection == .new ? "bg_tab_new" : "bg_tab_saved",
                bundle: .module
            )
            .resizable()
            
            HStack(spacing: 0) {
                Button(action: { selection = .new }) {
                    HStack(spacing: 8) {
                        if selection == .new {
                            Image("ic_file", bundle: .module)
                                .resizable()
                                .frame(width: 16, height: 20)
                        }
                        Text("New Bill")
                            .font(.custom("VodafoneRg-Bold", size: 16))
                            .foregroundColor(selection == .new ? Color("keyBs_white", bundle: .module) : Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, selection == .new ? 0 : 15)
                .buttonStyle(.plain)
                
                Button(action: { selection = .saved }) {
                    HStack(spacing: 8) {
                        if selection == .saved {
                            Image("ic_file", bundle: .module)
                                .resizable()
                                .frame(width: 16, height: 20)
                        }
                        Text("Saved Bills")
                            .font(.custom("VodafoneRg-Bold", size: 16))
                            .foregroundColor(selection == .saved ? Color("keyBs_white", bundle: .module) : Color("keyBs_font_gray_2", bundle: .module))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, selection == .saved ? 0 : 15)
                .buttonStyle(.plain)
            }
        }
        .frame(height: 55)
        .clipped() // make sure no overflow
    }
}

struct UtilityTabView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selection: UtilityTabView.Tab = .new
        var body: some View {
            UtilityTabView(selection: $selection)
        }
    }
    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}


// #Preview {
//     UtilityTabView(
//         selection: .constant(.new)
//     )
// }
