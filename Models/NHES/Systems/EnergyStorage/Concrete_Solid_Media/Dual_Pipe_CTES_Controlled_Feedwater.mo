within NHES.Systems.EnergyStorage.Concrete_Solid_Media;
model Dual_Pipe_CTES_Controlled_Feedwater
   extends BaseClasses.Partial_SubSystem_A(
    redeclare replaceable CS_Dummy CS,
    redeclare replaceable ED_Dummy ED,
    redeclare Data.Data_Dummy data);
  replaceable package HTF = Modelica.Media.Water.StandardWater annotation(allMatchingChoices = true);
  parameter Modelica.Units.SI.Pressure P_Rise_DFV = 6e5;
  Components.Dual_Pipe_Model CTES(
    nY=7,
    nX=9,
    tau=0.05,
    nPipes=1000,
    dX=1500,
    Pipe_to_Concrete_Length_Ratio=6,
    dY=0.6,
    redeclare package TES_Med = BaseClasses.HeatCrete,
    redeclare package HTF = HTF,
    Hot_Con_Start=453.15,
    Cold_Con_Start=443.15)
    annotation (Placement(transformation(extent={{-34,-32},{36,38}})));

  TRANSFORM.Fluid.Interfaces.FluidPort_Flow port_charge_a(redeclare package
      Medium = HTF) annotation (Placement(
        transformation(extent={{-112,32},{-92,52}}), iconTransformation(extent={
            {-112,32},{-92,52}})));
  TRANSFORM.Fluid.Interfaces.FluidPort_State port_discharge_b(redeclare package
      Medium = HTF) annotation (Placement(transformation(extent={{88,34},{108,54}}),
                    iconTransformation(extent={{88,34},{108,54}})));
  TRANSFORM.Fluid.Interfaces.FluidPort_Flow port_discharge_a(redeclare package
      Medium = HTF) annotation (Placement(transformation(extent={{92,-72},{112,-52}}),
        iconTransformation(extent={{92,-72},{112,-52}})));
  TRANSFORM.Fluid.Interfaces.FluidPort_State port_charge_b(redeclare package
      Medium = HTF) annotation (Placement(transformation(extent={{-112,-60},{-92,
            -40}}),
        iconTransformation(extent={{-112,-60},{-92,-40}})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary4(
    redeclare package Medium =
        HTF,
    use_T_in=true,
    p=5000000,
    T=373.15,
    nPorts=1)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={132,78})));
  TRANSFORM.Fluid.Valves.ValveLinear TBV(
    redeclare package Medium =
        HTF,
    dp_nominal=100000,
    m_flow_nominal=50)                   annotation (Placement(transformation(
        extent={{-8,8},{8,-8}},
        rotation=90,
        origin={132,52})));
  TRANSFORM.Fluid.Sensors.Pressure     sensor_p(redeclare package Medium =
       HTF,
      redeclare function iconUnit =
        TRANSFORM.Units.Conversions.Functions.Pressure_Pa.to_bar)
                                                       annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={120,14})));
  Modelica.Blocks.Sources.Constant const9(k=50e5)
    annotation (Placement(transformation(extent={{204,42},{184,62}})));
  TRANSFORM.Controls.LimPID PI_TBV(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=-5e-7,
    Ti=15,
    yMax=1.0,
    yMin=0.0,
    initType=Modelica.Blocks.Types.Init.InitialState)
    annotation (Placement(transformation(extent={{168,42},{148,62}})));
  TRANSFORM.Fluid.Machines.Pump_SimpleMassFlow pump_SimpleMassFlow2(
    m_flow_nominal=0.05,
    use_input=true,
    redeclare package Medium =
        HTF)                                             annotation (
      Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=180,
        origin={-78,-50})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_pT boundary1(
    redeclare package Medium =
        HTF,
    use_T_in=true,
    p=5000000,
    T=298.15,
    nPorts=1)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-8,-54})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temperature(redeclare package
      Medium = HTF)
    annotation (Placement(transformation(extent={{-72,26},{-52,46}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temperature1(redeclare package
      Medium = HTF)
    annotation (Placement(transformation(extent={{-80,-26},{-60,-6}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temperature2(redeclare package
      Medium = HTF)
    annotation (Placement(transformation(extent={{98,-18},{78,2}})));
  TRANSFORM.Fluid.Machines.Pump                pump_SimpleMassFlow1(
    p_a_start=500000,
    p_b_start=500000,
    use_T_start=false,
    T_start=373.15,
    h_start=1e6,
    m_flow_start=20,
    N_nominal=1200,
    dp_nominal=1000000,
    m_flow_nominal=5,
    redeclare package Medium = Modelica.Media.Water.StandardWater,
    d_nominal=1000,
    controlType="RPM",
    use_port=true)                                       annotation (
      Placement(transformation(
        extent={{-11,-11},{11,11}},
        rotation=180,
        origin={55,-7})));
  TRANSFORM.Fluid.Sensors.MassFlowRate sensor_m_flow(redeclare package Medium
      = Modelica.Media.Water.StandardWater)
    annotation (Placement(transformation(extent={{70,18},{90,38}})));
  Modelica.Fluid.Sensors.TemperatureTwoPort temperature3(redeclare package
      Medium = HTF)
    annotation (Placement(transformation(extent={{38,16},{58,36}})));
equation

  connect(const9.y,PI_TBV. u_s)
    annotation (Line(points={{183,52},{170,52}},     color={0,0,127}));
  connect(sensor_p.p,PI_TBV. u_m) annotation (Line(points={{126,14},{158,14},{158,
          40}},              color={0,0,127}));
  connect(TBV.port_b,boundary4. ports[1])
    annotation (Line(points={{132,60},{132,68}},   color={0,127,255}));
  connect(PI_TBV.y,TBV. opening)
    annotation (Line(points={{147,52},{138.4,52}},     color={0,0,127}));
  connect(TBV.port_a, sensor_p.port)
    annotation (Line(points={{132,44},{132,24},{120,24}}, color={0,127,255}));
  connect(port_charge_b, pump_SimpleMassFlow2.port_b)
    annotation (Line(points={{-102,-50},{-90,-50}}, color={0,127,255}));
  connect(boundary1.ports[1], pump_SimpleMassFlow2.port_a) annotation (Line(
        points={{-8,-64},{-8,-68},{-56,-68},{-56,-50},{-66,-50}}, color={0,127,255}));
  connect(port_charge_a, temperature.port_a) annotation (Line(points={{-102,42},
          {-78,42},{-78,36},{-72,36}}, color={0,127,255}));
  connect(CTES.Charge_Inlet, temperature.port_b) annotation (Line(points={{-26.3,
          10.7},{-46,10.7},{-46,36},{-52,36}}, color={0,127,255}));
  connect(CTES.Charge_Outlet, temperature1.port_a) annotation (Line(points={{-26.3,
          -9.6},{-26.3,-4},{-82,-4},{-82,-16},{-80,-16}}, color={0,127,255}));
  connect(temperature1.T, boundary1.T_in) annotation (Line(points={{-70,-5},{
          -70,-8},{-38,-8},{-38,-38},{-4,-38},{-4,-42}},
                                                     color={0,0,127}));
  connect(temperature1.port_b, pump_SimpleMassFlow2.port_a) annotation (Line(
        points={{-60,-16},{-54,-16},{-54,-50},{-66,-50}}, color={0,127,255}));
  connect(port_discharge_a, temperature2.port_a)
    annotation (Line(points={{102,-62},{102,-8},{98,-8}}, color={0,127,255}));
  connect(temperature2.T, boundary4.T_in) annotation (Line(points={{88,3},{106,3},
          {106,38},{118,38},{118,94},{136,94},{136,90}}, color={0,0,127}));
  connect(temperature2.port_a, sensor_p.port) annotation (Line(points={{98,-8},{
          108,-8},{108,24},{120,24}}, color={0,127,255}));
  connect(CTES.Discharge_Inlet, pump_SimpleMassFlow1.port_b) annotation (Line(
        points={{28.3,-11.7},{28.3,-7},{44,-7}},color={0,127,255}));
  connect(pump_SimpleMassFlow1.port_a, temperature2.port_b) annotation (Line(
        points={{66,-7},{72,-7},{72,-8},{78,-8}}, color={0,127,255}));
  connect(actuatorBus.DischargePumpSpeed, pump_SimpleMassFlow1.inputSignal)
    annotation (Line(
      points={{30,100},{32,100},{32,-42},{55,-42},{55,-14.7}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(sensor_m_flow.port_b, port_discharge_b)
    annotation (Line(points={{90,28},{98,28},{98,44}}, color={0,127,255}));
  connect(sensorBus.DischargeMFlow, sensor_m_flow.m_flow) annotation (Line(
      points={{-30,100},{-30,76},{80,76},{80,31.6}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(temperature3.port_b, sensor_m_flow.port_a)
    annotation (Line(points={{58,26},{58,28},{70,28}}, color={0,127,255}));
  connect(CTES.Discharge_Outlet, temperature3.port_a)
    annotation (Line(points={{29,10.7},{38,10.7},{38,26}}, color={0,127,255}));
  connect(actuatorBus.ChargePump, pump_SimpleMassFlow2.in_m_flow) annotation (
      Line(
      points={{30,100},{-92,100},{-92,-68},{-78,-68},{-78,-58.76}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  annotation (experiment(
      StopTime=864000,
      __Dymola_NumberOfIntervals=1957,
      __Dymola_Algorithm="Esdirk45a"),
    Diagram(coordinateSystem(extent={{-120,-100},{160,100}})),
    Icon(coordinateSystem(extent={{-120,-100},{160,100}}), graphics={
                             Bitmap(extent={{-92,-72},{92,76}},   fileName="modelica://NHES/Icons/EnergyStoragePackage/Concreteimg.jpg")}),
    Documentation(info="<html>
<p>This particular controlled CTES model is for use with the Nuscale stage-by-stage turbine model. The DCV is within the model itself, allowing the CTES to control its own pressure rise (surrogate for a pump) and flow characteristic. </p>
<p>That does mean that the demand and power levels need to be piped into the model, and a control system for the DCV needs to be put in place. </p>
</html>"));
end Dual_Pipe_CTES_Controlled_Feedwater;
