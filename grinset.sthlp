{smcl}
{* 29apr2023}{...}
{hi:help grinset}{...}
{right:{browse "https://github.com/benjann/grinset/"}}
{hline}

{title:Title}

{pstd}{hi:grinset} {hline 2} Add a graph as an inset to another graph


{title:Syntax}

{pstd}
    Syntax 1: add inset

{p 8 15 2}
    {cmd:grinset} [{it:name}] [{help grinset##position:{it:position}}] [{cmd:,}
    {help grinset##opts:{it:options}} ] {cmd::} {it:graph_command}

{pstd}
    Syntax 2: modify inset

{p 8 15 2}
    {cmd:grinset} [{it:name}] [{help grinset##position:{it:position}}] [{cmd:,} 
    {help grinset##opts:{it:options}} ] [{cmd::} {help grinset##id:{it:id}} ]

{pstd}
    where {it:name} is the name of the graph to be modified (default is
    the current/topmost graph).


{synoptset 24}{...}
{marker opts}{synopthdr:options}
{synoptline}
{synopt :{opt s:ize(# [#])}}size of the inset; default is {cmd:size(25)}
    {p_end}
{synopt :{opt sc:ale(#)}}scale of markers and labels; default is {cmd:scale(0.5)}
    {p_end}
{synopt :{cmd:name(}{it:newname}[{cmd:,} {cmdab:r:eplace}]{cmd:)}}custom name for the resulting graph
    {p_end}
{synopt :{opt nodraw}}do not draw the resulting graph
    {p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:grinset} adds the graph resulting from {it:graph_command} as an inset to
    the current (topmost) graph (or to the graph identified by {it:name}). The command
    has been inspired by a note on inset plots by Tibbles and Melse (2023).

{marker position}{...}
{pstd}
Argument {it:position} determines the position of the inset on the graph. The
syntax of {it:position} is

        {it:pos} [{it:pos}]

{pstd}
    where {it:pos} may be

{p2colset 9 15 17 2}{...}
{p2col:{it:#}}vertical (horizontal) offset from center; positive values
    shift up (right), negative values shift down (left)
    {p_end}
{p2col:{cmd:t=}{it:#}}gap between top of inset and top of graph
    {p_end}
{p2col:{cmd:b=}{it:#}}gap between bottom of inset and bottom of graph
    {p_end}
{p2col:{cmd:l=}{it:#}}gap between left edge of inset and left edge of graph
    {p_end}
{p2col:{cmd:r=}{it:#}}gap between right edge of inset and right edge of graph
    {p_end}

{pstd}
    At most one of {cmd:t} and {cmd:b} and at most one of {cmd:l} and {cmd:r}
    is allowed. In any case, {it:#} is interpreted as a
    percentage of the minimum of the width and height of the graph. By default,
    the inset will be placed at the center of the graph; this is equivalent to
    specifying {it:position} as {cmd:0 0}. If {it:position} is specified as
    {it:# #}, the first number is interpreted as vertical offset and the second
    as horizontal offset. Alternatively, use declarations {cmd:t} or {cmd:b} and
    {cmd:l} or {cmd:r} to position the inset with respect to the borders of the
    graph. For example, type

        {com}t=5 r=5{txt}

{pstd}
    to place the inset in the top right corner of the graph, with a margin equivalent
    to 5% of the minimum of the width and height of the graph.

{marker id}{...}
{pstd}
    In syntax 2, argument {it:id} selects the inset to be modified. This is useful
    if multiple insets have been added to the graph. Counting is backwards. The
    {it:id} of the inset added last is {cmd:1}; this is the
    inset that will be modified if {it:id} is omitted. The {it:id} of the inset
    added second last is {cmd:2}, the {it:id} of the inset added third last is
    {cmd:3}, and so on. For example, after adding three insets, type

        {com}grinset {it:...} : 3{txt}

{pstd}
    to modify the inset that has been added first (the third last inset).


{title:Options}

{phang}
    {opt size(# [#])} sets the height and width of the inset as a percentage of the
    height and width of the main graph. The default for a new inset
    is {cmd:size(25)}. Specify two values to set height and width individually.

{pmore}
    When changing the size of an existing inset (Syntax 2), the center of the inset
    will remain in the same position. Depending on context, you may thus also want
    to specify {help grinset##position:{it:position}}.

{pmore}
    Changing height and width of the graph after the inset has been added may have
    unexpected effects on the inset. It is best not to change the size of the graph
    after having added an inset.

{phang}
    {opt scale(#)} specifies a multiplier that affects the size
    of text, markers, and line widths of the inset. The default for a new inset is
    {cmd:scale(0.5)}.

{phang}
    {cmd:name(}{it:newname}[{cmd:,} {cmdab:replace}]{cmd:)} specifies a custom
    name for the resulting graph. Use this option if you want to create a new
    graph rather then modify the existing graph.

{phang}
    {opt nodraw} specifies that the graph not be displayed.


{title:Examples}

{pstd}
    Main graph:

        . {stata sysuse auto, clear}
        . {stata scatter price mpg}

{pstd}
    Add a histogram:

        . {stata "grinset r=5: histogram mpg, percent ylabel(, nogrid)"}

{pstd}
    Move the inset to a different position, change size, and change scaling of text and markers:

        . {stata grinset t=5 r=5, size(20) scale(0.4)}

{pstd}
    Add a second histogram:

        . {stata "grinset t=5 20, size(20) scale(0.4): histogram price, percent ylabel(, nogrid)"}


{title:References}

{phang}
    Tibbles, Matthew, Eric Melse. 2023. A note on creating inset plots using
    graph twoway. The Stata Journal 23(1): 265-275. {browse "https://doi.org/10.1177/1536867X231162022"}


{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2023). grinset: Stata module to add a graph as an inset to
    another graph. Available from {browse "https://ideas.repec.org/c/boc/bocode/s459203.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb graph}
