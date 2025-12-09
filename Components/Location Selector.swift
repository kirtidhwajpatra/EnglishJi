import SwiftUI

struct LocationSelectorField: View {
    let title: String
    let options: [String]
    @Binding var selectedValue: String

    @State private var isExpanded = false
    @State private var isFocused = false

    var body: some View {
        VStack(spacing: 6) {
            
            // Main interactive field
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                    isFocused = true
                }
            }) {
                HStack {
                    Spacer()
                    // Display Title if empty, otherwise display selected value
                    Text(selectedValue.isEmpty ? title : selectedValue)
                        .font(.system(size: 26, weight: .regular))
                        .kerning(-1)
                        .foregroundColor(selectedValue.isEmpty ?
                                         Color.gray.opacity(0.4) :
                                            Color(hex: "0F0039"))
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "0F0039").opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .frame(height: 50)
                // Make the whole area tappable
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Animated Underline
            Rectangle()
                .fill(Color(hex: "0F0039"))
                .frame(height: 2)
                .scaleEffect(x: isFocused || !selectedValue.isEmpty ? 1 : 0.2, y: 1, anchor: .center)
                .opacity(isFocused || !selectedValue.isEmpty ? 1 : 0.3)
                .animation(.easeInOut(duration: 0.25), value: isFocused)

            // Dropdown List
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { item in
                        Button {
                            // Update Binding and Close Dropdown
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedValue = item
                                isExpanded = false
                                isFocused = true
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Text(item)
                                    .font(.system(size: 22))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundColor(Color(hex: "0F0039"))
                                
                                if item != options.last {
                                    Divider().opacity(0.3)
                                }
                            }
                        }
                        .buttonStyle(.plain) // Ensures click works smoothly in lists
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(10) // Ensures dropdown floats above other content
            }
        }
        .padding(.horizontal, 24)
        // Removed the generic .onTapGesture here because it conflicts with the list buttons
    }
}


// MARK: - PREVIEW
struct LocationSelectorField_Previews: PreviewProvider {
    // We need a wrapper to hold state in the Preview
    struct PreviewWrapper: View {
        @State var selectedCity = ""
        @State var selectedCountry = ""
        
        var body: some View {
            VStack(spacing: 30) {
//                Text("Debugging Selection:")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text("City: \(selectedCity) | Country: \(selectedCountry)")
//                    .font(.caption)
                
//                Divider()
                
                LocationSelectorField(
                    title: "City",
                    options: ["New Delhi", "Mumbai", "Bangalore", "Kolkata"],
                    selectedValue: $selectedCity
                )
                
                LocationSelectorField(
                    title: "Country",
                    options: ["India", "USA", "UK"],
                    selectedValue: $selectedCountry
                )
                
            }
            .padding(.top, 50)
            .background(Color(hex: "F2F2F7"))
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
