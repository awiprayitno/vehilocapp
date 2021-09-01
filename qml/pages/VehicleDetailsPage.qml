import Felgo 3.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtPositioning 5.5
import QtLocation 5.5
import QtCharts 2.2

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

    function formatInputLog(data) {
        console.log('input no: ', data.input_no, ' sensor_name: ', data.sensor_name, ' new_state_desc', data.new_state_desc)
        var inputName = '';
        if (data.input_no > 0) {
            inputName = data.sensor_name ? data.sensor_name : "INPUT " + data.input_no;
        } else {
            inputName = data.sensor_name ? data.sensor_name : "OUTPUT " + Math.abs(data.input_no);
        }
        var inputState = data.new_state_desc ? data.new_state_desc : data.new_state ? "ON" : "OFF";

        console.log('inputName: ', inputName, ' inputState: ', inputState)
        var inputlogtext = '';
        if (data.input_no === 99) {
            inputlogtext = 'ACCU was ' + (data.new_state ? 'CONNECTED' : 'DISCONNECTED');
//            if (! jdetail.new_state)
//                inputlogtext = inputlogtext + ' <span style="color:red;" class="ionicons ion-alert" data-pack="default" data-tags="" />'
        } else {
            inputlogtext = inputName + ' was ' + inputState;
        }
        // show input no if user admin
        if (mainApp.usertype === 99) {
            if (data.new_state) {
                inputlogtext += ' ' + data.input_no ;
            } else {
                inputlogtext += ' ' + data.input_no;
            }
        }

        return inputlogtext
    }

    function formatJdetail(jdetail) {
        var toreturn = formatGpsdt(jdetail.startdt) + ' - ' + formatGpsdt(jdetail.enddt) + ' '
        if (jdetail.type === 1) {
            toreturn = toreturn + 'Stopped '
        } else if (jdetail.type === 2) {
            toreturn = toreturn + 'Moved for'
        }

        return toreturn
    }

    function checkSpeedAboveZero(entry) {
        return entry.speed > 0
    }

    property var vhcData: undefined
    property var listData: undefined
    property var jdetails: undefined
    property var inputlogs: undefined
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

        console.log("Getting data /"+vhcData.id+'/'+mydate + ' ...')
//        vhcQuickItem.visible = false
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
                jdetails = res.body['jdetails']
                inputlogs = res.body['inputlogs']
                listDataChanged()
                currentDataChanged()

                sliderData.value = listData.findIndex(checkSpeedAboveZero)
                currentData = listData[sliderData.value]
                mapItemViewGeofences.visible = false
                vhcDetailsMap.fitViewportToVisibleMapItems()
                mapItemViewGeofences.visible = true

                console.log('slider set to ', sliderData.value)

                var templowest = 100
                var temphighest = -20
                var speedhighest = 0
                speedSeries.visible = false
                tempSeries.visible = false
                speedSeries.clear()
                tempSeries.clear()
                for (var j = 0; j < listData.length; j ++) {
                    if (j === 0) {
                        dtAxis.min = new Date(listData[j].gpsdt * 1000)
                    }
                    speedSeries.append(listData[j].gpsdt * 1000, listData[j].speed)
                    if (listData[j].speed > speedhighest) {
                        speedhighest = listData[j].speed
                    }

                    if (listData[j].temp === 510)
                        continue
                    tempSeries.append(listData[j].gpsdt * 1000, listData[j].temp / 10.0)
                    if ((listData[j].temp / 10.0) < templowest) {
                        templowest = listData[j].temp / 10.0
                    }
                    if ((listData[j].temp / 10.0) > temphighest) {
                        temphighest = listData[j].temp / 10.0
                    }

                }
                dtAxis.min = new Date(listData[0].gpsdt * 1000)
                dtAxis.max = new Date(listData[listData.length -1].gpsdt * 1000)

                speedAxis.max = speedhighest + 10
                tempAxis.max = temphighest + 3
                tempAxis.min = templowest - 3

                tempAxis.applyNiceNumbers()
                speedAxis.applyNiceNumbers()
                speedSeries.visible = true
                tempSeries.visible = vhcData.type === 4
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
            center {
                latitude: -7.1599120
                longitude: 109.690050
            }

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

            MapItemView {
                id: mapItemViewGeofences
                model: jsonLMGeofences
                delegate: Component {
                    id: mapitemViewGFDelegate
                    MapPolygon {
                        path: model.geometry
                        border.color: 'red'
                        border.width: 1
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
                visible: vhcDetailsMap.zoomLevel > 15
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
                                ? ((currentData.speed === 0) ? "../../assets/arrow_red.png" : "../../assets/arrow_green.png")
                                : ((currentData.speed === 0) ? "../../assets/arrow_red16.png" : "../../assets/arrow_green16.png")
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
            leftPadding: dp(15)
            rightPadding: dp(15)
            onMoved: {
                currentData = listData[value]
                vhcDetailsMap.center = QtPositioning.coordinate(currentData.latitude, currentData.longitude)
                console.log('lat: ', currentData.latitude, ' lon: ', currentData.longitude)
            }
        }

        ChartView {
            id: chartviewSpeed
            width: parent.width
            height: dp(300)

//            theme: ChartView.ChartThemeBrownSand
            antialiasing: true

            DateTimeAxis {
                id: dtAxis
                format: 'h:mm'
                tickCount: 5
            }

            ValueAxis {
                id: speedAxis
                min: 0
                max: 150
                labelFormat: '%d'
                labelsColor: 'orange'
            }

            LineSeries {
                id: speedSeries
                name: 'Speed (km/h)'
                axisX: dtAxis
                axisY: speedAxis
                color: 'orange'
                width: 1
//                markerSize: dp(10)
//                borderWidth: dp(0)
            }

            ValueAxis {
                id: tempAxis
                visible: vhcData.type === 4
                min: -20
                max: 80
                labelFormat: '%d'
                labelsColor: 'blue'
            }

            LineSeries {
                id: tempSeries
                visible: vhcData.type === 4
                name: 'Temperature °C'
                axisX: dtAxis
                axisYRight: tempAxis
                color: 'blue'
                width: 1
            }
        }

        Repeater {
            model: jdetails

            Row {
                spacing: dp(6)
                height: dp(30)

                AppText {
                    id: timeText
                    text: formatGpsdt(modelData.startdt) + ' - ' + formatGpsdt(modelData.enddt)
                }

                AppText{
//                    horizontalAlignment: parent.horizontalCenter
                    text: modelData.type === 1 ? 'Stopped' : 'Moved ' + (modelData.distance/1000).toFixed(2) + ' km'
                }
                AppButton {
                    visible: modelData.type === 1
                    text: 'Show'
                    textSize: sp(8)
                    height: dp(10)
                    minimumHeight: dp(8)
                    onClicked: {
                        if (modelData.type === 1) {
                            vhcDetailsMap.center = QtPositioning.coordinate(modelData.lat, modelData.lon)
                            sliderData.value = listData.findIndex(entry => entry.gpsdt === modelData.enddt)

                            currentData = listData[sliderData.value]
                        }
                    }
                }
            }
        }

        AppText {
            text: 'Events'
            visible: inputlogs.length > 0
        }

        Repeater {
            model: inputlogs

            Row {
                spacing: dp(6)
                height: dp(30)

                AppText {
                    id: inputlogsTimeText
                    text: formatGpsdt(modelData.dt)
                }

                AppText{
                    text: formatInputLog(modelData)
                }

            }
        }
    }

    Component.onCompleted: {
        selectedDate = new Date()
    }
}
