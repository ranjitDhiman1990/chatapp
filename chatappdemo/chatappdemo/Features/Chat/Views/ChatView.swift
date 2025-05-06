//
//  ChatView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var router: Router
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel: ChatViewModel
    @State private var scrollViewContentSize: CGSize = .zero
    @State private var hasAppeared = false
    
    init (currentUser: AuthUser, otherUser: AuthUser?, conversation: UserConversation?) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(currentUser: currentUser, otherUser: otherUser, conversation: conversation))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .top) {
                        // Track content size for pagination
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: ViewSizeKey.self,
                                    value: geometry.size
                                )
                        }
                        
                        LazyVStack(spacing: 8) {
                            // Loading indicator at top
                            if viewModel.isLoadingPrevious {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical)
                            }
                            
                            // Messages list
                            ForEach(viewModel.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                                    .onAppear {
                                        if message.id == viewModel.messages.last?.id && !hasAppeared {
                                            proxy.scrollTo(message.id, anchor: .bottom)
                                        }
                                        checkIfShouldLoadMore(message: message)
                                    }
                            }
                            
                            // Bottom spacer for scroll to bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding()
                    }
                    .onPreferenceChange(ViewSizeKey.self) { size in
                        scrollViewContentSize = size
                    }
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages) { _ in
                    if !viewModel.isLoadingPrevious {
                        scrollToBottom(proxy: proxy)
                    }
                    guard let lastId = viewModel.messages.last?.id else { return }
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            if viewModel.otherUserTyping {
                TypingIndicatorView(userName: viewModel.typingUserName)
                    .transition(.opacity)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            MessageInputView(viewModel: viewModel)
        }
        .onAppear {
            if viewModel.conversation != nil {
                viewModel.loadChats(lastMessageId: nil)
                hasAppeared = true
            }
        }
        .navigationTitle(viewModel.otherUser?.displayName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavbarBackButton() {
                    if let conversationId = self.viewModel.conversation?.conversationId, !conversationId.isEmpty {
                        viewModel.setTypingIndicator(isTyping: false, userId: viewModel.currentUser.id, conversationId: conversationId)
                        _ = router.pop()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            let appState: AppState
            switch newPhase {
            case .active: appState = .active
            case .inactive: appState = .inactive
            case .background: appState = .background
            @unknown default: appState = .inactive
            }
            
            // Update typing state when app state changes
            if let conversationId = viewModel.conversation?.conversationId {
                viewModel.setTypingIndicator(
                    isTyping: false,
                    userId: viewModel.currentUser.id,
                    conversationId: conversationId,
                    appState: appState
                )
            }
        }
    }
    
    private func checkIfShouldLoadMore(message: Message) {
        // Load more when we're 3 messages away from the top
        guard let index = viewModel.messages.firstIndex(where: { $0.id == message.id }),
              index <= 2,
              !viewModel.isLoadingPrevious,
              viewModel.canLoadMore else {
            return
        }
        
        Task {
            viewModel.loadChats(lastMessageId: viewModel.messages.first?.id)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard !viewModel.messages.isEmpty else { return }
        withAnimation {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// Helper for tracking scroll view content size
struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: message.isOwnMessage ? .trailing : .leading, spacing: 4) {
            Text(message.content ?? "")
                .padding()
                .background(message.isOwnMessage ? Color(.systemGray5) : Color.blue)
                .foregroundColor(message.isOwnMessage ? .primary : .white)
                .cornerRadius(10)
            
            Text(message.timestamp?.formatted() ?? "")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: message.isOwnMessage ? .trailing : .leading)
        .padding(.horizontal, 8)
    }
}

struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        // Input area
        HStack {
            TextField("Type a message", text: $viewModel.newMessage, onEditingChanged: { isEditing in
                if let conversationId = self.viewModel.conversation?.conversationId, !conversationId.isEmpty, !viewModel.newMessage.isEmpty {
                    viewModel.setTypingIndicator(isTyping: isEditing, userId: viewModel.currentUser.id, conversationId: conversationId)
                }
            }, onCommit: {
                if let conversationId = self.viewModel.conversation?.conversationId, !conversationId.isEmpty {
                    viewModel.setTypingIndicator(isTyping: false, userId: viewModel.currentUser.id, conversationId: conversationId)
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: viewModel.newMessage) { newValue in
                if let conversationId = self.viewModel.conversation?.conversationId, !conversationId.isEmpty {
                    viewModel.setTypingIndicator(isTyping: !newValue.isEmpty, userId: viewModel.currentUser.id, conversationId: conversationId)
                }
            }
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.sendMessage(text: viewModel.newMessage)
                        viewModel.newMessage = ""
                    } catch {
                        debugPrint("Image upload error = \(error.localizedDescription)")
                    }
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 4)
    }
}

struct TypingIndicatorView: View {
    let userName: String
    @State private var dotScale: [CGFloat] = [0.5, 0.3, 0.1]
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(userName) is typing")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .frame(width: 6, height: 6)
                        .scaleEffect(dotScale[index])
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            animateDots()
        }
    }
    
    private func animateDots() {
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
            dotScale = [0.3, 0.6, 0.3]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                dotScale = [0.1, 0.3, 0.6]
            }
        }
    }
}
