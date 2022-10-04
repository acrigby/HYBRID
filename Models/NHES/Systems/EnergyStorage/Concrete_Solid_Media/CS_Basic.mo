within NHES.Systems.EnergyStorage.Concrete_Solid_Media;
model CS_Basic

  extends BaseClasses.Partial_ControlSystem;

  input Real FeedwaterTemperature
  annotation(Dialog(tab="General"));
  input Real DNI_Input
  annotation(Dialog(tab="General"));

  Modelica.Blocks.Sources.Constant const1(k=1)
    annotation (Placement(transformation(extent={{11,-11},{-11,11}},
        rotation=180,
        origin={-11,11})));
  Modelica.Blocks.Math.Add         add3
    annotation (Placement(transformation(extent={{-102,50},{-82,70}})));
  Modelica.Blocks.Sources.RealExpression
                                   realExpression(y=FeedwaterTemperature)
    annotation (Placement(transformation(extent={{-246,-64},{-184,-34}})));
  Modelica.Blocks.Sources.Constant const2(k=148 + 273)
    annotation (Placement(transformation(extent={{-238,-10},{-214,14}})));
  PrimaryHeatSystem.HTGR.VarLimVarK_PID PID1(
    use_k_in=true,
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=1e-1,
    Ti=5,
    yMax=12000,
    yMin=0)
           annotation (Placement(transformation(extent={{-174,22},{-154,42}})));
  Modelica.Blocks.Sources.Ramp ramp(
    height=1,
    duration=1e5,
    offset=1e-7,
    startTime=5e4)
    annotation (Placement(transformation(extent={{-228,62},{-208,82}})));
  Modelica.Blocks.Sources.Ramp ramp2(
    height=0,
    duration=1e4,
    offset=1200,
    startTime=1.9e5)
    annotation (Placement(transformation(extent={{-152,90},{-132,110}})));
  Modelica.Blocks.Sources.RealExpression
                                   realExpression1(y=DNI_Input)
    annotation (Placement(transformation(extent={{-200,-94},{-138,-64}})));
  Modelica.Blocks.Logical.Greater greater
    annotation (Placement(transformation(extent={{-114,-88},{-94,-68}})));
  Modelica.Blocks.Sources.Constant const3(k=2)
    annotation (Placement(transformation(extent={{-170,-126},{-146,-102}})));
  Modelica.Blocks.Logical.Switch switch1
    annotation (Placement(transformation(extent={{-68,-58},{-48,-38}})));
  Modelica.Blocks.Sources.Constant const4(k=25)
    annotation (Placement(transformation(extent={{-128,-40},{-104,-16}})));
  Modelica.Blocks.Sources.Constant const5(k=1)
    annotation (Placement(transformation(extent={{-136,-156},{-112,-132}})));
equation

  connect(actuatorBus.DFV_Opening, const1.y) annotation (Line(
      points={{30,-100},{30,11},{1.1,11}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(actuatorBus.DischargePumpSpeed, add3.y) annotation (Line(
      points={{30,-100},{30,60},{-81,60}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(const2.y, PID1.u_s) annotation (Line(points={{-212.8,2},{-196,2},{
          -196,32},{-176,32}}, color={0,0,127}));
  connect(realExpression.y, PID1.u_m) annotation (Line(points={{-180.9,-49},{-164,
          -49},{-164,20}},      color={0,0,127}));
  connect(PID1.y, add3.u2) annotation (Line(points={{-153,32},{-120,32},{-120,
          54},{-104,54}}, color={0,0,127}));
  connect(ramp2.y, add3.u1) annotation (Line(points={{-131,100},{-120,100},{-120,
          66},{-104,66}}, color={0,0,127}));
  connect(ramp.y, PID1.prop_k) annotation (Line(points={{-207,72},{-156,72},{-156,
          43.4},{-156.6,43.4}}, color={0,0,127}));
  connect(realExpression1.y, greater.u1) annotation (Line(points={{-134.9,-79},
          {-125.45,-79},{-125.45,-78},{-116,-78}}, color={0,0,127}));
  connect(const3.y, greater.u2) annotation (Line(points={{-144.8,-114},{-120,
          -114},{-120,-92},{-116,-92},{-116,-86}}, color={0,0,127}));
  connect(greater.y, switch1.u2) annotation (Line(points={{-93,-78},{-76,-78},{
          -76,-48},{-70,-48}}, color={255,0,255}));
  connect(const4.y, switch1.u1) annotation (Line(points={{-102.8,-28},{-78,-28},
          {-78,-40},{-70,-40}}, color={0,0,127}));
  connect(const5.y, switch1.u3) annotation (Line(points={{-110.8,-144},{-110.8,
          -120},{-70,-120},{-70,-56}}, color={0,0,127}));
  connect(actuatorBus.ChargePump, switch1.y) annotation (Line(
      points={{30,-100},{30,-48},{-47,-48}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
annotation(defaultComponentName="changeMe_CS", Icon(graphics={
        Text(
          extent={{-94,82},{94,74}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={255,255,237},
          fillPattern=FillPattern.Solid,
          textString="Change Me")}));
end CS_Basic;
