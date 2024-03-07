# MyToDo's 📝

This is a small ToDo application aimed at those of you that like writing your ToDo's down. I wanted a digital solution with some base features, but quickly realized that free choices out there don't offer that much in their free plan (👀 looking at you [ToDoIst](https://todoist.com/) with your reminders 👀). Thus, as every other developer, I decided to do it myself.

## Disclaimer ❗

Since I'm the only one currently working on this, bugs and/or other unexpected or undesired behaviour could occur. I'd be happy if you let me know by [opening an issue](https://github.com/kristi-balla/mytodos/issues/new/choose) or, if you're motivated enough, [submit a PR](https://github.com/kristi-balla/mytodos/compare). You should also bear in mind that the UI and UX isn't cutting edge, as that isn't my priority at the moment. In addition, this application was only tested as a linux- and web-app. If you want to try it out for mobile devices, be my guest! 

## Features ✨

The application is splitted in two important screens. This was done to contextualize the information.

### Calendar 🗓️

You might wonder why the calendar is relevant in this context. Since specific ToDo's are scheduled for specific times, it would be nice to view the ToDo's of specific days or of the whole week. It is also helpful when creating recurring events or the similar. This was a simple calendar implemented with [table_calendar](https://pub.dev/packages/table_calendar). The library brings many useful features such as nicely resizable calendars and high configurability of the components.

Up until now, the features supported are the following. The planned features are also clear:

- [X] format the view to only show the current week, 2 weeks or month 
- [X] create and delete events
- [ ] update events
- [ ] send a reminder as a system notification or browser alert at a configurable time before the event

For this view, an Event is just something happening at the determined time. For the other view, an Event is considered a ToDo. Thus, you can think of those interchangably. The events that get constructed require the following properties:

- `Title`: This will be shown in a larger font than the rest and in bold. You should give your events meaningful names
- `Description`: This will be shown below the title. It is a huge text field to let your mind run wild when going through the aspects and intricacies of the ToDo
- `StartDate`: When the event should start. This is particularly important in conjunction with reminders
- `Priority`: This dictates the ordering of the elements in the ToDo-View. The priorities a user can pick are <span style="color: red">critical</span>, <span style="color: orange">important</span>, <span style="color: green">medium</span>, <span style="color: blue">low</span>, <span style="color: purple">I told you I'd write this down</span>, and non-existant. It is recommended not to pick the latter, as if you're putting something in your todo-list, it is at least somewhat important
- `EndDate`: This states when the event is planned to end
- `Frequency`: This defines how often an event takes place. You can pick between once, daily, weekly, monthly, yearly, and never. Obviously, you don't want to pick the latter, otherwise why would you write something down.

### ToDo 📋

This view always shows the events of the currently selected day in the calendar, by default being `DateTime.now()`. This is still a work in progress, so here is a list of what I'm planning on achieving:

- [ ] reschedule events
- [ ] update various event fields
- [ ] show the event in the corresponding priority color
- [ ] have a button that can be used to close the todo, stimulating the idea of *striking it through*

## Fancier Features 🚀

- [ ] be able to integrate events from the device calendar or the google calendar
- [ ] deploy the website on firebase
- [ ] publish on playstore
- [ ] dark mode
- [ ] UI that doesn't hurt one's eyes

As you can see, there's a long way to go, but at least in the end, you will know you have an actually nice app you can use!
