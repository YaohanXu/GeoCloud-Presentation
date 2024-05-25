---
title: "Create an HTML page structure for the historical assessment value widget"
labels: ["Front-end"]
---

The code (HTML, JS, CSS) for the historical assessment value widget interface should all live under the `ui/widget/` folder. Refer to the [project slides](https://docs.google.com/presentation/d/1QZ6gXKYuN3Uk1owGHLrKVhh0EbPUGKQf9-VEnpnaCE4/edit) to review the wireframes. Think of this widget as something that could be dropped into the existing [Atlas](https://atlas.phila.gov/) site; as such, try to more-or-less match the styles on that site. The [Phila.gov Digital Standards](https://standards.phila.gov/) may be useful.

One difference from the wireframe in the slide show: Since this widget isn't actually on the Atlas site, we need a way to specify which property we want to look up. There should be an input box for the user to specify an OPA ID. Time permitting, we will change this to an address auto-complete.

**Acceptance Criteria:**
- A file named `index.html` in the `ui/widget/` folder
- A stylesheet (.css) file with the basic layout of the page, as shown in the [wireframe](https://docs.google.com/presentation/d/1QZ6gXKYuN3Uk1owGHLrKVhh0EbPUGKQf9-VEnpnaCE4/edit#slide=id.g1dfb0364a16_0_205), with the addition of an OPA ID input box