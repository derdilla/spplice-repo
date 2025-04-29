if (!("Entities" in this)) return

IncludeScript("ppmod3")
IncludeScript("dingus/cache")
IncludeScript("dingus/main")
IncludeScript("sl_maxwell")

local run = function () {
    cache()
    ppmod.wait(function(){main()},0.2)
}

local auto = Entities.CreateByClassname("logic_auto")
ppmod.addscript(auto,"OnNewGame",run)
ppmod.addscript(auto,"OnMapTransition",run)