within IDEAS.Thermal.Components.Storage;
model Buoyancy_eqcon "Buoyancy modelled as additional thermal conductivity"

  extends IDEAS.Thermal.Components.Storage.Partial_Buoyancy;

  parameter SI.ThermalConductivity lamBuo=1 "Equivalent thermal conductivity ";

initial equation
  assert(lamBuo <> 1, "Error: lamBuo has to be set to a realistic value");

equation
  for i in 1:nbrNodes-1 loop
    Q_flow[i] = lamBuo * surCroSec * dT[i] / (h/nbrNodes);
  end for;

  annotation (Documentation(info="<html>
<p>
This model outputs a heat flow rate that can be added to fluid volumes
in order to emulate buoyancy during a temperature inversion.
For simplicity, this model does not compute a buoyancy induced mass flow rate,
but rather a heat flow that has the same magnitude as the enthalpy flow
associated with the buoyancy induced mass flow rate.
</p>
</html>", revisions="<html>
<ul>
<li>
October 28, 2008 by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"),
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={
        Rectangle(
          extent={{-44,68},{36,28}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,-26},{36,-66}},
          lineColor={127,0,0},
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{24,10},{30,-22}},
          lineColor={127,0,0},
          pattern=LinePattern.None,
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{26,22},{20,10},{34,10},{34,10},{26,22}},
          lineColor={127,0,0},
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-32,22},{-26,-10}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-28,-18},{-36,-6},{-22,-6},{-22,-6},{-28,-18}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}),
            graphics));
end Buoyancy_eqcon;