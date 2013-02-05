{
    update =
    {
        files = {'update.lua*'}
    },

    wget =
    {
        files = {"wget.lua*"}
    },

    geometry =
    {
        files = {"line.lua*", "rect.lua*", "prism.lua*", "wall.lua*"}
    },

    basics =
    {
        files = {"echo.lua*", "place.lua*", "dig.lua*"}
    },

    utility =
    {
        depends = {"geometry", "basics", "control"}
        files = {"fell.lua*", "ex-tunnel.lua*", "floor.bat", "wait-on.lua*", "auto-fell.lua*"}
    },

    control =
    {
        files = {"if.lua*", "batch.lua*", "[[.lua*", "do.lua*"}
    },

    ["marx-says"] =
    {
        files = {"marx-says.lua*"}
    },

    twelvecraft =
    {
        files = {"make-cross.lua*", "make-road.lua*"}
    },
}