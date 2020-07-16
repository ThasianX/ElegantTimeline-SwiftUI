# ElegantTimeline

`ElegantTimeline` is a SwiftUI demonstration of a multi-faceted page view with interactions between the calendar, list, and app theme. 

If you are a developer, this repository is meant for you. Down below, I've listed all the features this demonstration app includes so you can learn more about a feature you're interested in implementing yourself.

ALSO, please do this repository justice and run it on an actual device. The simulator is too slow for hardcore renders like these :). The app will also look better if you run it on an iPhone X or above. The list snaps to the nearest cell based on the top notch bezel. How cool is that.

<br/>

<img src="GIFS/demo.gif" width="300"/> 

## Introduction

`ElegantTimeline` is inspired by [TimePage](https://us.moleskine.com/timepage/p0486). It uses [ElegantPages](https://github.com/ThasianX/ElegantPages) and [ElegantCalendar](https://github.com/ThasianX/ElegantCalendar), two libraries I wrote specifically for this demonstration.

Also, make sure to check out [TimePrints](https://github.com/ThasianX/TimePrints), an app that I'm working on that'll utilize this UI for visits tracking. Funny thing is, I've been so busy developing the components that eventually be implemented inside my app that I haven't actually worked much on my app in the past month.

## Features

### Paging + Theme Change
<img src="GIFS/paging-theme-change-demo.gif" width="300"/>

What you can learn: 
  - Custom gestures for different page turns: the calendar has a different animation for its page turn than the other views
  - Use of `GestureMask` while paging
  - Animating and offsetting the monthly calendar properly to have that bit of list background showing to the right
  - Overlaying the list and configuring opacity to achieve a smooth fade effect while paging
  - Animating and rotating a partial screen menu
  - The animation behind the theme change
  - Propogation of new theme down to all subviews
  
### SideBar that tracks current month and year + Visits slideshow list + Weeks/Months ago popup
<img src="GIFS/list-scroll-demo.gif" width="300"/>

What you can learn: 
  - The SideBar really is just 2 `Text` that are juggled depending on the current offset. So you can see the logic behind that
  - The list is really just a UITableView UIViewRepresentable
    - How to make sure `@State` isn't transferred over for reused cells
    - How to make sure visible cells move onto the next "slide" at the same time
  - The weeks/months ago popup relies heavily on the list logic, depending on whether the list is dragging or not, etc
  
### Monthly Calendar and list interaction
<img src="GIFS/monthly-calendar-list-interaction-demo.gif" width="300"/>

What you can learn: 
  - The interaction
    - When you scroll to a new month in the list, the calendar also scrolls to that same month
    - When you scroll to a new month in the calendar, the list scrolls to the last day of that month
    - When you tap a day in the calendar, the list scrolls to that day
  - Learn which `UITableViewDelegate` methods to implement that make this really efficient
    - The calendar isn't scrolling to a new month everytime the list scrolls to a new month
    - Only after the list stops scrolling does the calendar then scroll to the current month
    - Swiping to a different page - the calendar or menu - is forbidden while scrolling in the list so you can look into the code to find out how that works

### Yearly Calendar and list interaction
<img src="GIFS/yearly-calendar-list-interaction-demo.gif" width="300"/>

What you can learn: 
  - The interaction
    - When you tap a month in the yearly calendar, the monthly calendar switches over to that month and the list also scrolls ot the last day of that month
      - This is great if you want to get to a date that's far away quick
    - When you scroll to a new year in the list, the yearly calendar doesn't immediately scroll to that year
      - Only after you scroll back to the yearly calendar does it scroll to that year
    
### Fast Scrolling
<img src="GIFS/fast-scroll-demo.gif" width="300"/>

What you can learn: 
  - How it works
    - Make sure you're on the list view. Start dragging the month-year sidebar in whichever direction you want to fast scroll in.
    - Make sure that this gesture is entirely vertical because just a bit of horizontal translation will cease the fast scroll
    - Just a very intuitive gesture that makes sense if the user doesn't feel like scrolling to the calendar
    - The same calendar interactions apply here too: whatever month the fast scroll ends on is also the month the calendar scrolls to
  - Learn about how custom scrolling is simulated in the list through interacting with the `contentOffset` of the `UITableView`
    - There is a specific timing function needed in order to animate the custom scroll elegantly
    - The fast scroll also snaps to whatever cell it ends near, in a smooth manner

### Scrolling back to today
<img src="GIFS/scroll-back-to-today-demo.gif" width="300"/>

What you can learn: 
  - The custom scale animation that occurs when you tap the button and the fade out animation afterwards
  - Logic behind scrolling to the current day and when to show the button
  
### Header and footer quote
<img src="GIFS/header-footer-quote-demo.gif" width="300"/>

What you can learn: 
  - Just a pretty cool easter egg I added. Based off of the current list's scroll offset and whether it's scrolled past its edges or not

## Requirements

- iOS 13.0+
- Xcode 11.0+

## Resources

Also, here's a [dump of resources](resources.txt) I found useful when working on this

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
