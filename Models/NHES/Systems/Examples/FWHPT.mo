within NHES.Systems.Examples;
package FWHPT
  model LWR_L2_Turbine
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
    PrimaryHeatSystem.SMR_Generic.Components.SMR_Taveprogram_No_Pump
                                                             SMR_Taveprogram(
      port_b_nominal(
        p(displayUnit="Pa") = 3398e3,
        T(displayUnit="degC") = 580.05,
        h=2997670),
      redeclare PrimaryHeatSystem.SMR_Generic.CS_SMR_Tave CS(W_turbine=sensorW.W,
          W_Setpoint=sine.y),
      port_a_nominal(
        m_flow=67.07,
        T(displayUnit="degC") = 422.05,
        p=3447380))
      annotation (Placement(transformation(extent={{-102,-26},{-52,30}})));

    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=SMR_Taveprogram.port_b_nominal.p,
        h=SMR_Taveprogram.port_b_nominal.h,
        m_flow=-SMR_Taveprogram.port_b_nominal.m_flow), port_b1_nominal(p=
            SMR_Taveprogram.port_a_nominal.p, h=SMR_Taveprogram.port_a_nominal.h))
      annotation (Placement(transformation(extent={{-10,-18},{30,22}})));
    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
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

    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-52,28},{-6,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-38,2},{-24,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{32,0},{46,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{24,26},{70,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-26,-14},{-40,2}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-96,-56},{-52,-24}})));
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
    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));
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
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_NoBypass BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_New
        CS(electric_demand_int=SC.demand_BOP.y[1]))
      annotation (Placement(transformation(extent={{54,-20},{94,20}})));
  equation

    connect(SMR_Taveprogram.port_b, stateSensor1.port_a) annotation (Line(points={{
            -51.0909,12.7692},{-51.0909,11},{-38,11}},  color={0,127,255}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-24,11},{
            -22,11},{-22,12},{-16,12},{-16,10},{-10,10}},
                                                      color={0,127,255}));
    connect(stateSensor1.statePort, stateDisplay1.statePort) annotation (Line(
          points={{-30.965,11.045},{-22,11.045},{-22,14},{-20,14},{-20,24},{-29,24},
            {-29,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{30,10},{32,
            10},{32,9}},                        color={0,127,255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{39.035,9.045},{39.035,37.1},{47,37.1}}, color={0,0,0}));
    connect(SMR_Taveprogram.port_a, stateSensor3.port_b) annotation (Line(points={{
            -51.0909,-1.44615},{-46,-1.44615},{-46,-6},{-40,-6}},  color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-26,-6},{-10,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort, stateSensor3.statePort) annotation (Line(
          points={{-74,-44.16},{-74,-56},{-52,-56},{-52,-18},{-33.035,-18},{-33.035,
            -5.96}}, color={0,0,0}));
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
            118},{100,112},{106,112}},
                           color={0,0,127}));
    connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
            100},{106,100}},
                           color={0,0,127}));
    connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
            92},{98,92},{98,118},{132,118},{132,112}},
                                         color={0,0,127}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{46,9},{46,8},{54,8}}, color={0,127,255}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{94,0}}, color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{32,-6},{32,-8},
            {54,-8}}, color={0,127,255}));
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
  end LWR_L2_Turbine;

  model LWR_L2_Turbine_AdditionalFeedheater
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
    PrimaryHeatSystem.SMR_Generic.Components.SMR_Taveprogram_No_Pump
                                                             SMR_Taveprogram(
      port_b_nominal(
        p(displayUnit="Pa") = 3398e3,
        T(displayUnit="degC") = 580.05,
        h=2997670),
      redeclare PrimaryHeatSystem.SMR_Generic.CS_SMR_Tave CS(W_turbine=sensorW.W,
          W_Setpoint=sine.y),
      port_a_nominal(
        m_flow=67.07,
        T(displayUnit="degC") = 422.05,
        p=3447380))
      annotation (Placement(transformation(extent={{-102,-26},{-52,30}})));

    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=SMR_Taveprogram.port_b_nominal.p,
        h=SMR_Taveprogram.port_b_nominal.h,
        m_flow=-SMR_Taveprogram.port_b_nominal.m_flow), port_b1_nominal(p=
            SMR_Taveprogram.port_a_nominal.p, h=SMR_Taveprogram.port_a_nominal.h))
      annotation (Placement(transformation(extent={{-10,-18},{30,22}})));
    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
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

    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-52,28},{-6,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-38,2},{-24,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{32,0},{46,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{24,26},{70,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-26,-14},{-40,2}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-96,-56},{-52,-24}})));
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
    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));
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
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater
        CS(electric_demand_int=SC.demand_BOP.y[1]))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    Modelica.Fluid.Sources.MassFlowSource_T boundary(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      use_m_flow_in=true,
      T=573.15,
      nPorts=1) annotation (Placement(transformation(extent={{32,-52},{54,-32}})));
    Modelica.Fluid.Sources.Boundary_pT boundary1(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=100000,
      T=373.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{110,-52},{90,-32}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=15,
      rising=1e4,
      width=5e4,
      falling=1e4,
      period=1e5,
      offset=1,
      startTime=1e5)
      annotation (Placement(transformation(extent={{-16,-56},{4,-36}})));
  equation

    connect(SMR_Taveprogram.port_b, stateSensor1.port_a) annotation (Line(points={{
            -51.0909,12.7692},{-51.0909,11},{-38,11}},  color={0,127,255}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-24,11},{
            -22,11},{-22,12},{-16,12},{-16,10},{-10,10}},
                                                      color={0,127,255}));
    connect(stateSensor1.statePort, stateDisplay1.statePort) annotation (Line(
          points={{-30.965,11.045},{-22,11.045},{-22,14},{-20,14},{-20,24},{-29,24},
            {-29,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{30,10},{32,
            10},{32,9}},                        color={0,127,255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{39.035,9.045},{39.035,37.1},{47,37.1}}, color={0,0,0}));
    connect(SMR_Taveprogram.port_a, stateSensor3.port_b) annotation (Line(points={{
            -51.0909,-1.44615},{-46,-1.44615},{-46,-6},{-40,-6}},  color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-26,-6},{-10,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort, stateSensor3.statePort) annotation (Line(
          points={{-74,-44.16},{-74,-56},{-52,-56},{-52,-18},{-33.035,-18},{-33.035,
            -5.96}}, color={0,0,0}));
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
            118},{100,112},{106,112}},
                           color={0,0,127}));
    connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
            100},{106,100}},
                           color={0,0,127}));
    connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
            92},{98,92},{98,118},{132,118},{132,112}},
                                         color={0,0,127}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{46,9},{46,10},{54,10}},
                                                      color={0,127,255}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(boundary.ports[1], BOP.port_a1) annotation (Line(points={{54,-42},{66,
            -42},{66,-17.6}}, color={0,127,255}));
    connect(BOP.port_b1, boundary1.ports[1]) annotation (Line(points={{80.4,-17.6},
            {80.4,-42},{90,-42}}, color={0,127,255}));
    connect(trapezoid2.y, boundary.m_flow_in) annotation (Line(points={{5,-46},{12,
            -46},{12,-44},{22,-44},{22,-34},{32,-34}}, color={0,0,127}));
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
        StopTime=500000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater;

  model LWR_L2_Turbine_AdditionalFeedheater_Concrete
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
    PrimaryHeatSystem.SMR_Generic.Components.SMR_Taveprogram_No_Pump
                                                             SMR_Taveprogram(
      port_b_nominal(
        p(displayUnit="Pa") = 3398e3,
        T(displayUnit="degC") = 580.05,
        h=2997670),
      redeclare PrimaryHeatSystem.SMR_Generic.CS_SMR_Tave CS(W_turbine=sensorW.W,
          W_Setpoint=sine.y),
      port_a_nominal(
        m_flow=67.07,
        T(displayUnit="degC") = 422.05,
        p=3447380))
      annotation (Placement(transformation(extent={{-102,-26},{-52,30}})));

    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=SMR_Taveprogram.port_b_nominal.p,
        h=SMR_Taveprogram.port_b_nominal.h,
        m_flow=-SMR_Taveprogram.port_b_nominal.m_flow), port_b1_nominal(p=
            SMR_Taveprogram.port_a_nominal.p, h=SMR_Taveprogram.port_a_nominal.h))
      annotation (Placement(transformation(extent={{-10,-18},{30,22}})));
    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
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

    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-52,28},{-6,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-38,2},{-24,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{32,0},{46,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{24,26},{70,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-26,-14},{-40,2}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-96,-56},{-52,-24}})));
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
    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));
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
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater
        CS(electric_demand_int=SC.demand_BOP.y[1]))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Components.Dual_Pipe_Model
                               CTES(
      nY=7,
      nX=9,
      tau=0.05,
      nPipes=250,
      dX=150,
      dY=0.3,
      redeclare package TES_Med =
          EnergyStorage.Concrete_Solid_Media.BaseClasses.HeatCrete,
      HTF_h_start_hot=1e6,
      HTF_h_start_cold=1e6,
      Hot_Con_Start=443.15,
      Cold_Con_Start=433.15)
      annotation (Placement(transformation(extent={{-60,-158},{10,-88}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Condensate(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=2000000,
      h=500e3,
      nPorts=1) annotation (Placement(transformation(extent={{-174,-66},{-154,
              -46}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Charge_Source(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=2130000,
      h=3000e3,
      nPorts=1) annotation (Placement(transformation(extent={{-180,-134},{-160,
              -114}})));
    Modelica.Blocks.Sources.Trapezoid Charge_Signal(
      amplitude=1,
      rising=900,
      width=28100,
      falling=900,
      period=86400,
      offset=0,
      startTime=90000)
      annotation (Placement(transformation(extent={{-160,-96},{-140,-76}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Condensate_out(redeclare
        package Medium = Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-54,-64},{-92,-88}})));
    TRANSFORM.Fluid.Valves.ValveLinear Charge_Valve(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      dp_nominal=100000,
      m_flow_nominal=10)
      annotation (Placement(transformation(extent={{-128,-130},{-96,-98}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Discharge_out(redeclare
        package Medium = Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{6,-170},{38,-150}})));
    Modelica.Blocks.Sources.Trapezoid Discharge_Signal(
      amplitude=20,
      rising=5e4,
      width=10e4,
      falling=5e4,
      period=3e5,
      offset=0.05,
      startTime=135000)
      annotation (Placement(transformation(extent={{-4,-68},{16,-48}})));
    TRANSFORM.Fluid.Machines.Pump_SimpleMassFlow pump_SimpleMassFlow1(
      m_flow_nominal=10,
      use_input=true,
      redeclare package Medium = Modelica.Media.Water.StandardWater)
                                                           annotation (
        Placement(transformation(
          extent={{-11,11},{11,-11}},
          rotation=180,
          origin={47,-89})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=9000000,
      T=373.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{92,-62},{112,-42}})));
    TRANSFORM.Fluid.Valves.ValveLinear TBV(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      dp_nominal=30000000,
      m_flow_nominal=1)                    annotation (Placement(transformation(
          extent={{-8,8},{8,-8}},
          rotation=180,
          origin={132,-52})));
    TRANSFORM.Fluid.Sensors.Pressure     sensor_p(redeclare package Medium =
          Modelica.Media.Water.StandardWater, redeclare function iconUnit =
          TRANSFORM.Units.Conversions.Functions.Pressure_Pa.to_bar)
                                                         annotation (Placement(
          transformation(
          extent={{10,-10},{-10,10}},
          rotation=180,
          origin={80,-106})));
    Modelica.Blocks.Sources.Constant const9(k=140e5)
      annotation (Placement(transformation(extent={{274,-100},{254,-80}})));
    TRANSFORM.Controls.LimPID PI_TBV(
      controllerType=Modelica.Blocks.Types.SimpleController.PI,
      k=-5e-7,
      Ti=15,
      yMax=1.0,
      yMin=0.0,
      initType=Modelica.Blocks.Types.Init.NoInit)
      annotation (Placement(transformation(extent={{228,-100},{208,-80}})));
  equation

    connect(SMR_Taveprogram.port_b, stateSensor1.port_a) annotation (Line(points={{
            -51.0909,12.7692},{-51.0909,11},{-38,11}},  color={0,127,255}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-24,11},{
            -22,11},{-22,12},{-16,12},{-16,10},{-10,10}},
                                                      color={0,127,255}));
    connect(stateSensor1.statePort, stateDisplay1.statePort) annotation (Line(
          points={{-30.965,11.045},{-22,11.045},{-22,14},{-20,14},{-20,24},{-29,24},
            {-29,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{30,10},{32,
            10},{32,9}},                        color={0,127,255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{39.035,9.045},{39.035,37.1},{47,37.1}}, color={0,0,0}));
    connect(SMR_Taveprogram.port_a, stateSensor3.port_b) annotation (Line(points={{
            -51.0909,-1.44615},{-46,-1.44615},{-46,-6},{-40,-6}},  color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-26,-6},{-10,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort, stateSensor3.statePort) annotation (Line(
          points={{-74,-44.16},{-74,-54},{-34,-54},{-34,-20},{-33.035,-20},{
            -33.035,-5.96}},
                     color={0,0,0}));
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
            118},{100,112},{106,112}},
                           color={0,0,127}));
    connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
            100},{106,100}},
                           color={0,0,127}));
    connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
            92},{98,92},{98,118},{132,118},{132,112}},
                                         color={0,0,127}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{46,9},{46,10},{54,10}},
                                                      color={0,127,255}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(Charge_Valve.port_a,Charge_Source. ports[1]) annotation (Line(points={{-128,
            -114},{-130,-114},{-130,-124},{-160,-124}},
                                                   color={0,127,255}));
    connect(Charge_Signal.y,Charge_Valve. opening)
      annotation (Line(points={{-139,-86},{-112,-86},{-112,-101.2}},
                                                              color={0,0,127}));
    connect(CTES.Charge_Inlet,Charge_Valve. port_b) annotation (Line(points={{-52.3,
            -115.3},{-88,-115.3},{-88,-112},{-94,-112},{-94,-114},{-96,-114}},
                                                                   color={0,127,255}));
    connect(CTES.Charge_Outlet,Condensate_out. port_a) annotation (Line(points={{-14.5,
            -101.3},{-14.5,-76},{-54,-76}},           color={0,127,255}));
    connect(CTES.Discharge_Outlet,Discharge_out. port_a) annotation (Line(points={{-30.6,
            -142.6},{-30,-142.6},{-30,-160},{6,-160},{6,-160}},
                                                           color={0,127,255}));
    connect(Condensate_out.port_b,Condensate. ports[1])
      annotation (Line(points={{-92,-76},{-130,-76},{-130,-56},{-154,-56}},
                                                 color={0,127,255}));
    connect(Discharge_out.port_b, BOP.port_a1) annotation (Line(points={{38,-160},
            {66,-160},{66,-17.6}},           color={0,127,255}));
    connect(CTES.Discharge_Inlet, pump_SimpleMassFlow1.port_b) annotation (Line(
          points={{2.3,-123.7},{2,-123.7},{2,-124},{20,-124},{20,-88},{36,-88},
            {36,-89}},                                               color={0,
            127,255}));
    connect(pump_SimpleMassFlow1.port_a, BOP.port_b1) annotation (Line(points={
            {58,-89},{80.4,-89},{80.4,-17.6}}, color={0,127,255}));
    connect(Discharge_Signal.y, pump_SimpleMassFlow1.in_m_flow) annotation (
        Line(points={{17,-58},{47,-58},{47,-80.97}},
          color={0,0,127}));
    connect(boundary.ports[1], TBV.port_b) annotation (Line(points={{112,-52},{
            124,-52}},           color={0,127,255}));
    connect(TBV.port_a, pump_SimpleMassFlow1.port_a) annotation (Line(points={{
            140,-52},{146,-52},{146,-89},{58,-89}}, color={0,127,255}));
    connect(sensor_p.port, pump_SimpleMassFlow1.port_a) annotation (Line(points={{80,-96},
            {80,-89},{58,-89}},          color={0,127,255}));
    connect(const9.y,PI_TBV. u_s)
      annotation (Line(points={{253,-90},{230,-90}},
                                                   color={0,0,127}));
    connect(sensor_p.p, PI_TBV.u_m) annotation (Line(points={{86,-106},{218,
            -106},{218,-102}},                       color={0,0,127}));
    connect(PI_TBV.y, TBV.opening) annotation (Line(points={{207,-90},{166,-90},
            {166,-40},{132,-40},{132,-45.6}}, color={0,0,127}));
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
        StopTime=500000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_Concrete;

  model LWR_L2_Turbine_AdditionalFeedheater_Therminol
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
    PrimaryHeatSystem.SMR_Generic.Components.SMR_Taveprogram_No_Pump
                                                             SMR_Taveprogram(
      port_b_nominal(
        p(displayUnit="Pa") = 3398e3,
        T(displayUnit="degC") = 580.05,
        h=2997670),
      redeclare PrimaryHeatSystem.SMR_Generic.CS_SMR_Tave CS(W_turbine=sensorW.W,
          W_Setpoint=sine.y),
      port_a_nominal(
        m_flow=67.07,
        T(displayUnit="degC") = 422.05,
        p=3447380))
      annotation (Placement(transformation(extent={{-102,-26},{-52,30}})));

    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=SMR_Taveprogram.port_b_nominal.p,
        h=SMR_Taveprogram.port_b_nominal.h,
        m_flow=-SMR_Taveprogram.port_b_nominal.m_flow), port_b1_nominal(p=
            SMR_Taveprogram.port_a_nominal.p, h=SMR_Taveprogram.port_a_nominal.h))
      annotation (Placement(transformation(extent={{-10,-18},{30,22}})));
    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
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

    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-52,28},{-6,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-38,2},{-24,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{32,0},{46,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{24,26},{70,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-26,-14},{-40,2}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-96,-56},{-52,-24}})));
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
    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));
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
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater_therminol BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater
        CS(electric_demand_int=SC.demand_BOP.y[1]))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Components.Dual_Pipe_Model
                               CTES(
      nY=7,
      nX=9,
      tau=0.05,
      nPipes=250,
      dX=150,
      dY=0.3,
      redeclare package HTF =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      redeclare package TES_Med =
          EnergyStorage.Concrete_Solid_Media.BaseClasses.HeatCrete,
      HTF_h_start_hot=1e6,
      HTF_h_start_cold=1e6,
      Hot_Con_Start=443.15,
      Cold_Con_Start=433.15)
      annotation (Placement(transformation(extent={{-60,-158},{10,-88}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Condensate(
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      p=2000000,
      h=500e3,
      nPorts=1) annotation (Placement(transformation(extent={{54,-52},{34,-32}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Charge_Source(
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      p=2130000,
      h=3000e3,
      nPorts=1) annotation (Placement(transformation(extent={{-166,-126},{-146,-106}})));
    Modelica.Blocks.Sources.Trapezoid Charge_Signal(
      amplitude=1,
      rising=900,
      width=28100,
      falling=900,
      period=86400,
      offset=0,
      startTime=90000)
      annotation (Placement(transformation(extent={{-152,-94},{-132,-74}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Condensate_out(redeclare
        package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C)
      annotation (Placement(transformation(extent={{-10,-60},{28,-84}})));
    TRANSFORM.Fluid.Valves.ValveLinear Charge_Valve(
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      dp_nominal=100000,
      m_flow_nominal=10)
      annotation (Placement(transformation(extent={{-128,-130},{-96,-98}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Discharge_out(redeclare
        package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C)
      annotation (Placement(transformation(extent={{18,-152},{50,-132}})));
    Modelica.Blocks.Sources.Trapezoid Discharge_Signal(
      amplitude=20,
      rising=1e4,
      width=28100,
      falling=1e4,
      period=86400,
      offset=0.05,
      startTime=135000)
      annotation (Placement(transformation(extent={{16,-192},{36,-172}})));
    TRANSFORM.Fluid.Machines.Pump_SimpleMassFlow pump_SimpleMassFlow1(
      m_flow_nominal=10,
      use_input=true,
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C)
                                                           annotation (
        Placement(transformation(
          extent={{-11,-11},{11,11}},
          rotation=180,
          origin={47,-89})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary(
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      p=500000,
      T=373.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{92,-60},{112,-40}})));
    TRANSFORM.Fluid.Valves.ValveLinear TBV(
      redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C,
      dp_nominal=100000,
      m_flow_nominal=50)                   annotation (Placement(transformation(
          extent={{-8,8},{8,-8}},
          rotation=180,
          origin={132,-52})));
    TRANSFORM.Fluid.Sensors.Pressure     sensor_p(redeclare package Medium =
          TRANSFORM.Media.Fluids.Therminol_66.LinearTherminol66_A_250C, redeclare
        function                                                                           iconUnit =
          TRANSFORM.Units.Conversions.Functions.Pressure_Pa.to_bar)
                                                         annotation (Placement(
          transformation(
          extent={{10,-10},{-10,10}},
          rotation=180,
          origin={84,-106})));
    Modelica.Blocks.Sources.Constant const9(k=10e5)
      annotation (Placement(transformation(extent={{168,-100},{188,-80}})));
    TRANSFORM.Controls.LimPID PI_TBV(
      controllerType=Modelica.Blocks.Types.SimpleController.PI,
      k=-5e-7,
      Ti=15,
      yMax=1.0,
      yMin=0.0,
      initType=Modelica.Blocks.Types.Init.NoInit)
      annotation (Placement(transformation(extent={{208,-100},{228,-80}})));
  equation

    connect(SMR_Taveprogram.port_b, stateSensor1.port_a) annotation (Line(points={{
            -51.0909,12.7692},{-51.0909,11},{-38,11}},  color={0,127,255}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-24,11},{
            -22,11},{-22,12},{-16,12},{-16,10},{-10,10}},
                                                      color={0,127,255}));
    connect(stateSensor1.statePort, stateDisplay1.statePort) annotation (Line(
          points={{-30.965,11.045},{-22,11.045},{-22,14},{-20,14},{-20,24},{-29,24},
            {-29,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{30,10},{32,
            10},{32,9}},                        color={0,127,255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{39.035,9.045},{39.035,37.1},{47,37.1}}, color={0,0,0}));
    connect(SMR_Taveprogram.port_a, stateSensor3.port_b) annotation (Line(points={{
            -51.0909,-1.44615},{-46,-1.44615},{-46,-6},{-40,-6}},  color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-26,-6},{-10,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort, stateSensor3.statePort) annotation (Line(
          points={{-74,-44.16},{-74,-56},{-52,-56},{-52,-18},{-33.035,-18},{-33.035,
            -5.96}}, color={0,0,0}));
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
            118},{100,112},{106,112}},
                           color={0,0,127}));
    connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
            100},{106,100}},
                           color={0,0,127}));
    connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
            92},{98,92},{98,118},{132,118},{132,112}},
                                         color={0,0,127}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{46,9},{46,10},{54,10}},
                                                      color={0,127,255}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(Charge_Valve.port_a,Charge_Source. ports[1]) annotation (Line(points={{-128,
            -114},{-138,-114},{-138,-116},{-146,-116}},
                                                   color={0,127,255}));
    connect(Charge_Signal.y,Charge_Valve. opening)
      annotation (Line(points={{-131,-84},{-112,-84},{-112,-101.2}},
                                                              color={0,0,127}));
    connect(CTES.Charge_Inlet,Charge_Valve. port_b) annotation (Line(points={{-52.3,
            -115.3},{-88,-115.3},{-88,-112},{-94,-112},{-94,-114},{-96,-114}},
                                                                   color={0,127,255}));
    connect(CTES.Charge_Outlet,Condensate_out. port_a) annotation (Line(points={{-14.5,
            -101.3},{-14.5,-72},{-10,-72}},           color={0,127,255}));
    connect(CTES.Discharge_Outlet,Discharge_out. port_a) annotation (Line(points={{-30.6,
            -142.6},{-6,-142.6},{-6,-142},{18,-142},{18,-142},{18,-142}},
                                                           color={0,127,255}));
    connect(Condensate_out.port_b,Condensate. ports[1])
      annotation (Line(points={{28,-72},{32,-72},{32,-56},{26,-56},{26,-42},{34,-42}},
                                                 color={0,127,255}));
    connect(Discharge_out.port_b, BOP.port_a1) annotation (Line(points={{50,-142},
            {50,-120},{66,-120},{66,-17.6}}, color={0,127,255}));
    connect(CTES.Discharge_Inlet, pump_SimpleMassFlow1.port_b) annotation (Line(
          points={{2.3,-123.7},{2.3,-105.85},{36,-105.85},{36,-89}}, color={0,
            127,255}));
    connect(pump_SimpleMassFlow1.port_a, BOP.port_b1) annotation (Line(points={
            {58,-89},{80.4,-89},{80.4,-17.6}}, color={0,127,255}));
    connect(Discharge_Signal.y, pump_SimpleMassFlow1.in_m_flow) annotation (
        Line(points={{37,-182},{68,-182},{68,-128},{47,-128},{47,-97.03}},
          color={0,0,127}));
    connect(boundary.ports[1], TBV.port_b) annotation (Line(points={{112,-50},{
            112,-52},{124,-52}}, color={0,127,255}));
    connect(TBV.port_a, pump_SimpleMassFlow1.port_a) annotation (Line(points={{
            140,-52},{146,-52},{146,-89},{58,-89}}, color={0,127,255}));
    connect(sensor_p.port, pump_SimpleMassFlow1.port_a) annotation (Line(points=
           {{84,-96},{84,-89},{58,-89}}, color={0,127,255}));
    connect(const9.y,PI_TBV. u_s)
      annotation (Line(points={{189,-90},{206,-90}},
                                                   color={0,0,127}));
    connect(sensor_p.p, PI_TBV.u_m) annotation (Line(points={{90,-106},{154,
            -106},{154,-108},{218,-108},{218,-102}}, color={0,0,127}));
    connect(PI_TBV.y, TBV.opening) annotation (Line(points={{229,-90},{228,-90},
            {228,-38},{132,-38},{132,-45.6}}, color={0,0,127}));
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
        StopTime=500000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_Therminol;

  model LWR_L2_Turbine_AdditionalFeedheater_QuickSim
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
    PrimaryHeatSystem.SMR_Generic.Components.SMR_Taveprogram_No_Pump
                                                             SMR_Taveprogram(
      port_b_nominal(
        p(displayUnit="Pa") = 3398e3,
        T(displayUnit="degC") = 580.05,
        h=2997670),
      redeclare PrimaryHeatSystem.SMR_Generic.CS_SMR_Tave CS(W_turbine=sensorW.W,
          W_Setpoint=sine.y),
      port_a_nominal(
        m_flow=67.07,
        T(displayUnit="degC") = 422.05,
        p=3447380))
      annotation (Placement(transformation(extent={{-102,-26},{-52,30}})));

    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=SMR_Taveprogram.port_b_nominal.p,
        h=SMR_Taveprogram.port_b_nominal.h,
        m_flow=-SMR_Taveprogram.port_b_nominal.m_flow), port_b1_nominal(p=
            SMR_Taveprogram.port_a_nominal.p, h=SMR_Taveprogram.port_a_nominal.h))
      annotation (Placement(transformation(extent={{-10,-18},{30,22}})));
    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
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

    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-52,28},{-6,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-38,2},{-24,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{32,0},{46,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{24,26},{70,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-26,-14},{-40,2}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-96,-56},{-52,-24}})));
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
    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));
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
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl
        CS(electric_demand_int=SC.demand_BOP.y[1]))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Discharge_out(redeclare
        package Medium = Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{2,-52},{34,-32}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=9500000,
      T=373.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{92,-62},{112,-42}})));
    TRANSFORM.Fluid.Valves.ValveLinear TBV(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      dp_nominal=500000,
      m_flow_nominal=45)                   annotation (Placement(transformation(
          extent={{-8,8},{8,-8}},
          rotation=180,
          origin={132,-52})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary1(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p=10000000,
      T=463.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{-28,-52},{-8,-32}})));
    Modelica.Blocks.Sources.Trapezoid Discharge_Signal(
      amplitude=1,
      rising=5e4,
      width=10e4,
      falling=5e4,
      period=3e5,
      offset=0,
      startTime=135000)
      annotation (Placement(transformation(extent={{182,-52},{162,-32}})));
  equation

    connect(SMR_Taveprogram.port_b, stateSensor1.port_a) annotation (Line(points={{
            -51.0909,12.7692},{-51.0909,11},{-38,11}},  color={0,127,255}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-24,11},{
            -22,11},{-22,12},{-16,12},{-16,10},{-10,10}},
                                                      color={0,127,255}));
    connect(stateSensor1.statePort, stateDisplay1.statePort) annotation (Line(
          points={{-30.965,11.045},{-22,11.045},{-22,14},{-20,14},{-20,24},{-29,24},
            {-29,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{30,10},{32,
            10},{32,9}},                        color={0,127,255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{39.035,9.045},{39.035,37.1},{47,37.1}}, color={0,0,0}));
    connect(SMR_Taveprogram.port_a, stateSensor3.port_b) annotation (Line(points={{
            -51.0909,-1.44615},{-46,-1.44615},{-46,-6},{-40,-6}},  color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-26,-6},{-10,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort, stateSensor3.statePort) annotation (Line(
          points={{-74,-44.16},{-74,-54},{-34,-54},{-34,-20},{-33.035,-20},{
            -33.035,-5.96}},
                     color={0,0,0}));
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(trapezoid.y, add.u1) annotation (Line(points={{87,122},{87,118},{100,
            118},{100,112},{106,112}},
                           color={0,0,127}));
    connect(trapezoid1.y, add.u2) annotation (Line(points={{87,86},{100,86},{100,
            100},{106,100}},
                           color={0,0,127}));
    connect(add.y, sum1.u[1]) annotation (Line(points={{129,106},{128,106},{128,
            92},{98,92},{98,118},{132,118},{132,112}},
                                         color={0,0,127}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{46,9},{46,10},{54,10}},
                                                      color={0,127,255}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(Discharge_out.port_b, BOP.port_a1) annotation (Line(points={{34,-42},{
            66,-42},{66,-17.6}},             color={0,127,255}));
    connect(boundary.ports[1], TBV.port_b) annotation (Line(points={{112,-52},{
            124,-52}},           color={0,127,255}));
    connect(boundary1.ports[1], Discharge_out.port_a) annotation (Line(points={{-8,-42},
            {2,-42}},                                 color={0,127,255}));
    connect(BOP.port_b1, TBV.port_a) annotation (Line(points={{80.4,-17.6},{
            80.4,-70},{148,-70},{148,-52},{140,-52}}, color={0,127,255}));
    connect(Discharge_Signal.y, TBV.opening) annotation (Line(points={{161,-42},{132,
            -42},{132,-45.6}},                                       color={0,0,
            127}));
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
        StopTime=500000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_QuickSim;
end FWHPT;
