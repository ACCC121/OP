//
// Created for MyBooks
// by  Stewart Lynch on 2023-10-03
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import PhotosUI

struct EditOpportunitiesView: View {
    @Environment(\.dismiss) private var dismiss
    let opportunity: Opportunity
    @State private var status: Status
    @State private var rating: Int?
    @State private var title = ""
    @State private var author = ""
    @State private var synopsis = ""
    @State private var dateAdded = Date.distantPast
    @State private var dateStarted = Date.distantPast
    @State private var dateCompleted = Date.distantPast
    @State private var recommendedBy = ""
    @State private var showGenres = false
    @State private var selectedBookCover: PhotosPickerItem?
    @State private var selectedOpportunityCoverData: Data?
    
    init(opportunity: Opportunity) {
        self.opportunity = opportunity
        _status = State(initialValue: Status(rawValue: opportunity.status)!)
    }
    
    var body: some View {
        HStack {
            Text("Status")
            Picker("Status", selection: $status) {
                ForEach(Status.allCases) { status in
                    Text(status.descr).tag(status)
                }
            }
            .buttonStyle(.bordered)
        }
        VStack(alignment: .leading) {
            GroupBox {
                LabeledContent {
                    switch status {
                    case .onShelf:
                        DatePicker("", selection: $dateAdded, displayedComponents: .date)
                    case .inProgress, .completed:
                        DatePicker("", selection: $dateAdded, in: ...dateStarted, displayedComponents: .date)
                    }
                    
                } label: {
                    Text("Date Added")
                }
                if status == .inProgress || status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateStarted, in: dateAdded..., displayedComponents: .date)
                    } label: {
                        Text("Date Started")
                    }
                }
                if status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateCompleted, in: dateStarted..., displayedComponents: .date)
                    } label: {
                        Text("Date Completed")
                    }
                }
            }
            .foregroundStyle(.secondary)
            .onChange(of: status) { oldValue, newValue in
                if newValue == .onShelf {
                    dateStarted = Date.distantPast
                    dateCompleted = Date.distantPast
                } else if newValue == .inProgress && oldValue == .completed {
                    // from completed to inProgress
                    dateCompleted = Date.distantPast
                } else if newValue == .inProgress && oldValue == .onShelf {
                    // opportunity has been started
                    dateStarted = Date.now
                } else if newValue == .completed && oldValue == .onShelf {
                    // Forgot to start opportunity
                    dateCompleted = Date.now
                    dateStarted = dateAdded
                } else {
                    // completed
                    dateCompleted = Date.now
                }
            }
            Divider()
            HStack {
                PhotosPicker(
                    selection: $selectedBookCover,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Group {
                            if let selectedOpportunityCoverData,
                               let uiImage = UIImage(data: selectedOpportunityCoverData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .tint(.primary)
                            }
                        }
                        .frame(width: 75, height: 100)
                        .overlay(alignment: .bottomTrailing) {
                            if selectedOpportunityCoverData != nil {
                                Button {
                                    selectedBookCover = nil
                                    selectedOpportunityCoverData = nil
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                VStack {
                    LabeledContent {
                        RatingsView(maxRating: 5, currentRating: $rating, width: 30)
                    } label: {
                        Text("Rating")
                    }
                    LabeledContent {
                        TextField("", text: $title)
                    } label: {
                        Text("Title").foregroundStyle(.secondary)
                    }
                    LabeledContent {
                        TextField("", text: $author)
                    } label: {
                        Text("Author").foregroundStyle(.secondary)
                    }
                }
            }
            LabeledContent {
                TextField("", text: $recommendedBy)
            } label: {
                Text("Recommended by").foregroundStyle(.secondary)
            }
            Divider()
            Text("Synopsis").foregroundStyle(.secondary)
            TextEditor(text: $synopsis)
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 2))
            if let contacts = opportunity.contacts {
                ViewThatFits {
                    ContactsStackView(contacts: contacts)
                    ScrollView(.horizontal, showsIndicators: false) {
                        ContactsStackView(contacts: contacts)
                    }
                }
            }
            HStack {
                Button("contacts", systemImage: "bookmark.fill") {
                    showGenres.toggle()
                }
                .sheet(isPresented: $showGenres) {
                    ContactsView(opportunity: opportunity)
                }
                NavigationLink {
                    QuotesListView(opportunity: opportunity)
                } label: {
                    let count = opportunity.quotes?.count ?? 0
                    Label("\(count) Quotes", systemImage: "quote.opening")
                }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()

        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if changed {
                Button("Update") {
                    opportunity.status = status.rawValue
                    opportunity.rating = rating
                    opportunity.title = title
                    opportunity.author = author
                    opportunity.synopsis = synopsis
                    opportunity.dateAdded = dateAdded
                    opportunity.dateStarted = dateStarted
                    opportunity.dateCompleted = dateCompleted
                    opportunity.recommendedBy = recommendedBy
                    opportunity.opportunityCover = selectedOpportunityCoverData
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            rating = opportunity.rating
            title = opportunity.title
            author = opportunity.author
            synopsis = opportunity.synopsis
            dateAdded = opportunity.dateAdded
            dateStarted = opportunity.dateStarted
            dateCompleted = opportunity.dateCompleted
            recommendedBy = opportunity.recommendedBy
            selectedOpportunityCoverData = opportunity.opportunityCover
        }
        .task(id: selectedBookCover) {
            if let data = try? await selectedBookCover?.loadTransferable(type: Data.self) {
                selectedOpportunityCoverData = data
            }
        }
    }
    
    var changed: Bool {
        status != Status(rawValue: opportunity.status)!
        || rating != opportunity.rating
        || title != opportunity.title
        || author != opportunity.author
        || synopsis != opportunity.synopsis
        || dateAdded != opportunity.dateAdded
        || dateStarted != opportunity.dateStarted
        || dateCompleted != opportunity.dateCompleted
        || recommendedBy != opportunity.recommendedBy
        || selectedOpportunityCoverData != opportunity.opportunityCover
    }
}

#Preview {
    let preview = Preview(Opportunity.self)
   return  NavigationStack {
       EditOpportunitiesView(opportunity: Opportunity.sampleOpportunities[4])
           .modelContainer(preview.container)
    }
}
