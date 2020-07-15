within IDEAS.Examples.IBPSA;
model SingleZoneResidentialHydronicHeatPump
  "Single zone residential hydronic example using a heat pump as heating production system"
  extends Modelica.Icons.Example;
  package MediumWater = IDEAS.Media.Water "Water medium";
  package MediumAir = IDEAS.Media.Air "Air medium";
  package MediumGlycol = IDEAS.Media.Antifreeze.PropyleneGlycolWater (property_T=273.15, X_a = 0.5) "Glycol medium";
  parameter Modelica.SIunits.Temperature TSetCooUno = 273.15+30 "Unoccupied cooling setpoint" annotation (Dialog(group="Setpoints"));
  parameter Modelica.SIunits.Temperature TSetCooOcc = 273.15+24 "Occupied cooling setpoint" annotation (Dialog(group="Setpoints"));
  parameter Modelica.SIunits.Temperature TSetHeaUno = 273.15+15 "Unoccupied heating setpoint" annotation (Dialog(group="Setpoints"));
  parameter Modelica.SIunits.Temperature TSetHeaOcc = 273.15+21 "Occupied heating setpoint" annotation (Dialog(group="Setpoints"));
  parameter Real scalingFactor = 5 "Factor to scale up the model area and occupancy";

  inner IDEAS.BoundaryConditions.SimInfoManager       sim
    "Simulation information manager for climate data"
    annotation (Placement(transformation(extent={{-240,160},{-220,180}})));

  IDEAS.Buildings.Validation.Cases.Case900Template case900Template(
    redeclare Buildings.Components.Occupants.Input occNum,
    redeclare Buildings.Components.OccupancyType.OfficeWork occTyp,
    mSenFac=1,
    n50=10,
    bouTypFlo=IDEAS.Buildings.Components.Interfaces.BoundaryType.SlabOnGround,
    l=8*sqrt(scalingFactor),
    w=6*sqrt(scalingFactor),
    A_winA=24,
    redeclare IDEAS.Buildings.Data.Constructions.InsulatedFloorHeating
      conTypFlo(mats={IDEAS.Buildings.Data.Materials.Concrete(d=0.15),
          IDEAS.Buildings.Data.Insulation.Pur(d=0.2),
          IDEAS.Buildings.Data.Materials.Screed(d=0.05),
          IDEAS.Buildings.Data.Materials.Tile(d=0.01)}),
    hasEmb=true)
    "Case 900 BESTEST model"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));

  Utilities.Time.CalendarTime calTim(zerTim=IDEAS.Utilities.Time.Types.ZeroTime.NY2019)
    annotation (Placement(transformation(extent={{-240,140},{-220,160}})));
  Modelica.Blocks.Sources.RealExpression yOcc(y=if (calTim.hour < 7 or calTim.hour >
        19) or calTim.weekDay > 5 then 1*scalingFactor else 0)
    "Fixed schedule of 1 occupant between 7 am and 8 pm"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  IDEAS.Utilities.IO.SignalExchange.Overwrite oveHeaPumY(u(
      min=0,
      max=1,
      unit="1"), description="Heat pump modulating signal between 0 (not working) and 1 (working at maximum capacity)")
    "Block for overwriting heat pump modulating signal" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={90,150})));
  Modelica.Blocks.Sources.Constant offSetOcc(k=0.2, y(unit="K"))
    "Offset above heating temperature setpoint during occupied hours to ensure comfort"
    annotation (Placement(transformation(extent={{-200,142},{-180,162}})));
  Utilities.IO.SignalExchange.Read reaPPumEmi(
    description="Emission circuit pump electrical power",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
    y(unit="W"))
    "Block for reading the electrical power of the pump of the emission system"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));

  Modelica.Blocks.Math.RealToInteger realToInteger
    annotation (Placement(transformation(extent={{52,100},{72,120}})));
  Utilities.IO.SignalExchange.Overwrite ovePum(u(
      min=0,
      max=1,
      unit="1"), description=
        "Integer signal to control the stage of the emission circuit pump either on or off")
    "Block for overwriting emission circuit pump control signal" annotation (
      Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={2,110})));

  Utilities.IO.SignalExchange.Read reaCO2RooAir(
    description="CO2 concentration in the zone",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.CO2Concentration,
    y(unit="ppm")) "Block for reading CO2 concentration in the zone"
    annotation (Placement(transformation(extent={{-60,-60},{-80,-40}})));

  Utilities.IO.SignalExchange.Overwrite oveTSetCoo(u(
      unit="K",
      min=273.15 + 23,
      max=273.15 + 30), description="Zone temperature setpoint for cooling")
    "Overwrite for zone cooling setpoint" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-170,10})));
  Utilities.IO.SignalExchange.Overwrite oveTSetHea(u(
      max=273.15 + 23,
      unit="K",
      min=273.15 + 15), description="Zone temperature setpoint for heating")
    "Overwrite for zone heating setpoint" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-170,-30})));
  Utilities.IO.SignalExchange.Read reaTSetCoo(description=
        "Zone air temperature setpoint for cooling", y(unit="K"))
    "Read zone cooling setpoint"
    annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
  Utilities.IO.SignalExchange.Read reaTSetHea(description=
        "Zone air temperature setpoint for heating", y(unit="K"))
    "Read zone cooling heating"
    annotation (Placement(transformation(extent={{-140,-40},{-120,-20}})));
  Modelica.Blocks.Sources.RealExpression TSetCoo(y=if yOcc.y > 0 then
        TSetCooOcc else TSetCooUno) "Cooling temperature setpoint with setback"
    annotation (Placement(transformation(extent={{-220,0},{-200,20}})));
  Modelica.Blocks.Sources.RealExpression TSetHea(y=if yOcc.y > 0 then
        TSetHeaOcc else TSetHeaUno) "Heating temperature setpoint with setback"
    annotation (Placement(transformation(extent={{-220,-40},{-200,-20}})));
  Utilities.IO.SignalExchange.Read reaHeaPumY(description="Block for reading the heat pump modulating signal",
      y(unit="1")) "Read heat pump modulating signal"
    annotation (Placement(transformation(extent={{120,140},{140,160}})));
  Utilities.IO.SignalExchange.Read reaPum(description=
        "Control signal for emission cirquit pump", y(unit="1"))
    "Read control signal for emission circuit pump"
    annotation (Placement(transformation(extent={{22,100},{42,120}})));
  Modelica.Blocks.Continuous.LimPID conPI(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.6,
    Ti=8000,
    yMax=1,
    yMin=0,
    initType=Modelica.Blocks.Types.InitPID.InitialState)
    "PI controller for the boiler supply water temperature"
    annotation (Placement(transformation(extent={{20,140},{40,160}})));
  Modelica.Blocks.Math.Add addOcc
    annotation (Placement(transformation(extent={{-160,120},{-140,140}})));
  Fluid.Movers.FlowControlled_dp pum(
    inputType=IDEAS.Fluid.Types.InputType.Stages,
    massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    use_inputFilter=false,
    dp_nominal=20000,
    m_flow_nominal=0.5,
    redeclare package Medium = MediumWater,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState)
    "Circulation pump for emission system"
    annotation (Placement(transformation(extent={{40,30},{20,50}})));
  Fluid.Sensors.TemperatureTwoPort senTemSup(
    redeclare package Medium = MediumWater,
    m_flow_nominal=pum.m_flow_nominal,
    tau=0) "Supply water temperature sensor"
    annotation (Placement(transformation(extent={{80,50},{60,30}})));
  Fluid.HeatExchangers.RadiantSlab.EmbeddedPipe floHea(
    redeclare package Medium = MediumWater,
    redeclare Fluid.HeatExchangers.RadiantSlab.BaseClasses.FH_Standard1
      RadSlaCha,
    allowFlowReversal=true,
    m_flow_nominal=pum.m_flow_nominal,
    dp_nominal=pum.dp_nominal/2,
    A_floor=case900Template.AZone) "Floor heating of the zone"
    annotation (Placement(transformation(extent={{0,0},{-20,20}})));
  Fluid.Sensors.TemperatureTwoPort senTemRet(
    redeclare package Medium = MediumWater,
    m_flow_nominal=pum.m_flow_nominal,
    tau=0) "Return water temperature sensor"
    annotation (Placement(transformation(extent={{80,-10},{60,-30}})));
  Fluid.HeatPumps.ScrollWaterToWater heaPum(
    redeclare package Medium1 = MediumWater,
    redeclare package Medium2 = MediumAir,
    scaling_factor=1,
    m2_flow_nominal=fan.m_flow_nominal,
    enable_variable_speed=true,
    m1_flow_nominal=pum.m_flow_nominal,
    T1_start=293.15,
    T2_start=278.15,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    TEvaMin=253.15,
    dTHys=3,
    dp1_nominal=pum.dp_nominal/2,
    dp2_nominal=fan.dp_nominal/2,
    datHeaPum=Data.Heating.Carrier_30AW015_15kW_4_9COP_R410A())
    "Air to water heat pump model with calibrated parameters from manufacturer data"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={130,10})));
  Fluid.Sources.Boundary_pT bouWat(redeclare package Medium = MediumWater,
      nPorts=1) "Expansion vessel" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={50,10})));

  Modelica.Blocks.Sources.RealExpression yPum(y=if heaPum.com.isOn then 1 else
        0) "Control input signal to emission circuit pump"
    annotation (Placement(transformation(extent={{-40,100},{-20,120}})));
  Utilities.IO.SignalExchange.Read reaPHeaPum(
    description="Heat pump electrical power",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
    y(unit="W")) "Block for reading the electrical power of the heat pump"
    annotation (Placement(transformation(extent={{140,70},{160,90}})));

  Utilities.IO.SignalExchange.Read       reaTZon(
    description="Operative zone temperature",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.OperativeZoneTemperature,
    y(unit="K")) "Block for reading the operative zone temperature"
    annotation (Placement(transformation(extent={{-32,70},{-12,90}})));

  Utilities.IO.SignalExchange.Read reaQFloHea(
    description="Floor heating thermal power released to the zone",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
    y(unit="W"))
    "Block for reading the floor heating thermal power released to the zone"
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Utilities.IO.SignalExchange.Read reaQHeaPumEva(
    description="Heat pump thermal power exchanged in the evaporator",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
    y(unit="W"))
    "Block for reading the heat pump thermal power exchanged in the evaporator"
    annotation (Placement(transformation(extent={{160,0},{180,20}})));
  Utilities.IO.SignalExchange.Read reaQHeaPumCon(
    description="Heat pump thermal power exchanged in the condenser",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
    y(unit="W"))
    "Block for reading the heat pump thermal power exchanged in the condenser"
    annotation (Placement(transformation(extent={{100,0},{80,20}})));
  Utilities.IO.SignalExchange.Read reaTSup(description="Supply water temperature to emission system",
      y(unit="K")) "Read supply water temperature to emission system"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  Utilities.IO.SignalExchange.Read reaTRet(description="Return water temperature from emission system",
      y(unit="K")) "Read return water temperature from emission system"
    annotation (Placement(transformation(extent={{100,-60},{120,-40}})));
  Utilities.IO.SignalExchange.Read reaCOP(description="Heat pump COP", y(unit=
          "1")) "Read heat pump COP"
    annotation (Placement(transformation(extent={{200,-60},{220,-40}})));
  Modelica.Blocks.Sources.RealExpression heaPumCOP(y=heaPum.com.COP)
    "Substracts heat pump COP"
    annotation (Placement(transformation(extent={{160,-60},{180,-40}})));
  Fluid.Sources.OutsideAir outAir(redeclare package Medium = MediumAir,
                                  nPorts=2) "Outside air"
    annotation (Placement(transformation(extent={{260,0},{240,20}})));
  Modelica.Blocks.Math.RealToInteger realToInteger2
    annotation (Placement(transformation(extent={{252,100},{272,120}})));
  Utilities.IO.SignalExchange.Overwrite oveFan(u(
      min=0,
      max=1,
      unit="1"), description="Integer signal to control the stage of the fan either on or off")
    "Block for overwriting fan control signal" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={202,110})));
  Utilities.IO.SignalExchange.Read reaFan(description="Control signal for fan",
      y(unit="1")) "Read control signal for fan"
    annotation (Placement(transformation(extent={{222,100},{242,120}})));
  Modelica.Blocks.Sources.RealExpression yFan(y=if heaPum.com.isOn then 1 else 0)
    "Control input signal to fan"
    annotation (Placement(transformation(extent={{160,100},{180,120}})));
  Fluid.Movers.FlowControlled_dp fan(
    redeclare package Medium = MediumAir,
    massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    inputType=IDEAS.Fluid.Types.InputType.Stages,
    use_inputFilter=false,
    dp_nominal=100,
    m_flow_nominal=3,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState)
    "Fan to pump air through heat exchanger"
    annotation (Placement(transformation(extent={{220,30},{200,50}})));
  Utilities.IO.SignalExchange.Read reaPFan(
    description=
        "Electrical power of the fan insuflating air through the heat exchanger",
    KPIs=IDEAS.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
    y(unit="W"))
    "Block for reading the electrical power of the fan insuflating air through the heat exchanger"
    annotation (Placement(transformation(extent={{220,70},{240,90}})));

  Modelica.Blocks.Math.Add addUno
    annotation (Placement(transformation(extent={{-160,40},{-140,60}})));
  Modelica.Blocks.Sources.Constant offSetUno(k=4.5, y(unit="K"))
    "Offset above heating temperature setpoint during unoccupied hours to ensure comfort"
    annotation (Placement(transformation(extent={{-200,60},{-180,80}})));
  Modelica.Blocks.Logical.Greater greater
    annotation (Placement(transformation(extent={{-80,100},{-60,80}})));
  Modelica.Blocks.Logical.Switch switch1(y(unit="K"))
    annotation (Placement(transformation(extent={{-20,140},{0,160}})));
  Modelica.Blocks.Sources.Constant const(k=0)
    annotation (Placement(transformation(extent={{-114,110},{-94,130}})));
equation
  connect(case900Template.ppm, reaCO2RooAir.u) annotation (Line(points={{-59,10},
          {-54,10},{-54,-50},{-58,-50}},
                                    color={0,0,127}));
  connect(oveTSetCoo.y, reaTSetCoo.u)
    annotation (Line(points={{-159,10},{-142,10}}, color={0,0,127}));
  connect(oveTSetHea.y, reaTSetHea.u)
    annotation (Line(points={{-159,-30},{-142,-30}},
                                                   color={0,0,127}));
  connect(TSetCoo.y, oveTSetCoo.u)
    annotation (Line(points={{-199,10},{-182,10}},   color={0,0,127}));
  connect(TSetHea.y, oveTSetHea.u)
    annotation (Line(points={{-199,-30},{-182,-30}}, color={0,0,127}));
  connect(ovePum.y, reaPum.u)
    annotation (Line(points={{13,110},{20,110}}, color={0,0,127}));
  connect(realToInteger.u, reaPum.y)
    annotation (Line(points={{50,110},{43,110}}, color={0,0,127}));
  connect(yOcc.y, case900Template.yOcc) annotation (Line(points={{-59,40},{-52,
          40},{-52,14},{-58,14}},
                              color={0,0,127}));
  connect(senTemSup.port_b, pum.port_a)
    annotation (Line(points={{60,40},{40,40}}, color={0,127,255}));
  connect(bouWat.ports[1], pum.port_a)
    annotation (Line(points={{50,20},{50,40},{40,40}}, color={0,127,255}));
  connect(heaPum.port_b1,senTemSup.port_a)  annotation (Line(points={{124,20},{124,
          40},{80,40}},               color={0,127,255}));
  connect(senTemRet.port_a,heaPum. port_a1) annotation (Line(points={{80,-20},{124,
          -20},{124,0}},        color={0,127,255}));
  connect(case900Template.gainEmb[1], floHea.heatPortEmb[1]) annotation (Line(
        points={{-60,1},{-40,1},{-40,20},{-10,20}},          color={191,0,0}));
  connect(pum.port_b, floHea.port_a)
    annotation (Line(points={{20,40},{0,40},{0,10}}, color={0,127,255}));
  connect(floHea.port_b, senTemRet.port_b)
    annotation (Line(points={{-20,10},{-20,-20},{60,-20}},color={0,127,255}));
  connect(pum.P, reaPPumEmi.u)
    annotation (Line(points={{19,49},{0,49},{0,80},{18,80}}, color={0,0,127}));
  connect(reaHeaPumY.y, heaPum.y) annotation (Line(points={{141,150},{292,150},
          {292,-24},{127,-24},{127,-2}},
                                    color={0,0,127}));
  connect(yPum.y, ovePum.u)
    annotation (Line(points={{-19,110},{-10,110}}, color={0,0,127}));
  connect(realToInteger.y, pum.stage) annotation (Line(points={{73,110},{80,110},
          {80,60},{30,60},{30,52}}, color={255,127,0}));
  connect(heaPum.P, reaPHeaPum.u)
    annotation (Line(points={{130,21},{130,80},{138,80}}, color={0,0,127}));
  connect(case900Template.TSensor, reaTZon.u) annotation (Line(points={{-60,13},
          {-46,13},{-46,80},{-34,80}}, color={0,0,127}));
  connect(floHea.QTot, reaQFloHea.u) annotation (Line(points={{-21,16},{-32,16},
          {-32,-50},{-22,-50}},
                           color={0,0,127}));
  connect(heaPum.QEva_flow, reaQHeaPumEva.u) annotation (Line(points={{139,21},{
          139,28},{150,28},{150,10},{158,10}}, color={0,0,127}));
  connect(heaPum.QCon_flow, reaQHeaPumCon.u) annotation (Line(points={{121,21},{
          121,28},{110,28},{110,10},{102,10}}, color={0,0,127}));
  connect(reaTSup.u, senTemSup.T) annotation (Line(points={{98,80},{90,80},{90,26},
          {70,26},{70,29}}, color={0,0,127}));
  connect(senTemRet.T, reaTRet.u)
    annotation (Line(points={{70,-31},{70,-50},{98,-50}}, color={0,0,127}));
  connect(heaPumCOP.y, reaCOP.u)
    annotation (Line(points={{181,-50},{198,-50}}, color={0,0,127}));
  connect(oveFan.y, reaFan.u)
    annotation (Line(points={{213,110},{220,110}}, color={0,0,127}));
  connect(realToInteger2.u, reaFan.y)
    annotation (Line(points={{250,110},{243,110}}, color={0,0,127}));
  connect(yFan.y, oveFan.u)
    annotation (Line(points={{181,110},{190,110}}, color={0,0,127}));
  connect(fan.port_a, outAir.ports[1])
    annotation (Line(points={{220,40},{240,40},{240,12}},color={0,127,255}));
  connect(realToInteger2.y, fan.stage) annotation (Line(points={{273,110},{280,110},
          {280,60},{210,60},{210,52}}, color={255,127,0}));
  connect(fan.P, reaPFan.u) annotation (Line(points={{199,49},{190,49},{190,80},
          {218,80}}, color={0,0,127}));
  connect(offSetOcc.y, addOcc.u1) annotation (Line(points={{-179,152},{-170,152},
          {-170,136},{-162,136}}, color={0,0,127}));
  connect(offSetUno.y, addUno.u1) annotation (Line(points={{-179,70},{-172,70},
          {-172,56},{-162,56}}, color={0,0,127}));
  connect(oveTSetHea.y, addOcc.u2) annotation (Line(points={{-159,-30},{-154,
          -30},{-154,-50},{-228,-50},{-228,124},{-162,124}}, color={0,0,127}));
  connect(oveTSetHea.y, addUno.u2) annotation (Line(points={{-159,-30},{-154,
          -30},{-154,-50},{-228,-50},{-228,44},{-162,44}}, color={0,0,127}));
  connect(oveHeaPumY.y, reaHeaPumY.u)
    annotation (Line(points={{101,150},{118,150}}, color={0,0,127}));
  connect(greater.y, switch1.u2) annotation (Line(points={{-59,90},{-52,90},{
          -52,150},{-22,150}}, color={255,0,255}));
  connect(case900Template.TSensor, conPI.u_m) annotation (Line(points={{-60,13},
          {-46,13},{-46,130},{30,130},{30,138}}, color={0,0,127}));
  connect(conPI.y, oveHeaPumY.u)
    annotation (Line(points={{41,150},{78,150}}, color={0,0,127}));
  connect(switch1.y, conPI.u_s)
    annotation (Line(points={{1,150},{18,150}}, color={0,0,127}));
  connect(addOcc.y, switch1.u1) annotation (Line(points={{-139,130},{-128,130},
          {-128,158},{-22,158}}, color={0,0,127}));
  connect(addUno.y, switch1.u3) annotation (Line(points={{-139,50},{-120,50},{
          -120,142},{-22,142}}, color={0,0,127}));
  connect(const.y, greater.u2) annotation (Line(points={{-93,120},{-90,120},{
          -90,98},{-82,98}}, color={0,0,127}));
  connect(yOcc.y, greater.u1) annotation (Line(points={{-59,40},{-52,40},{-52,
          60},{-100,60},{-100,90},{-82,90}}, color={0,0,127}));
  connect(outAir.ports[2], heaPum.port_b2) annotation (Line(points={{240,8},{240,
          -20},{136,-20},{136,0}}, color={0,127,255}));
  connect(heaPum.port_a2, fan.port_b)
    annotation (Line(points={{136,20},{136,40},{200,40}}, color={0,127,255}));
  annotation (
    experiment(
      StopTime=1728000,
      __Dymola_NumberOfIntervals=5000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Lsodar"),
    Documentation(info="<html>
<p>
This is a single zone residential hydronic system model with an air-source 
heat pump and floor heating for WP 1.2 of IBPSA project 1. 
</p>
<h3>Building Design and Use</h3>
<h4>Architecture</h4>
<p>
This model represents a simplified residential dwelling for a family of 5 members. 
The building envelope model is based on the BESTEST case 900 test case. 
The envelope model is therefore similar to the one used in 
<a href=\"modelica://IDEAS.Examples.IBPSA.SingleZoneResidentialHydronic\">
IDEAS.Examples.IBPSA.SingleZoneResidentialHydronic</a> 
but it is scaled to an area that is 5 times larger. Particularly, the model consists 
of a single zone with a rectangular floor plan of 13.4 by 17.9 meters and a 
height of 2.7 m. The zone further consists of several south-oriented windows, 
which are modelled using a single window of 24 m2.
</p>
<h4>Constructions</h4>
<p><b>Exterior walls</b> </p>
<p>
The walls are modeled using 
<a href=\"modelica://IDEAS.Buildings.Components.OuterWall\">
IDEAS.Buildings.Components.OuterWall</a> and consist of the following layers:
</p>
<table cellspacing=\"2\" cellpadding=\"0\" border=\"0\" summary=\"Layers\">
<tr>
<td><p align=\"center\"><h4>Name</h4></p></td>
<td><p align=\"center\"><h4>Thickness [m]</h4></p></td>
<td><p align=\"center\"><h4>Thermal Conductivity [W/m-K]</h4></p></td>
<td><p align=\"center\"><h4>Specific Heat Capacity [J/kg-K]</h4></p></td>
<td><p align=\"center\"><h4>Density [kg/m3]</h4></p></td>
</tr>
<tr>
<td><p>Layer 1 (wood siding)</p></td>
<td><p>0.009</p></td>
<td><p>0.14</p></td>
<td><p>900</p></td>
<td><p>530</p></td>
</tr>
<tr>
<td><p>Layer 2 (insulation)</p></td>
<td><p>0.0615</p></td>
<td><p>0.04</p></td>
<td><p>1400</p></td>
<td><p>10</p></td>
</tr>
<tr>
<td><p>Layer 3 (concrete)</p></td>
<td><p>0.1</p></td>
<td><p>0.51</p></td>
<td><p>1000</p></td>
<td><p>1400</p></td>
</tr>
</table>
<p><b>Floor</b> </p>
<p>
The floor is modeled using 
<a href=\"modelica://IDEAS.Buildings.Components.SlabOnGround\">
IDEAS.Buildings.Components.SlabOnGround</a> and consists of the following layers: 
</p>
<table cellspacing=\"2\" cellpadding=\"0\" border=\"0\" summary=\"Layers\">
<tr>
<td><p align=\"center\"><h4>Name</h4></p></td>
<td><p align=\"center\"><h4>Thickness [m]</h4></p></td>
<td><p align=\"center\"><h4>Thermal Conductivity [W/m-K]</h4></p></td>
<td><p align=\"center\"><h4>Specific Heat Capacity [J/kg-K]</h4></p></td>
<td><p align=\"center\"><h4>Density [kg/m3]</h4></p></td>
</tr>
<tr>
<td><p>Layer 1 (roof deck)</p></td>
<td><p>0.019</p></td>
<td><p>0.14</p></td>
<td><p>900</p></td>
<td><p>530</p></td>
</tr>
<tr>
<td><p>Layer 2 (insulation)</p></td>
<td><p>0.20</p></td>
<td><p>0.02</p></td>
<td><p>1470</p></td>
<td><p>30</p></td>
</tr>
<tr>
<td><p>Layer 3 (screed)</p></td>
<td><p>0.05</p></td>
<td><p>0.6</p></td>
<td><p>840</p></td>
<td><p>1100</p></td>
</tr>
<tr>
<td><p>Layer 4 (tile)</p></td>
<td><p>0.01</p></td>
<td><p>1.4</p></td>
<td><p>840</p></td>
<td><p>2100</p></td>
</tr>
</table>
<p><b>Roof</b> </p>
<p>
The roof is modeled using 
<a href=\"modelica://IDEAS.Buildings.Components.OuterWall\">
IDEAS.Buildings.Components.OuterWall</a> and consist of the following layers:
</p>
<table cellspacing=\"2\" cellpadding=\"0\" border=\"0\" summary=\"Layers\">
<tr>
<td><p align=\"center\"><h4>Name</h4></p></td>
<td><p align=\"center\"><h4>Thickness [m]</h4></p></td>
<td><p align=\"center\"><h4>Thermal Conductivity [W/m-K]</h4></p></td>
<td><p align=\"center\"><h4>Specific Heat Capacity [J/kg-K]</h4></p></td>
<td><p align=\"center\"><h4>Density [kg/m3]</h4></p></td>
</tr>
<tr>
<td><p>Layer 1 (wood siding)</p></td>
<td><p>0.009</p></td>
<td><p>0.14</p></td>
<td><p>900</p></td>
<td><p>530</p></td>
</tr>
<tr>
<td><p>Layer 2 (fiber glass)</p></td>
<td><p>0.1118</p></td>
<td><p>0.04</p></td>
<td><p>840</p></td>
<td><p>12</p></td>
</tr>
<tr>
<td><p>Layer 3 (plaster board)</p></td>
<td><p>0.01</p></td>
<td><p>0.16</p></td>
<td><p>840</p></td>
<td><p>950</p></td>
</tr>
</table>
<h4>Occupancy schedules</h4>
<p>
The zone is occupied by 5 people before 7 am and after 8 pm each weekday and 
full time during weekends. 
</p>
<h4>Internal loads and schedules</h4>
<p>
There are no internal loads other than the occupants. 
</p>

<h4>Climate data</h4>
<p>
The model uses a climate file containing one year of weather data for Uccle, 
Belgium. 
</p>

<h3>HVAC System Design</h3>
<h4>Primary and secondary system designs</h4>
<p>
An air-to-water modulating heat pump of 15 kW nominal heating capacity 
extracts energy from the ambient air to heat up the floor heating emission 
system. A fan blows ambient air through the heat pump evaporator 
when the heat pump is operating.
The floor heating system injects heat between 
Layer 2 (insulation) and Layer 3 (screed), with water as 
working fluid. The floor heating mass flow rate is 0.5 kg/s when the heat pump 
is working. 
</p>

<h4>Equipment specifications and performance maps</h4>
<p><b>Heat pump</b> </p>
<p>
A water-to-air heat pump with a scroll compressor is used. 
The heat pump is modeled as described by: 
</p>
<p>
H. Jin. <i>Parameter estimation based models of water source heat pumps. 
</i>PhD Thesis. Oklahoma State University. Stillwater, Oklahoma, USA. 2012. 
</p>
<p>
with air instead of water blowing through the evaporator. Air condensation is
therefore neglected. The model parameters are obtained by calibration of the heat pump model to manufacturer 
performance data following the procedure explained in
<a href=\"https://simulationresearch.lbl.gov/modelica/releases/latest/help/Buildings_Fluid_HeatPumps_Calibration.html\">
this heat pump calibration guide</a>
using manufacturer performance data from a Carrier air-to-water heat pump model 30AW015. 
</p>
<p>
Variable heat pump compressor speed is achieved by multiplying the full load suction volume flow rate by the 
normalized compressor speed. The power and heat transfer rates are forced to zero if the 
resulting heat pump state has higher evaporating pressure than condensing pressure. 
</p>
<p>
Parameters <code>TConMax</code> and 
<code>TEvaMin</code> are used to set an upper and lower bound for the condenser 
and evaporator temperatures. The compressor is disabled when these operating conditions are exceeded, or when the evaporator 
temperature is larger than the condenser temperature. This mimics the temperature protection of the heat pump. 
</p>
<p>
The compression process is assumed isentropic. The thermal energy of superheating is ignored in the evaluation 
of the heat transferred to the refrigerant in the evaporator. There is no supercooling. 
</p>

<p><b>Fluid movers</b> </p>
<p>
The floor heating system circulation pump  
has the default efficiency of the pump model, which is 49 % at the time of writing. 
Also the fan that blows ambient air through the heat exchanger uses this default efficiency 
of 49 %.
</p>

<h4>Rule-based or local-loop controllers (if included)</h4>
<p>
A baseline controller is implemented to procure comfort within the building zone. 
A PI controller is tuned with the indoor air temperature as the controlled variable 
and the heat pump modulation signal for compressor frequency as the control variable. 
The control variable is limited between 0 and 1, and it is computed to drive the indoor 
temperature towards a reference defined as the heating comfort set-point plus an offset 
which varies depending on the occupancy schedule: during occupied periods the offset is 
set to only 0.2 degrees Celsius and is meant to avoid discomfort from slight oscilations 
around the set-point; during unoccupied periods the offset is set to 4.5 degrees Celsius 
and is meant to compensate for the large temperature setback used during these periods. 
The latter offset prevents the need of abrubpt changes in the indoor temperature that may not 
be achievable because of the large thermal inertia of the floor heating system and 
which would consequently cause importante levels of discomfort. All other equipment 
(fan for the heat pump evaporator circuit and floor heating emission system pump) 
are slaves of the heat pump functioning, i.e. they are switched on when the heat pump 
is working (modulating signal higher than 0) and switched off otherwise. 
</p>
<h3>Model IO's</h3>
<h4>Inputs</h4>
<p>The model inputs are: </p>
<ul>
<li>
<code>oveTSetHea_u</code> [K] [min=288.15, max=296.15]: Zone temperature setpoint for heating
</li>
<li>
<code>oveTSetCoo_u</code> [K] [min=296.15, max=303.15]: Zone temperature setpoint for cooling
</li>
<li>
<code>ovePum_u</code> [1] [min=0.0, max=1.0]: Integer signal to control the stage of the emission circuit pump either on or off
</li>
<li>
<code>oveHeaPumY_u</code> [1] [min=0.0, max=1.0]: Heat pump modulating signal between 0 (not working) and 1 (working at maximum capacity)
</li>
<li>
<code>oveFan_u</code> [1] [min=0.0, max=1.0]: Integer signal to control the stage of the fan either on or off
</li>
</ul>
<h4>Outputs</h4>
<p>The model outputs are: </p>
<ul>
<li>
<code>reaQFloHea_y</code> [W] [min=None, max=None]: Floor heating thermal power released to the zone
</li>
<li>
<code>reaCOP_y</code> [1] [min=None, max=None]: Heat pump COP
</li>
<li>
<code>reaTZon_y</code> [K] [min=None, max=None]: Operative zone temperature
</li>
<li>
<code>reaTSetHea_y</code> [K] [min=None, max=None]: Zone air temperature setpoint for heating
</li>
<li>
<code>reaPFan_y</code> [W] [min=None, max=None]: Electrical power of the fan insuflating air through the heat exchanger
</li>
<li>
<code>reaFan_y</code> [1] [min=None, max=None]: Control signal for fan
</li>
<li>
<code>reaCO2RooAir_y</code> [ppm] [min=None, max=None]: CO2 concentration in the zone
</li>
<li>
<code>reaPum_y</code> [1] [min=None, max=None]: Control signal for emission cirquit pump
</li>
<li>
<code>reaPPumEmi_y</code> [W] [min=None, max=None]: Emission circuit pump electrical power
</li>
<li>
<code>reaQHeaPumCon_y</code> [W] [min=None, max=None]: Heat pump thermal power exchanged in the condenser
</li>
<li>
<code>reaHeaPumY_y</code> [1] [min=None, max=None]: Block for reading the heat pump modulating signal
</li>
<li>
<code>reaPHeaPum_y</code> [W] [min=None, max=None]: Heat pump electrical power
</li>
<li>
<code>reaTSetCoo_y</code> [K] [min=None, max=None]: Zone air temperature setpoint for cooling
</li>
<li>
<code>reaQHeaPumEva_y</code> [W] [min=None, max=None]: Heat pump thermal power exchanged in the evaporator
</li>
<li>
<code>reaTRet_y</code> [K] [min=None, max=None]: Return water temperature from emission system
</li>
<li>
<code>reaTSup_y</code> [K] [min=None, max=None]: Supply water temperature to emission system
</li>

</ul>
<h3>Additional System Design</h3>
<h4>Lighting</h4>
<p>
No lighting model is included. 
</p>
<h4>Shading</h4>
<p>
No shading model is included. 
</p>
<h3>Model Implementation Details</h3>
<h4>Moist vs. dry air</h4>
<p>
The model uses moist air despite that no condensation is modelled in any of the used components. 
</p>
<h4>Pressure-flow models</h4>
<p>
A simple, single circulation loop is used to model the floor heating system 
as well as the air circulation through the heat pump evaporator. 
</p>
<h4>Infiltration models</h4>
<p>
Fixed air infiltration corresponding to an n50 value of 10 is modelled. 
</p>
<h3>Scenario Information</h3>
<p><b>Energy Pricing</b> </p>
<p>
The <b>Constant Electricity Price</b> profile is: 
</p>
<p>
The constant electricity price scenario uses a constant price of 0.0535 EUR/kWh, 
as obtained from the &quot;Easy Indexed&quot; deal for electricity (normal rate) in 
<a href=\"https://www.energyprice.be/products-list/Engie\">
https://www.energyprice.be/products-list/Engie</a> (accessed on June 2020). 
</p>
<p>
The <b>Dynamic Electricity Price</b> profile is: 
</p>
<p>
The dynamic electricity price scenario uses a dual rate of 0.0666 EUR/kWh during 
day time and 0.0383 EUR/kWh during night time, as obtained from the &quot;Easy Indexed&quot; 
deal for electricity (dual rate) in <a href=\"https://www.energyprice.be/products-list/Engie\">
https://www.energyprice.be/products-list/Engie</a> (accessed on June 2020). 
The on-peak daily period takes place between 7:00 a.m. and 10:00 p.m. 
The off-peak daily period takes place between 10:00 p.m. and 7:00 a.m. 
</p>
<p>
The <b>Highly Dynamic Electricity Price</b> profile is: 
</p>
<p>
The highly dynamic electricity price scenario is based on the the Belgian day-ahead 
energy prices as determined by the BELPEX wholescale electricity market in the year 2019. 
Obtained from: <a href=\"https://my.elexys.be/MarketInformation/SpotBelpex.aspx\">
https://my.elexys.be/MarketInformation/SpotBelpex.aspx</a> 
</p>
<p>
The <b>Gas Price</b> profile is: 
</p>
<p>
The gas price is assumed constant and equal to 0.0198 EUR/kWh as obtained from the 
&quot;Easy Indexed&quot; deal for gas <a href=\"https://www.energyprice.be/products-list/Engie\">
https://www.energyprice.be/products-list/Engie</a> (accessed on June 2020). 
</p>
<h4>Emission Factors</h4>
<p>
The <b>Electricity Emissions Factor</b> profile is: 
</p>
<p>
It is used a constant emission factor for electricity of 0.167 kgCO2/kWh, 
which is the grid electricity emission factor reported by the Association of Issuing Bodies 
(AIB) for year 2018. For reference, see: 
<a href=\"https://www.carbonfootprint.com/docs/2019_06_emissions_factors_sources_for_2019_electricity.pdf\">
https://www.carbonfootprint.com/docs/2019_06_emissions_factors_sources_for_2019_electricity.pdf</a> 
</p>
<p>The <b>Gas Emissions Factor</b> profile is: </p>
<p>
Based on the kgCO2 emitted per amount of natural gas burned in terms of energy content. 
It is 0.18108 kgCO2/kWh (53.07 kgCO2/milBTU). For reference, see: 
<a href=\"https://www.eia.gov/environment/emissions/co2_vol_mass.php\">
https://www.eia.gov/environment/emissions/co2_vol_mass.php</a> 
</p>
</html>", revisions="<html>
<ul>
<li>
July 15, 2020 by Filip Jorissen:<br/>
Review and documentation revisions.
</li>
<li>
July 14, 2020 by Javier Arroyo:<br/>
Use calibrated air-to-water heat pump model. 
</li>
<li>
June 16, 2020 by Javier Arroyo:<br/>
First implementation. 
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(extent={{-240,-80},{300,180}}, preserveAspectRatio=
           false)),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}, preserveAspectRatio=
            false)));
end SingleZoneResidentialHydronicHeatPump;
