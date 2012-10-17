within IDEAS;
model SimInfoManager
  "Simulation information manager for handling time and climate data required in each for simulation."

protected
  parameter IDEAS.Climate.Meteo.Files.min60 hourly "Hourly climate data";
  parameter IDEAS.Climate.Meteo.Locations.Uccle Uccle "Uccle, Belgium";
  parameter IDEAS.Occupants.Extern.Interfaces.fromFiles fromFiles
    "Default occupant behavior to be read";
public
  replaceable parameter IDEAS.Climate.Meteo.Detail detail = hourly
    "Timeframe detail of the climate data"   annotation (choicesAllMatching = true,Dialog(group="Climate"));
  replaceable parameter IDEAS.Climate.Meteo.location city = Uccle
    "Location of the depicted climate data"   annotation (choicesAllMatching = true,Dialog(group="Climate"));
  parameter Boolean occBeh = false "true if user behaviour is included"
                                         annotation(Dialog(group="User behaviour"));
  replaceable parameter IDEAS.Occupants.Extern.Interfaces.occupant occupants = fromFiles
    "Occupant behavior" annotation(choicesAllMatching = true,Dialog(group="User behaviour"));
  parameter Integer nOcc = 33 "Number of occupant profiles" annotation(Dialog(group="User behaviour"));

protected
  parameter String filNamClim = "..\\Inputs\\" + city.locNam + detail.filNam;
  parameter Modelica.SIunits.Angle lat(displayUnit="deg") = city.lat
    "latitude of the locatioin";
  parameter Modelica.SIunits.Angle lon(displayUnit="deg") = city.lon;
  parameter Modelica.SIunits.Temperature Tdes = city.Tdes
    "design outdoor temperature";
  parameter Modelica.SIunits.Temperature TdesGround = city.TdesGround
    "design ground temperature";
  parameter Modelica.SIunits.Time timZonSta = city.timZonSta
    "standard time zone";
  parameter Boolean DST = city.DST "take into account daylight saving time";
  parameter Integer yr = city.yr "depcited year for DST only";

  final parameter Boolean BesTest = Modelica.Utilities.Strings.isEqual(city.locNam,"BesTest");

public
  Modelica.SIunits.Irradiance solDirPer
    "direct irradiation on normal to solar zenith";
  Modelica.SIunits.Irradiance solDirHor
    "direct irradiation on horizontal surface";
  Modelica.SIunits.Irradiance solDifHor
    "difuse irradiation on horizontal surface";
  Modelica.SIunits.Irradiance solGloHor = solDirHor + solDifHor
    "global irradiation on horizontal";
  Modelica.SIunits.Temperature Te
    "ambient outdoor temperature for determination of sky radiation exchange";
  Modelica.SIunits.Temperature Tsky "effective overall sky temperature";
  Modelica.SIunits.Temperature TeAv = Te
    "running average of ambient outdoor temperature of the last 5 days, not yet implemented";
  Modelica.SIunits.Temperature Tground = TdesGround "ground temperature";
  Modelica.SIunits.Velocity Va "air velocity";
  Real Fc "cloud factor";
  Modelica.SIunits.Irradiance irr;
  Boolean summer;

  Boolean day = true;

  Real workday;
  Real weekend;

  Modelica.SIunits.Time timLoc;
  Modelica.SIunits.Time timSol;
  Modelica.SIunits.Time timCal;

  IDEAS.BaseClasses.Control.Hyst_NoEvent calcWE(uLow=604800, uHigh=432000)
    "calculation of weekend or workday"
    annotation (Placement(transformation(extent={{-20,26},{-6,40}})));
  IDEAS.BaseClasses.Control.rem_NoEvent remWE(interval=604800)
    annotation (Placement(transformation(extent={{-40,26},{-26,40}})));

protected
  IDEAS.Climate.Time.SimTimes timMan(
    delay=detail.timestep/2,
    timZonSta=timZonSta,
    lon=lon,
    DST=false,
    ifSolCor=true)
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Blocks.Tables.CombiTable1Ds climate_nonSolar(final smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    final tableOnFile=true, final tableName="data",final fileName=filNamClim, final columns = {15,16,12,10})
    annotation (Placement(transformation(extent={{-40,66},{-26,80}})));
  Modelica.Blocks.Tables.CombiTable1Ds climate_solar(
    final tableOnFile=true, final tableName="data",final fileName=filNamClim, final columns = {7,11,14},
    final smoothness=Modelica.Blocks.Types.Smoothness.LinearSegments)
    annotation (Placement(transformation(extent={{-40,46},{-26,60}})));

public
Modelica.Blocks.Tables.CombiTable1Ds tabQCon(
    final smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile = true,
    tableName = "data",
    fileName = "..\\Inputs\\" + occupants.filQCon,
    columns=2:nOcc) if occBeh annotation (Placement(transformation(extent={{-40,-34},
            {-26,-20}})));
Modelica.Blocks.Tables.CombiTable1Ds tabQRad(
    final smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile = true,
    tableName = "data",
    fileName = "..\\Inputs\\" + occupants.filQRad,
    columns=2:nOcc) if occBeh annotation (Placement(transformation(extent={{-36,-38},
            {-22,-24}})));
Modelica.Blocks.Tables.CombiTable1Ds tabPre(
    final smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile = true,
    tableName = "data",
    fileName = "..\\Inputs\\" + occupants.filPres,
    columns=2:nOcc) if occBeh annotation (Placement(transformation(extent={{-40,-14},
            {-26,0}})));
Modelica.Blocks.Tables.CombiTable1Ds tabP(
    final smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile = true,
    tableName = "data",
    fileName = "..\\Inputs\\" + occupants.filP,
    columns=2:nOcc) if occBeh annotation (Placement(transformation(extent={{-40,-58},
            {-26,-44}})));
Modelica.Blocks.Tables.CombiTable1Ds tabQ(
    final smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile = true,
    tableName = "data",
    fileName = "..\\Inputs\\" + occupants.filQ,
    columns=2:nOcc) if occBeh annotation (Placement(transformation(extent={{-36,-62},
            {-22,-48}})));
Modelica.Blocks.Tables.CombiTable1Ds tabDHW(
    final smoothness=Modelica.Blocks.Types.Smoothness.LinearSegments,
    tableOnFile=true,
    tableName="data",
    fileName="..\\Inputs\\" + occupants.filDHW,
    columns=2:nOcc) if occBeh
                            annotation (Placement(transformation(extent={{-40,-82},
            {-26,-68}})));
algorithm
    weekend := calcWE.y;
    workday := 1-calcWE.y;

equation

  solDirPer = climate_solar.y[3];
  solDirHor = climate_solar.y[1]-climate_solar.y[2];
  solDifHor = climate_solar.y[2];
  Te = climate_nonSolar.y[1]+273.15;

  if not BesTest then
    Tsky = Te - (23.8 - 0.2025 * (Te-273.15)*(1-0.87*Fc));
    Fc = 0.2;
    Va = 2.5;
  else
    Tsky = climate_nonSolar.y[2]+273.15;
    Fc = climate_nonSolar.y[3]*0.87;
    Va = climate_nonSolar.y[4];
  end if;

  irr = climate_solar.y[1];
  summer = timMan.summer;
  timLoc = timMan.timLoc;
  timSol = timMan.timSol;
  timCal = timMan.timCal;

  connect(remWE.y, calcWE.u) annotation (Line(
      points={{-25.3,33},{-20.56,33}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, remWE.u) annotation (Line(
      points={{-60,66},{-52,66},{-52,33},{-41.4,33}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCalSol, climate_solar.u) annotation (Line(
      points={{-60,62},{-52,62},{-52,53},{-41.4,53}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timSol, climate_nonSolar.u) annotation (Line(
      points={{-60,70},{-50,70},{-50,73},{-41.4,73}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabPre.u) annotation (Line(
      points={{-60,66},{-52,66},{-52,-7},{-41.4,-7}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabQCon.u) annotation (Line(
      points={{-60,66},{-52,66},{-52,-27},{-41.4,-27}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabQRad.u) annotation (Line(
      points={{-60,66},{-50,66},{-50,-31},{-37.4,-31}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabP.u) annotation (Line(
      points={{-60,66},{-52,66},{-52,-51},{-41.4,-51}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabQ.u) annotation (Line(
      points={{-60,66},{-50,66},{-50,-55},{-37.4,-55}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(timMan.timCal, tabDHW.u) annotation (Line(
      points={{-60,66},{-52,66},{-52,-75},{-41.4,-75}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation(defaultComponentName="sim", defaultComponentPrefixes="inner",  missingInnerMessage="Your model is using an outer \"sim\" component. An inner \"sim\" component is not defined. For simulation drag IDEAS.SimInfoManager into your model.",
        Icon(graphics={
        Ellipse(
          extent={{-60,78},{74,-58}},
          lineColor={95,95,95},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{18,52},{30,44},{36,44},{36,46},{34,48},{34,56},{22,60},{16,60},
              {10,58},{6,54},{8,52},{2,52},{-8,48},{-14,52},{-24,48},{-26,40},{-18,
              40},{-14,32},{-14,28},{-12,24},{-16,10},{-8,2},{-8,-2},{-6,-6},{-4,
              -4},{0,-6},{2,-12},{10,-18},{18,-24},{22,-30},{26,-36},{32,-44},{34,
              -50},{36,-58},{60,-44},{72,-28},{72,-18},{64,-14},{58,-12},{48,-12},
              {44,-14},{40,-16},{34,-16},{26,-24},{20,-22},{20,-18},{24,-12},{16,
              -16},{8,-12},{8,-8},{10,-2},{16,0},{24,0},{28,-2},{30,-8},{32,-6},
              {28,2},{30,12},{34,18},{36,20},{38,24},{34,26},{36,32},{26,38},{18,
              38},{20,32},{18,28},{12,32},{14,38},{16,42},{24,40},{22,46},{16,50},
              {18,52}},
          lineColor={255,255,255},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-34,64},{-30,62},{-26,64},{-24,60},{-36,58},{-24,52},{-16,54},
              {-14,62},{-8,68},{6,74},{12,74},{22,70},{28,64},{30,64},{44,62},{46,
              58},{42,56},{50,50},{66,34},{68,20},{74,12},{80,46},{70,78},{44,90},
              {2,90},{-32,80},{-34,64}},
          lineColor={255,255,255},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Bitmap(extent={{22,-8},{20,-8}},  fileName=""),
        Ellipse(extent={{-60,78},{74,-58}}, lineColor={95,95,95}),
        Polygon(
          points={{-66,-20},{-70,-16},{-72,-20},{-68,-30},{-60,-42},{-60,-40},{-62,
              -32},{-66,-20}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-62,-4},{-58,0},{-54,-2},{-54,-12},{-52,-20},{-48,-24},{-50,-28},
              {-50,-30},{-54,-28},{-56,-26},{-58,-12},{-62,-4}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-48,0},{-46,4},{-42,4},{-40,0},{-40,-4},{-38,-16},{-38,-22},{
              -40,-24},{-44,-22},{-44,-16},{-48,0}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-32,2},{-28,4},{-24,4},{-24,0},{-24,-12},{-24,-20},{-26,-24},
              {-30,-24},{-32,-6},{-32,2}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-6,-36},{-12,-42},{-8,-42},{-4,-36},{0,-26},{-2,-22},{-6,-22},
              {-8,-26},{-10,-32},{-8,-36},{-6,-36}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-60,-44},{-58,-40},{-54,-40},{-50,-36},{-42,-32},{-36,-32},{-32,
              -28},{-26,-28},{-24,-34},{-24,-36},{-26,-38},{-20,-42},{-16,-46},{
              -12,-46},{-8,-48},{-10,-52},{-12,-60},{-16,-66},{-20,-68},{-26,-70},
              {-30,-70},{-34,-70},{-36,-74},{-40,-76},{-42,-76},{-48,-72},{-54,-62},
              {-60,-44}},
          lineColor={127,0,0},
          smooth=Smooth.None,
          fillColor={127,67,62},
          fillPattern=FillPattern.Solid)}),
    Diagram(graphics),
    Documentation(info="<html>
</html>"));
end SimInfoManager;
