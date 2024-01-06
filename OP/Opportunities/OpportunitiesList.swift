//
// Created for Myopportunitys
// by  Stewart Lynch on 2023-10-04
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import SwiftUI
import SwiftData

struct OpportunitiesList: View {
    @Environment(\.modelContext) private var context
    @Query private var opportunitys: [Opportunity]
    init(sortOrder: SortOrder, filterString: String) {
        let sortDescriptors: [SortDescriptor<Opportunity>] = switch sortOrder {
        case .status:
            [SortDescriptor(\Opportunity.status), SortDescriptor(\Opportunity.title)]
        case .title:
            [SortDescriptor(\Opportunity.title)]
        case .author:
            [SortDescriptor(\Opportunity.author)]
        }
        let predicate = #Predicate<Opportunity> { opportunity in
            opportunity.title.localizedStandardContains(filterString)
            || opportunity.author.localizedStandardContains(filterString)
            || filterString.isEmpty
        }
        _opportunitys = Query(filter: predicate, sort: sortDescriptors)
    }
    var body: some View {
        Group {
            if opportunitys.isEmpty {
                ContentUnavailableView("Enter your first opportunity.", systemImage: "opportunity.fill")
            } else {
                List {
                    ForEach(opportunitys) { opportunity in
                        NavigationLink {
                            EditOpportunitiesView(opportunity: opportunity)
                        } label: {
                            HStack(spacing: 10) {
                                opportunity.icon
                                VStack(alignment: .leading) {
                                    Text(opportunity.title).font(.title2)
                                    Text(opportunity.author).foregroundStyle(.secondary)
                                    if let rating = opportunity.rating {
                                        HStack {
                                            ForEach(1..<rating, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .imageScale(.small)
                                                    .foregroundStyle(.yellow)
                                            }
                                        }
                                    }
                                    if let contacts = opportunity.contacts {
                                        ViewThatFits {
                                            ContactsStackView(contacts: contacts)
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                ContactsStackView(contacts: contacts)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let opportunity = opportunitys[index]
                            context.delete(opportunity)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    let preview = Preview(Opportunity.self)
    preview.addExamples(Opportunity.sampleOpportunities)
    return NavigationStack {
        OpportunitiesList(sortOrder: .status, filterString: "")
    }
        .modelContainer(preview.container)
}
