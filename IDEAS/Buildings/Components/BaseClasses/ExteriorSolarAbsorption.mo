within IDEAS.Buildings.Components.BaseClasses;
model ExteriorSolarAbsorption
  "shortwave radiation absorption on an exterior surface"

  parameter Modelica.SIunits.Area A "surface area";

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a port_a(T(start=289.15))
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Blocks.Interfaces.RealInput solDir
    "direct solar illuminance on surface se"
    annotation (Placement(transformation(extent={{120,40},{80,80}})));
  Modelica.Blocks.Interfaces.RealInput solDif
    "diffuse solar illuminance on surface s"
    annotation (Placement(transformation(extent={{120,0},{80,40}})));
  Modelica.Blocks.Interfaces.RealInput epsSw
    "shortwave emissivity of the surface"
    annotation (Placement(transformation(extent={{-120,40},{-80,80}})));
equation
port_a.Q_flow = - (solDir + solDif) * epsSw;

  annotation (Icon(graphics={
        Rectangle(
          extent={{-90,80},{-60,-80}},
          fillColor={192,192,192},
          fillPattern=FillPattern.Backward,
          pattern=LinePattern.None),
        Line(
          points={{-60,80},{-60,-80}},
          color={0,0,0},
          thickness=0.5),
        Line(points={{-40,10},{40,10}}, color={191,0,0}),
        Line(points={{-40,10},{-30,16}}, color={191,0,0}),
        Line(points={{-40,10},{-30,4}}, color={191,0,0}),
        Line(points={{-40,-10},{40,-10}}, color={191,0,0}),
        Line(points={{-40,-30},{40,-30}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-24}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-36}}, color={191,0,0}),
        Line(points={{-40,30},{40,30}}, color={191,0,0}),
        Line(points={{-40,30},{-30,36}}, color={191,0,0}),
        Line(points={{-40,30},{-30,24}},color={191,0,0}),
        Line(points={{-40,-10},{-30,-4}},color={191,0,0}),
        Line(points={{-40,-10},{-30,-16}},
                                        color={191,0,0})}));
end ExteriorSolarAbsorption;
