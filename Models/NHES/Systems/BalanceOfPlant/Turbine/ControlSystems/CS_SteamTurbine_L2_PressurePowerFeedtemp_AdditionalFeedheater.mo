within NHES.Systems.BalanceOfPlant.Turbine.ControlSystems;
model CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater
  extends NHES.Systems.BalanceOfPlant.Turbine.BaseClasses.Partial_ControlSystem;

  extends NHES.Icons.DummyIcon;

  input Real electric_demand_int = data.Q_Nom;

  Modelica.Blocks.Sources.Constant const5(k=data.T_Feedwater)
    annotation (Placement(transformation(extent={{-92,-56},{-72,-36}})));
  TRANSFORM.Controls.LimPID TCV_Power(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=5e-9,
    Ti=30,
    k_s=1,
    k_m=1,
    yMax=0.75,
    yMin=-0.25 + 0.01,
    initType=Modelica.Blocks.Types.Init.NoInit,
    xi_start=1500)
    annotation (Placement(transformation(extent={{-48,-2},{-28,-22}})));
  Modelica.Blocks.Sources.RealExpression
                                   realExpression(y=electric_demand_int)
    annotation (Placement(transformation(extent={{-94,-6},{-80,6}})));
  Modelica.Blocks.Sources.Constant const7(k=0.25)
    annotation (Placement(transformation(extent={{-26,-28},{-18,-20}})));
  Modelica.Blocks.Math.Add         add1
    annotation (Placement(transformation(extent={{-8,-28},{12,-8}})));
  Modelica.Blocks.Math.Add         add2
    annotation (Placement(transformation(extent={{-8,-56},{12,-36}})));
  StagebyStageTurbineSecondary.Control_and_Distribution.Timer             timer(
      Start_Time=1e-2)
    annotation (Placement(transformation(extent={{-32,-44},{-24,-36}})));
  replaceable Data.Turbine_2_Setpoints data(
    p_steam=3500000,
    p_steam_vent=15000000,
    T_Steam_Ref=579.75,
    Q_Nom=40e6,
    T_Feedwater=421.15)
    annotation (Placement(transformation(extent={{-98,12},{-78,32}})));
  Modelica.Blocks.Sources.Constant const(k=data.Q_Nom)
    annotation (Placement(transformation(extent={{-78,-22},{-64,-8}})));
  Modelica.Blocks.Sources.Constant const2(k=1)
    annotation (Placement(transformation(extent={{2,74},{22,94}})));
  TRANSFORM.Controls.LimPID PI_TBV(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=-5e-7,
    Ti=15,
    yMax=1.0,
    yMin=0.0,
    initType=Modelica.Blocks.Types.Init.NoInit)
    annotation (Placement(transformation(extent={{-38,72},{-18,92}})));
  Modelica.Blocks.Sources.Constant const9(k=data.p_steam_vent)
    annotation (Placement(transformation(extent={{-78,72},{-58,92}})));
  TRANSFORM.Controls.LimPID Turb_Divert_Valve1(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=1e-4,
    Ti=60,
    Td=0.1,
    yMax=-0.05,
    yMin=-0.099,
    initType=Modelica.Blocks.Types.Init.NoInit,
    xi_start=1500)
    annotation (Placement(transformation(extent={{-60,-56},{-40,-36}})));
  Modelica.Blocks.Sources.Constant const1(k=0.1)
    annotation (Placement(transformation(extent={{-32,-58},{-24,-50}})));
  TRANSFORM.Controls.LimPID FWCP_Speed1(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=5e-3,
    Ti=15,
    Td=1,
    yMax=1000,
    yMin=-1200,
    wp=1,
    wd=0.5,
    initType=Modelica.Blocks.Types.Init.NoInit,
    xi_start=1500)
    annotation (Placement(transformation(extent={{-16,120},{4,140}})));
  Modelica.Blocks.Sources.Constant const8(k=1600)
    annotation (Placement(transformation(extent={{8,138},{16,146}})));
  Modelica.Blocks.Math.Add         add3
    annotation (Placement(transformation(extent={{24,126},{44,146}})));
  Modelica.Blocks.Sources.Constant const10(k=67)
    annotation (Placement(transformation(extent={{-110,124},{-90,144}})));
equation
  connect(sensorBus.Power, TCV_Power.u_m) annotation (Line(
      points={{-30,-100},{-100,-100},{-100,8},{-38,8},{-38,0}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(const7.y,add1. u2) annotation (Line(points={{-17.6,-24},{-10,-24}},
                                      color={0,0,127}));
  connect(TCV_Power.y, add1.u1)
    annotation (Line(points={{-27,-12},{-10,-12}}, color={0,0,127}));
  connect(add2.u1,timer. y) annotation (Line(points={{-10,-40},{-23.44,-40}},
                                                                color={0,0,127}));
  connect(actuatorBus.Divert_Valve_Position, add2.y) annotation (Line(
      points={{30,-100},{30,-46},{13,-46}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(actuatorBus.opening_TCV, add1.y) annotation (Line(
      points={{30.1,-99.9},{30.1,-18},{13,-18}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(actuatorBus.opening_BV, const2.y) annotation (Line(
      points={{30.1,-99.9},{30.1,84},{23,84}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(const9.y, PI_TBV.u_s)
    annotation (Line(points={{-57,82},{-40,82}}, color={0,0,127}));
  connect(sensorBus.Steam_Pressure, PI_TBV.u_m) annotation (Line(
      points={{-30,-100},{-100,-100},{-100,62},{-28,62},{-28,70}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(actuatorBus.TBV, PI_TBV.y) annotation (Line(
      points={{30,-100},{30,66},{-10,66},{-10,82},{-17,82}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(const.y, TCV_Power.u_s) annotation (Line(points={{-63.3,-15},{-56,-15},
          {-56,-12},{-50,-12}}, color={0,0,127}));
  connect(sensorBus.Feedwater_Temp, Turb_Divert_Valve1.u_m) annotation (Line(
      points={{-30,-100},{-30,-66},{-50,-66},{-50,-58}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(const5.y, Turb_Divert_Valve1.u_s)
    annotation (Line(points={{-71,-46},{-62,-46}},           color={0,0,127}));
  connect(Turb_Divert_Valve1.y, timer.u) annotation (Line(points={{-39,-46},{
          -38,-46},{-38,-40},{-32.8,-40}}, color={0,0,127}));
  connect(const1.y, add2.u2) annotation (Line(points={{-23.6,-54},{-23.6,-52},{
          -10,-52}}, color={0,0,127}));
  connect(FWCP_Speed1.y, add3.u2)
    annotation (Line(points={{5,130},{22,130}}, color={0,0,127}));
  connect(const10.y, FWCP_Speed1.u_s) annotation (Line(points={{-89,134},{-89,
          132},{-18,132},{-18,130}}, color={0,0,127}));
  connect(actuatorBus.Feed_Pump_Speed, add3.y) annotation (Line(
      points={{30,-100},{30,116},{50,116},{50,136},{45,136}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(const8.y, add3.u1)
    annotation (Line(points={{16.4,142},{22,142}}, color={0,0,127}));
  connect(sensorBus.Reactor_mflow, FWCP_Speed1.u_m) annotation (Line(
      points={{-30,-100},{-100,-100},{-100,108},{-6,108},{-6,118}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
end CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater;
