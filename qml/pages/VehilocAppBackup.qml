import QtQuick 2.0
import Felgo 3.0
import QtPositioning 5.5
import QtLocation 5.5

//Page {
//    id: vehilocApp
    Navigation {
        navigationMode: navigationModeTabs
        NavigationItem {
            title: 'Map'
            icon: IconType.mapmarker
            NavigationStack {
                Page {
                    id: pageMap
                    title: qsTr("Map")

                    AppMap {
                        id: map
                        anchors.fill: parent
                        showUserPosition: true
                        //            anchors.bottom: parent.bottom
                        //            anchors.left: parent.left
                        //            anchors.bottomMargin: (page.height - (page.height / map.scale)) / 2.0
                        //            anchors.leftMargin: (page.width - (page.width / map.scale)) / 2.0
                        //            width: page.width / map.scale
                        //            height: page.height / map.scale
                        //            scale: Theme.isAndroid ? dp(1) : 1
                        // reverse scale for correct sizing


                        // configure plugin for displaying map here
                        // see http://doc.qt.io/qt-5/qtlocation-index.html#plugin-references-and-parameters
                        // for a documentation of possible Location Plugins
                        plugin: Plugin {
                            name: "osm" // e.g. mapbox, ...
                            parameters: [
                                // set required plugin parameters here
                            ]
                        }

                        // Center map to Vienna, AT
                        //            center: QtPositioning.coordinate(48.208417, 16.372472)
                        Component.onCompleted: {
                            if (userPositionAvailable) {
                                center = userPosition.coordinate
                                zoomToUserPosition()
                            }
                        }

                        // once we successfully received the location, we zoom to the user position
                        onUserPositionAvailableChanged: {
                            if(userPositionAvailable)
                                zoomToUserPosition()
                        }
                    }
                }
            }
        }

        NavigationItem {
            title: 'Vehicles'
            icon: IconType.car

            NavigationStack {
                Page {
                    title: 'Vehicles'

                }
            }
        }

        NavigationItem {
            title: 'Settings'
            icon: IconType.gears

            NavigationStack {
                Page {
                    title: 'Settings'
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: dp(2)

                        AppButton {
                            text: 'Log Out'
                            anchors.centerIn: parent
                            onClicked: {
                                console.log('Logging out')
                                nativeUtils.clearKeychainValue("token")
                                mainView.clearAndPush(loginPage)
                            }
                        }
                    }
                }
            }
        }
    }
//}
