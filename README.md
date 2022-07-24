# RickAndMortyAPIDemoApp
This project produces two ~~identical~~ nearly identical iOS apps – one using UIKit and one using SwiftUI. It pulls data from the popular Rick and Morty API at [https://rickandmortyapi.com](https://rickandmortyapi.com).

![The Rick (UIKit) app and Morty (SwiftUI) app running side by side in split screen on an iPad](/Documentation/Images/screenshot_001.jpg)

## Requirements
Xcode 14 and iOS 16 (both currently in BETA)

## Rick (UIKit)
The Rick version of the app is coded using modern UIKit and requires iOS 15.
Modern UIKit basically means the following: 

- `UICollectionLayoutListConfiguration` instead of `UITableView`
- `UICollectionViewDiffableDataSource` instead of classic `UICollectionViewDataSource` 
- `UICollectionView.dequeueConfiguredReusableCell(using:for:item:)` instead of classic `UICollectionView.dequeueReusableCell(withReuseIdentifier:for:)`
- `UICollectionViewListCell`, `UIContentView`, and `UIContentConfiguration` instead of subclassing `UICollectionViewCell`

Understanding these took some time, since I have been accustomed to classic UIKit since back in the Objective-C days (but not as far back as pre-ARC 🦕). `UITableView` is a proud workhorse of iOS apps everywhere! After I watched the below WWDC videos multiple times, I found using `UICollectionView` and the modern apis to be some great evolution for UIKit.


Helpful WWDC sessions:
- [WWDC19 – Advances in UI Data Sources](https://developer.apple.com/videos/play/wwdc2019/220/)
- [WWDC19 – Advances in Collection View Layout](https://developer.apple.com/videos/play/wwdc2019/215/)
- [WWDC20 – Lists in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10026/)
- [WWDC20 – Modern Cell Configuration](https://developer.apple.com/videos/play/wwdc2020/10027/)
- [WWDC20 – Build for iPad](https://developer.apple.com/videos/play/wwdc2020/10105)
- [WWDC21 – Make Blazing Fast Lists and Collection Views](https://developer.apple.com/videos/play/wwdc2021/10252/)

## Morty (SwiftUI)
The Morty version of the app is coded using SwiftUI and requires iOS 16. It  uses `NavigationStack` along with `navigationDestination(for:destination:)`.

## Shared Code
Both apps share the model layer and the cloud layer.

Additionaly, instead of classic `completionHandler`s, the cloud code uses modern `async/await`. (Which is great and I hope to avoid the Combine framework entirely except for using `ObservableObject`.)

## API
The [Rick and Morty API](https://rickandmortyapi.com) is geared towards web apps. The API pages its data, returning a max of 20 results at a time. Therefore the app makes multiple calls to the API to download the full data so the user can navigate and search without paging.

## Using the App
There are a total of 6 screens in the app.

- A searchable list of all characters
- A searchable list of all locations
- A searchable list of all episodes
- A character detail screen
- A location detail screen
- An episode detail screen

When you select a character, location, or episode from one of the lists the detail screen is shown in a modal. 

From the Character Detail screen you can navigate to a character's origin, last known location, or any episode the character appeared in.

From the Location Detail screen you can navigate to any character associated with that location.

From the Episode Detail screen you can navigate to any character appearing in the episode.

You can push an unlimited number of characters, locations, and episodes on the detail screen before dismissing it.

![The list of episodes screen on an iPhone 13 Pro](/Documentation/Images/screenshot_002.png)
![The episode detail screen presented as a modal on an iPhone 13 Pro](/Documentation/Images/screenshot_003.png)


