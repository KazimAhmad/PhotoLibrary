//
//  AlbumsView.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 20/01/2026.
//

import SwiftUI

struct AlbumsView: View {
    @StateObject var viewModel: AlbumsViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 80, height: 4)
                    .padding()
                ScrollView {
                    ForEach(viewModel.titles, id: \.self) { title in
                        Text(title)
                            .padding(8)
                            .onTapGesture {
                                viewModel.didSelectAlbum?(title)
                                viewModel.dismiss()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(height: 400)
            .foregroundStyle(Color.white)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .background (
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black)
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AlbumsView(viewModel: AlbumsViewModel(titles: ["1", "2", "3"],
                                          coordinator: PhotoLibraryCoordiantor()))
}
