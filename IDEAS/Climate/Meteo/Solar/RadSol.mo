within IDEAS.Climate.Meteo.Solar;
model RadSol "solar angle to surface"

  extends Modelica.Blocks.Interfaces.BlockIcon;

  parameter Boolean remDefVals = false "Remove default signal values";
  parameter Integer numAzi;
  parameter Modelica.SIunits.Angle inc(displayUnit="degree") "inclination";
  parameter Modelica.SIunits.Angle azi(displayUnit="degree") "azimuth";
  parameter Modelica.SIunits.Angle lat(displayUnit="degree") "latitude";

  BoundaryConditions.WeatherData.Bus weaBus(numSolBus=numAzi + 1)
    annotation (Placement(transformation(extent={{-110,70},{-90,90}})));
  Buildings.Components.Interfaces.SolBus solBus
    annotation (Placement(transformation(extent={{80,-20},{120,20}})));

protected
  BaseClasses.AngleSolar angSolar(
    inc=inc,
    azi=azi,
    lat=lat) annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
  BaseClasses.solDirTil solDirTil(inc=inc)
    annotation (Placement(transformation(extent={{0,20},{20,40}})));
  BaseClasses.Perez
        perez(inc=inc)
    annotation (Placement(transformation(extent={{0,-8},{20,12}})));

  Modelica.Blocks.Sources.Constant dummyVal(k=0) if  not remDefVals
    "Tenv and angInc value when not needed"
    annotation (Placement(transformation(extent={{-20,-100},{0,-80}})));
equation
  connect(angSolar.angInc, solDirTil.angSol) annotation (Line(
      points={{-20,36},{0,36}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angSolar.angDec, weaBus.angDec) annotation (Line(
      points={{-40,36},{-52,36},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angSolar.angHou, weaBus.angHou) annotation (Line(
      points={{-40,32},{-52,32},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(solDirTil.solDirPer, weaBus.solDirPer) annotation (Line(
      points={{0,32.8},{0,34},{-8,34},{-8,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.angInc, angSolar.angInc) annotation (Line(
      points={{0,11},{0,22.5},{-20,22.5},{-20,36}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.angZen, weaBus.angZen) annotation (Line(
      points={{0,7},{-52,7},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.F2, weaBus.F2) annotation (Line(
      points={{0,-1},{-53,-1},{-53,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.F1, weaBus.F1) annotation (Line(
      points={{0,3},{-52,3},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.solGloHor, weaBus.solGloHor) annotation (Line(
      points={{0,-7},{-52,-7},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.solDifHor, weaBus.solDifHor) annotation (Line(
      points={{0,-5},{-52,-5},{-52,80},{-100,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(solDirTil.solDirTil, solBus.iSolDir) annotation (Line(
      points={{20,36},{60,36},{60,0},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.solDifTil, solBus.iSolDif) annotation (Line(
      points={{20,8},{96,8},{96,0},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(angSolar.angInc, solBus.angInc) annotation (Line(
      points={{-20,36},{-18,36},{-18,52},{60,52},{60,0},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(perez.angZen, solBus.angZen) annotation (Line(
      points={{0,7},{-6,7},{-6,0},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dummyVal.y, solBus.Tenv) annotation (Line(
      points={{1,-90},{100,-90},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dummyVal.y, solBus.angAzi) annotation (Line(
      points={{1,-90},{0,-90},{0,-86},{100,-86},{100,0}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),
                      graphics), Icon(graphics={
        Polygon(
          points={{-90,-80},{-40,-40},{40,-40},{90,-80},{-90,-80}},
          lineColor={95,95,95},
          smooth=Smooth.None),
        Polygon(
          points={{16,-46},{22,-72},{-72,-4},{-18,-22},{16,-46}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillPattern=FillPattern.Solid,
          fillColor={175,175,175}),
        Ellipse(
          extent={{88,84},{40,38}},
          lineColor={255,255,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid)}),
    Documentation(revisions="<html>
<ul>
<li>
February 10, 2015 by Filip Jorissen:<br/>
Adjusted implementation for grouping of solar calculations.
</li>
</ul>
</html>"));
end RadSol;
