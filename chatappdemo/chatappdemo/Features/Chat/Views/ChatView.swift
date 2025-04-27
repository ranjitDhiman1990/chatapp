//
//  ChatView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var newMessage: String = ""
    
    init (currentUser: AuthUser, otherUser: AuthUser?, conversation: UserConversation?) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(currentUser: currentUser, otherUser: otherUser, conversation: conversation))
    }
    
    var body: some View {
        VStack {
            // Messages list
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            // Input area
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.sendMessage(text: newMessage)
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
            .padding()
        }
        .onAppear {
            if viewModel.conversation != nil {
                viewModel.loadChats(lastMessageId: nil)
            }
        }
        .navigationTitle(viewModel.otherUser?.displayName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavbarBackButton()
            }
        }
    }
    
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: message.isOwnMessage ? .leading : .trailing, spacing: 4) {
            Text(message.content ?? "")
                .padding()
                .background(message.isOwnMessage ? Color(.systemGray5) : Color.blue)
                .foregroundColor(message.isOwnMessage ? .primary : .white)
                .cornerRadius(10)
            
            Text(message.timestamp?.formatted() ?? "")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: message.isOwnMessage ? .leading : .trailing)
        .padding(.horizontal, 8)
    }
}
