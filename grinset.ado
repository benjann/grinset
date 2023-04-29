*! version 1.0.1  29apr2023  Ben Jann

program grinset
    version 14.2
    // syntax
    capt _on_colon_parse `0'
    if _rc==1 exit _rc
    if _rc==0 {
        local 0 `"`s(before)'"'
        local gr `"`s(after)'"'
        if `"`gr'"'=="" {
            di as err "must specify plot command or is inset ID after colon"
            exit 198
        }
        capt numlist `"`gr'"'
        if _rc==0 {
            numlist `"`gr'"', max(1) int
            local ID = abs(`r(numlist)')
            local gr
        }
    }
    syntax [anything(equalok)] [, /*
            */ Size(numlist max=2 >0) /*
            */ SCale(numlist max=1 >0) /*
            */ name(str) nodraw ]
    // graph to modify
    gettoken NAME : anything, parse(" =")
    if `"`NAME'"'!="" {
        capt confirm name `NAME'
        if _rc local NAME
        else {
            gettoken NAME next : anything, parse(" =")
            gettoken next      : next, parse(" =")
            if `"`next'"'=="=" local NAME
            else gettoken NAME anything : anything
        }
    }
    if `"`NAME'"'!="" {
        capt classutil d `NAME'
        if _rc {
            di as err `"graph `NAME' not found"'
            exit 111
        }
    }
    else {
        capt gr_current NAME :, query
        if _rc {
            di as err "no graph found"
            exit 111
        }
    }
    // name of output graph
    _parse_name `name' // returns name replace
    // positioning
    mata: _parse_positions(st_local("anything")) // ypos, yref, xpos, xref
    if "`ypos'"!="" confirm number `ypos'
    if "`xpos'"!="" confirm number `xpos'
    // no insert to add; modify existing inset
    if `"`gr'"'=="" {
        capt n _modify_inset "`NAME'" "`name'" "`replace'" "`draw'" "`ID'" /*
            */ "`size'" "`scale'" "`yref'" "`ypos'" "`xref'" "`xpos'"
        if _rc exit _rc
        exit
    }
    // size and scale options
    if "`size'"=="" local size 25
    local size `size' `size'
    gettoken fysize size : size
    gettoken fxsize size : size
    if "`scale'"=="" local scale .5
    // properties of main (current/topmost) graph; determine fysize/fxsize
    local scheme scheme(`.`NAME'._scheme.scheme_name')
    local ysize `.`NAME'.style.declared_ysize.val'
    local xsize `.`NAME'.style.declared_xsize.val'
    if `ysize'>`xsize' local fysize = `fysize' * (`ysize'/`xsize')
    else               local fxsize = `fxsize' * (`xsize'/`ysize')
    // create inset graph
    _parse comma lhs gropts: gr
    _parse_gropts `gropts' // returns ischeme, updates gropts
    if `"`ischeme'"'=="" local ischeme `scheme'
    tempname INSET
    `lhs', `gropts' `ischeme' /*
        */ graphregion(style(none) istyle(none) margin(zero)) nodraw /*
        */ name(`INSET') fysize(`fysize') fxsize(`fxsize') scale(`scale')
    // add inset to main graph
    if "`name'"=="" {
        local name `NAME'
        if "`name'"!="Graph" {
            local nameopt name(`name', replace)
        }
    }
    else if "`name'"!="Graph" {
        if "`replace'"!="" local nameopt(`name', replace)
        else               local nameopt(`name')
    }
    graph combine `NAME' `INSET', `nameopt' `scheme' nodraw /*
        */ graphregion(margin(zero)) altshrink /*
        */ ysize(`ysize') xsize(`xsize')
    _gm_edit .`name'.plotregion1.Expand graph2 left 1
    // reposition insert
    if "`ypos'`xpos'"!="" {
        _position_inset "`name'" "`yref'" "`ypos'" "`xref'" "`xpos'" /*
            */ `ysize' `xsize'
    }
    // done
    if "`draw'"=="" {
        graph display `name', ysize(`ysize') xsize(`xsize')
    }
end

program _parse_name
    syntax [name] [, Replace ]
    c_local name `namelist'
    c_local replace `replace'
end

program _parse_gropts
    syntax [, SCHeme(passthru) /*
        remove: */ GRAPHRegion(str) nodraw name(str) /*
                */ fysize(str) fxsize(str) scale(str) /* 
        */ * ]
    c_local ischeme `scheme'
    c_local gropts  `macval(options)'
end

program _modify_inset
    args NAME name replace draw ID size scale yref ypos xref xpos
    if "`name'"=="`NAME'" local name
    if "`name'"!="" {
        if "`name'"=="Graph" local replace replace
        graph copy `NAME' `name', `replace'
        local NAME `name'
    }
    else local name `NAME'
    local id `name'
    if "`ID'"=="" local ID 1
    forv i=2/`ID' {
        local id `id'.plotregion1.graph1
    }
    capture {
        if "`scale'"!="" {
            _gm_edit .`id'.plotregion1.graph2.gmetric_mult = `scale'
        }
        local ysize `.`name'.style.declared_ysize.val'
        local xsize `.`name'.style.declared_xsize.val'
        if "`size'"!="" {
            local size `size' `size'
            gettoken fysize size : size
            gettoken fxsize size : size
            if `ysize'>`xsize' local fysize = `fysize' * (`ysize'/`xsize')
            else               local fxsize = `fxsize' * (`xsize'/`ysize')
            _gm_edit .`id'.plotregion1.graph2.fixed_ysize = `fysize'
            _gm_edit .`id'.plotregion1.graph2.fixed_xsize = `fxsize'
        }
        if "`ypos'`xpos'"!="" {
            _position_inset "`id'" "`yref'" "`ypos'" "`xref'" "`xpos'" /*
                */ `ysize' `xsize'
        }
    }
    if _rc==1 exit _rc
    if _rc {
        di as err "could not modify inset; maybe inset does not exist"
        exit 498
    }
    if "`draw'"=="" {
        graph display `name'
    }
end

program _position_inset
    args id yref ypos xref xpos ysize xsize
    local fy 1
    local fx 1
    if `ysize'>`xsize' local fy = `ysize'/`xsize'
    else               local fx = `xsize'/`ysize'
    if "`yref'"!="" {
        local ypos = 50*`fy' - `ypos' - /*
            */ `.`id'.plotregion1.graph2.fixed_ysize'/2
        if "`yref'"=="b" local ypos = -`ypos'
    }
    if "`xref'"!="" {
        local xpos = 50*`fx' - `xpos' - /*
            */`.`id'.plotregion1.graph2.fixed_xsize'/2
        if "`xref'"=="l" local xpos = -`xpos'
    }
    _gm_edit .`id'.plotregion1.graph2.yoffset = `ypos'
    _gm_edit .`id'.plotregion1.graph2.xoffset = `xpos'
end


version 14.2
mata:
mata set matastrict on

void _parse_positions(string scalar s)
{
    real scalar      l
    string scalar    ypos, xpos, yref, xref
    string rowvector t, xrefs, yrefs
    
    yref = xref = ""
    yrefs = ("t", "b") 
    xrefs = ("l", "r")
    t = tokens(s, " =")
    l = length(t)
    if (l<=0) {
        // nothing specified
        ypos = xpos = ""
    }
    else if (l<=2) {
        // ypos [xpos]
        ypos = t[1]
        xpos = (l<2 ? "0" : t[2])
    }
    else {
        if (t[2]!="=") {
            if (l!=4)      _parse_positions_err(s)
            if (t[3]!="=") _parse_positions_err(s)
            if (anyof(xrefs, t[2])) {
                // ypos {l|r}=xpos
                ypos = t[1]; xref = t[2]; xpos = t[4]
            }
            else if (anyof(yrefs, t[2])) {
                // xpos {b|t}=ypos
                xpos = t[1]; yref = t[2]; ypos = t[4]
            }
            else _parse_positions_err(s)
        }
        else {
            if (anyof(yrefs, t[1])) {
                // {t|b}=ypos ...
                yref = t[1]; ypos = t[3]
            }
            else if (anyof(xrefs, t[1])) {
                // {l|r}=xpos ...
                xref = t[1]; xpos = t[3]
            }
            else _parse_positions_err(s)
            if (l==3) {
                if (yref!="") xpos = "0" // {t|b}=ypos
                else          ypos = "0" // {l|r}=xpos
            }
            else if (l==4) {
                if (yref!="") xpos = t[4] // {t|b}=ypos xpos
                else          ypos = t[4] // {l|r}=xpos ypos
            }
            else if (l==6) {
                if (t[5]!="=") _parse_positions_err(s)
                if (anyof(xrefs, t[4])) {
                    // {t|b}=ypos {l|r}=xpos
                    if (xref!="") _parse_positions_err(s)
                    xref = t[4]; xpos = t[6]
                }
                else if (anyof(yrefs, t[4])) {
                    // {l|r}=xpos {t|b}=ypos
                    if (yref!="") _parse_positions_err(s)
                    yref = t[4]; ypos = t[6]
                }
                else _parse_positions_err(s)
            }
            else _parse_positions_err(s)
        }
    }
    st_local("ypos", ypos)
    st_local("yref", yref)
    st_local("xpos", xpos)
    st_local("xref", xref)
}

void _parse_positions_err(string scalar s)
{
    errprintf("invalid specification: %s\n", s)
    exit(198)
}

end


