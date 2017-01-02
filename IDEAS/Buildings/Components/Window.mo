within IDEAS.Buildings.Components;
model Window "Multipane window"
  replaceable IDEAS.Buildings.Data.Glazing.Ins2 glazing
    constrainedby IDEAS.Buildings.Data.Interfaces.Glazing "Glazing type"
    annotation (__Dymola_choicesAllMatching=true, Dialog(group=
          "Construction details"));

  extends IDEAS.Buildings.Components.Interfaces.PartialSurface(
    dT_nominal_a=-3,
    intCon_a(final A=
           A*(1 - frac),
           linearise=linIntCon_a or sim.linearise,
           dT_nominal=dT_nominal_a),
    QTra_design(fixed=false),
    Qgai(y=-(propsBus_a.surfCon.Q_flow +
        propsBus_a.surfRad.Q_flow + propsBus_a.iSolDif.Q_flow + propsBus_a.iSolDir.Q_flow)),
    E(y=0),
    layMul(
      A=A*(1 - frac),
      nLay=glazing.nLay,
      mats=glazing.mats,
      energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      dT_nom_air=5,
      linIntCon=true));
  parameter Boolean linExtCon=sim.linExtCon
    "= true, if exterior convective heat transfer should be linearised (uses average wind speed)"
    annotation(Dialog(tab="Convection"));
  parameter Boolean linExtRad=sim.linExtRad
    "= true, if exterior radiative heat transfer should be linearised"
    annotation(Dialog(tab="Radiation"));

  parameter Modelica.SIunits.Area A "Total window and windowframe area";
  parameter Real frac(
    min=0,
    max=1) = 0.15 "Area fraction of the window frame";
  parameter IDEAS.Buildings.Components.Interfaces.WindowDynamicsType
    windowDynamicsType=IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.Two
    "Type of dynamics for glazing and frame: using zero, one combined or two states"
    annotation (Dialog(tab="Dynamics"));
  parameter Real fraC = if windowDynamicsType == IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.Two and fraType.present then frac else 0
    "Fraction of thermal mass C that is attributed to frame"
    annotation(Dialog(tab="Dynamics", enable=windowDynamicsType == IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.Two));

  replaceable IDEAS.Buildings.Components.ThermalBridges.LineLosses briType constrainedby
    IDEAS.Buildings.Components.ThermalBridges.BaseClasses.ThermalBridge
    "Thermal bridge of window edge" annotation (__Dymola_choicesAllMatching=true, Dialog(group=
          "Construction details"));

  replaceable IDEAS.Buildings.Data.Frames.None fraType
    constrainedby IDEAS.Buildings.Data.Interfaces.Frame "Window frame type"
    annotation (__Dymola_choicesAllMatching=true, Dialog(group=
          "Construction details"));
  replaceable IDEAS.Buildings.Components.Shading.None shaType constrainedby
    Shading.Interfaces.PartialShading(
                            final azi=azi) "First shading type"  annotation (Placement(transformation(extent={{-50,-60},
            {-40,-40}})),
      __Dymola_choicesAllMatching=true, Dialog(group="Construction details"));

  Modelica.Blocks.Interfaces.RealInput Ctrl if shaType.controlled
    "Control signal between 0 and 1, i.e. 1 is fully closed" annotation (
      Placement(transformation(
        extent={{20,-20},{-20,20}},
        rotation=-90,
        origin={-50,-110}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-40,-100})));

  Modelica.Thermal.HeatTransfer.Components.ThermalConductor theBri(final G=briType.G) if
       briType.present "Themal bridge of the window perimeter"
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));


protected
  final parameter Real U_value=glazing.U_value*(1-frac)+fraType.U_value*frac
    "Window U-value";

  IDEAS.Buildings.Components.BaseClasses.ConvectiveHeatTransfer.ExteriorConvection
    eCon(final A=A*(1 - frac), linearise=linExtCon or sim.linearise)
    "convective surface heat transimission on the exterior side of the wall"
    annotation (Placement(transformation(extent={{-20,-38},{-40,-18}})));

  IDEAS.Buildings.Components.BaseClasses.RadiativeHeatTransfer.ExteriorHeatRadiation
    skyRad(final A=A*(1 - frac), Tenv_nom=sim.Tenv_nom,
    linearise=linExtRad or sim.linearise)
    "determination of radiant heat exchange with the environment and sky"
    annotation (Placement(transformation(extent={{-20,-10},{-40,10}})));
  replaceable
  IDEAS.Buildings.Components.BaseClasses.RadiativeHeatTransfer.SwWindowResponse
    solWin(
    final nLay=glazing.nLay,
    final SwAbs=glazing.SwAbs,
    final SwTrans=glazing.SwTrans,
    final SwTransDif=glazing.SwTransDif,
    final SwAbsDif=glazing.SwAbsDif)
    annotation (Placement(transformation(extent={{-10,-60},{10,-40}})));

  IDEAS.Buildings.Components.BaseClasses.ConvectiveHeatTransfer.InteriorConvection
    iConFra(final A=A*frac, final inc=inc,
    linearise=linIntCon_a or sim.linearise) if
                        fraType.present
    "convective surface heat transimission on the interior side of the wall"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  IDEAS.Buildings.Components.BaseClasses.RadiativeHeatTransfer.ExteriorHeatRadiation
    skyRadFra(final A=A*frac, Tenv_nom=sim.Tenv_nom,
    linearise=linExtRad or sim.linearise) if
                         fraType.present
    "determination of radiant heat exchange with the environment and sky"
    annotation (Placement(transformation(extent={{-20,80},{-40,100}})));
  IDEAS.Buildings.Components.BaseClasses.ConvectiveHeatTransfer.ExteriorConvection
    eConFra(final A=A*frac, linearise=linExtCon or sim.linearise) if
                 fraType.present
    "convective surface heat transimission on the exterior side of the wall"
    annotation (Placement(transformation(extent={{-20,60},{-40,80}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor layFra(final G=
        fraType.U_value*A*frac) if fraType.present  annotation (Placement(transformation(extent={{10,70},
            {-10,90}})));

  BoundaryConditions.SolarIrradiation.RadSolData radSolData(
    inc=inc,
    azi=azi,
    lat=sim.lat,
    outputAngles=sim.outputAngles,
    incAndAziInBus=sim.incAndAziInBus,
    numIncAndAziInBus=sim.numIncAndAziInBus)
    annotation (Placement(transformation(extent={{-100,-60},{-80,-40}})));
  Modelica.Blocks.Math.Gain gainDir(k=A*(1 - frac))
    annotation (Placement(transformation(extent={{-70,-34},{-62,-26}})));
  Modelica.Blocks.Math.Gain gainDif(k=A*(1 - frac))
    annotation (Placement(transformation(extent={{-70,-46},{-62,-38}})));
  Modelica.Blocks.Routing.RealPassThrough Tdes
    "Design temperature passthrough since propsBus variables cannot be addressed directly";
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heaCapGla(
     C=Cgla, T(fixed=true, start=T_start)) if addCapGla
    "Heat capacitor for glazing"
    annotation (Placement(transformation(extent={{6,-12},{26,-32}})));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heaCapFra(
     C=Cfra, T(fixed=true, start=T_start)) if addCapFra
    "Heat capacitor for frame"
    annotation (Placement(transformation(extent={{6,88},{26,108}})));

protected
  final parameter Boolean addCapGla =  not windowDynamicsType == IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.None;
  final parameter Boolean addCapFra =  fraType.present and windowDynamicsType == IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.Two;

  final parameter Modelica.SIunits.HeatCapacity Cgla = layMul.C*(1- fraC)
    "Heat capacity of glazing state";
  final parameter Modelica.SIunits.HeatCapacity Cfra = layMul.C*fraC
    "Heat capacity of frame state";

initial equation
  QTra_design = (U_value*A + briType.G) *(273.15 + 21 - Tdes.y);




equation
  connect(eCon.port_a, layMul.port_b) annotation (Line(
      points={{-20,-28},{-14,-28},{-14,0},{-10,0}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(skyRad.port_a, layMul.port_b) annotation (Line(
      points={{-20,0},{-10,0}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(solWin.iSolDir, propsBus_a.iSolDir) annotation (Line(
      points={{-2,-60},{-2,-70},{100.1,-70},{100.1,19.9}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(solWin.iSolDif, propsBus_a.iSolDif) annotation (Line(
      points={{2,-60},{2,-70},{100.1,-70},{100.1,19.9}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(solWin.iSolAbs, layMul.port_gain) annotation (Line(
      points={{0,-40},{0,-10}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(layMul.iEpsLw_b, skyRad.epsLw) annotation (Line(
      points={{-10,8},{-14,8},{-14,3.4},{-20,3.4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(shaType.Ctrl, Ctrl) annotation (Line(
      points={{-45,-60},{-50,-60},{-50,-110}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(iConFra.port_b, propsBus_a.surfCon) annotation (Line(
      points={{40,80},{46,80},{46,19.9},{100.1,19.9}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(layFra.port_a, iConFra.port_a) annotation (Line(
      points={{10,80},{20,80}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(skyRadFra.port_a, layFra.port_b) annotation (Line(
      points={{-20,90},{-16,90},{-16,80},{-10,80}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(eConFra.port_a, layFra.port_b) annotation (Line(
      points={{-20,70},{-16,70},{-16,80},{-10,80}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(layMul.iEpsLw_b, skyRadFra.epsLw) annotation (Line(
      points={{-10,8},{-14,8},{-14,93.4},{-20,93.4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.angInc, shaType.angInc) annotation (Line(
      points={{-79.4,-54},{-50,-54}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.angAzi, shaType.angAzi) annotation (Line(
      points={{-79.4,-58},{-50,-58}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.angZen, shaType.angZen) annotation (Line(
      points={{-79.4,-56},{-50,-56}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.weaBus, propsBus_a.weaBus) annotation (Line(
      points={{-80,-42},{-80,20},{0,20},{0,19.9},{100.1,19.9}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(shaType.solDif, gainDif.y) annotation (Line(
      points={{-50,-48},{-56,-48},{-56,-42},{-61.6,-42}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(gainDif.u, radSolData.solDif) annotation (Line(
      points={{-70.8,-42},{-76,-42},{-76,-50},{-79.4,-50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.solDir, gainDir.u) annotation (Line(
      points={{-79.4,-48},{-76,-48},{-76,-30},{-70.8,-30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(gainDir.y, shaType.solDir) annotation (Line(
      points={{-61.6,-30},{-50,-30},{-50,-44}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(radSolData.Tenv, skyRad.Tenv) annotation (Line(
      points={{-79.4,-52},{-54,-52},{-54,10},{-20,10},{-20,6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(skyRadFra.Tenv, skyRad.Tenv) annotation (Line(
      points={{-20,96},{-12,96},{-12,6},{-20,6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eConFra.Te, eCon.Te) annotation (Line(
      points={{-20,65.2},{-20,-32.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eCon.hConExt, eConFra.hConExt) annotation (Line(
      points={{-20,-37},{-20,61}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eCon.Te, propsBus_a.weaBus.Te) annotation (Line(
      points={{-20,-32.8},{100.1,-32.8},{100.1,19.9}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eCon.hConExt, propsBus_a.weaBus.hConExt) annotation (Line(
      points={{-20,-37},{100.1,-37},{100.1,19.9}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(Tdes.u, propsBus_a.weaBus.Tdes);
  connect(shaType.iSolDir, solWin.solDir)
    annotation (Line(points={{-40,-44},{-26,-44},{-10,-44}}, color={0,0,127}));
  connect(shaType.iSolDif, solWin.solDif)
    annotation (Line(points={{-40,-48},{-25,-48},{-10,-48}}, color={0,0,127}));
  connect(shaType.iAngInc, solWin.angInc) annotation (Line(points={{-40,-54},{-26,
          -54},{-26,-56},{-10,-56}},     color={0,0,127}));
  connect(heaCapGla.port, layMul.port_a)
    annotation (Line(points={{16,-12},{16,0},{10,0}},     color={191,0,0}));
  connect(heaCapFra.port, layFra.port_a)
    annotation (Line(points={{16,88},{16,80},{10,80}}, color={191,0,0}));
  if windowDynamicsType == IDEAS.Buildings.Components.Interfaces.WindowDynamicsType.Combined then
    connect(heaCapGla.port, layFra.port_a) annotation (Line(points={{16,-12},{16,
            -12},{16,80},{10,80}},  color={191,0,0}));
  end if;
  connect(theBri.port_b, layFra.port_a) annotation (Line(points={{10,40},{16,40},
          {16,80},{10,80}}, color={191,0,0}));
  connect(theBri.port_a, layMul.port_b) annotation (Line(points={{-10,40},{-14,
          40},{-14,0},{-10,0}},
                            color={191,0,0}));
    annotation (
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-50,-100},{50,100}}),
        graphics={
        Polygon(
          points={{-46,60},{50,24},{50,-50},{-30,-20},{-46,-20},{-46,60}},
          smooth=Smooth.None,
          pattern=LinePattern.None,
          fillColor={255,255,170},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0}),
        Line(
          points={{-50,60},{-30,60},{-30,80},{50,80}},
          color={175,175,175}),
        Line(
          points={{-50,-20},{-30,-20},{-30,-70},{-30,-70},{52,-70}},
          color={175,175,175}),
        Line(
          points={{-50,60},{-50,66},{-50,100},{50,100}},
          color={175,175,175}),
        Line(
          points={{-50,-20},{-50,-90},{50,-90}},
          color={175,175,175}),
        Line(
          points={{-46,60},{-46,-20}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None)}),
    Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},{100,
            100}})),
    Documentation(info="<html>
<p>
This model should be used to model windows or other transparant surfaces.
See <a href=modelica://IDEAS.Buildings.Components.Interfaces.PartialSurface>IDEAS.Buildings.Components.Interfaces.PartialSurface</a> 
for equations, options, parameters, validation and dynamics that are common for all surfaces and windows.
</p>
<h4>Typical use and important parameters</h4>
<p>
Parameter <code>A</code> is the total window surface area, i.e. the
sum of the frame surface area and the glazing surface area.
</p>
<p>
Parameter <code>frac</code> may be used to define the surface
area of the frame as a fraction of <code>A</code>. 
</p>
<p>
Parameter <code>glazing</code>  must be used to define the glass properties.
It contains information about the number of glass layers,
their thickness, thermal properties and emissivity.
</p>
<p>
Optional parameter <code>briType</code> may be used to compute additional line losses
along the edges of the glazing.
</p>
<p>
Optional parameter <code>fraType</code> may be used to define the frame thermal properties.
If <code>fraType = None</code> then the frame is assumed to be perfectly insulating.
</p>
<p>
Optional parameter <code>shaType</code> may be used to define the window shading properties.
</p>
</html>", revisions="<html>
<ul>
<li>
February 10, 2016, by Filip Jorissen and Damien Picard:<br/>
Revised implementation: cleaned up connections and partials.
</li>
<li>
December 17, 2015, Filip Jorissen:<br/>
Added thermal connection between frame and glazing state. 
This is required for decoupling steady state thermal dynamics
without adding a second state for the window.
</li>
<li>
July 14, 2015, Filip Jorissen:<br/>
Removed second shading device since a new partial was created
for handling this.
</li>
<li>
June 14, 2015, Filip Jorissen:<br/>
Adjusted implementation for computing conservation of energy.
</li>
<li>
February 10, 2015 by Filip Jorissen:<br/>
Adjusted implementation for grouping of solar calculations.
</li>
</ul>
</html>"));
end Window;
