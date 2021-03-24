# App Name: Photoration

# Features:

This app is a photo exploration application where it has five major features:

1: Users can view the most recent photos 

2: Users can view the interesting photos

3: User can view the specific photo that is clicked

4: Users can save photos for later browsing

5: Users can add tags for photos for categories

Additionally, this app provides an accessibility feature (**Voice Over**) that helps users with visual impariments navigate the app more friendly than iOS provides by default. 

# Network Service
This app uses Flickr APIs to fetch data

# Local persistence
This app uses CoreData to persist data locally

1: App first reads data from CoreData and then make network API calls and then persist data in CoreData. 

2: For favorite feature, it persists the photo save states and the states will be consistent across the app, which means that at any point of accessing a photo, the photo will have the right state: saved or not saved. 


# User Interfaces and Architecture
This app has a TabBarController as the root ViewController, and has 3 tabs:

1: **MostRecentPhotosViewController**: Shows the most recent photos in CollectionView, and users can pull to refresh the page

2: **InterestingPhotosViewController**: Shows the interesting photos in CollectionView, and users can pull to refresh the page

3: **FavoritePhotosViewController**: Shows the saved photos in CollectionView

Also, clicking a single photo brings users to a new page:

4: **PhotoInfoViewController**: Displays a full size of photo in a ImageView

In PhotoInfoViewController, users are able to save and tag a photo in:

5: **TagsViewController**: Users can create, select and deselect tags for the photo that is being viewed. 

6: App pops an **Alert** if the app looses the network connection

7: API related business logic is encapsulated in **FlickrAPI.swift**, and remote and local fetching related logic is encapsulated in **PhotoStore.swift**

# How to build
The app doesn't require any particular step to build the project, so any latest XCode should run the app. 

**Note**: the app uses an API key from Flickr, so please feel free to replace it. 
