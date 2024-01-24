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
    connect(CTES.Charge_Outlet,Condensate_out. port_a) annotation (Line(points={{-52.3,
            -135.6},{-52.3,-72},{-10,-72}},           color={0,127,255}));
    connect(CTES.Discharge_Outlet,Discharge_out. port_a) annotation (Line(points={{3,
            -115.3},{-6,-115.3},{-6,-142},{18,-142},{18,-142},{18,-142}},
                                                           color={0,127,255}));
    connect(Condensate_out.port_b,Condensate. ports[1])
      annotation (Line(points={{28,-72},{32,-72},{32,-56},{26,-56},{26,-42},{34,-42}},
                                                 color={0,127,255}));
    connect(Discharge_out.port_b, BOP.port_a1) annotation (Line(points={{50,-142},
            {50,-120},{66,-120},{66,-17.6}}, color={0,127,255}));
    connect(CTES.Discharge_Inlet, pump_SimpleMassFlow1.port_b) annotation (Line(
          points={{2.3,-137.7},{2.3,-105.85},{36,-105.85},{36,-89}}, color={0,
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

  model Parabolic_Trough_Dual_Pipe_CTES_Water
    extends Modelica.Icons.Example;
    parameter Modelica.Units.SI.MassFlowRate shell_flow_shim=1.5;
    parameter Modelica.Units.SI.MassFlowRate tube_flow_shim=1.5;
    EnergyStorage.Concrete_Solid_Media.Components.Dual_Pipe_Model CTES(
      nY=7,
      nX=9,
      tau=0.05,
      nPipes=250,
      dX=150,
      dY=0.3,
      redeclare package TES_Med =
          EnergyStorage.Concrete_Solid_Media.BaseClasses.HeatCrete,
      Hot_Con_Start=443.15,
      Cold_Con_Start=363.15)
      annotation (Placement(transformation(extent={{-38,-38},{32,32}})));

    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Discharge_Exit(
      redeclare package Medium =
          Modelica.Media.Water.StandardWater,
      p=90000,
      h=800e3,
      nPorts=1)
      annotation (Placement(transformation(extent={{146,-54},{126,-34}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Condensate_out(redeclare
        package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-52,-22},{-90,-46}})));
    TRANSFORM.Fluid.Sensors.SpecificEnthalpyTwoPort Discharge_out(redeclare
        package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{68,-62},{100,-42}})));
    Modelica.Blocks.Sources.Trapezoid Discharge_Signal(
      amplitude=1,
      rising=900,
      width=28100,
      falling=900,
      period=86400,
      offset=0,
      startTime=135000)
      annotation (Placement(transformation(extent={{38,10},{58,30}})));
    TRANSFORM.Fluid.Valves.ValveLinear Discharge_Valve(
      redeclare package Medium =
          Modelica.Media.Water.StandardWater,
      dp_nominal=150000,
      m_flow_nominal=10)
      annotation (Placement(transformation(extent={{106,-22},{68,16}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_ph Discharge_Source(
      redeclare package Medium =
          Modelica.Media.Water.StandardWater,
      p=100000,
      h=400e3,
      nPorts=1) annotation (Placement(transformation(extent={{146,-14},{126,6}})));
    TRANSFORM.Fluid.BoundaryConditions.MassFlowSource_T boundary(
      redeclare package Medium =
          Modelica.Media.Water.StandardWater,
      m_flow=0.5,
      T=298.15,
      nPorts=1)
      annotation (Placement(transformation(extent={{-162,-74},{-142,-54}})));
    TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary1(
      redeclare package Medium =
          Modelica.Media.Water.StandardWater,
      p=200000,
      T=423.15,
      nPorts=1) annotation (Placement(transformation(extent={{-66,-72},{-86,-52}})));
   ThermoCycle.Components.Units.Solar.SolarField_SchottSopo         solarCollectorIncSchott1(
      Mdotnom=0.5,
      redeclare model FluidHeatTransferModel =
          ThermoCycle.Components.HeatFlow.HeatTransfer.Ideal,
      redeclare
        ThermoCycle.Components.HeatFlow.Walls.SolarAbsorber.Geometry.Schott_SopoNova.Schott_2008_PTR70_Vacuum
        CollectorGeometry,
      redeclare package Medium1 = Modelica.Media.Water.StandardWater,
      Ns=2,
      Tstart_inlet=298.15,
      Tstart_outlet=373.15,
      pstart=1000000)
      annotation (Placement(transformation(extent={{-146,-10},{-104,60}})));
    Modelica.Blocks.Sources.Constant const2(k=25 + 273.15)
      annotation (Placement(transformation(extent={{-206,10},{-186,30}})));
    Modelica.Blocks.Sources.Constant const4(k=0)
      annotation (Placement(transformation(extent={{-206,36},{-186,56}})));
    Modelica.Blocks.Sources.Constant const5(k=0)
      annotation (Placement(transformation(extent={{-204,66},{-184,86}})));
    Modelica.Blocks.Sources.Step step1(
      startTime=100,
      height=0,
      offset=0)
      annotation (Placement(transformation(extent={{-206,-22},{-186,-2}})));
  equation

    connect(Discharge_Source.ports[1], Discharge_Valve.port_a) annotation (Line(
          points={{126,-4},{120,-4},{120,-3},{106,-3}},
                                                    color={0,127,255}));
    connect(Discharge_Signal.y, Discharge_Valve.opening)
      annotation (Line(points={{59,20},{87,20},{87,12.2}}, color={0,0,127}));
    connect(CTES.Charge_Outlet, Condensate_out.port_a) annotation (Line(points={{-30.3,
            -15.6},{-30.3,-14},{-46,-14},{-46,-34},{-52,-34}},
                                                      color={0,127,255}));
    connect(CTES.Discharge_Inlet, Discharge_Valve.port_b) annotation (Line(points={{24.3,
            -17.7},{62.15,-17.7},{62.15,-3},{68,-3}}, color={0,127,255}));
    connect(CTES.Discharge_Outlet, Discharge_out.port_a) annotation (Line(points={{25,4.7},
            {62,4.7},{62,-52},{68,-52}},                   color={0,127,255}));
    connect(Discharge_out.port_b, Discharge_Exit.ports[1])
      annotation (Line(points={{100,-52},{120,-52},{120,-44},{126,-44}},
                                                     color={0,127,255}));

    connect(boundary1.ports[1], Condensate_out.port_b) annotation (Line(points=
            {{-86,-62},{-96,-62},{-96,-34},{-90,-34}}, color={0,127,255}));
    connect(const5.y, solarCollectorIncSchott1.v_wind) annotation (Line(
        points={{-183,76},{-168,76},{-168,52},{-142.733,52},{-142.733,53}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const4.y, solarCollectorIncSchott1.CosEff) annotation (Line(
        points={{-185,46},{-160,46},{-160,39.3182},{-142.5,39.3182}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(const2.y, solarCollectorIncSchott1.Tamb) annotation (Line(
        points={{-185,20},{-166,20},{-166,24.0455},{-142.967,24.0455}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(step1.y, solarCollectorIncSchott1.DNI) annotation (Line(
        points={{-185,-12},{-168,-12},{-168,5.5909},{-142.5,5.5909}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(boundary.ports[1], solarCollectorIncSchott1.InFlow) annotation (Line(
          points={{-142,-64},{-118,-64},{-118,-10.6364}}, color={0,127,255}));
    connect(solarCollectorIncSchott1.OutFlow, CTES.Charge_Inlet) annotation (Line(
          points={{-118,59.3636},{-118,66},{-46,66},{-46,4.7},{-30.3,4.7}}, color=
           {0,0,255}));
    annotation (experiment(
        StopTime=864000,
        __Dymola_NumberOfIntervals=1957,
        __Dymola_Algorithm="Esdirk45a"),
      Diagram(coordinateSystem(extent={{-120,-100},{160,100}})),
      Icon(coordinateSystem(extent={{-120,-100},{160,100}})));
  end Parabolic_Trough_Dual_Pipe_CTES_Water;

  model LWR_L2_Turbine_AdditionalFeedheater_Combination
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_Feedwater
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Basic CS(DNI_Input=
            DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{18,48},{38,68}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{39,58},{52,58},{52,
            68},{58,68}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_Combination;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass CS(DNI_Input=
            DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{18,48},{38,68}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{39,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl_200
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
   Real Effficiency = (BOP.generator1.Q_mech/PHS[1].Q_total.y)*100;

    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
    BaseClasses.Data_Capacity dataCapacity(IP_capacity(displayUnit="MW")=
        53303300, BOP_capacity(displayUnit="MW") = 1165000000)
      annotation (Placement(transformation(extent={{-100,82},{-80,102}})));
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM1.port_b2_nominal.p,
        h=EM1.port_b2_nominal.h,
        m_flow=-EM1.port_b2_nominal.m_flow),
      port_b_nominal(p=EM1.port_a2_nominal.p, h=EM1.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow_200_2
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass_200
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass_200_2 CS(DNI_Input=
            DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=0,
      rising=1e4,
      width=1e6,
      falling=100,
      period=2e6,
      offset=50e6,
      startTime=1e5)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=15e6)
                 annotation (Placement(transformation(extent={{18,48},{38,68}})));
    PrimaryHeatSystem.GenericModular_PWR.GenericModule PHS[1](redeclare
        NHES.Systems.PrimaryHeatSystem.GenericModular_PWR.CS_SteadyState CS)
      annotation (Placement(transformation(extent={{-178,-26},{-122,30}})));
      EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM1(
        port_a1_nominal(
        p=PHS[1].port_b_nominal.p,
        h=PHS[1].port_b_nominal.h,
        m_flow=sum(-PHS.port_b_nominal.m_flow)), port_b1_nominal(p=PHS[1].port_a_nominal.p,
          h=PHS[1].port_a_nominal.h))
      "{-IP.port_a_nominal.m_flow}"                                                                              annotation (Placement(transformation(extent={{-78,-26},
              {-22,30}})));
    TRANSFORM.Fluid.Volumes.MixingVolume volume(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      p_start=PHS[1].port_b_nominal.p,
      use_T_start=false,
      h_start=PHS[1].port_b_nominal.h,
      redeclare model Geometry =
          TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
          (V=0.001),
      nPorts_b=1,
      nPorts_a=1)
      annotation (Placement(transformation(extent={{-110,2},{-90,22}})));
    TRANSFORM.Fluid.Volumes.MixingVolume volume1(
      redeclare package Medium = Modelica.Media.Water.StandardWater,
      use_T_start=false,
      redeclare model Geometry =
          TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
          (V=0.001),
      p_start=PHS[1].port_a_nominal.p,
      h_start=PHS[1].port_a_nominal.h,
      nPorts_b=1,
      nPorts_a=1)
      annotation (Placement(transformation(extent={{-90,-20},{-110,0}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{39,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
    connect(EM1.port_b2, BOP.port_a) annotation (Line(points={{-22,13.2},{28,13.2},
            {28,10},{54,10}}, color={0,127,255}));
    connect(EM1.port_a2, BOP.port_b) annotation (Line(points={{-22,-9.2},{28,-9.2},
            {28,-6},{54,-6}}, color={0,127,255}));
    connect(PHS.port_a,volume1. port_b) annotation (Line(points={{-122,-9.2},{
            -114,-9.2},{-114,-10},{-106,-10}},          color={0,127,255}));
    connect(volume1.port_a[1], EM1.port_b1) annotation (Line(points={{-94,-10},{-86,
            -10},{-86,-9.2},{-78,-9.2}}, color={0,127,255}));
    connect(volume.port_b[1], EM1.port_a1) annotation (Line(points={{-94,12},{-86,
            12},{-86,13.2},{-78,13.2}}, color={0,127,255}));
    connect(PHS.port_b,volume. port_a) annotation (Line(points={{-122,13.2},{
            -114,13.2},{-114,12},{-106,12}},             color={0,127,255}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl_200;

  model HTGR_Ex1
    "High Fidelity Natural Circulation Model based on NuScale reactor. Hot channel calcs, pressurizer, and beginning of cycle reactivity feedback"
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

    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{100,-22},{140,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{160,-20},{200,20}})));
    BaseClasses.Data_Capacity dataCapacity(IP_capacity(displayUnit="MW")=
        53303300, BOP_capacity(displayUnit="MW") = 60000000)
      annotation (Placement(transformation(extent={{-100,82},{-80,102}})));
    Modelica.Blocks.Sources.Constant delayStart(k=10000)
      annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 60000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Uprate_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));
    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM(port_a1_nominal(
        p=14000000,
        h=3e6,
        m_flow=50), port_b1_nominal(p=14100000, h=2e6))
      annotation (Placement(transformation(extent={{-34,-18},{6,22}})));
    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-80,28},{-34,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-52,2},{-38,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{10,0},{24,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{-4,26},{42,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-44,-14},{-58,2}})));
    PrimaryHeatSystem.HTGR.HTGR_Rankine.Components.HTGR_PebbleBed_Primary_Loop_STHX
      hTGR_PebbleBed_Primary_Loop_TESUC(redeclare
        PrimaryHeatSystem.HTGR.HTGR_Rankine.ControlSystems.CS_Rankine_Primary_SS_ClosedFeedheat
        CS(data(P_Steam_Ref=14000000)))
      annotation (Placement(transformation(extent={{-106,-20},{-62,22}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-120,-54},{-76,-22}})));
    BalanceOfPlant.Turbine.HTGR_RankineCycles.HTGR_Rankine_Cycle_Transient BOP(
        redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_Rankine_Xe100_Based_Secondary_TransientControl
        CS) annotation (Placement(transformation(extent={{46,-22},{86,22}})));
  equation
      hTGR_PebbleBed_Primary_Loop_TESUC.input_steam_pressure =
      BOP.sensor_p.p;
    connect(SY.port_Grid, EG.portElec_a)
      annotation (Line(points={{140,0},{160,0}}, color={255,0,0}));
    connect(stateSensor1.port_b, EM.port_a1) annotation (Line(points={{-38,11},{-38,
            10},{-34,10}},                            color={0,127,255}));
    connect(stateSensor1.statePort,stateDisplay1. statePort) annotation (Line(
          points={{-44.965,11.045},{-50,11.045},{-50,14},{-48,14},{-48,24},{-57,24},
            {-57,39.1}}, color={0,0,0}));
    connect(EM.port_b2, stateSensor2.port_a) annotation (Line(points={{6,10},{4,10},
            {4,12},{6,12},{6,9},{10,9}}, color={0,127,255}));
    connect(stateSensor3.port_a, EM.port_b1)
      annotation (Line(points={{-44,-6},{-34,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort,stateSensor3. statePort) annotation (Line(
          points={{-98,-42.16},{-98,-58},{-50,-58},{-50,-10},{-51.035,-10},{-51.035,
            -5.96}}, color={0,0,0}));
    connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_b,stateSensor1. port_a)
      annotation (Line(points={{-62.66,11.29},{-52,11}}, color={0,127,255}));
    connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_a,stateSensor3. port_b)
      annotation (Line(points={{-62.66,-5.93},{-62.66,-6},{-58,-6}}, color={0,127,
            255}));
    connect(stateSensor2.statePort, stateDisplay2.statePort) annotation (Line(
          points={{17.035,9.045},{17.035,23.5225},{19,23.5225},{19,37.1}}, color={
            0,0,0}));
    connect(BOP.port_e, SY.port_a[1])
      annotation (Line(points={{86,0},{100,0}}, color={255,0,0}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{24,9},{24,8.8},{46,8.8}}, color={0,127,255}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{6,-6},{40,-6},{40,-8.8},
            {46,-8.8}}, color={0,127,255}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
              -100},{220,100}}), graphics={
          Ellipse(lineColor = {75,138,73},
                  fillColor={255,255,255},
                  fillPattern = FillPattern.Solid,
                  extent={{-38,-104},{162,96}}),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points={{26,52},{126,-8},{26,-68},{26,52}})}),
                                  Diagram(coordinateSystem(preserveAspectRatio=
              false, extent={{-100,-100},{220,100}})),
      experiment(
        StopTime=1000000,
        Interval=3.5,
        __Dymola_Algorithm="Esdirk45a"));
  end HTGR_Ex1;

  model HTGR_AdditionalFeedheater_NewControl_265
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
   //Real Effficiency = (BOP.generator1.Q_mech/PHS[1].Q_total.y)*100;

    SwitchYard.SimpleYard.SimpleConnections SY(nPorts_a=1)
      annotation (Placement(transformation(extent={{114,-22},{154,22}})));
    ElectricalGrid.InfiniteGrid.Infinite EG
      annotation (Placement(transformation(extent={{192,-20},{232,20}})));
    BaseClasses.Data_Capacity dataCapacity(IP_capacity(displayUnit="MW")=
        53303300, BOP_capacity(displayUnit="MW") = 1165000000)
      annotation (Placement(transformation(extent={{-100,82},{-80,102}})));
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM1.port_b2_nominal.p,
        h=EM1.port_b2_nominal.h,
        m_flow=-EM1.port_b2_nominal.m_flow),
      port_b_nominal(p=EM1.port_a2_nominal.p, h=EM1.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow_200_2
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass_200
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass_200_2 CS(DNI_Input=
            DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=0,
      rising=1e4,
      width=1e6,
      falling=100,
      period=2e6,
      offset=50e6,
      startTime=1e5)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=15e6)
                 annotation (Placement(transformation(extent={{18,48},{38,68}})));
    EnergyManifold.SteamManifold.SteamManifold_L1_boundaries EM1(port_a1_nominal(
        p=14000000,
        h=3e6,
        m_flow=50), port_b1_nominal(p=14100000, h=2e6))
      annotation (Placement(transformation(extent={{-74,-18},{-34,22}})));
    Fluid.Sensors.stateDisplay stateDisplay1
      annotation (Placement(transformation(extent={{-120,28},{-74,58}})));
    Fluid.Sensors.stateSensor stateSensor1(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-92,2},{-78,20}})));
    Fluid.Sensors.stateSensor stateSensor2(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-30,0},{-16,18}})));
    Fluid.Sensors.stateDisplay stateDisplay2
      annotation (Placement(transformation(extent={{-44,26},{2,56}})));
    Fluid.Sensors.stateSensor stateSensor3(redeclare package Medium =
          Modelica.Media.Water.StandardWater)
      annotation (Placement(transformation(extent={{-84,-14},{-98,2}})));
    PrimaryHeatSystem.HTGR.HTGR_Rankine.Components.HTGR_PebbleBed_Primary_Loop_STHX
      hTGR_PebbleBed_Primary_Loop_TESUC(redeclare
        PrimaryHeatSystem.HTGR.HTGR_Rankine.ControlSystems.CS_Rankine_Primary_SS_ClosedFeedheat
        CS(data(P_Steam_Ref=14000000)))
      annotation (Placement(transformation(extent={{-146,-20},{-102,22}})));
    Fluid.Sensors.stateDisplay stateDisplay3
      annotation (Placement(transformation(extent={{-160,-54},{-116,-22}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
      hTGR_PebbleBed_Primary_Loop_TESUC.input_steam_pressure =
      BOP.sensor_p.p;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{39,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
    connect(stateSensor1.port_b, EM1.port_a1)
      annotation (Line(points={{-78,11},{-78,10},{-74,10}}, color={0,127,255}));
    connect(stateSensor1.statePort,stateDisplay1. statePort) annotation (Line(
          points={{-84.965,11.045},{-90,11.045},{-90,14},{-88,14},{-88,24},{-97,24},
            {-97,39.1}}, color={0,0,0}));
    connect(EM1.port_b2, stateSensor2.port_a) annotation (Line(points={{-34,10},{-36,
            10},{-36,12},{-34,12},{-34,9},{-30,9}}, color={0,127,255}));
    connect(stateSensor3.port_a, EM1.port_b1)
      annotation (Line(points={{-84,-6},{-74,-6}}, color={0,127,255}));
    connect(stateDisplay3.statePort,stateSensor3. statePort) annotation (Line(
          points={{-138,-42.16},{-138,-58},{-90,-58},{-90,-10},{-91.035,-10},{-91.035,
            -5.96}}, color={0,0,0}));
    connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_b,stateSensor1. port_a)
      annotation (Line(points={{-102.66,11.29},{-92,11}},color={0,127,255}));
    connect(hTGR_PebbleBed_Primary_Loop_TESUC.port_a,stateSensor3. port_b)
      annotation (Line(points={{-102.66,-5.93},{-102.66,-6},{-98,-6}},
                                                                     color={0,127,
            255}));
    connect(stateSensor2.statePort,stateDisplay2. statePort) annotation (Line(
          points={{-22.965,9.045},{-22.965,23.5225},{-21,23.5225},{-21,37.1}},
                                                                           color={
            0,0,0}));
    connect(stateSensor2.port_b, BOP.port_a)
      annotation (Line(points={{-16,9},{-16,10},{54,10}}, color={0,127,255}));
    connect(EM1.port_a2, BOP.port_b)
      annotation (Line(points={{-34,-6},{54,-6}}, color={0,127,255}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end HTGR_AdditionalFeedheater_NewControl_265;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl2
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
    parameter String fileName2=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/CosEff_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass2 CS(DNI_Input=
           DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1], CosEff_Input=CosEff_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{16,48},{36,68}})));
    Modelica.Blocks.Sources.CombiTimeTable CosEff_Input(
      tableOnFile=true,
      offset={0.01},
      startTime=0,
      tableName="CosEff",
      timeScale=timeScale,
      fileName=fileName2)
      annotation (Placement(transformation(extent={{-62,42},{-42,62}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{37,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl2;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl2_FMU
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
    parameter String fileName2=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/CosEff_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater_FMU
                                                                               BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=PowerTransient))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass2 CS(DNI_Input=
           DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1], CosEff_Input=CosEff_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{18,48},{38,68}})));
    Modelica.Blocks.Sources.CombiTimeTable CosEff_Input(
      tableOnFile=true,
      offset={0.01},
      startTime=0,
      tableName="CosEff",
      timeScale=timeScale,
      fileName=fileName2)
      annotation (Placement(transformation(extent={{-62,42},{-42,62}})));
    Modelica.Blocks.Interfaces.RealInput PowerTransient
      annotation (Placement(transformation(extent={{-140,20},{-100,60}})));
    Modelica.Blocks.Interfaces.RealInput PumpFeedForward
      annotation (Placement(transformation(extent={{-140,-66},{-100,-26}})));
    Modelica.Blocks.Interfaces.RealOutput PowerOut annotation (Placement(
          transformation(extent={{240,24},{270,54}}), iconTransformation(extent=
             {{240,24},{270,54}})));
    Modelica.Blocks.Interfaces.RealOutput MassFlowRate annotation (Placement(
          transformation(extent={{240,-58},{270,-28}}), iconTransformation(
            extent={{240,-58},{270,-28}})));
    TRANSFORM.Fluid.Sensors.MassFlowRate sensor_m_flow
      annotation (Placement(transformation(extent={{-20,-26},{-40,-6}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{39,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
    connect(PumpFeedForward, BOP.PumpFeedForward) annotation (Line(points={{
            -120,-46},{-94,-46},{-94,-28},{-98,-28},{-98,-22},{-100,-22},{-100,
            18},{-98,18},{-98,36},{48,36},{48,21.6},{56,21.6}}, color={0,0,127}));
    connect(sensorW.W, PowerOut) annotation (Line(points={{169,6.6},{168,6.6},{
            168,39},{255,39}}, color={0,0,127}));
    connect(EM.port_b1, sensor_m_flow.port_a) annotation (Line(points={{-10,-6},
            {-14,-6},{-14,-16},{-20,-16}}, color={0,127,255}));
    connect(sensor_m_flow.port_b, SMR_Taveprogram.port_a) annotation (Line(
          points={{-40,-16},{-40,0.553846},{-45.0909,0.553846}}, color={0,127,
            255}));
    connect(sensor_m_flow.m_flow, MassFlowRate) annotation (Line(points={{-30,
            -12.4},{-30,-2},{-16,-2},{-16,-24},{24,-24},{24,-22},{110,-22},{110,
            -43},{255,-43}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl2_FMU;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
    parameter String fileName2=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/CosEff_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater_Deaerator
                                                                               BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass2 CS(DNI_Input=
           DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1], CosEff_Input=CosEff_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{16,48},{36,68}})));
    Modelica.Blocks.Sources.CombiTimeTable CosEff_Input(
      tableOnFile=true,
      offset={0.01},
      startTime=0,
      tableName="CosEff",
      timeScale=timeScale,
      fileName=fileName2)
      annotation (Placement(transformation(extent={{-62,42},{-42,62}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{37,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator_ThreeStage
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
    parameter String fileName2=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/CosEff_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater_Deaerator_ThreeStage
                                                                               BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow_deaerator
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{42,-20},{106,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass2 CS(DNI_Input=
           DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1], CosEff_Input=CosEff_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-1e6,
      y_max=9e6) annotation (Placement(transformation(extent={{16,48},{36,68}})));
    Modelica.Blocks.Sources.CombiTimeTable CosEff_Input(
      tableOnFile=true,
      offset={0.01},
      startTime=0,
      tableName="CosEff",
      timeScale=timeScale,
      fileName=fileName2)
      annotation (Placement(transformation(extent={{-62,42},{-42,62}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{114,1},{95.3333,1}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{32,-6},{
            32,-7.4},{52.6667,-7.4}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-19.58},{65.4667,
            -19.58}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.8267,-19.58},{80.8267,-80},{61.1571,-80},{
            61.1571,-67.64}},       color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{41.3333,10},{41.3333,9.4},{52.6667,9.4}},
                                                 color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{37,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
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
        StopTime=10000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator_ThreeStage;

  model LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator_2
    "TES use case demonstration of a NuScale-style LWR operating within an energy arbitrage IES, storing and dispensing energy on demand from a two tank molten salt energy storage system nominally using HITEC salt to store heat."
   parameter Real fracNominal_BOP = abs(EM.port_b2_nominal.m_flow)/EM.port_a1_nominal.m_flow;
   parameter Real fracNominal_Other = sum(abs(EM.port_b3_nominal_m_flow))/EM.port_a1_nominal.m_flow;
   parameter SI.Time timeScale=2*60*60 "Time scale of first table column";
   parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/DNI_timeSeries.txt")
    "File where matrix is stored";
    parameter String fileName2=Modelica.Utilities.Files.loadResource(
      "modelica://NHES/Resources/Data/RAVEN/CosEff_timeSeries.txt")
    "File where matrix is stored";
   Real demandChange=
   min(1.05,
   max(SC.W_totalSetpoint_BOP/SC.W_nominal_BOP*fracNominal_BOP
       + sum(EM.port_b3.m_flow./EM.port_b3_nominal_m_flow)*fracNominal_Other,
       0.5));
   Real Effficiency = (BOP.generator1.Q_mech/SMR_Taveprogram.Q_total.y)*100;
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
      annotation (Placement(transformation(extent={{-96,-24},{-46,32}})));

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
    SupervisoryControl.InputSetpointData SC(delayStart=delayStart.k,
      W_nominal_BOP(displayUnit="MW") = 50000000,
      fileName=Modelica.Utilities.Files.loadResource(
          "modelica://NHES/Resources/Data/RAVEN/Nominal_50_timeSeries.txt"))
      annotation (Placement(transformation(extent={{158,60},{198,100}})));

    TRANSFORM.Electrical.Sensors.PowerSensor sensorW
      annotation (Placement(transformation(extent={{162,-6},{176,6}})));

    Modelica.Blocks.Sources.CombiTimeTable DNI_Input(
      tableOnFile=true,
      offset={1},
      startTime=0,
      tableName="DNI",
      timeScale=timeScale,
      fileName=fileName)
      annotation (Placement(transformation(extent={{-62,74},{-42,94}})));
    BalanceOfPlant.Turbine.SteamTurbine_L2_ClosedFeedHeat_AdditionalFeedheater_Deaerator_2
                                                                               BOP(
      port_a_nominal(
        p=EM.port_b2_nominal.p,
        h=EM.port_b2_nominal.h,
        m_flow=-EM.port_b2_nominal.m_flow),
      port_b_nominal(p=EM.port_a2_nominal.p, h=EM.port_a2_nominal.h),
      redeclare
        BalanceOfPlant.Turbine.ControlSystems.CS_SteamTurbine_L2_PressurePowerFeedtemp_AdditionalFeedheater_PressControl_Combined_mflow
        CS(electric_demand=sum2.y))
      annotation (Placement(transformation(extent={{54,-18},{94,22}})));
    EnergyStorage.Concrete_Solid_Media.Dual_Pipe_CTES_Controlled_FeedwaterBypass
      dual_Pipe_CTES_Controlled_Feedwater(redeclare
        NHES.Systems.EnergyStorage.Concrete_Solid_Media.CS_Bypass2_1 CS(
          DNI_Input=DNI_Input.y[1]))
      annotation (Placement(transformation(extent={{12,-76},{74,-32}})));
    SecondaryEnergySupply.ConcentratedSolar1.ParabolicTrough parabolicTrough(DNI_Input=
         DNI_Input.y[1], CosEff_Input=CosEff_Input.y[1])
      annotation (Placement(transformation(extent={{-60,-74},{0,-32}})));
    Modelica.Blocks.Sources.Constant delayStart(k=0)
      annotation (Placement(transformation(extent={{-34,78},{-14,98}})));
    Modelica.Blocks.Sources.Sine sine(
      amplitude=17.5e6,
      f=1/20000,
      offset=42e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{-40,118},{-20,138}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid(
      amplitude=-20.58e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=47e6,
      startTime=2000)
      annotation (Placement(transformation(extent={{52,158},{72,178}})));
    Modelica.Blocks.Math.Add         add
      annotation (Placement(transformation(extent={{94,142},{114,162}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid1(
      amplitude=20.14e6,
      rising=100,
      width=7800,
      falling=100,
      period=20000,
      offset=0,
      startTime=14000)
      annotation (Placement(transformation(extent={{52,122},{72,142}})));
    Modelica.Blocks.Sources.Constant const(k=47.5e6)
      annotation (Placement(transformation(extent={{4,114},{24,134}})));
    Modelica.Blocks.Math.Sum sum1
      annotation (Placement(transformation(extent={{120,148},{140,168}})));
    Modelica.Blocks.Sources.Trapezoid trapezoid2(
      amplitude=7e6,
      rising=100,
      width=9800,
      falling=100,
      period=20000,
      offset=48.6e6,
      startTime=1e6)
      annotation (Placement(transformation(extent={{18,80},{38,100}})));
    Modelica.Blocks.Math.Add         add1
      annotation (Placement(transformation(extent={{60,64},{80,84}})));
    Modelica.Blocks.Math.Sum sum2
      annotation (Placement(transformation(extent={{94,64},{114,84}})));
    Modelica.Blocks.Noise.UniformNoise uniformNoise(
      samplePeriod=10000,
      y_off=0,
      startTime=2e5,
      y_min=-0.5e6,
      y_max=9.5e6)
                 annotation (Placement(transformation(extent={{16,48},{36,68}})));
    Modelica.Blocks.Sources.CombiTimeTable CosEff_Input(
      tableOnFile=true,
      offset={0.01},
      startTime=0,
      tableName="CosEff",
      timeScale=timeScale,
      fileName=fileName2)
      annotation (Placement(transformation(extent={{-62,42},{-42,62}})));
  equation
      dual_Pipe_CTES_Controlled_Feedwater.CS.FeedwaterTemperature = BOP.sensor_T2.T;
    connect(SY.port_Grid, sensorW.port_a)
      annotation (Line(points={{154,0},{162,0}}, color={255,0,0}));
    connect(sensorW.port_b, EG.portElec_a)
      annotation (Line(points={{176,0},{192,0}}, color={255,0,0}));
    connect(SY.port_a[1], BOP.portElec_b)
      annotation (Line(points={{114,0},{104,0},{104,2},{94,2}},
                                                color={255,0,0}));
    connect(EM.port_a2, BOP.port_b) annotation (Line(points={{30,-6},{54,-6}},
                      color={0,127,255}));
    connect(dual_Pipe_CTES_Controlled_Feedwater.port_discharge_b, BOP.port_a1)
      annotation (Line(points={{60.2714,-44.32},{60.2714,-42},{66,-42},{66,
            -17.6}},
          color={0,127,255}));
    connect(BOP.port_b1, dual_Pipe_CTES_Controlled_Feedwater.port_discharge_a)
      annotation (Line(points={{80.4,-17.6},{80.4,-40},{82,-40},{82,-68},{
            61.1571,-68},{61.1571,-67.64}},
                                    color={0,127,255}));
    connect(EM.port_b2, BOP.port_a)
      annotation (Line(points={{30,10},{54,10}}, color={0,127,255}));
    connect(parabolicTrough.Outlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_a)
      annotation (Line(points={{-13.2857,-43.76},{-13.2857,-44},{15.9857,-44},{
            15.9857,-44.76}},
                      color={0,127,255}));
    connect(SMR_Taveprogram.port_b, EM.port_a1) annotation (Line(points={{
            -45.0909,14.7692},{-18,14.7692},{-18,10},{-10,10}},
                                                       color={0,127,255}));
    connect(SMR_Taveprogram.port_a, EM.port_b1) annotation (Line(points={{-45.0909,
            0.553846},{-16,0.553846},{-16,-6},{-10,-6}}, color={0,127,255}));
    connect(parabolicTrough.Inlet, dual_Pipe_CTES_Controlled_Feedwater.port_charge_b)
      annotation (Line(points={{-13.2857,-63.92},{-13.2857,-64},{15.9857,-64},{
            15.9857,-65}},
                   color={0,127,255}));
    connect(trapezoid.y,add. u1) annotation (Line(points={{73,168},{73,164},{86,
            164},{86,158},{92,158}},
                           color={0,0,127}));
    connect(trapezoid1.y,add. u2) annotation (Line(points={{73,132},{86,132},{
            86,146},{92,146}},
                           color={0,0,127}));
    connect(add.y,sum1. u[1]) annotation (Line(points={{115,152},{114,152},{114,
            138},{84,138},{84,164},{118,164},{118,158}},
                                         color={0,0,127}));
    connect(trapezoid2.y, add1.u1) annotation (Line(points={{39,90},{39,86},{52,
            86},{52,80},{58,80}}, color={0,0,127}));
    connect(add1.y, sum2.u[1])
      annotation (Line(points={{81,74},{92,74}}, color={0,0,127}));
    connect(uniformNoise.y, add1.u2) annotation (Line(points={{37,58},{52,58},{
            52,68},{58,68}}, color={0,0,127}));
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
        StopTime=1000000,
        Interval=10,
        __Dymola_Algorithm="Esdirk45a"),
      Documentation(info="<html>
<p>NuScale style reactor system. System has a nominal thermal output of 160MWt rather than the updated 200MWt.</p>
<p>System is based upon report: Frick, Konor L. Status Report on the NuScale Module Developed in the Modelica Framework. United States: N. p., 2019. Web. doi:10.2172/1569288.</p>
</html>"),
      __Dymola_experimentSetupOutput(events=false));
  end LWR_L2_Turbine_AdditionalFeedheater_NewControl2_Deaerator_2;
end FWHPT;
