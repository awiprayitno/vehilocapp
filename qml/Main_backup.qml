import Felgo 3.0
import QtQuick 2.0
import QtPositioning 5.5
import QtLocation 5.5

App {
    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:s
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    licenseKey: "605F71B82AAAF5F35B4CA75A76CD78381E23551FDB8A6E46FECFAF020D99D2D3D1414620E6A7EFFECED5B77D68EAE14960E4BB6916E4C6AC44E859893557A00D2AA4907189F488686D4DF8DF8E4A97C810CFB1E9CC6E6E3580A528108C4B52F4ADB0825FF9CED6DA78DACC4DB71E96370494953DBEFB386475E8CD174D9C344E372F7C0EEE8ED41BC515827826128B723B7F4B4A9F890F488BE0ED39DD75FE948E1C9CD48B210532267E96BE8BD70D458287C2CDA9159AC8B1E2C907888A3904E735BE76A604E1345F346CBFF7E796F4C78AAD7255B1EF48A3B7762742923F856C23F6A6E81367EC1810B8368934692751508A9884DF38FF2CF461D26516F5B02F4D1BEB922A624BCFBA7CC98C5CE77B3D646F44CD597EB04D45F60966540B9397A07BA5E4E80A9892BCA0C921DC98C2"

    Component {
        id: loginPage
        Page {
            title: 'Please log in'
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: dp(2)

                AppTextField {
                    id: tfUsername
                    placeholderText: "Username"
                    inputMode: inputModeUsername
                }
                AppTextField {
                    id: tfPassword
                    placeholderText: "Password"
                    inputMode: inputModePassword
                }
                AppButton {
                    text: 'Login'
                    onClicked: {
                        console.log('button Login clicked with username', tfUsername.text, ' and pass: ', tfPassword.text)
                        HttpRequest
                        .get("https://vehiloc.net/rest/token")
                        .auth(tfUsername.text, tfPassword.text)
                        .timeout(5000)
                        .end(function(err, res) {
                            if(res.ok) {
                                console.log(res.status);
                                //                                console.log(JSON.stringify(res.header, null, 4));
                                console.log(JSON.stringify(res.body, null, 4));
                                console.log(res.body.token)
                                nativeUtils.setKeychainValue("token", res.body.token)
                                mainView.push(vehilocApp)
                            }
                            else {
                                console.log(err.message)
                                console.log(err.response)
                                nativeUtils.displayAlertDialog(qsTr("Login failed"), qsTr("Please check your username/password"), qsTr("OK"))
                            }
                        });
                    }
                }
            }
        }
    }

    Component {
        id: vehilocApp
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

        Component.onCompleted: {
            console.log('vehiloc app component loaded')
            var token = nativeUtils.getKeychainValue("token")
            console.log('token: ', token)

            if (token.length == 0) {
                console.log('token not found, load login page')
                mainView.push(loginPage)
            } else {
                console.log('token found, check token', token)
                HttpRequest
                .get("https://vehiloc.net/rest/token")
                .auth(token, 'unused')
                .timeout(5000)
                .end(function(err, res) {
                    if(res.ok) {
                        console.log(res.status);
                        console.log(JSON.stringify(res.body, null, 4));
                        console.log('got new token:', res.body.token)
                        nativeUtils.setKeychainValue("token", res.body.token)
                        mainView.push(vehilocApp)
                    }
                    else {
                        console.log(err.message)
                        console.log(err.response)
                        console.log('invalid/expired token, login again')
                        mainView.push(loginPage)
                    }
                });
                // if token valid: mainView.push(vehilocApp)

                // else mainView.push(loginPage)
            }
        }
    }

    NavigationStack {
        id: mainView

        Component.onCompleted: {
            console.log('navigationstack component loaded')
            var token = nativeUtils.getKeychainValue("token")
            console.log('token: ', token)

            if (token.length == 0) {
                console.log('token not found, load login page')
                mainView.push(loginPage)
            } else {
                console.log('token found, check token', token)
                HttpRequest
                .get("https://vehiloc.net/rest/token")
                .auth(token, 'unused')
                .timeout(5000)
                .end(function(err, res) {
                    if(res.ok) {
                        console.log(res.status);
                        console.log(JSON.stringify(res.body, null, 4));
                        console.log('got new token:', res.body.token)
                        nativeUtils.setKeychainValue("token", res.body.token)
                        mainView.push(vehilocApp)
                    }
                    else {
                        console.log(err.message)
                        console.log(err.response)
                        console.log('invalid/expired token, login again')
                        mainView.push(loginPage)
                    }
                });
                // if token valid: mainView.push(vehilocApp)

                // else mainView.push(loginPage)
            }
        }
    }
}
