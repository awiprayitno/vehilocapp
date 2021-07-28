import Felgo 3.0
import QtQuick 2.0
import QtPositioning 5.5
import QtLocation 5.5
import QtQuick.Layouts 1.11
import "pages"

App {
    // You get free licenseKeys from https://felgo.com/licenseKey
    // With a licenseKey you can:s
    //  * Publish your games & apps for the app stores
    //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    licenseKey: "605F71B82AAAF5F35B4CA75A76CD78381E23551FDB8A6E46FECFAF020D99D2D3D1414620E6A7EFFECED5B77D68EAE14960E4BB6916E4C6AC44E859893557A00D2AA4907189F488686D4DF8DF8E4A97C810CFB1E9CC6E6E3580A528108C4B52F4ADB0825FF9CED6DA78DACC4DB71E96370494953DBEFB386475E8CD174D9C344E372F7C0EEE8ED41BC515827826128B723B7F4B4A9F890F488BE0ED39DD75FE948E1C9CD48B210532267E96BE8BD70D458287C2CDA9159AC8B1E2C907888A3904E735BE76A604E1345F346CBFF7E796F4C78AAD7255B1EF48A3B7762742923F856C23F6A6E81367EC1810B8368934692751508A9884DF38FF2CF461D26516F5B02F4D1BEB922A624BCFBA7CC98C5CE77B3D646F44CD597EB04D45F60966540B9397A07BA5E4E80A9892BCA0C921DC98C2"
    id: mainApp
    property var userLoggedIn: false
    property var token: ''
    property var vehicles: []
    property var geofences: []
    property var showGFLables: false
//    property var geofences: [{ "customer_id": 3, "geometry": [ { "latitude": -7.7022626717, "longitude": 109.02928004661489 }, { "latitude": -7.702687358367529, "longitude": 109.02925918309677 }, { "latitude": -7.703107955070292, "longitude": 109.02919679346951 }, { "latitude": -7.703520411232121, "longitude": 109.02909347857933 }, { "latitude": -7.703920754674705, "longitude": 109.02895023340507 }, { "latitude": -7.704305129871843, "longitude": 109.0287684374761 }, { "latitude": -7.704669835080264, "longitude": 109.02854984158658 }, { "latitude": -7.705011357989443, "longitude": 109.02829655093443 }, { "latitude": -7.705326409547071, "longitude": 109.02801100484707 }, { "latitude": -7.7056119556344225, "longitude": 109.02769595328945 }, { "latitude": -7.70586524628658, "longitude": 109.02735443038027 }, { "latitude": -7.706083842176102, "longitude": 109.02698972517184 }, { "latitude": -7.706265638105074, "longitude": 109.0266053499747 }, { "latitude": -7.706408883279321, "longitude": 109.02620500653212 }, { "latitude": -7.706512198169509, "longitude": 109.0257925503703 }, { "latitude": -7.706574587796769, "longitude": 109.02537195366753 }, { "latitude": -7.706595451314884, "longitude": 109.024947267 }, { "latitude": -7.706574587796769, "longitude": 109.02452258033247 }, { "latitude": -7.706512198169509, "longitude": 109.0241019836297 }, { "latitude": -7.706408883279321, "longitude": 109.02368952746788 }, { "latitude": -7.706265638105074, "longitude": 109.0232891840253 }, { "latitude": -7.706083842176102, "longitude": 109.02290480882816 }, { "latitude": -7.70586524628658, "longitude": 109.02254010361973 }, { "latitude": -7.7056119556344225, "longitude": 109.02219858071055 }, { "latitude": -7.705326409547071, "longitude": 109.02188352915293 }, { "latitude": -7.705011357989443, "longitude": 109.02159798306558 }, { "latitude": -7.704669835080264, "longitude": 109.02134469241342 }, { "latitude": -7.704305129871843, "longitude": 109.0211260965239 }, { "latitude": -7.703920754674705, "longitude": 109.02094430059493 }, { "latitude": -7.703520411232121, "longitude": 109.02080105542068 }, { "latitude": -7.703107955070292, "longitude": 109.0206977405305 }, { "latitude": -7.702687358367529, "longitude": 109.02063535090323 }, { "latitude": -7.7022626717, "longitude": 109.02061448738512 }, { "latitude": -7.701837985032471, "longitude": 109.02063535090323 }, { "latitude": -7.701417388329707, "longitude": 109.0206977405305 }, { "latitude": -7.701004932167878, "longitude": 109.02080105542068 }, { "latitude": -7.7006045887252945, "longitude": 109.02094430059493 }, { "latitude": -7.700220213528157, "longitude": 109.0211260965239 }, { "latitude": -7.699855508319736, "longitude": 109.02134469241342 }, { "latitude": -7.699513985410556, "longitude": 109.02159798306558 }, { "latitude": -7.699198933852928, "longitude": 109.02188352915293 }, { "latitude": -7.698913387765577, "longitude": 109.02219858071055 }, { "latitude": -7.69866009711342, "longitude": 109.02254010361973 }, { "latitude": -7.698441501223898, "longitude": 109.02290480882816 }, { "latitude": -7.698259705294926, "longitude": 109.0232891840253 }, { "latitude": -7.698116460120678, "longitude": 109.02368952746788 }, { "latitude": -7.69801314523049, "longitude": 109.0241019836297 }, { "latitude": -7.69795075560323, "longitude": 109.02452258033247 }, { "latitude": -7.697929892085115, "longitude": 109.024947267 }, { "latitude": -7.69795075560323, "longitude": 109.02537195366753 }, { "latitude": -7.69801314523049, "longitude": 109.0257925503703 }, { "latitude": -7.698116460120678, "longitude": 109.02620500653212 }, { "latitude": -7.698259705294926, "longitude": 109.0266053499747 }, { "latitude": -7.698441501223898, "longitude": 109.02698972517184 }, { "latitude": -7.69866009711342, "longitude": 109.02735443038027 }, { "latitude": -7.698913387765577, "longitude": 109.02769595328945 }, { "latitude": -7.699198933852928, "longitude": 109.02801100484707 }, { "latitude": -7.699513985410556, "longitude": 109.02829655093443 }, { "latitude": -7.699855508319736, "longitude": 109.02854984158658 }, { "latitude": -7.700220213528157, "longitude": 109.0287684374761 }, { "latitude": -7.7006045887252945, "longitude": 109.02895023340507 }, { "latitude": -7.701004932167878, "longitude": 109.02909347857933 }, { "latitude": -7.701417388329707, "longitude": 109.02919679346951 }, { "latitude": -7.701837985032471, "longitude": 109.02925918309677 }, { "latitude": -7.7022626717, "longitude": 109.02928004661489 } ], "id": 3, "name": "Cilacap" }]

    JsonListModel {
        id: jsonLMVehicles
        source: vehicles
        keyField: 'id'
        fields: ['id', 'name', 'plate_no', 'customer_name', 'lat', 'lon', 'bearing', 'speed', 'gpsdt', 'type', 'base_mcc', 'sensors']
    }

    JsonListModel {
        id: jsonLMGeofences
        source: geofences
        keyField: 'id'
        fields: ['id', 'name', 'geometry']
    }

//    SortFilterProxyModel {
//        id: sortedModel
//        // Note: when using JsonListModel, the sorters or filter might not be applied correctly when directly assigning sourceModel
//        // use the Component.onCompleted handler instead to initialize SortFilterProxyModel
//        Component.onCompleted: sourceModel = jsonLMVehicles
//        sorters: StringSorter { id: nameSorter; roleName: "name"; ascendingOrder: true }
//    }

    Navigation {
        id: vehilocApp
        enabled: userLoggedIn

        property int sensorFontSize: 10
        property int mapNameFontSize: 12

        navigationMode: navigationModeTabs
        NavigationItem {
            title: 'Map'
            icon: IconType.mapmarker
            NavigationStack {
                Page {
                    id: pageMap
                    title: qsTr("Map")

                    rightBarItem: NavigationBarRow {
                        IconButtonBarItem {
                            icon: showGFLables ? IconType.toggleon : IconType.toggleoff
                            onClicked: {
                                mainApp.showGFLables = !mainApp.showGFLables
                            }
                            visible: mainApp.geofences.length > 0
                        }
                    }

                    AppMap {
                        id: map
                        anchors.fill: parent
                        showUserPosition: true


                        // configure plugin for displaying map here
                        // see http://doc.qt.io/qt-5/qtlocation-index.html#plugin-references-and-parameters
                        // for a documentation of possible Location Plugins
                        plugin: Plugin {
                            name: "osm" // e.g. mapbox, ...
                            parameters: [
                                // set required plugin parameters here
                            ]
                        }

                        MapItemView {
                            id: mapItemView
                            model: jsonLMVehicles
                            delegate: Component {
                                id: mapitemViewDelegate
                                MapQuickItem {
                                    id: vehicleQuickItem
                                    coordinate {
                                        latitude: model.lat
                                        longitude: model.lon
                                    }

                                    anchorPoint.x: vehicleIcon.width/2
                                    anchorPoint.y: vehicleIcon.height/2
                                    sourceItem:  Column {
                                        Image
                                        {
                                            id: vehicleIcon
                                            source: Qt.platform.os === 'android'
                                                    ? ((model.speed === 0) ? "../assets/arrow_red.png" : "../assets/arrow_green.png")
                                                    : ((model.speed === 0) ? "../assets/arrow_red16.png" : "../assets/arrow_green16.png")
                                            transform: Rotation
                                            {
                                                id: assetRotation2
                                                origin.x: vehicleIcon.width / 2
                                                origin.y: vehicleIcon.height / 2
                                                angle: model.bearing ? model.bearing : 0
                                            }
                                        }
                                        Rectangle {
                                            id: mapNameBG
                                            color: "red"
                                            radius: dp(2)
                                            width: mapNameText.width
                                            height: mapNameText.height
                                            opacity: 0.7
                                            AppText {
                                                id: mapNameText
                                                text: model.name
                                                fontSize: vehilocApp.mapNameFontSize
                                                anchors.horizontalCenter: mapNameBG.horizontalCenter

                                                color: 'white'
                                                leftPadding: dp(3)
                                                rightPadding: dp(3)
                                            }
                                        }
                                    }
                                    Component.onCompleted: {
//                                        console.log('Loaded a mapquick item ', model.name ,'lat: ', model.lat, ' lon: ', model.lon)
                                    }
                                }
                            }
                        }

                        MapItemView {
                            id: mapItemViewGeofences
                            model: jsonLMGeofences
                            delegate: Component {
                                id: mapitemViewGFDelegate
                                MapPolygon {
                                    path: model.geometry
                                    border.color: 'red'
                                    border.width: 2
                                    Component.onCompleted: {
//                                        console.log('Loaded a geofence ', model.name)
                                    }
//                                    MouseArea {
//                                        anchors.fill:parent
//                                        id: mousearea
//                                        drag.target: parent
//                                    }
                                }
                            }
                        }

                        MapItemView {
                            visible: mainApp.showGFLables
                            model: jsonLMGeofences
                            delegate: Component {
                                MapQuickItem {
                                    coordinate {
                                        latitude: model.geometry[0]['latitude']
                                        longitude: model.geometry[0]['longitude']
                                    }
                                    sourceItem: AppText {
                                        text: model.name
                                        color: 'red'
                                        fontSize: 11
                                    }
                                }
                            }
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
                ListPage {
                    id: listVehicles
                    title: 'Vehicles (' + mainApp.vehicles.length + ')'

                    pullToRefreshHandler.pullToRefreshEnabled: true

                    rightBarItem: ActivityIndicatorBarItem {
                        animating: HttpNetworkActivityIndicator.enabled
                        visible: animating
                    }

                    model: jsonLMVehicles
                    delegate: AppListItem {
                        id: vehicleDelegate

                        leftItem: ColumnLayout {
                            spacing: dp(2)
                            width: dp(40)
                            Rectangle {
                                color: (Math.floor(Date.now() / 1000) - model.gpsdt) > 86400
                                       ? 'gray' : model.speed > 0
                                         ? "green" : "red"
                                radius: dp(2)
                                Layout.fillWidth: true
                                Layout.preferredHeight: model.type === 4 ? dp(20) : dp(40)
                                Layout.topMargin: dp(8)

                                AppText {
                                    text: model.type === 4 ? model.speed : model.speed + '\nkm/h'
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    color: "white"
                                    fontSize: 14
//                                    bottomPadding: dp(12)
                                }
                            }

                            Rectangle {
                                border.color: "green"
                                radius: dp(2)
                                Layout.fillWidth: true
                                height: dp(20)
                                visible: model.type === 4

                                AppText {
                                    text: model.base_mcc !== 510 ? model.base_mcc / 10 + '°' : '--' + '°'
                                    anchors.centerIn: parent
                                    color: "green"
                                    fontSize: 12
//                                    bottomPadding: dp(12)
                                }
                            }
                        } //ColumnLayout

//                        rightItem: Rectangle {
//                            border.color: 'green'
//                            radius: dp(2)
//                            width: dp(50)
//                            height: dp(40)
//                            anchors.verticalCenter: parent.verticalCenter

//                            AppText {
//                                anchors.centerIn: parent
//                                color: "green"
//                                text: "18:11"
//                            }
//                        }

                        textItem: Row {
                            spacing: dp(5)
                            AppText {
                                text: model.name
                            }

                            Rectangle {
                                visible: model.sensors[0] !== undefined
                                color: model.sensors[0] !== undefined ? model.sensors[0]["bgcolor"] : 'white'
                                radius: dp(2)
                                width: sensorText0.width
                                height: sensorText0.height
                                AppText {
                                    id: sensorText0
                                    text: model.sensors[0] !== undefined ? model.sensors[0].name : ' '
                                    fontSize: vehilocApp.sensorFontSize
                                    color: 'yellow'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }
                            Rectangle {
                                visible: model.sensors[1] !== undefined
                                color: model.sensors[1] !== undefined ? model.sensors[1]["bgcolor"] : 'white'
                                radius: dp(2)
                                width: sensorText1.width
                                height: sensorText1.height
                                AppText {
                                    id: sensorText1
                                    text: model.sensors[1] !== undefined ? model.sensors[1].name : ' '
                                    fontSize: vehilocApp.sensorFontSize
                                    color: 'yellow'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }
                            Rectangle {
                                visible: model.sensors[2] !== undefined
                                color: model.sensors[2] !== undefined ? model.sensors[2]["bgcolor"] : 'white'
                                radius: dp(2)
                                width: sensorText2.width
                                height: sensorText2.height
                                AppText {
                                    id: sensorText2
                                    text: model.sensors[2] !== undefined ? model.sensors[2].name : ' '
                                    fontSize: vehilocApp.sensorFontSize
                                    color: 'yellow'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }
                            Rectangle {
                                visible: model.sensors[3] !== undefined
                                color: model.sensors[3] !== undefined ? model.sensors[3]["bgcolor"] : 'white'
                                radius: dp(2)
                                width: sensorText3.width
                                height: sensorText3.height
                                AppText {
                                    id: sensorText3
                                    text: model.sensors[3] !== undefined ? model.sensors[3].name : ' '
                                    fontSize: vehilocApp.sensorFontSize
                                    color: 'yellow'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }
                        }

                        detailTextItem: Row {
                            spacing: dp(5)
                            Rectangle {
                                id: plateNoBG
                                color: "black"
                                radius: dp(2)
                                width: plateNoText.width
                                height: plateNoText.height
                                AppText {
                                    id: plateNoText
                                    text: model.plate_no
                                    fontSize: 12
                                    color: 'white'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }
                        }



//                        text: model.name
//                        detailText: model.plate_no + ' Speed: ' + model.speed + ' Last update: ' + toLocalDateTimeString(model.gpsdt)
//                        onSelected: {
//                            console.log('clicked model: ' + model.name)
//                        }
                    }

                    section.property: "customer_name"
                    section.delegate: SimpleSection { }

                    pullToRefreshHandler.onRefresh:  {
                        console.log('Updating data..')
                        mainApp.loadVehiloc()
                        console.log('Updating data finished.')
                    }
                }
            }
        }

        NavigationItem {
            title: 'Settings'
            icon: IconType.gears

            NavigationStack {
                Page {
                    title: 'Settings'
                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: dp(2)

                        AppButton {
                            text: 'Log Out'
                            anchors.verticalCenter: parent
                            onClicked: {
                                console.log('Logging out')
                                mainApp.logOut()
                            }
                        }
                    }
                }
            }
        }
    }

    LoginPage {
        visible: opacity > 0
        enabled: visible
        opacity: mainApp.userLoggedIn ? 0 : 1 // hide if user is logged in
    }

    function toLocalDateTimeString(utc_timestamp, no_today) {
        var d = new Date(utc_timestamp * 1000)
        var today = new Date();
        var mymin = d.getMinutes() + "";
        if (mymin.length === 1) {mymin = '0' + mymin;}
        if ((no_today === undefined) && (today.getFullYear() === d.getFullYear()) && (today.getMonth() === d.getMonth()) && (today.getDate() === d.getDate())) {
            return 'today ' + d.getHours() + ':' + mymin;
        } else {
            return (1 + d.getMonth()) + '/' + d.getDate() + '/' + d.getFullYear() + ' ' + d.getHours() + ':' + mymin;
        }
    }

    function loadVehiloc() {
        // get list of vehicles
        console.log('Updating vehicles list...')
        HttpRequest
        .get("https://vehiloc.net/rest/vehicles")
        .auth(mainApp.token, 'unused')
        .timeout(20000)
        .end(function(err, res) {
            if(res.ok) {
                console.log('Got vehicles data, status: ', res.status);
//                console.log(JSON.stringify(res.body, null, 4));
                mainApp.vehicles = res.body
//                console.log(mainApp.vehicles[0]['name'])
                mainApp.userLoggedIn = true
            }
            else {
                console.log('Error message: ', err.message)
                console.log('Error response: ', err.response)
            }
        });        
    }

    function loadGeofences() {
        // get list of vehicles
        console.log('Updating geofences...')
        HttpRequest
        .get("https://vehiloc.net/rest/geofences")
        .auth(mainApp.token, 'unused')
        .timeout(20000)
        .end(function(err, res) {
            if(res.ok) {
                console.log('Got geofences data, status: ', res.status);
                console.log(JSON.stringify(res.body, null, 4));
                mainApp.geofences = res.body
                console.log(mainApp.geofences[0])
            }
            else {
                console.log('Error message: ', err.message)
                console.log('Error response: ', err.response)
            }
        });
    }

    function logOut() {
        nativeUtils.clearKeychainValue("token")
        token = ''
        userLoggedIn = false
        mainApp.vehicles = []
        mainApp.geofences = []
    }

    Component.onCompleted: {
        HttpNetworkActivityIndicator.activationDelay = 0

        console.log('navigationstack component loaded')
        var token = nativeUtils.getKeychainValue("token")

        if (token.length > 0) {
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
                    mainApp.token = res.body.token
                    mainApp.loadVehiloc()
                    mainApp.loadGeofences()
                }
                else {
                    console.log(err.message)
                    console.log(err.response)
                    console.log('invalid/expired token, login again')
                }
            });
        } else {
            console.log('No token found, please log in')
        }
    }

    onApplicationPaused: console.log("Application paused.")
    onApplicationResumed: console.log("Application resumed.")
}
