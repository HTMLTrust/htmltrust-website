// HTMLTrust mermaid config — overrides Hugo Blox default.
// Blox's default reads Tailwind v4 CSS vars and wraps them in `rgb(...)`,
// producing `rgb(oklch(...))` which mermaid cannot parse. We use static hex
// values that read clearly on the dark site palette.

window.mermaid.initialize({
  startOnLoad: true,
  theme: "base",
  themeVariables: {
    // node backgrounds + text
    background:          "#0d1620",
    primaryColor:        "#142231",
    primaryTextColor:    "#e6edf3",
    primaryBorderColor:  "#4ca1af",

    secondaryColor:      "#1f3346",
    secondaryTextColor:  "#e6edf3",
    secondaryBorderColor:"#4ca1af",

    tertiaryColor:       "#0a1018",
    tertiaryTextColor:   "#aab4be",
    tertiaryBorderColor: "#2a3a4a",

    // flowchart specifics
    mainBkg:             "#142231",
    nodeBorder:          "#4ca1af",
    clusterBkg:          "#0a1018",
    clusterBorder:       "#2a3a4a",
    titleColor:          "#e6edf3",
    lineColor:           "#7a8aa0",
    textColor:           "#e6edf3",
    edgeLabelBackground: "#0d1620",

    // sequence diagram specifics
    actorBkg:            "#142231",
    actorBorder:         "#4ca1af",
    actorTextColor:      "#e6edf3",
    actorLineColor:      "#7a8aa0",
    signalColor:         "#aab4be",
    signalTextColor:     "#e6edf3",
    labelBoxBkgColor:    "#1f3346",
    labelBoxBorderColor: "#4ca1af",
    labelTextColor:      "#e6edf3",
    loopTextColor:       "#e6edf3",
    noteBkgColor:        "#1f3346",
    noteTextColor:       "#e6edf3",
    noteBorderColor:     "#4ca1af",

    fontFamily: getComputedStyle(document.documentElement).getPropertyValue("font-family"),
    fontSize: "16px",
  },
  flowchart: {
    curve: "basis",
    htmlLabels: true,
    padding: 12,
  },
  sequence: {
    actorMargin: 50,
    messageAlign: "center",
    mirrorActors: false,
  },
});
