import SwiftUI

struct PrompterView: View {
    @ObservedObject var viewModel: PrompterViewModel

    // Measure content height to loop or stop appropriately
    @State private var contentHeight: CGFloat = 0

    // Tracks whether we paused due to hover and what the previous play state was
    @State private var wasPlayingBeforeHover: Bool = false
    @State private var isHovering: Bool = false

    var body: some View {
        ZStack {
            Color.black
            GeometryReader { geo in
                // container is fixed, only text moves
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    movingText
                        .frame(width: geo.size.width, alignment: .center)
                        .offset(y: -viewModel.offset)
                        .background(HeightReader(height: $contentHeight))
                    Spacer(minLength: 0)
                }
                .clipped()
                .onChange(of: viewModel.offset) { _, newValue in
                    // If we've scrolled past the end, loop smoothly
                    if contentHeight > 0, newValue > contentHeight {
                        viewModel.offset = 0
                    }
                }
                .onChange(of: viewModel.text) { _, _ in
                    // Reset offset when text changes to avoid jump into middle
                    viewModel.offset = 0
                }
            }
        }
        .ignoresSafeArea()
        .onHover { hovering in
            handleHoverChange(hovering: hovering)
        }
    }

    private func handleHoverChange(hovering: Bool) {
        guard viewModel.pauseOnHover else {
            // If the feature is off, do nothing and reset tracking flags
            isHovering = false
            wasPlayingBeforeHover = false
            return
        }

        if hovering {
            // Entering hover: remember current playing state and pause
            isHovering = true
            wasPlayingBeforeHover = viewModel.isPlaying
            if viewModel.isPlaying {
                viewModel.isPlaying = false
            }
        } else {
            // Leaving hover: restore previous playing state if we paused due to hover
            if isHovering, wasPlayingBeforeHover {
                viewModel.isPlaying = true
            }
            isHovering = false
            wasPlayingBeforeHover = false
        }
    }

    private var movingText: some View {
        // Duplicate the text once to create a seamless loop
        let linesSpacing = 8.0
        return VStack(spacing: linesSpacing) {
            textBlock
            textBlock
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
    }

    private var textBlock: some View {
        Text(viewModel.text.isEmpty ? "Put some text in Settings..." : viewModel.text)
            .font(.system(size: viewModel.fontSize, weight: .regular, design: .default))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct HeightReader: View {
    @Binding var height: CGFloat
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { height = proxy.size.height }
                .onChange(of: proxy.size) { _, newSize in
                    height = newSize.height
                }
        }
    }
}
