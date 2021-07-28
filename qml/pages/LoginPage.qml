import Felgo 3.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

Page {
    id: loginPage
    title: 'Please log in'

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: dp(2)
        AppActivityIndicator {
            id: loadingIndicator
            visible: false
            iconSize: dp(30)
        }

        AppText {
            text: "Welcome to VehiLoc"
        }

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
                        mainApp.loadVehiloc()
                        mainApp.loadGeofences()
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
