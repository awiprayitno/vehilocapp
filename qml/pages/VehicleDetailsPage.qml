import Felgo 3.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtPositioning 5.5
import QtLocation 5.5

FlickablePage {
    id: vhcDetailsPage
//    title: vhcData.name

    titleItem: Row {
        spacing: dp(5)
        AppText {
            text: vhcData.name
            fontSize: Theme.navigationBar.titleTextSize
            color: Theme.navigationBar.titleColor
            font.bold: Theme.navigationBar.titleTextBold

        }

        Rectangle {
            color: "black"
            radius: dp(2)
            width: plateNoText.width
            height: plateNoText.height
            anchors.verticalCenter: parent.verticalCenter

            AppText {
                id: plateNoText
                text: vhcData.plate_no
                fontSize: 16
                color: 'white'
                font.bold: true
                leftPadding: dp(3)
                rightPadding: dp(3)
            }
        }
    }

    rightBarItem: ActivityIndicatorBarItem {
        animating: HttpNetworkActivityIndicator.enabled
        visible: animating
    }

    function formatGpsdt(gpsdt) {
        var gpstime = new Date(gpsdt * 1000)
        return gpstime.toLocaleTimeString(Qt.locale('id_ID'), 'HH:mm')
    }

    property var vhcData: undefined
    property var listData: undefined
    property var currentData: undefined
    property date selectedDate: undefined

    // you can configure the internal flickable with the "flickable" property of the page
    flickable.contentWidth: contentColumn.width
    flickable.contentHeight: contentColumn.height

    onSelectedDateChanged: {
        console.log('date changed to: ', selectedDate)
        var mydate = selectedDate.setHours(0,0,0,0) / 1000
        console.log('mydate: ', mydate)
        datePickerButton.text = selectedDate.toLocaleDateString(Qt.locale('id_ID'), 'd-MMM-yy')

        console.log('Getting data...')
        HttpRequest
        .get("https://vehiloc.net/rest/vehicle_daily_history/"+vhcData.id+'/'+mydate)
        .auth(mainApp.token, 'unused')
        .timeout(20000)
        .end(function(err, res) {
            if(res.ok) {
                console.log('Got vehicle data, status: ', res.status);
//                console.log(JSON.stringify(res.body['data'], null, 4));
//                vhcPolyline.path = res.body['data']
                listData = res.body['data']
                vhcDetailsMap.fitViewportToVisibleMapItems()
            }
            else {
                console.log('Error message: ', err.message)
                console.log('Error response: ', err.response)
            }
        });

    }

    Connections {
        target: nativeUtils
        onDatePickerFinished: {
            if (accepted) {
                selectedDate = date
            }
        }
    }

    Column {
        id: contentColumn
        width: page.width

        Row {
//            leftPadding: dp(10)
            anchors.horizontalCenter: parent.horizontalCenter
            AppButton {
                minimumWidth: dp(50)
                text: currentData.speed + ' km/h'
            }

            AppButton {
                text: "<"
                minimumWidth: dp(40)
                onClicked: {
                    var tdi = selectedDate
                    tdi.setDate(tdi.getDate() - 1)
                    selectedDate = tdi
                }
            }

            AppButton {
                id: datePickerButton
                onClicked: nativeUtils.displayDatePicker(selectedDate, '2000-01-01', new Date())
            }

            AppButton {
                text: ">"
                minimumWidth: dp(40)
                enabled: (new Date()).getDate() != selectedDate.getDate()
                onClicked: {
                    var tdi = selectedDate
                    tdi.setDate(tdi.getDate() + 1)
                    if (new Date() >= tdi) {
                        selectedDate = tdi
                    }
                }
            }
            AppButton {
                minimumWidth: dp(50)
                text: formatGpsdt(currentData.gpsdt)
            }
        }

        AppMap {
            id: vhcDetailsMap
            height: dp(300)
            width: parent.width
            plugin: Plugin {
                name: "osm" // e.g. mapbox, ...
                parameters: [
                    // set required plugin parameters here
                ]
            }
            MapPolyline {
                id: vhcPolyline
                line.width: 2
                line.color: 'red'
                path: listData
            }

            MapQuickItem {
                id: vhcQuickItem
                coordinate {
                    latitude: currentData.latitude
                    longitude: currentData.longitude
                }

                anchorPoint.x: vehicleIcon.width/2
                anchorPoint.y: vehicleIcon.height/2
                sourceItem: Column {
                    Image
                    {
                        id: vehicleIcon
                        source: Qt.platform.os === 'android'
                                ? ((model.speed === 0) ? "../../assets/arrow_red.png" : "../../assets/arrow_green.png")
                                : ((model.speed === 0) ? "../../assets/arrow_red16.png" : "../../assets/arrow_green16.png")
                        transform: Rotation
                        {
                            id: assetRotation2
                            origin.x: vehicleIcon.width / 2
                            origin.y: vehicleIcon.height / 2
                            angle: currentData.bearing ? currentData.bearing : 0
                        }
                    }
//                    Rectangle {
//                        id: mapNameBG
//                        color: "red"
//                        radius: dp(2)
//                        width: mapNameText.width
//                        height: mapNameText.height
//                        opacity: 0.7
//                        AppText {
//                            id: mapNameText
//                            text: model.name
//                            fontSize: vehilocApp.mapNameFontSize
//                            anchors.horizontalCenter: mapNameBG.horizontalCenter

//                            color: 'white'
//                            leftPadding: dp(3)
//                            rightPadding: dp(3)
//                        }
//                    }
                }
            }
        }

        AppSlider {
            id: sliderData
            width: parent.width
            height: dp(50)
            from: 0
            stepSize: 1
            to: listData.length

            onMoved: {
                currentData = listData[value]
                console.log('lat: ', currentData.latitude, ' lon: ', currentData.longitude)
            }
        }

        Repeater {
            model: ["red","green","yellow","blue"]

            Rectangle {
                color: modelData    // This will be "red", "green", ...
                width: parent.width
                height: dp(200)
                AppText {
                    text: 'lat: ' + vhcData.lat + ' lon: ' + vhcData.lon
                }
            }
        }
    }

    Component.onCompleted: {
        selectedDate = new Date()
    }
}
