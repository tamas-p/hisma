function register(renderLocation, subscribeLocation) {
  console.log("onLoad --------");
  createOverlayBoxes();

  // img = document.getElementById("rendered");
  // console.log(img);
  //   img.onload = function () {
  //     console.log("onload!");
  //     hide("loading");
  //   };
  // img.addEventListener("load", (event) => {
  //   console.log("imag onload.");
  //   hide("loading");
  // });

  show("loading");
  connect(renderLocation, subscribeLocation);
}

async function reload(location) {
  console.log("re-loading");
  show("loading");
  // img.src = location + "?rand_number=" + Math.random();
  // img.data = location + "?rand_number=" + Math.random();

  const response = await fetch(location + "?rand_number=" + Math.random());
  const svg = await response.text();
  var element = document.getElementById("rendered");
  element.innerHTML = svg;
  hide("loading");
}

//-----------------------------------------------------------------------------

var websocket;
function connect(renderLocation, subscribeLocation) {
  var wsUri = "ws://" + location.host + subscribeLocation;
  websocket = new WebSocket(wsUri);
  websocket.onmessage = function (evt) {
    switch (evt.data) {
      case "RELOAD":
        reload(renderLocation);
        break;
      default:
        console.log(`Can not understand ${evt.data}.`);
    }
  };

  websocket.onopen = function (evt) {
    console.log("Connected.");
    hide("warning");
    hide("error");
    reload(renderLocation);
  };

  websocket.onclose = function (evt) {
    console.log("Disconnected.");
    show("warning");
    setTimeout(function () {
      connect(renderLocation, subscribeLocation);
    }, 1000);
  };

  websocket.onerror = function (evt) {
    console.log("Error.");
    hide("loading");
    hide("warning");
    show("error");
    websocket.close();
  };
}

/**
 *
 * @param {String} message
 */
function sendMessage(message) {
  // alert(evt.target.id);
  websocket.send(message.target.id);
}

//-----------------------------------------------------------------------------

function show(id) {
  // document.getElementById("rendered").style.opacity = 0.3;
  document.getElementById(id).style.opacity = 1.0;
}

function hide(id) {
  // document.getElementById("rendered").style.opacity = 1.0;
  document.getElementById(id).style.opacity = 0.0;
}

function createOverlayBoxes() {
  createOverlayBox(
    "warning",
    "textWarning",
    "Disconnected from Visualization Server"
  );

  createOverlayBox(
    "error",
    "textWarning",
    "Error while connecting to Visualization Server"
  );

  createOverlayBox("loading", "textLoading", "Loading...");
}

/// Creates a widget to represent info, warning or error to
/// the user.

/**
 * Creates a widget to represent info, warning or error to the user.
 * @param  {String} id Identifier.
 * @param  {String} type CCS style name to use.
 * @param  {String} str String to be shown in the widget.
 */
function createOverlayBox(id, type, str) {
  console.log("createOverlayBox for " + id);

  var div = document.createElement("div");
  div.className = "middle";
  div.id = id;

  var divText = document.createElement("div");
  divText.className = type;
  divText.innerHTML = str;
  div.appendChild(divText);

  var renderedDiv = document.getElementById("mainContainer");
  renderedDiv.appendChild(div);
}
