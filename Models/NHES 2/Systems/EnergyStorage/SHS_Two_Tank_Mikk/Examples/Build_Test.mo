within NHES.Systems.EnergyStorage.SHS_Two_Tank_Mikk.Examples;
model Build_Test
  "Initial build test of two tank system. No reference documents were used, the test is simply to evaluate overall system behavior."
  extends Modelica.Icons.Example;
  NHES.Systems.EnergyStorage.SHS_Two_Tank_Mikk.Two_Tank_SHS_System
    two_Tank_SHS_System(redeclare
      NHES.Systems.EnergyStorage.SHS_Two_Tank_Mikk.CS_Boiler_03 CS,
    redeclare replaceable
      NHES.Systems.EnergyStorage.SHS_Two_Tank_Mikk.Data.Data_SHS data(
        DHX_K_tube(unit="1/m4"), DHX_K_shell(unit="1/m4")),
      Produced_steam_flow=valveLinear.port_a.m_flow)
    annotation (Placement(transformation(extent={{-50,-50},{46,52}})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort CHX_Inlet_T(redeclare package
      Medium = Modelica.Media.Water.StandardWater)
    annotation (Placement(transformation(extent={{-92,-8},{-72,-28}})));
  Modelica.Fluid.Sources.MassFlowSource_T boundary5(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    use_m_flow_in=true,
    m_flow=8,
    T=598.15,
    nPorts=1) annotation (Placement(transformation(extent={{-144,-28},{-124,-8}})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort CHX_Discharge_T(redeclare package
      Medium = Modelica.Media.Water.StandardWater)
    annotation (Placement(transformation(extent={{-94,6},{-114,26}})));
  Modelica.Fluid.Sources.Boundary_pT boundary1(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    p=5000000,
    T=343.15,
    nPorts=1) annotation (Placement(transformation(extent={{-148,6},{-128,26}})));
  Modelica.Blocks.Logical.TriggeredTrapezoid triggeredTrapezoid(
    amplitude=10,
    rising=600,
    falling=600,
    offset=0)
    annotation (Placement(transformation(extent={{-176,-20},{-156,0}})));

  TRANSFORM.Fluid.Machines.Pump_SimpleMassFlow pump(redeclare package Medium =
        Modelica.Media.Water.StandardWater, m_flow_nominal=25)
    annotation (Placement(transformation(extent={{126,2},{106,22}})));
  TRANSFORM.Fluid.Volumes.BoilerDrum boilerDrum(
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.TwoVolume_withLevel.Cylinder
        (
        length=20,
        r_inner=3,
        th_wall=0.03),
    level_start=11.0,
    p_liquid_start=500000,
    p_vapor_start=500000,
    use_LiquidHeatPort=false,
    Twall_start=343.15)
    annotation (Placement(transformation(extent={{86,30},{104,52}})));
  TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T boundary3(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    use_m_flow_in=true,
    m_flow=1.0,
    T=343.15,
    nPorts=1) annotation (Placement(transformation(extent={{142,32},{124,50}})));
  TRANSFORM.Fluid.Valves.ValveLinear valveLinear(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    dp_nominal=50000,
    m_flow_nominal=10)
    annotation (Placement(transformation(extent={{72,62},{52,82}})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    p=400000,
    nPorts=1)
    annotation (Placement(transformation(extent={{22,62},{42,82}})));
  Modelica.Blocks.Sources.Constant const1(k=5e5)
    annotation (Placement(transformation(extent={{2,102},{22,122}})));
  TRANSFORM.Controls.LimPID PID1(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=-1e-3,
    Ti=15,
    yMax=1.0,
    yMin=0.0) annotation (Placement(transformation(extent={{48,102},{68,122}})));
  Modelica.Blocks.Sources.RealExpression Boiler_Pressure(y=boilerDrum.medium_vapor.p)
    annotation (Placement(transformation(extent={{28,82},{48,102}})));
  Modelica.Blocks.Sources.RealExpression Level_Boiler(y=boilerDrum.level)
    annotation (Placement(transformation(extent={{124,52},{144,72}})));
  TRANSFORM.Controls.LimPID PID(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=2e-2,
    Ti=10,
    yMin=-0.25)
              annotation (Placement(transformation(extent={{166,76},{186,96}})));
  Modelica.Blocks.Sources.Constant const(k=10)
    annotation (Placement(transformation(extent={{128,76},{148,96}})));
equation
  two_Tank_SHS_System.Charging_Trigger = triggeredTrapezoid.u;
 // two_Tank_SHS_System.Produced_steam_flow = valveLinear.port_a.m_flow;
  connect(boundary5.ports[1], CHX_Inlet_T.port_a) annotation (Line(points={{-124,
          -18},{-92,-18}},            color={0,127,255}));
  connect(CHX_Inlet_T.port_b, two_Tank_SHS_System.port_ch_a) annotation (Line(
        points={{-72,-18},{-50,-18},{-50,-30.62},{-49.04,-30.62}}, color={0,127,
          255}));
  connect(CHX_Discharge_T.port_a, two_Tank_SHS_System.port_ch_b) annotation (
      Line(points={{-94,16},{-84,16},{-84,22},{-68,22},{-68,32},{-49.04,32},{-49.04,
          28.54}}, color={0,127,255}));
  connect(CHX_Discharge_T.port_b, boundary1.ports[1])
    annotation (Line(points={{-114,16},{-128,16}}, color={0,127,255}));
  connect(boundary5.m_flow_in, triggeredTrapezoid.y)
    annotation (Line(points={{-144,-10},{-155,-10}},
                                                   color={0,0,127}));
  connect(pump.port_a,boilerDrum. downcomerPort) annotation (Line(points={{126,12},
          {130,12},{130,28},{101.3,28},{101.3,32.2}},                   color={0,
          127,255}));
  connect(boilerDrum.steamPort,valveLinear. port_a) annotation (Line(points={{101.3,
          49.36},{102,49.36},{102,72},{72,72}},     color={0,127,255}));
  connect(valveLinear.port_b,boundary. ports[1])
    annotation (Line(points={{52,72},{42,72}},   color={0,127,255}));
  connect(pump.port_b, two_Tank_SHS_System.port_dch_b) annotation (Line(points={{106,12},
          {94,12},{94,16},{80,16},{80,-30.62},{46,-30.62}},          color={0,127,
          255}));
  connect(two_Tank_SHS_System.port_dch_a, boilerDrum.riserPort) annotation (
      Line(points={{45.04,30.58},{88.7,30.58},{88.7,32.2}}, color={0,127,255}));
  connect(boundary3.ports[1], boilerDrum.feedwaterPort)
    annotation (Line(points={{124,41},{104,41}}, color={0,127,255}));
  connect(PID1.u_s,const1. y)
    annotation (Line(points={{46,112},{23,112}},  color={0,0,127}));
  connect(PID1.y, valveLinear.opening) annotation (Line(points={{69,112},{88,112},
          {88,86},{64,86},{64,80},{62,80}}, color={0,0,127}));
  connect(Boiler_Pressure.y, PID1.u_m)
    annotation (Line(points={{49,92},{58,92},{58,100}}, color={0,0,127}));
  connect(const.y, PID.u_s)
    annotation (Line(points={{149,86},{164,86}}, color={0,0,127}));
  connect(Level_Boiler.y, PID.u_m) annotation (Line(points={{145,62},{174,62},{174,
          74},{176,74}}, color={0,0,127}));
  connect(PID.y, boundary3.m_flow_in) annotation (Line(points={{187,86},{214,86},
          {214,48.2},{142,48.2}}, color={0,0,127}));
  annotation (experiment(
      StopTime=432000,
      Interval=37,
      __Dymola_Algorithm="Esdirk45a"));
end Build_Test;
