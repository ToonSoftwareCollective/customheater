import QtQuick 2.1
import BxtClient 1.0
import qb.components 1.0
import qb.base 1.0



App {
	id: root

	property url customerheaterTileUrl : "CustomheaterTile.qml";
	property url thumbnailIcon: "qrc:/tsc/customheaterIcon.png"
	property url customheaterScreenUrl : "CustomheaterScreen.qml"
	property url customheaterSettingsUrl : "CustomheaterSettings.qml"

	property variant settings: { 
                "hasZwavePlug": false,
                "zwavePlugId": 0,
                "hasDeviceUrl": false,
                "deviceUrlOn": "",
                "deviceUrlOff": "",
                "waitOnTimer": 0, 
                "waitOffTimer": 0 
	}

        property bool isHeating : false

	function init() {
		//registry.registerWidget("screen", customheaterScreenUrl, this);
		//registry.registerWidget("screen", customheaterSettingsUrl, this, "customheaterSettings");
		//registry.registerWidget("tile", customerheaterTileUrl, this, null, {thumbLabel: "CustomHeater", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
	}

	Component.onCompleted: {
		// load the settings on completed is recommended instead of during init
		loadSettings(); 
	}

	function loadSettings()  {
		var settingsFile = new XMLHttpRequest();
		settingsFile.onreadystatechange = function() {
			if (settingsFile.readyState == XMLHttpRequest.DONE) {
				if (settingsFile.responseText.length > 0)  {
					var temp = JSON.parse(settingsFile.responseText);
					for (var setting in settings) {
						if (temp[setting] === undefined )  { temp[setting] = settings[setting]; } // use default if no saved setting exists
					}
					settings = temp;
				}
			}
		}
		settingsFile.open("GET", "file:///mnt/data/tsc/customheater.userSettings.json", true);
		settingsFile.send();
	}

        function onThermostatInfoChanged(node) {
                var tempNode = node.child;
                while (tempNode) {
			if (tempNode.name === "burnerInfo") {
                        	switch (parseFloat(tempNode.text)) {
                       		case 0:
                        	        //off
	                       	        isHeating = false; 
                        	        break;
                       		case 1:
                        	        //heating
                        	        isHeating = true; 
                        	        break;
                        	case 2:
                        	        //DHW
                        	        isHeating = false; 
                        	        break;
                        	case 3:
                        	        //preheating
                        	        isHeating = true; 
                        	        break;
                        	case 4:
                        	        //Error
                        	        isHeating = false; 
                        	        break;
                        	}
			}
			tempNode = tempNode.sibling;
                }
		console.log("TSC customheater: " + isHeating);
        }

        BxtDiscoveryHandler {
                id: thermstatDiscoHandler
                deviceType: "happ_thermstat"
        }

        BxtDatasetHandler {
                id: thermstatInfoDsHandler
                dataset: "thermostatInfo"
                discoHandler: thermstatDiscoHandler
                onDatasetUpdate: onThermostatInfoChanged(update)
        }
}
