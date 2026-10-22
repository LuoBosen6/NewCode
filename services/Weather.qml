import QtQuick

// Fetches weather from Open-Meteo and exposes it as plain properties.
//
// Two rules that keep the time axis honest (these bit the old setup):
//   1. `timezone=auto` + `timeformat=unixtime`: every timestamp is absolute,
//      and `is_day` is computed for the same place the request was made for.
//   2. Display always goes through `new Date(epoch * 1000)` (local time), so
//      the clock labels and the day/night icons can never drift apart.
QtObject {
    id: root

    property real latitude: 38.94755
    property real longitude: 118.55078
    property string locationName: "曹妃甸"
    property int refreshMinutes: 30

    property string status: "idle"          // idle | loading | ready | error
    property string errorMessage: ""
    property var current: ({})
    property var hourly: []                 // [{time, temp, code, isDay, precip}]
    property var daily: []                  // [{time, code, high, low}]
    property var updatedAt: null

    signal updated()

    function refresh() {
        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + root.latitude
            + "&longitude=" + root.longitude
            + "&timezone=auto&timeformat=unixtime&forecast_days=8&past_days=1&windspeed_unit=ms"
            + "&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m"
            + "&hourly=temperature_2m,weather_code,is_day,precipitation_probability"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min";
        const request = new XMLHttpRequest();
        request.onreadystatechange = function () {
            if (request.readyState !== XMLHttpRequest.DONE)
                return;
            if (request.status !== 200) {
                root.status = "error";
                root.errorMessage = "HTTP " + request.status;
                return;
            }
            try {
                root.apply(JSON.parse(request.responseText));
            } catch (error) {
                root.status = "error";
                root.errorMessage = String(error);
            }
        };
        root.status = root.hourly.length > 0 ? "ready" : "loading";
        request.open("GET", url);
        request.send();
    }

    function apply(data) {
        const currentData = data.current || {};
        root.current = {
            "temp": currentData.temperature_2m,
            "feels": currentData.apparent_temperature,
            "code": currentData.weather_code,
            "wind": currentData.wind_speed_10m,
            "humidity": currentData.relative_humidity_2m
        };

        // Keep the current hour plus the next 24; dropping the past makes the
        // first visible column always "now" when the card is not scrolled.
        const hourlyData = data.hourly || {};
        const times = hourlyData.time || [];
        const now = Math.floor(Date.now() / 1000);
        const rows = [];
        for (let i = 0; i < times.length; ++i) {
            if (times[i] < now - 3600)
                continue;
            rows.push({
                "time": times[i],
                "temp": (hourlyData.temperature_2m || [])[i],
                "code": (hourlyData.weather_code || [])[i],
                "isDay": (hourlyData.is_day || [])[i] === 1,
                "precip": (hourlyData.precipitation_probability || [])[i]
            });
            if (rows.length >= 25)
                break;
        }
        root.hourly = rows;

        const dailyData = data.daily || {};
        const days = dailyData.time || [];
        const out = [];
        for (let i = 0; i < days.length; ++i) {
            out.push({
                "time": days[i],
                "code": (dailyData.weather_code || [])[i],
                "high": (dailyData.temperature_2m_max || [])[i],
                "low": (dailyData.temperature_2m_min || [])[i]
            });
        }
        root.daily = out.slice(0, 7);

        root.updatedAt = new Date();
        root.status = "ready";
        root.updated();
    }

    property Timer refreshTimer: Timer {
        interval: root.refreshMinutes * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
