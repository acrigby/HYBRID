within NHES.Systems.BalanceOfPlant.Turbine;
model SteamTurbine_Basic_NoFeedHeat "Two stage BOP model"
  extends BaseClasses.Partial_SubSystem_C(
    redeclare replaceable
      ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp CS,
    redeclare replaceable ControlSystems.ED_Dummy ED,
    redeclare replaceable Data.TESTurbine data(
      p_condensor=7000,
      V_FeedwaterMixVolume=10,
      V_Header=10,
      R_entry=8e4,
      valve_SHS_mflow=30,
      valve_SHS_dp_nominal=1200000,
      valve_TCV_LPT_mflow=30,
      valve_TCV_LPT_dp_nominal=10000,
      InternalBypassValve_mflow_small=0,
      InternalBypassValve_p_spring=15000000,
      InternalBypassValve_K=40,
      LPT_p_in_nominal=1200000,
      LPT_p_exit_nominal=7000,
      LPT_T_in_nominal=491.15,
      LPT_nominal_mflow=26.83,
      LPT_efficiency=1,
      firstfeedpump_p_nominal=2000000,
      secondfeedpump_p_nominal=2000000));

  replaceable Data.IntermediateTurbineInitialisation init(
    FeedwaterMixVolume_p_start=3000000,
      FeedwaterMixVolume_h_start=2e6,
    InternalBypassValve_dp_start=3500000,
    InternalBypassValve_mflow_start=0.1,
    HPT_p_a_start=3000000,
    HPT_p_b_start=10000,
    HPT_T_a_start=523.15,
    HPT_T_b_start=333.15)
  annotation (Placement(transformation(extent={{68,120},{88,140}})));

  Fluid.Vessels.IdealCondenser Condenser(
    p= data.p_condensor,
    V_total=data.V_condensor,
    V_liquid_start=init.condensor_V_liquid_start)
    annotation (Placement(transformation(extent={{156,-112},{136,-92}})));

  Electrical.Generator      generator1(J=data.generator_MoI)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={84,-92})));

  TRANSFORM.Electrical.Sensors.PowerSensor sensorW
    annotation (Placement(transformation(extent={{110,-58},{130,-38}})));

  Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor
    annotation (Placement(transformation(extent={{52,-66},{72,-86}})));

  TRANSFORM.Fluid.Machines.SteamTurbine LPT(
    nUnits=1,
    energyDynamics=TRANSFORM.Types.Dynamics.DynamicFreeInitial,
    eta_mech=data.LPT_efficiency,
    redeclare model Eta_wetSteam =
        TRANSFORM.Fluid.Machines.BaseClasses.WetSteamEfficiency.eta_Constant (
          eta_nominal=0.9),
    p_a_start=init.LPT_p_a_start,
    p_b_start=init.LPT_p_b_start,
    T_a_start=init.LPT_T_a_start,
    T_b_start=init.LPT_T_b_start,
    m_flow_nominal=data.LPT_nominal_mflow,
    p_inlet_nominal=data.LPT_p_in_nominal,
    p_outlet_nominal=data.LPT_p_exit_nominal,
    T_nominal=data.LPT_T_in_nominal) annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=90,
        origin={46,-40})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort
                                       sensor_T3(redeclare package Medium =
        Modelica.Media.Water.StandardWater)            annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={134,72})));
  TRANSFORM.Fluid.Valves.ValveLinear TCV_LPT(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    m_flow_start=400,
    dp_nominal=data.valve_TCV_LPT_dp_nominal,
    m_flow_nominal=data.valve_TCV_LPT_mflow) annotation (Placement(
        transformation(
        extent={{8,8},{-8,-8}},
        rotation=180,
        origin={104,72})));
  TRANSFORM.Fluid.Valves.ValveLinear Discharge_OnOff(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    m_flow_start=400,
    dp_nominal=100000,
    m_flow_nominal=26) annotation (Placement(transformation(
        extent={{8,8},{-8,-8}},
        rotation=180,
        origin={126,-146})));
  TRANSFORM.Fluid.Machines.Pump_Controlled firstfeedpump1(
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    p_a_start=10000,
    p_b_start=1100000,
    N_nominal=1500,
    dp_nominal=1200000,
    m_flow_nominal=26,
    controlType="RPM",
    use_port=true)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={94,-142})));
  TRANSFORM.Fluid.Sensors.Pressure     sensor_p(redeclare package Medium =
        Modelica.Media.Water.StandardWater, redeclare function iconUnit =
        TRANSFORM.Units.Conversions.Functions.Pressure_Pa.to_bar)
                                                       annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-124,60})));
initial equation

equation

  connect(generator1.portElec, sensorW.port_a) annotation (Line(points={{84,-102},
          {84,-106},{104,-106},{104,-48},{110,-48}},
                                                   color={255,0,0}));
  connect(sensorW.port_b, portElec_b) annotation (Line(points={{130,-48},{146,
          -48},{146,0},{160,0}},                     color={255,0,0}));
  connect(sensorBus.Power, sensorW.W) annotation (Line(
      points={{-30,100},{120,100},{120,-37}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(powerSensor.flange_b, generator1.shaft_a) annotation (Line(points={{72,-76},
          {84,-76},{84,-82}},                      color={0,0,0}));
  connect(LPT.shaft_b, powerSensor.flange_a)
    annotation (Line(points={{46,-50},{46,-76},{52,-76}}, color={0,0,0}));
  connect(LPT.portLP, Condenser.port_a) annotation (Line(points={{52,-50},{52,-58},
          {38,-58},{38,-112},{118,-112},{118,-84},{153,-84},{153,-92}}, color={0,
          127,255}));
  connect(sensorBus.SHS_Return_T, sensor_T3.T) annotation (Line(
      points={{-30,100},{-30,74},{88,74},{88,58},{134,58},{134,68.4}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(actuatorBus.TCV_SHS, TCV_LPT.opening) annotation (Line(
      points={{30,100},{104,100},{104,78.4}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(TCV_LPT.port_b, sensor_T3.port_b)
    annotation (Line(points={{112,72},{124,72}}, color={0,127,255}));
  connect(actuatorBus.Discharge_OnOff_Throttle, Discharge_OnOff.opening)
    annotation (Line(
      points={{30,100},{186,100},{186,-132},{126,-132},{126,-139.6}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(firstfeedpump1.port_a, Condenser.port_b) annotation (Line(points={{84,-142},
          {78,-142},{78,-128},{146,-128},{146,-112}},       color={0,127,255}));
  connect(firstfeedpump1.port_b, Discharge_OnOff.port_a) annotation (Line(
        points={{104,-142},{112,-142},{112,-146},{118,-146}}, color={0,127,255}));
  connect(TCV_LPT.port_a, LPT.portHP)
    annotation (Line(points={{96,72},{52,72},{52,-30}}, color={0,127,255}));
  connect(Discharge_OnOff.port_b, port_b) annotation (Line(points={{134,-146},{
          144,-146},{144,-160},{-144,-160},{-144,-40},{-160,-40}}, color={0,127,
          255}));
  connect(actuatorBus.Feed_Pump_Speed, firstfeedpump1.inputSignal) annotation (
      Line(
      points={{30,100},{112,100},{112,102},{206,102},{206,-138},{114,-138},{114,
          -132},{94,-132},{94,-135}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(sensorBus.Steam_Pressure,sensor_p. p) annotation (Line(
      points={{-30,100},{-30,60},{-130,60}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(port_a, sensor_p.port) annotation (Line(points={{-160,40},{-124,40},{
          -124,50}}, color={0,127,255}));
  connect(sensor_p.port, sensor_T3.port_a) annotation (Line(points={{-124,50},{
          -124,40},{150,40},{150,72},{144,72}}, color={0,127,255}));
annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-24,2},{24,-2}},
          lineColor={0,0,0},
          fillColor={64,164,200},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={20,-42},
          rotation=180),
        Rectangle(
          extent={{-11.5,3},{11.5,-3}},
          lineColor={0,0,0},
          fillColor={64,164,200},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={-1,-28.5},
          rotation=90),
        Rectangle(
          extent={{-4.5,2.5},{4.5,-2.5}},
          lineColor={0,0,0},
          fillColor={64,164,200},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={-8.5,-31.5},
          rotation=360),
        Rectangle(
          extent={{-0.800004,5},{29.1996,-5}},
          lineColor={0,0,0},
          origin={-71.1996,-49},
          rotation=0,
          fillColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-18,3},{18,-3}},
          lineColor={0,0,0},
          fillColor={66,200,200},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={-39,28},
          rotation=-90),
        Rectangle(
          extent={{-1.81332,3},{66.1869,-3}},
          lineColor={0,0,0},
          origin={-18.1867,-3},
          rotation=0,
          fillColor={135,135,135},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-70,46},{-36,34}},
          lineColor={0,0,0},
          fillColor={66,200,200},
          fillPattern=FillPattern.HorizontalCylinder),
        Polygon(
          points={{-42,12},{-42,-18},{-12,-36},{-12,32},{-42,12}},
          lineColor={0,0,0},
          fillColor={0,114,208},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-31,-10},{-21,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="HPT"),
        Ellipse(
          extent={{46,12},{74,-14}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-0.601938,3},{23.3253,-3}},
          lineColor={0,0,0},
          origin={22.6019,-29},
          rotation=0,
          fillColor={0,128,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-0.43805,2.7864},{15.9886,-2.7864}},
          lineColor={0,0,0},
          origin={45.2136,-41.989},
          rotation=90,
          fillColor={0,128,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Ellipse(
          extent={{32,-42},{60,-68}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-0.373344,2},{13.6267,-2}},
          lineColor={0,0,0},
          origin={18.3733,-56},
          rotation=0,
          fillColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-0.341463,2},{13.6587,-2}},
          lineColor={0,0,0},
          origin={20,-44.3415},
          rotation=-90,
          fillColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-1.41463,2.0001},{56.5851,-2.0001}},
          lineColor={0,0,0},
          origin={18.5851,-46.0001},
          rotation=180,
          fillColor={0,0,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Ellipse(
          extent={{-46,-40},{-34,-52}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={0,100,199}),
        Polygon(
          points={{-44,-50},{-48,-54},{-32,-54},{-36,-50},{-44,-50}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.VerticalCylinder),
        Ellipse(
          extent={{-56,49},{-38,31}},
          lineColor={95,95,95},
          fillColor={175,175,175},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{-46,49},{-48,61}},
          lineColor={0,0,0},
          fillColor={95,95,95},
          fillPattern=FillPattern.VerticalCylinder),
        Rectangle(
          extent={{-56,63},{-38,61}},
          lineColor={0,0,0},
          fillColor={181,0,0},
          fillPattern=FillPattern.HorizontalCylinder),
        Ellipse(
          extent={{-45,49},{-49,31}},
          lineColor={0,0,0},
          fillPattern=FillPattern.VerticalCylinder,
          fillColor={162,162,0}),
        Text(
          extent={{55,-10},{65,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="G"),
        Text(
          extent={{41,-62},{51,-48}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="C"),
        Polygon(
          points={{-39,-43},{-39,-49},{-43,-46},{-39,-43}},
          lineColor={0,0,0},
          pattern=LinePattern.None,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={255,255,255}),
        Polygon(
          points={{-4,12},{-4,-18},{26,-36},{26,32},{-4,12}},
          lineColor={0,0,0},
          fillColor={0,114,208},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{7,-10},{17,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="LPT"),
        Rectangle(
          extent={{-4,-40},{22,-48}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          lineThickness=1,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={28,108,200}),
        Line(
          points={{-4,-44},{22,-44}},
          color={255,0,0},
          thickness=1)}),                                        Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=1000,
      Interval=10,
      __Dymola_Algorithm="Esdirk45a"),
    Documentation(info="<html>
<p>A two stage turbine rankine cycle with feedwater heating internal to the system - can be externally bypassed or LPT can be bypassed both will feedwater heat post bypass</p>
</html>"));
end SteamTurbine_Basic_NoFeedHeat;
