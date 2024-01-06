//
// Created for Myopportunities
// by  Stewart Lynch on 2023-10-03
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import SwiftData

enum SortOrder: LocalizedStringResource, Identifiable, CaseIterable {
    case status, title, author
    
    var id: Self {
        self
    }
}

struct OpportunitiesListView: View {
    @State private var createNewBook = false
    @State private var sortOrder = SortOrder.status
    @State private var filter = ""
    var body: some View {
        NavigationStack {
            Picker("", selection: $sortOrder) {
                ForEach(SortOrder.allCases) { sortOrder in
                    Text("Sort by \(sortOrder.rawValue)").tag(sortOrder)
                }
            }
            .buttonStyle(.bordered)
            OpportunitiesList(sortOrder: sortOrder, filterString: filter)
                .searchable(text: $filter, prompt: Text("Filter on title or author"))
                .navigationTitle("My opportunities")
                .toolbar {
                    Button {
                        createNewBook = true
                    }label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
                .sheet(isPresented: $createNewBook) {
                    NewOpportunitiesView()
                        .presentationDetents([.medium])
                }
        }
    }
}

#Preview("English") {
    let preview = Preview(Opportunity.self)
    let opportunities = Opportunity.sampleOpportunities
    let contacts = Contact.sampleContacts
    preview.addExamples(opportunities)
    preview.addExamples(contacts)
    return OpportunitiesListView()
        .modelContainer(preview.container)
}

#Preview("German") {
    let preview = Preview(Opportunity.self)
    let opportunities = Opportunity.sampleOpportunities
    let contacts = Contact.sampleContacts
    preview.addExamples(opportunities)
    preview.addExamples(contacts)
    return OpportunitiesListView()
        .modelContainer(preview.container)
        .environment(\.locale, Locale(identifier: "DE"))
}
