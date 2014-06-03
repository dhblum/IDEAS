within IDEAS.Fluid.HeatExchangers.GroundHeatExchangers.Borefield.Data.ShortTermResponse;
record example_accurate
  extends Records.ShortTermResponse(
    name="example_accurate",
    vecLen=BaseClasses.Scripts.readTrajectoryVecLen(
        "..\\IDEAS\\IDEAS\\Fluid\\HeatExchangers\\GroundHeatExchangers\\Borefield\\Data\\ShortTermResponse\\example_accurateData"),
    tVec=BaseClasses.Scripts.readTrajectorytVec(
        "..\\IDEAS\\IDEAS\\Fluid\\HeatExchangers\\GroundHeatExchangers\\Borefield\\Data\\ShortTermResponse\\example_accurateData"),
    TResSho=BaseClasses.Scripts.readTrajectoryTResSho(
        "..\\IDEAS\\IDEAS\\Fluid\\HeatExchangers\\GroundHeatExchangers\\Borefield\\Data\\ShortTermResponse\\example_accurateData"));

end example_accurate;
