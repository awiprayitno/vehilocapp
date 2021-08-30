import Felgo 3.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

Page {
    id: loginPage
    title: 'Please log in'

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(2)

        AppActivityIndicator {
            id: loadingIndicator
            visible: false
            iconSize: dp(30)
        }

        AppImage {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: dp(80)
            defaultSource: '../../assets/logo.png'
        }

        AppText {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: dp(30)
            text: "Welcome to VehiLoc"
        }

        AppTextField {
            id: tfUsername
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: dp(20)
            placeholderText: "Username"
            inputMode: inputModeUsername
        }
        AppTextField {
            id: tfPassword
            Layout.alignment: Qt.AlignCenter
            placeholderText: "Password"
            inputMode: inputModePassword
        }
        AppButton {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: dp(20)
            text: 'Login'
            isDefault: true
            onClicked: {
                loadingIndicator.visible = true
                loginPage.forceActiveFocus()    //move focus away to prevent strange mark symbol appear
                console.log('button Login clicked with username', tfUsername.text, ' and pass: ', tfPassword.text)
                HttpRequest
                .get("https://vehiloc.net/rest/token")
                .auth(tfUsername.text, tfPassword.text)
                .timeout(5000)
                .end(function(err, res) {
                    loadingIndicator.visible = false
                    if(res.ok) {
                        console.log('Status: ', res.status);
                        //                                console.log(JSON.stringify(res.header, null, 4));
//                        console.log(JSON.stringify(res.body, null, 4));
                        console.log('Token: ', res.body.token)
                        nativeUtils.setKeychainValue("token", res.body.token)
                        mainApp.token = res.body.token
                        mainApp.username = res.body.username
                        mainApp.usertype = res.body.usertype
                        mainApp.loadVehiloc()
                        mainApp.loadGeofences()
                        vehilocApp.currentIndex = 0
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
    Component.onCompleted: {
        console.log('LoginPage finished loading')
    }
}
