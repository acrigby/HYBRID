within NHES.Systems.Examples.TES_Use_Case;
model HTGR_Case_01_IndependentBOP
  "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
 parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
 parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
 parameter SI.Time timeScale=60*60 "Time scale of first table column";
 parameter String fileName=Modelica.Utilities.Files.loadResource(
    "modelica://NHES/Resources/Data/RAVEN/DMM_Dissertation_Demand.txt")
  "File where matrix is stored";
 Real demandChange=
 min(1.05,
 max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
     + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
     0.5));

  EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(
    port_a1_nominal(
      p=14000000,
      h=2e6,
      m_flow=50),
    port_b1_nominal(p=14100000, h=2e6),
    port_b3_nominal_m_flow={-0.67},
    nPorts_b3=1)
    annotation (Placement(transformation(extent={{-22,-6},{18,34}})));
  BalanceOfPlant.Turbine.HTGR_RankineCycles.SteamTurbine_OpenFeedHeat_DivertPowerControl_HTGR
    intermediate_Rankine_Cycle_TESUC(
    redeclare replaceable NHES.Systems.BalanceOfPlant.Turbine.Data.TESTurbine
      data(
      p_in_nominal=14000000,
      p_condensor=8000,
      V_condensor=10000,
      V_FeedwaterMixVolume=25,
      V_Header=10,
      valve_TCV_mflow=50,
      valve_TCV_dp_nominal=500000,
      valve_SHS_mflow=15,
      valve_SHS_dp_nominal=3000000,
      valve_TCV_LPT_mflow=30,
      valve_TCV_LPT_dp_nominal=10000,
      InternalBypassValve_mflow_small=0,
      InternalBypassValve_p_spring=20000000,
      InternalBypassValve_K(unit="1/(m.kg)") = 40,
      InternalBypassValve_tau(unit="1/s"),
      HPT_p_exit_nominal=2500000,
      HPT_T_in_nominal=673.15,
      HPT_nominal_mflow=50,
      HPT_efficiency=1,
      LPT_p_in_nominal=2500000,
      LPT_p_exit_nominal=7000,
      LPT_T_in_nominal=573.15,
      LPT_nominal_mflow=50,
      LPT_efficiency=1,
      firstfeedpump_p_nominal=6000000,
      secondfeedpump_p_nominal=5500000,
      controlledfeedpump_mflow_nominal=75,
      MainFeedHeater_K_tube(unit="1/m4"),
      MainFeedHeater_K_shell(unit="1/m4"),
      BypassFeedHeater_K_tube(unit="1/m4"),
      BypassFeedHeater_K_shell(unit="1/m4")),
    port_a_nominal(
      p=EM.port_b2_nominal.p,
      h=EM.port_b2_nominal.h,
      m_flow=-EM.port_b2_nominal.m_flow),
    port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
    redeclare
      NHES.Systems.BalanceOfPlant.Turbine.ControlSystems.CS_DivertPowerControl_HTGR_3
      CS(
      electric_demand=sum1.y,
      Overall_Power=sensorW.W,
      data(
        p_steam=14000000,
        T_Feedwater=481.15,
        p_steam_vent=16500000,
        m_flow_reactor=50)),
    redeclare
      NHES.Systems.BalanceOfPlant.Turbine.Data.IntermediateTurbineInitialisation
      init(
      FeedwaterMixVolume_p_start=3000000,
      FeedwaterMixVolume_h_start=2e6,
      InternalBypassValve_dp_start=3500000,
      InternalBypassValve_mflow_start=0.1,
      HPT_p_a_start=3000000,
      HPT_p_b_start=10000,
      HPT_T_a_start=523.15,
      HPT_T_b_start=333.15))
    annotation (Placement(transformation(extent={{40,-6},{80,34}})));
  SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=2)
    annotation (Placement(transformation(extent={{98,-42},{120,-12}})));
  ElectricalGrid.InfiniteGrid.Infinite EG
    annotation (Placement(transformation(extent={{168,-42},{200,-14}})));
  BaseClasses.Data_Capacity dataCapacity(IP_capacity(displayUnit="MW")=
      53303300, BOP_capacity(displayUnit="MW") = 1165000000)
    annotation (Placement(transformation(extent={{-100,82},{-80,102}})));
  Modelica.Blocks.Sources.Constant delayStart(k=0)
    annotation (Placement(transformation(extent={{-62,78},{-42,98}})));
  SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
    W_nominal_BOP(displayUnit="MW") = 50000000,
    fileName=Modelica.Utilities.Files.loadResource(
        "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
    annotation (Placement(transformation(extent={{158,60},{198,100}})));

  EnergyStorage.SHS_Two_Tank.Components.Two_Tank_SHS_System_BestModel
    two_Tank_SHS_System_NTU(
    redeclare
      NHES.Systems.EnergyStorage.SHS_Two_Tank.ControlSystems.CS_BestExample_2
      CS,
    redeclare replaceable NHES.Systems.EnergyStorage.SHS_Two_Tank.Data.Data_SHS
      data(
      ht_level_max=11.7,
      ht_area=3390,
      ht_surface_pressure=120000,
      ht_init_level=2,
      hot_tank_init_temp=673.15,
      cold_tank_level_max=11.7,
      cold_tank_area=3390,
      ct_surface_pressure=120000,
      cold_tank_init_level=9.7,
      cold_tank_init_temp=533.15,
      m_flow_ch_min=0.1,
      DHX_NTU=20,
      DHX_K_tube(unit="1/m4"),
      DHX_K_shell(unit="1/m4"),
      DHX_p_start_tube=120000,
      DHX_h_start_tube_inlet=272e3,
      DHX_h_start_tube_outlet=530e3,
      charge_pump_dp_nominal=1200000,
      charge_pump_m_flow_nominal=900,
      charge_pump_constantRPM=3000,
      disvalve_dp_nominal=100000,
      chvalve_m_flow_nom=900,
      disvalve_m_flow_nom=900,
      chvalve_dp_nominal=100000),
    redeclare package Storage_Medium = NHES.Media.Hitec.Hitec,
    m_flow_min=0.1,
    tank_height=11.7,
    Steam_Output_Temp=stateSensor6.temperature.T)
    annotation (Placement(transformation(extent={{-58,-100},{14,-30}})));

  Fluid.Sensors.stateSensor stateSensor6(redeclare package Medium =
        Modelica.Media.Water.StandardWater)
    annotation (Placement(transformation(extent={{24,-94},{38,-78}})));
  Modelica.Blocks.Sources.Sine sine(
    amplitude=17.5e6,
    f=1/20000,
    offset=42e6,
    startTime=2000)
    annotation (Placement(transformation(extent={{-26,72},{-6,92}})));
  Modelica.Blocks.Sources.Trapezoid trapezoid(
    amplitude=-20.58e6,
    rising=100,
    width=9800,
    falling=100,
    period=20000,
    offset=47e6,
    startTime=2000)
    annotation (Placement(transformation(extent={{66,112},{86,132}})));
  BalanceOfPlant.Turbine.SteamTurbine_Basic_NoFeedHeat
    intermediate_Rankine_Cycle_TESUC_1_Independent_SmallCycle(
    port_a_nominal(
      p=EM.port_b2_nominal.p,
      h=EM.port_b2_nominal.h,
      m_flow=-EM.port_b2_nominal.m_flow),
    port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
    redeclare
      NHES.Systems.BalanceOfPlant.Turbine.ControlSystems.CS_SmallCycle_NoFeedHeat
      CS(electric_demand=sum1.y))
    annotation (Placement(transformation(extent={{48,-84},{86,-42}})));
  TRANSFORM.Electrical.Sensors.PowerSensor sensorW
    annotation (Placement(transformation(extent={{126,-44},{162,-12}})));
  Modelica.Blocks.Math.Add         add
    annotation (Placement(transformation(extent={{108,96},{128,116}})));
  Modelica.Blocks.Sources.Trapezoid trapezoid1(
    amplitude=20.14e6,
    rising=100,
    width=7800,
    falling=100,
    period=20000,
    offset=0,
    startTime=14000)
    annotation (Placement(transformation(extent={{66,76},{86,96}})));

  Modelica.Blocks.Sources.Constant const(k=47.5e6)
    annotation (Placement(transformation(extent={{18,68},{38,88}})));
  Modelica.Blocks.Sources.CombiTimeTable demand_BOP(
    tableOnFile=true,
    startTime=0,
    tableName="BOP",
    timeScale=timeScale,
    fileName=fileName)
    annotation (Placement(transformation(extent={{-98,112},{-78,132}})));
  Modelica.Blocks.Math.Sum sum1
    annotation (Placement(transformation(extent={{134,102},{154,122}})));
  PrimaryHeatSystem.HTGR.HTGR_Rankine.Components.HTGR_PebbleBed_Primary_Loop_TESUC
    hTGR_PebbleBed_Primary_Loop_TESUC(redeclare
      PrimaryHeatSystem.HTGR.HTGR_Rankine.ControlSystems.CS_Rankine_Primary_2
      CS(data(P_Steam_Ref=6000000)))
    annotation (Placement(transformation(extent={{-94,-18},{-36,40}})));
equation
  hTGR_PebbleBed_Primary_Loop_TESUC.input_steam_pressure =
    intermediate_Rankine_Cycle_TESUC.sensor_p.p;

  connect(EM.port_a2, intermediate_Rankine_Cycle_TESUC.port_b)
    annotation (Line(points={{18,6},{40,6}},   color={0,127,255}));
  connect(intermediate_Rankine_Cycle_TESUC.portElec_b, SY.port_a[1])
    annotation (Line(points={{80,14},{92,14},{92,-27.375},{98,-27.375}},
                                                                     color={255,
          0,0}));
  connect(two_Tank_SHS_System_NTU.port_dch_b, stateSensor6.port_a) annotation (
      Line(points={{14,-86.7},{19,-86.7},{19,-86},{24,-86}},
                                                    color={0,127,255}));
  connect(stateSensor6.port_b,
    intermediate_Rankine_Cycle_TESUC_1_Independent_SmallCycle.port_a)
    annotation (Line(points={{38,-86},{40,-86},{40,-54},{44,-54},{44,-54.6},{48,
          -54.6}},           color={0,127,255}));
  connect(intermediate_Rankine_Cycle_TESUC_1_Independent_SmallCycle.portElec_b,
    SY.port_a[2]) annotation (Line(points={{86,-63},{92,-63},{92,-26.625},{98,
          -26.625}},            color={255,0,0}));
  connect(SY.port_Grid, sensorW.port_a)
    annotation (Line(points={{120,-27},{120,-28},{126,-28}},
                                               color={255,0,0}));
  connect(sensorW.port_b, EG.portElec_a)
    annotation (Line(points={{162,-28},{168,-28}},
                                               color={255,0,0}));
  connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
          118},{100,112},{106,112}},
                         color={0,0,127}));
  connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
          100},{106,100}},
                         color={0,0,127}));
  connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
          92},{98,92},{98,118},{132,118},{132,112}}, color={0,0,127}));
  connect(intermediate_Rankine_Cycle_TESUC_1_Independent_SmallCycle.port_b,
    two_Tank_SHS_System_NTU.port_dch_a) annotation (Line(points={{48,-71.4},{48,
          -70},{20,-70},{20,-44.7},{13.28,-44.7}}, color={0,127,255}));
  connect(two_Tank_SHS_System_NTU.port_ch_a, EM.port_b3[1]) annotation (Line(
        points={{-57.28,-86.7},{-82,-86.7},{-82,-20},{6,-20},{6,-6}}, color={0,
          127,255}));
  connect(two_Tank_SHS_System_NTU.port_ch_b, intermediate_Rankine_Cycle_TESUC.port_a1)
    annotation (Line(points={{-57.28,-46.1},{-64,-46.1},{-64,-24},{47.2,-24},{
          47.2,-5.2}}, color={0,127,255}));
  connect(EM.port_b2, intermediate_Rankine_Cycle_TESUC.port_a)
    annotation (Line(points={{18,22},{40,22}}, color={0,127,255}));
  connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_b, EM.port_a1) annotation (
      Line(points={{-36.87,25.21},{-36.87,22},{-22,22}}, color={0,127,255}));
  connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_a, EM.port_b1) annotation (
      Line(points={{-36.87,1.43},{-36.87,6},{-22,6}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{200,100}}), graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent={{-54,-102},{146,98}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points={{16,62},{116,2},{16,-58},{16,62}})}),
                                Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-100,-100},{200,100}})),
    experiment(
      StopTime=200000,
      Interval=10,
      __Dymola_Algorithm="Esdirk45a"),
    Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
    __Dymola_experimentSetupOutput(events=false));
end HTGR_Case_01_IndependentBOP;
