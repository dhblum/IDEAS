within IDEAS.Examples.Tutorial;
model Example5 "New model with 2 coupled zones"
  extends Modelica.Icons.Example;
  package Medium = IDEAS.Media.Air "Air medium";

  parameter Modelica.SIunits.Length l = 8 "Zone length";
  parameter Modelica.SIunits.Length w = 4 "Zone width";
  parameter Modelica.SIunits.Length h = 2.7 "Zone height";

  inner BoundaryConditions.SimInfoManager       sim
    annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
  Buildings.Components.RectangularZoneTemplate rectangularZoneTemplate(
    redeclare package Medium = Medium,
    aziA=IDEAS.Types.Azimuth.N,
    h=h,
    bouTypA=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    bouTypB=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    bouTypD=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypA,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypB,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypC,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypD,
    bouTypC=IDEAS.Buildings.Components.Interfaces.BoundaryType.InternalWall,
    bouTypFlo=IDEAS.Buildings.Components.Interfaces.BoundaryType.InternalWall,
    bouTypCei=IDEAS.Buildings.Components.Interfaces.BoundaryType.External,
    redeclare Buildings.Validation.Data.Constructions.HeavyFloor conTypFlo,
    l=w,
    w=l/2,
    hasWinA=true,
    A_winA=2*1.3,
    redeclare TwinHouses.BaseClasses.Data.Materials.Glazing glazingA)
    "North part of the zone"
    annotation (Placement(transformation(extent={{-10,20},{10,40}})));
  Buildings.Components.RectangularZoneTemplate rectangularZoneTemplate1(
    redeclare package Medium = Medium,
    aziA=IDEAS.Types.Azimuth.N,
    h=h,
    bouTypB=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    bouTypC=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    bouTypD=IDEAS.Buildings.Components.Interfaces.BoundaryType.OuterWall,
    bouTypFlo=IDEAS.Buildings.Components.Interfaces.BoundaryType.InternalWall,
    bouTypCei=IDEAS.Buildings.Components.Interfaces.BoundaryType.External,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypB,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypC,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypD,
    redeclare Buildings.Validation.Data.Constructions.HeavyWall conTypFlo,
    bouTypA=IDEAS.Buildings.Components.Interfaces.BoundaryType.External,
    l=w,
    w=l/2,
    hasWinC=true,
    A_winC=2*1.3,
    redeclare TwinHouses.BaseClasses.Data.Materials.Glazing glazingC)
    "South part of the zone"
    annotation (Placement(transformation(extent={{-10,-40},{10,-20}})));
equation
  connect(rectangularZoneTemplate.proBusFlo, rectangularZoneTemplate.proBusCei)
    annotation (Line(
      points={{0,24},{28,24},{28,36},{-0.2,36}},
      color={255,204,51},
      thickness=0.5));
  connect(rectangularZoneTemplate1.proBusA, rectangularZoneTemplate.proBusC)
    annotation (Line(
      points={{-6,-21},{-6,2},{6.8,2},{6.8,20.2}},
      color={255,204,51},
      thickness=0.5));
  connect(rectangularZoneTemplate1.proBusCei, rectangularZoneTemplate1.proBusFlo)
    annotation (Line(
      points={{-0.2,-24},{28,-24},{28,-36},{0,-36}},
      color={255,204,51},
      thickness=0.5));
end Example5;
