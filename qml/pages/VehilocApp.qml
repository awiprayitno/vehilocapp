import QtQuick 2.0
import Felgo 3.0
import QtPositioning 5.5
import QtLocation 5.5

Page {
    id: vehilocApp
    AppText {
        text: 'vehiloc app'
        anchors.centerIn: parent
    }

    Component.onCompleted: {
        console.log('VehiLoc app finished loading')
    }
}
