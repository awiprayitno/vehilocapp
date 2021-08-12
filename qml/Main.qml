import Felgo 3.0
import QtQuick 2.0
import QtPositioning 5.5
import QtLocation 5.5
import QtQuick.Layouts 1.11
import QtWebSockets 1.1
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
    property var vhcIndex: ({})
    property var vehicles: []
    property var geofences: []
    property var showGFLables: false
//    property var geofences: [{ "customer_id": 3, "geometry": [ { "latitude": -7.7022626717, "longitude": 109.02928004661489 }, { "latitude": -7.702687358367529, "longitude": 109.02925918309677 }, { "latitude": -7.703107955070292, "longitude": 109.02919679346951 }, { "latitude": -7.703520411232121, "longitude": 109.02909347857933 }, { "latitude": -7.703920754674705, "longitude": 109.02895023340507 }, { "latitude": -7.704305129871843, "longitude": 109.0287684374761 }, { "latitude": -7.704669835080264, "longitude": 109.02854984158658 }, { "latitude": -7.705011357989443, "longitude": 109.02829655093443 }, { "latitude": -7.705326409547071, "longitude": 109.02801100484707 }, { "latitude": -7.7056119556344225, "longitude": 109.02769595328945 }, { "latitude": -7.70586524628658, "longitude": 109.02735443038027 }, { "latitude": -7.706083842176102, "longitude": 109.02698972517184 }, { "latitude": -7.706265638105074, "longitude": 109.0266053499747 }, { "latitude": -7.706408883279321, "longitude": 109.02620500653212 }, { "latitude": -7.706512198169509, "longitude": 109.0257925503703 }, { "latitude": -7.706574587796769, "longitude": 109.02537195366753 }, { "latitude": -7.706595451314884, "longitude": 109.024947267 }, { "latitude": -7.706574587796769, "longitude": 109.02452258033247 }, { "latitude": -7.706512198169509, "longitude": 109.0241019836297 }, { "latitude": -7.706408883279321, "longitude": 109.02368952746788 }, { "latitude": -7.706265638105074, "longitude": 109.0232891840253 }, { "latitude": -7.706083842176102, "longitude": 109.02290480882816 }, { "latitude": -7.70586524628658, "longitude": 109.02254010361973 }, { "latitude": -7.7056119556344225, "longitude": 109.02219858071055 }, { "latitude": -7.705326409547071, "longitude": 109.02188352915293 }, { "latitude": -7.705011357989443, "longitude": 109.02159798306558 }, { "latitude": -7.704669835080264, "longitude": 109.02134469241342 }, { "latitude": -7.704305129871843, "longitude": 109.0211260965239 }, { "latitude": -7.703920754674705, "longitude": 109.02094430059493 }, { "latitude": -7.703520411232121, "longitude": 109.02080105542068 }, { "latitude": -7.703107955070292, "longitude": 109.0206977405305 }, { "latitude": -7.702687358367529, "longitude": 109.02063535090323 }, { "latitude": -7.7022626717, "longitude": 109.02061448738512 }, { "latitude": -7.701837985032471, "longitude": 109.02063535090323 }, { "latitude": -7.701417388329707, "longitude": 109.0206977405305 }, { "latitude": -7.701004932167878, "longitude": 109.02080105542068 }, { "latitude": -7.7006045887252945, "longitude": 109.02094430059493 }, { "latitude": -7.700220213528157, "longitude": 109.0211260965239 }, { "latitude": -7.699855508319736, "longitude": 109.02134469241342 }, { "latitude": -7.699513985410556, "longitude": 109.02159798306558 }, { "latitude": -7.699198933852928, "longitude": 109.02188352915293 }, { "latitude": -7.698913387765577, "longitude": 109.02219858071055 }, { "latitude": -7.69866009711342, "longitude": 109.02254010361973 }, { "latitude": -7.698441501223898, "longitude": 109.02290480882816 }, { "latitude": -7.698259705294926, "longitude": 109.0232891840253 }, { "latitude": -7.698116460120678, "longitude": 109.02368952746788 }, { "latitude": -7.69801314523049, "longitude": 109.0241019836297 }, { "latitude": -7.69795075560323, "longitude": 109.02452258033247 }, { "latitude": -7.697929892085115, "longitude": 109.024947267 }, { "latitude": -7.69795075560323, "longitude": 109.02537195366753 }, { "latitude": -7.69801314523049, "longitude": 109.0257925503703 }, { "latitude": -7.698116460120678, "longitude": 109.02620500653212 }, { "latitude": -7.698259705294926, "longitude": 109.0266053499747 }, { "latitude": -7.698441501223898, "longitude": 109.02698972517184 }, { "latitude": -7.69866009711342, "longitude": 109.02735443038027 }, { "latitude": -7.698913387765577, "longitude": 109.02769595328945 }, { "latitude": -7.699198933852928, "longitude": 109.02801100484707 }, { "latitude": -7.699513985410556, "longitude": 109.02829655093443 }, { "latitude": -7.699855508319736, "longitude": 109.02854984158658 }, { "latitude": -7.700220213528157, "longitude": 109.0287684374761 }, { "latitude": -7.7006045887252945, "longitude": 109.02895023340507 }, { "latitude": -7.701004932167878, "longitude": 109.02909347857933 }, { "latitude": -7.701417388329707, "longitude": 109.02919679346951 }, { "latitude": -7.701837985032471, "longitude": 109.02925918309677 }, { "latitude": -7.7022626717, "longitude": 109.02928004661489 } ], "id": 3, "name": "Cilacap" }]

    WebSocket {
        id: wsVehiloc
//        url: 'wss://vehiloc.net/sub-split/14533199'
//        active: true
        onTextMessageReceived: {
//            console.log('text received: ', message)
            // {"gpsdt": 1627726666, "bearing": 46, "adextpowervalue": 100, "alt": 0, "speed": 21,
            // "vehicle_id": 1301, "eventcode": 18, "base_ci": 40016, "lon": 110.455209, "ad1value": 0, "adbattvalue": 99,
            // "base_mcc": 510, "base_lac": 4901, "gsmsignal": 100, "hdop": 0, "gpsstatus": 1,
            // "lat": -7.022951, "sensors": [], "geofences": [], "vehicle_type": 0, "createdt": 1627726667, "runtime": 0,
            // "io_states": 512, "ad3value": 0, "journey": 45391742, "ad2value": 0, "trackertype": 6706,
            // "satellitenumber": 15, "base_mnc": 10, "temp_alert": false}
            var new_data = JSON.parse(message)
            var row = mainApp.vehicles[vhcIndex[new_data['vehicle_id']]]
            if (row) {
                console.log('got new data vhc_id: ', row['id'], 'updated from : ', new Date(row['gpsdt']*1000).toLocaleTimeString('H:mm') + ' to: ' + new Date(new_data['gpsdt']*1000).toLocaleTimeString('H:mm'))
                if ((row['lon'] !== new_data['lon']) && (row['lat'] !== new_data['lat'])) {
                    row['address'] = undefined
                }

                row['gpsdt'] = new_data['gpsdt']
                row['bearing'] = new_data['bearing']
                row['speed'] = new_data['speed']
                row['lon'] = new_data['lon']
                row['lat'] = new_data['lat']
                row['base_mcc'] = new_data['base_mcc']
                row['sensors'] = new_data['sensors']
                row['io_states'] = new_data['io_states']
                row['adextpowervalue'] = new_data['adextpowervalue']
                row['alt'] = new_data['alt']
                row['adbattvalue'] = new_data['adbattvalue']
                row['gsmsignal'] = new_data['gsmsignal']
                row['gpsstatus'] = new_data['gpsstatus']
                row['runtime'] = new_data['runtime']
                row['journey'] = new_data['journey']
                row['satellitenumber'] = new_data['satellitenumber']
                row['geofences'] = new_data['geofences']

                mainApp.vehiclesChanged()
            }
        }
    }

    JsonListModel {
        id: jsonLMVehicles
        source: vehicles
        keyField: 'id'
        fields: ['id', 'name', 'plate_no', 'customer_name', 'lat', 'lon', 'bearing', 'speed', 'gpsdt', 'type', 'base_mcc', 'sensors', 'trackertype', 'io_states', 'adextpowervalue', 'geofences', 'address']
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
            id: navItemMap
            title: 'Map'
            icon: IconType.mapmarker

            NavigationStack {
                id: navStackMap
                property alias moiMap: pageMap
                Page {
                    id: pageMap
                    title: qsTr("Map")
                    property alias meiMap: map

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

                        property var elehehe: 'inside map hurray'

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
                    delegate: SwipeOptionsContainer {
                        id: containerSwipe

                        property var vhcGeofences: model.geofences
                        property var vhcSensors: model.sensors
                        property var vhcAddress: model.address

                        AppListItem {
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
                                        text: model.speed === undefined ? '---' : model.type === 4 ? model.speed : model.speed + '\nkm/h'
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        color: "white"
                                        fontSize: 14
                                        //                                    bottomPadding: dp(12)
                                    }
                                }

                                Rectangle {
                                    border.color: "dodgerblue"
                                    radius: dp(2)
                                    Layout.fillWidth: true
                                    height: dp(20)
                                    visible: model.type === 4

                                    AppText {
                                        text: model.base_mcc !== 510 ? model.base_mcc / 10 + '°' : '--' + '°'
                                        anchors.centerIn: parent
                                        color: "dodgerblue"
                                        fontSize: 12
                                        //                                    bottomPadding: dp(12)
                                    }
                                }
                            } //ColumnLayout

                            rightItem: ColumnLayout {
                                spacing: dp(2)
                                width: dp(50)
                                AppText {
                                    Layout.preferredHeight: dp(20)
                                    Layout.alignment: Qt.AlignRight
                                    Layout.topMargin: dp(7)
                                    text: formatGpsdt(model.gpsdt)
                                    color: "blue"
                                    fontSize: 14
                                }


                                Image
                                {
                                    id: batteryIcon
                                    source: getBatteryIcon(model.trackertype, model.adextpowervalue, model.io_states)
                                    Layout.alignment: Qt.AlignRight
                                }
                            } //ColumnLayout

                            textItem: Row {
                                spacing: dp(5)
                                AppText {
                                    text: model.name
                                }

                                Repeater {
                                    model: vhcSensors.length
                                    Rectangle {
                                        color: vhcSensors[index]["bgcolor"]
                                        radius: dp(2)
                                        width: sensorText.width
                                        height: sensorText.height
                                        AppText {
                                            id: sensorText
                                            text: vhcSensors[index].name
                                            fontSize: vehilocApp.sensorFontSize
                                            color: 'yellow'
                                            leftPadding: dp(3)
                                            rightPadding: dp(3)
                                        }
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
                                Repeater {
                                    model: vhcAddress !== undefined ? 0 : vhcGeofences !== undefined ? vhcGeofences.length : 0
                                    Rectangle {
                                        color: "green"
                                        radius: dp(2)
                                        width: gfText.width
                                        height: gfText.height
                                        AppText {
                                            id: gfText
                                            text: vhcGeofences[index]['name']
                                            fontSize: 12
                                            color: 'white'
                                            leftPadding: dp(3)
                                            rightPadding: dp(3)
                                        }
                                    }
                                }
                                AppText {
                                    id: textVhcAddress
                                    visible: model.address !== undefined
                                    text: model.address !== undefined ? model.address : ''
                                    fontSize: 12
                                    color: 'black'
                                    leftPadding: dp(3)
                                    rightPadding: dp(3)
                                }
                            }

                            onSelected: {
//                                console.log('clicked model: ' + model.name + ' index: ' + index + ' ' + mainApp.vehicles[index]['name'])
                                if (mainApp.vehicles[index]['address'] === undefined || (mainApp.vehicles[index]['geofences'].length === 0)) {
                                    HttpRequest
                                    .get("https://vehiloc.net/rest/address", {lat: model.lat, lon: model.lon})
                                    .auth(mainApp.token, 'unused')
                                    .timeout(2000)
                                    .end(function(err, res) {
                                        if(res.ok) {
                                            //                                    console.log(JSON.stringify(res.body, null, 4));
                                            //                                    console.log(res.body);
                                            mainApp.vehicles[index]['address'] = res.body['address']
                                            mainApp.vehiclesChanged()
                                        }
                                        else {
                                            console.log('Error message: ', err.message)
                                            console.log('Error response: ', err.response)
                                        }
                                    });
                                } else {
                                    mainApp.vehicles[index]['address'] = undefined
                                    mainApp.vehiclesChanged()
                                }
                            }
                        } // AppListItem
                        leftOption: SwipeButton {
                            text: 'Map'
                            icon: IconType.mapmarker
                            height: vehicleDelegate.height
                            onClicked: {
                                console.log(vehicleDelegate.item)
                                vehilocApp.currentIndex = 0
                                vehilocApp.setMapCenter(model.lat, model.lon)
                            }
                        }
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

        function setMapCenter(lat, lon) {
            navItemMap.navigationStack.moiMap.meiMap.center = QtPositioning.coordinate(lat, lon)
            navItemMap.navigationStack.moiMap.meiMap.zoomLevel = 14
        }
    }

    LoginPage {
        visible: opacity > 0
        enabled: visible
        opacity: mainApp.userLoggedIn ? 0 : 1 // hide if user is logged in
    }

    function formatGpsdt(gpsdt) {
        // return current time if gps is still today, return date/month if this year, return year < this year
        var currenttime = new Date();
        var gpstime = new Date(gpsdt * 1000)
        if ((currenttime.getFullYear() === gpstime.getFullYear()) && (currenttime.getMonth() === gpstime.getMonth()) && (currenttime.getDate() === gpstime.getDate())) {
            return gpstime.toLocaleTimeString(Qt.locale('id_ID'), 'H:mm')
        }

        if (currenttime.getFullYear() === gpstime.getFullYear()) {
            return gpstime.toLocaleDateString(Qt.locale('id_ID'), 'd-MMM')
        }

        return gpstime.toLocaleDateString(Qt.locale('id_ID'), 'yyyy')
    }

    function getBatteryIcon(trackertype, adextpowervalue, io_states) {
        if (trackertype === 6706) {
            if (adextpowervalue > 0) {
                return "../assets/battery_green.png"
            } else {
                return "../assets/battery_red.png"
            }
        }
        if (trackertype === 380) {
            if (adextpowervalue > 100) {
                return "../assets/battery_green.png"
            } else {
                return "../assets/battery_red.png"
            }
        }
        if (trackertype === 4140) {
            if ((io_states &  (1 << 7)) == 0) {
                return "../assets/battery_green.png"
            } else {
                return "../assets/battery_red.png"
            }
        }
        return ""
    }

    function loadVehiloc() {
        // get list of vehicles
        console.log('Updating vehicles list and deactivate websocket ...')
        wsVehiloc.active = false
        HttpRequest
        .get("https://vehiloc.net/rest/vehicles")
        .auth(mainApp.token, 'unused')
        .timeout(20000)
        .end(function(err, res) {
            if(res.ok) {
                console.log('Got vehicles list.')
                mainApp.vehicles = res.body
                mainApp.userLoggedIn = true

                //build vehicle vhcIndex
                mainApp.vehicles.forEach(function(vhc, idx, theArray) {
                    vhcIndex[vhc['id']] = idx
                })

                // subscribe updates
                console.log('Vehicles index built, Getting customer salts for websocket...')
                HttpRequest
                .get("https://vehiloc.net/rest/customer_salts")
                .auth(mainApp.token, 'unused')
                .timeout(20000)
                .end(function(err, res) {
                    if(res.ok) {
                        wsVehiloc.url = 'wss://vehiloc.net/sub-split/' + res.body.join(',')
                        wsVehiloc.active = true
                        console.log('Got customer salts and websocket activated: ', wsVehiloc.url)
                    }
                    else {
                        console.log('Error message: ', err.message)
                        console.log('Error response: ', err.response)
                    }
                });
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
//                console.log(JSON.stringify(res.body, null, 4));
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
        wsVehiloc.active = false
        wsVehiloc.url = ''
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
//                    map.fitViewportToVisibleMapItems()
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
