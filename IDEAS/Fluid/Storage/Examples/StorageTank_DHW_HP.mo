within IDEAS.Fluid.Storage.Examples;
model StorageTank_DHW_HP
  "Example of a DHW system composed of HP and storage tank"
  import IDEAS;

  extends Modelica.Icons.Example;

  package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater
    annotation (__Dymola_choicesAllMatching=true);

  parameter Integer nbrNodes=10 "Number of nodes in the storage tank";

  Fluid.Storage.StorageTank_OneIntHX storageTank(
    nbrNodes=nbrNodes,
    T_start={273.15 + 60 for i in 1:nbrNodes},
    volumeTank=0.3,
    heightTank=1.6,
    UIns=0.4,
    redeclare package MediumHX = Medium,
    redeclare package Medium = Medium,
    m_flow_nominal=1)
    annotation (Placement(transformation(extent={{-30,-64},{42,10}})));

  Fluid.Domestic_Hot_Water.DHW_RealInput dHW(TDHWSet=273.15 + 45,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{62,8},{82,20}})));
  Fluid.Production.HP_AirWater hP_AWMod(QNom=10000,
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-88,-2},{-68,18}})));
  Fluid.Movers.Pump pump(
    m=1,
    useInput=true,
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-38,-62},{-58,-42}})));
  inner IDEAS.SimInfoManager sim(redeclare IDEAS.Climate.Meteo.Locations.Uccle
      city, redeclare IDEAS.Climate.Meteo.Files.min60 detail)
    annotation (Placement(transformation(extent={{-94,-94},{-74,-74}})));
  IDEAS.Controls.ControlHeating.Ctrl_Heating_TES HPControl(
    dTSafetyTop=3,
    dTHPTankSet=2,
    DHW=true,
    TSupNom=313.15,
    TDHWSet=323.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-82,60})));
  Modelica.Blocks.Sources.Pulse pulse(period=3600, width=10)
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Modelica.Blocks.Sources.SawTooth sawTooth(
    period=1000,
    startTime=30000,
    amplitude=0.15)
    annotation (Placement(transformation(extent={{-10,62},{10,82}})));
  IDEAS.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium = Medium,
    p=300000,
    nPorts=1) annotation (Placement(transformation(extent={{38,-96},{18,-76}})));

  parameter SI.MassFlowRate m_flow_nominal=0.5 "Nominal mass flow rate";
  Modelica.Blocks.Math.Product product
    annotation (Placement(transformation(extent={{36,48},{46,58}})));
equation

  connect(HPControl.THPSet, hP_AWMod.TSet) annotation (Line(
      points={{-78.1111,48.6667},{-78.1111,32},{-79,32},{-79,18}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(storageTank.T[10], HPControl.TTankBot) annotation (Line(
      points={{42,-18.4615},{70,-18.4615},{70,-18},{92,-18},{92,96},{-83.1111,
          96},{-83.1111,69.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(storageTank.T[1], HPControl.TTankTop) annotation (Line(
      points={{42,-18.4615},{92,-18.4615},{92,96},{-78.1111,96},{-78.1111,
          69.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(HPControl.onOff, pump.m_flowSet) annotation (Line(
      points={{-83.1111,48.6667},{-83.1111,40},{-48,40},{-48,-41.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(bou.ports[1], pump.port_a) annotation (Line(
      points={{18,-86},{-38,-86},{-38,-52}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(product.u2, pulse.y) annotation (Line(
      points={{35,50},{24,50},{24,40},{11,40}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(product.u1, sawTooth.y) annotation (Line(
      points={{35,56},{24,56},{24,72},{11,72}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(product.y, dHW.mDHW60C) annotation (Line(
      points={{46.5,53},{62,53},{62,18.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(hP_AWMod.port_b, storageTank.portHXUpper) annotation (Line(
      points={{-68,10.7273},{-52,10.7273},{-52,12},{-30,12},{-30,-41.2308}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(hP_AWMod.port_a, pump.port_b) annotation (Line(
      points={{-68,3.45455},{-66,3.45455},{-66,4},{-58,4},{-58,-52}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storageTank.port_b, dHW.port_cold) annotation (Line(
      points={{42,-58.3077},{64,-58.3077},{64,-58},{82,-58},{82,11.4286}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(storageTank.port_a, dHW.port_hot) annotation (Line(
      points={{42,4.30769},{42,11.4286},{62,11.4286}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pump.port_a, storageTank.portHXLower) annotation (Line(
      points={{-38,-52},{-34,-52},{-34,-52.6154},{-30,-52.6154}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}), graphics),
    experiment(StopTime=86400),
    __Dymola_experimentSetupOutput,
    Documentation(revisions="<html>
<ul>
<li>March 2014 by Filip Jorissen:<br/> 
Annex60 compatibility
</li>
</ul>
</html>"));
end StorageTank_DHW_HP;
