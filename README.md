# grinset
Stata module to add a graph as an inset to another graph

`grinset` has been inspired by a note on inset plots by 
[Tibbles and Melse (2023)](https://doi.org/10.1177/1536867X231162022).

To install `cdist` from GitHub, type

    . net install grinset, replace from(https://raw.githubusercontent.com/benjann/grinset/main/)

Stata 14 (or newer) is required.

---

---

Example (use of [`grstyle`](https://github.com/benjann/grstyle) and is made; 
type `ssc install grstyle` to install the package; `grstyle` also requires 
[`palettes`](https://github.com/benjann/palettes)
and [`colrspace`](https://github.com/benjann/colrspace), so additionally type 
`ssc install palettes` and `ssc install colrspace`).

Data and setup.

    sysuse auto, clear
    grstyle init
    grstyle set plain, nogrid
    grstyle set color sb
    grstyle set color sb, select(2) inten(.7): histogram
    grstyle set color sb, select(2): histogram_line

Main graph.

    scatter price mpg

![example 1](/images/1.png)

Add a histogram. 

    grinset r=5: histogram mpg, percent

![example 2](/images/2.png)

Move the inset to a different position. 

    grinset t=5 r=5

![example 3](/images/3.png)

Add a second histogram.

    grinset t=5 10: histogram price, percent

![example 4](/images/4.png)

---

Main changes:

    27apr2023 (version 1.0.0)
    - released on github

