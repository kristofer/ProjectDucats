import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color("AccentColor").ignoresSafeArea()
            VStack {
                Image("AppImage")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(24)
                Text("Ducats")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
