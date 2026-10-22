# NewCode — 桌面卡片

一套独立、极简的 niri/Wayland 桌面卡片（quickshell 0.3.x），不依赖任何其它配置：

- **时钟**（时间 + 日期）
- **当前天气**（温度、体感、湿度、风速）
- **每日预报**（7 天，高/低温 + 图标）
- **逐小时预报**（25 小时，可横向滑动，温度曲线）

## 运行

```bash
qs -p /path/to/NewCode
```

或多显示器/常驻，可以在 niri 配置里加：

```kdl
spawn-at-startup "qs" "-p" "/path/to/NewCode"
```

## 配置

位置和坐标在 `shell.qml` 里：

```qml
Weather {
    id: weatherService
    latitude: 38.94755
    longitude: 118.55078
    locationName: "曹妃甸"
    refreshMinutes: 30
}
```

## 设计要点

- **时间轴与图标永远同源**：请求固定 `timezone=auto` + `timeformat=unixtime`，
  返回的 `is_day` 与显示用的小时都基于同一个地点的时区，昼夜图标不会错位。
- **逐小时卡片按绝对时间锚定**：滑动后记住“第一列对应的时刻”，
  数据刷新时重新对齐到那一刻，而不是固定像素偏移。
- **输入只给需要的地方**：整个 surface 是 Bottom 层且不排除桌面区域，
  `mask` 只覆盖需要滑动的逐小时卡片，其它区域点击穿透。
- 天气数据来自 [Open-Meteo](https://open-meteo.com/)，免 API key。

## 目录

```
shell.qml                 入口：layer surface + 布局 + 输入 mask
services/Weather.qml      拉取/刷新/数据整形
components/Card.qml       卡片外观
components/MeteoIcon.qml  天气码 → 图标（昼夜区分）+ 中文描述
components/TrendChart.qml Canvas 温度曲线
cards/*.qml               四张卡片
assets/weather/*.svg      meteocons（fill 样式，25 个用到的图标）
```
