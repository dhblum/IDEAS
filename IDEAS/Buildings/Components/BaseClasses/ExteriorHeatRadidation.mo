within IDEAS.Buildings.Components.BaseClasses;
model ExteriorHeatRadidation
  "longwave radiative heat exchange of an exterior surface with the environment"

  parameter Modelica.SIunits.Area A "surface area";
  parameter Modelica.SIunits.Angle inc "inclination";

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a port_a(T(start=289.15))
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
outer IDEAS.Climate.SimInfoManager sim "Simulation information manager"
    annotation (Placement(transformation(extent={{-100,80},{-80,100}})));

protected
  Real Fse = (1-cos(inc))/2
    "radiant-interchange configuration factor between surface and environment";
  Real Fssky = (1+cos(inc))/2
    "radiant-interchange configuration factor between surface and sky";
  Modelica.SIunits.Temperature Tenv
    "Radiative temperature of the total environment";

public
  Modelica.Blocks.Interfaces.RealInput epsLw
    "shortwave emissivity of the surface"
    annotation (Placement(transformation(extent={{-120,40},{-80,80}})));
equation

Tenv = (Fssky*sim.Tsky^4+(1-Fssky)*sim.Te^4)^0.25;
port_a.Q_flow = A*Modelica.Constants.sigma*epsLw*(port_a.T^4-Tenv^4);

  annotation (Icon(graphics={
        Line(points={{-40,10},{40,10}}, color={191,0,0}),
        Line(points={{-40,10},{-30,16}}, color={191,0,0}),
        Line(points={{-40,10},{-30,4}}, color={191,0,0}),
        Line(points={{-40,-10},{40,-10}}, color={191,0,0}),
        Line(points={{30,-16},{40,-10}}, color={191,0,0}),
        Line(points={{30,-4},{40,-10}}, color={191,0,0}),
        Line(points={{-40,-30},{40,-30}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-24}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-36}}, color={191,0,0}),
        Line(points={{-40,30},{40,30}}, color={191,0,0}),
        Line(points={{30,24},{40,30}}, color={191,0,0}),
        Line(points={{30,36},{40,30}}, color={191,0,0}),
        Rectangle(
          extent={{-90,80},{-60,-80}},
          fillColor={192,192,192},
          fillPattern=FillPattern.Backward,
          pattern=LinePattern.None),
        Line(
          points={{-60,80},{-60,-80}},
          color={0,0,0},
          thickness=0.5),
        Rectangle(
          extent={{90,80},{60,-80}},
          fillColor={192,192,192},
          fillPattern=FillPattern.Backward,
          pattern=LinePattern.None),
        Line(
          points={{60,80},{60,-80}},
          color={0,0,0},
          thickness=0.5)}));
end ExteriorHeatRadidation;
