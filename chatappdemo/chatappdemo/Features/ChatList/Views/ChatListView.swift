//
//  ChatListView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var router: Router
    @StateObject var viewModel: ChatListViewModel
    @State private var showUserSearch = false
    @State private var showUsersList = false
    @State private var selectedUser: AuthUser? = nil
    @State private var selectedConversation: UserConversation? = nil
    
    init (currentUser: AuthUser) {
        _viewModel = StateObject(wrappedValue: ChatListViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if viewModel.shouldShowLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding()
                        .listRowBackground(Color(.systemGroupedBackground))
                } else if viewModel.shouldShowEmptyState {
                    emptyStateView
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding()
                        .listRowBackground(Color(.systemGroupedBackground))
                } else if viewModel.shouldShowError {
                    if case let .error(error) = viewModel.viewState {
                        errorView(error: error)
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .padding()
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                } else {
                    ForEach(viewModel.filteredConversations) { conversation in
                        ChatListRow(conversation: conversation)
                            .onTapGesture {
                                let user = AuthUser(
                                    id: conversation.otherUserId ?? "",
                                    displayName: conversation.otherUserName,
                                    photoURL: URL(string: conversation.otherUserImageUrl ?? "")
                                )
                                selectedUser = user
                                selectedConversation = conversation
                                showUsersList = false
                                self.router.push(.ChatView(
                                    currentUser: viewModel.currentUser,
                                    otherUser: user,
                                    conversation: conversation
                                ))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        if let index = viewModel.filteredConversations.firstIndex(where: { $0.id == conversation.id }) {
                                            await deleteConversation(at: index)
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.plain) // ← Removes extra default list insets
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await loadConversations()
            }
            
            // Floating Action Button
            floatingActionButton
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.router.push(.EditProfileView)
                } label: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.primary)
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .task {
            await loadConversations()
        }
        .sheet(isPresented: $showUsersList) {
            UsersListView(
                currentUser: viewModel.currentUser,
                onUserSelected: { user in
                    showUsersList = false
                    selectedUser = user
                    self.router.push(.ChatView(
                        currentUser: viewModel.currentUser,
                        otherUser: user,
                        conversation: nil
                    ))
                }
            )
        }
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button {
                    showUsersList = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No conversations yet")
                .font(.title2)
            Text("Start a new conversation to see it here")
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("Something went wrong")
                .font(.title2)
            Text(error.localizedDescription)
                .foregroundColor(.gray)
            
            Button("Try Again") {
                Task {
                    await loadConversations()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
    
    private func loadConversations() async {
        do {
            try await viewModel.loadConversations()
        } catch {
            // Error is already handled by the view model
            debugPrint("Error loading conversations: \(error)")
        }
    }
    
    private func deleteConversation(at index: Int) async {
        do {
            try await viewModel.deleteConversation(at: index)
        } catch {
            debugPrint("Error deleting conversation: \(error)")
            // You might want to show an alert here
        }
    }
}


struct ChatListRow: View {
    let conversation: UserConversation
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileImageView(imageUrl: conversation.otherUserImageUrl ?? "", size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.otherUserName ?? "")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(conversation.lastMessage?.timestamp.formatted(.relative(presentation: .named)) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    if conversation.isTyping ?? false {
                        Text("typing...")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    } else {
                        Text(conversation.lastMessage?.text ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if (conversation.unreadCount ?? 0) > 0 {
                        Text("\(conversation.unreadCount ?? 0)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(size: 40))
            
            Text("Error loading conversations")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Retry", action: retryAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}
