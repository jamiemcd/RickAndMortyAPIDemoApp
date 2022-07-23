# RickAndMortyAPIDemoApp
This project produces two ~~identical~~ nearly identical iOS apps – one using UIKit and one using SwiftUI. It pulls data from the popular Rick and Morty API at [https://rickandmortyapi.com](https://rickandmortyapi.com).

![The Rick (UIKit) app and Morty (SwiftUI) app running side by side in split screen on an iPad](/Documentation/Images/screenshot_001.jpg)

## Requirements
Xcode 14 and iOS 16 (both currently in BETA)

## Rick (UIKit)
The Rick version of the app is coded using modern UIKit. 
- async/await
- `UICollectionLayoutListConfiguration` instead of `UITableView`
- `UICollectionViewDiffableDataSource` instead of classic `UICollectionViewDataSource`
- `UICollectionView.dequeueConfiguredReusableCell(using:for:item:)` instead of classic `dequeueReusableCell(withReuseIdentifier:for:)`


## Morty (SwiftUI)
The Morty version of the app is coded using SwiftUI. 

## API
The [Rick and Morty API](https://rickandmortyapi.com) is geared towards web apps. The API pages its data, returning a max of 20 results at a time. Therefore the app makes multiple calls to the API to download the full data so the user can navigate without paging.


