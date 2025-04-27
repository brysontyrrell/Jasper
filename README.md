# Jasper

A companion app for Jamf Pro operators and administrators.

Jasper is one of several starter apps I worked on to learn different skills with Swift. The focus of Jasper is building interfaces around APIs using the [`swift-openapi-generator`](https://github.com/apple/swift-openapi-generator). This is also an attempt at a cross-platform app that displays optimally for either iPhone or iPad.

The code for this app is being made available for anyone to reference, copy, critique, or take inspiration from.

## Multiple Jamf Pro Servers

Connect to more than one Jamf Pro instance and color code the intrerface so you always know which one you are working with at a glance.

![Jasper's main server list view.](images/server_list.png)
![Add servers with unique color codes.](images/add_server_sheet_iphone.png)

## Jamf Pro Views

Basic server information and alerts are visible on the main view. You can perform a quick search entering text that will be matched against a wide range of proprities such as serial numbers, device names, models, and assigned username.

On iPad these results will be requested and loaded as you type.

![View Jamf Pro information at a glance on iPad with search results on the same screen.](images/ipad_quick_search.png)
![View Jamf Pro information at a glance on iPhone.](images/server_view_iphone.png)

## Saved Searches

Constantly used searches can be saved for single tap loading. All the search features of this app wrap around the `/v1/computers-inventory` API and its available filters.

![Adding saved searches on iPad.](images/add_search_sheet_ipad.png)
![Viewing searches on iPad.](images/ipad_search_results.png)
![Adding saved searches on iPhone.](images/add_search_sheet_iphone.png)
![Viewing device details on iPhone.](images/device_view_iphone.png)


