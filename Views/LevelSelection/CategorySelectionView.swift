import SwiftUI

struct CategorySelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCategory: () -> Void
    
    @State private var headerAppear = false
    
    var body: some View {
        ZStack {
            AppColors.meshGradient.ignoresSafeArea()
            BackgroundStarsView().ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        
                        Text("MathPlot")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accent, AppColors.accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("Choose a Function Type")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 24)
                .scaleEffect(headerAppear ? 1 : 0.9, anchor: .leading)
                .opacity(headerAppear ? 1 : 0)
                
                GeometryReader { geo in
                    let cardCount = CGFloat(FunctionCategory.allCases.count)
                    let totalSpacing: CGFloat = (cardCount - 1) * 12
                    let availableHeight = geo.size.height - 40
                    let cardHeight = (availableHeight - totalSpacing) / cardCount
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(
                                Array(FunctionCategory.allCases.enumerated()),
                                id: \.element.id
                            ) { index, category in
                                CategoryCard(
                                    category: category,
                                    completedCount: viewModel.completedCount(for: category),
                                    totalCount: viewModel.totalCount(for: category),
                                    delay: Double(index) * 0.08,
                                    cardHeight: max(cardHeight, 90)
                                )
                                .onTapGesture {
                                    viewModel.selectedCategory = category
                                    onSelectCategory()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                headerAppear = true
            }
        }
    }
}

