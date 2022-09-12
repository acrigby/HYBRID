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
end FWHPT;
