import Cutie
import QtQuick

CutieWindow {
	id: mainWindow
	width: 400
	height: 800
	visible: true
	title: qsTr("Calculator")

	readonly property color secondaryAlphaLightColor: Qt.rgba(
		Atmosphere.secondaryAlphaColor.r,
		Atmosphere.secondaryAlphaColor.g,
		Atmosphere.secondaryAlphaColor.b,
		0.1
	)

	// Calculator state: `expression` is what the user typed, `result` is the
	// last evaluated value (or a live preview while typing).
	property string expression: ""
	property string result: ""

	readonly property string operators: "+−×÷"

	function press(key) {
		var last = expression.slice(-1);
		if (key === "C") {
			expression = "";
			result = "";
		} else if (key === "⌫") {
			expression = expression.slice(0, -1);
			result = "";
		} else if (key === "=") {
			if (result !== "" && result !== qsTr("Error")) {
				expression = result;
				result = "";
			}
			return;
		} else if (operators.indexOf(key) >= 0) {
			// Start a new calculation from the previous result, and never
			// allow two operators in a row.
			if (expression === "")
				return;
			if (operators.indexOf(last) >= 0)
				expression = expression.slice(0, -1);
			expression += key;
		} else {
			expression += key;
		}
		preview();
	}

	function evaluate(expr) {
		var js = expr.replace(/×/g, "*").replace(/÷/g, "/")
			.replace(/−/g, "-").replace(/%/g, "/100");
		if (!/^[0-9+\-*\/.()\s]+$/.test(js))
			return "";
		try {
			var value = Function("return (" + js + ")")();
			if (!isFinite(value))
				return qsTr("Error");
			return String(parseFloat(value.toPrecision(12)));
		} catch (e) {
			return "";
		}
	}

	function preview() {
		var expr = expression;
		// Ignore a dangling operator while previewing
		if (operators.indexOf(expr.slice(-1)) >= 0)
			expr = expr.slice(0, -1);
		var value = evaluate(expr);
		result = (value === expr) ? "" : value;
	}

	initialPage: CutiePage {
		width: mainWindow.width
		height: mainWindow.height

		CutiePageHeader {
			id: header
			title: mainWindow.title
			width: parent.width
		}

		// ── Display ─────────────────────────────────────────────
		Column {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: keypad.top
			anchors.margins: 20
			spacing: 6

			CutieLabel {
				width: parent.width
				text: mainWindow.expression === "" ? "0" : mainWindow.expression
				horizontalAlignment: Text.AlignRight
				elide: Text.ElideLeft
				font.pixelSize: 40
				font.bold: true
			}

			CutieLabel {
				width: parent.width
				height: 24
				text: mainWindow.result
				horizontalAlignment: Text.AlignRight
				elide: Text.ElideLeft
				font.pixelSize: 20
				opacity: 0.75
			}
		}

		// ── Keypad ──────────────────────────────────────────────
		Grid {
			id: keypad
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.margins: 16
			anchors.bottomMargin: 24
			columns: 4
			spacing: 8

			readonly property real cellWidth: (width - 3 * spacing) / 4

			Repeater {
				model: [
					{ key: "C" }, { key: "⌫" }, { key: "%" }, { key: "÷", op: true },
					{ key: "7" }, { key: "8" }, { key: "9" }, { key: "×", op: true },
					{ key: "4" }, { key: "5" }, { key: "6" }, { key: "−", op: true },
					{ key: "1" }, { key: "2" }, { key: "3" }, { key: "+", op: true },
					{ key: "00"}, { key: "0" }, { key: "." }, { key: "=", op: true }
				]

				delegate: CutieButton {
					width: keypad.cellWidth
                    height: 72
					text: modelData.key
					font.pixelSize: 24
					color: modelData.op ? Atmosphere.primaryColor
					                    : mainWindow.secondaryAlphaLightColor
					onClicked: mainWindow.press(modelData.key)
				}
			}
		}
	}
}
