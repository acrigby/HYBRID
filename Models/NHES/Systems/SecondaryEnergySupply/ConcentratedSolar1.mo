within NHES.Systems.SecondaryEnergySupply;
package ConcentratedSolar1

  package Examples
    extends Modelica.Icons.ExamplesPackage;

    model Test
      extends Modelica.Icons.Example;

      SubSystem_Dummy changeMe
        annotation (Placement(transformation(extent={{-40,-42},{40,38}})));

      annotation (
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
                100,100}})),
        experiment(
          StopTime=100,
          __Dymola_NumberOfIntervals=100,
          __Dymola_Algorithm="Esdirk45a"),
        __Dymola_experimentSetupOutput);
    end Test;
  end Examples;

  model SubSystem_Dummy

    extends BaseClasses.Partial_SubSystem_A(
      redeclare replaceable
        NHES.Systems.SecondaryEnergySupply.ConcentratedSolar1.CS_Dummy CS,
      redeclare replaceable
        NHES.Systems.SecondaryEnergySupply.ConcentratedSolar1.ED_Dummy ED,
      redeclare Data.Data_Dummy data);

  equation

    annotation (
      defaultComponentName="changeMe",
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
              140}})),
      Icon(coordinateSystem(extent={{-100,-100},{100,100}}), graphics={
          Text(
            extent={{-94,82},{94,74}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={255,255,237},
            fillPattern=FillPattern.Solid,
            textString="Change Me")}));
  end SubSystem_Dummy;

  package Components

  end Components;

  package CS "Control systems package"
  end CS;

  package Data

    model Data_Dummy

      extends BaseClasses.Record_Data;

      annotation (
        defaultComponentName="data",
        Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
              lineColor={0,0,0},
              extent={{-100,-90},{100,-70}},
              textString="changeMe")}),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        Documentation(info="<html>
</html>"));
    end Data_Dummy;
  end Data;

  package BaseClasses
    extends TRANSFORM.Icons.BasesPackage;

    partial model Partial_SubSystem

      extends NHES.Systems.BaseClasses.Partial_SubSystem;

      extends Record_SubSystem;

      replaceable Partial_ControlSystem CS annotation (choicesAllMatching=true,
          Placement(transformation(extent={{-18,122},{-2,138}})));
      replaceable Partial_EventDriver ED annotation (choicesAllMatching=true,
          Placement(transformation(extent={{2,122},{18,138}})));
      replaceable Record_Data data
        annotation (Placement(transformation(extent={{42,122},{58,138}})));

      SignalSubBus_ActuatorInput actuatorBus
        annotation (Placement(transformation(extent={{10,80},{50,120}}),
            iconTransformation(extent={{10,80},{50,120}})));
      SignalSubBus_SensorOutput sensorBus
        annotation (Placement(transformation(extent={{-50,80},{-10,120}}),
            iconTransformation(extent={{-50,80},{-10,120}})));

    equation
      connect(sensorBus, ED.sensorBus) annotation (Line(
          points={{-30,100},{-16,100},{7.6,100},{7.6,122}},
          color={239,82,82},
          pattern=LinePattern.Dash,
          thickness=0.5));
      connect(sensorBus, CS.sensorBus) annotation (Line(
          points={{-30,100},{-12.4,100},{-12.4,122}},
          color={239,82,82},
          pattern=LinePattern.Dash,
          thickness=0.5));
      connect(actuatorBus, CS.actuatorBus) annotation (Line(
          points={{30,100},{12,100},{-7.6,100},{-7.6,122}},
          color={111,216,99},
          pattern=LinePattern.Dash,
          thickness=0.5));
      connect(actuatorBus, ED.actuatorBus) annotation (Line(
          points={{30,100},{20,100},{12.4,100},{12.4,122}},
          color={111,216,99},
          pattern=LinePattern.Dash,
          thickness=0.5));

      annotation (
        defaultComponentName="changeMe",
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
                100}})),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
                100,140}})));
    end Partial_SubSystem;

    partial model Partial_SubSystem_A

      extends Partial_SubSystem;

      extends Record_SubSystem_A;

      annotation (
        defaultComponentName="changeMe",
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
                140}})));
    end Partial_SubSystem_A;

    partial model Record_Data

      extends Modelica.Icons.Record;

      annotation (defaultComponentName="data",
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end Record_Data;

    partial record Record_SubSystem

      annotation (defaultComponentName="subsystem",
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end Record_SubSystem;

    partial record Record_SubSystem_A

      extends Record_SubSystem;

      annotation (defaultComponentName="subsystem",
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end Record_SubSystem_A;

    partial model Partial_ControlSystem

      extends NHES.Systems.BaseClasses.Partial_ControlSystem;

      SignalSubBus_ActuatorInput actuatorBus
        annotation (Placement(transformation(extent={{10,-120},{50,-80}}),
            iconTransformation(extent={{10,-120},{50,-80}})));
      SignalSubBus_SensorOutput sensorBus
        annotation (Placement(transformation(extent={{-50,-120},{-10,-80}}),
            iconTransformation(extent={{-50,-120},{-10,-80}})));

      annotation (
        defaultComponentName="CS",
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
                100}})),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
                100,100}})));

    end Partial_ControlSystem;

    partial model Partial_EventDriver

      extends NHES.Systems.BaseClasses.Partial_EventDriver;

      SignalSubBus_ActuatorInput actuatorBus
        annotation (Placement(transformation(extent={{10,-120},{50,-80}}),
            iconTransformation(extent={{10,-120},{50,-80}})));
      SignalSubBus_SensorOutput sensorBus
        annotation (Placement(transformation(extent={{-50,-120},{-10,-80}}),
            iconTransformation(extent={{-50,-120},{-10,-80}})));

      annotation (
        defaultComponentName="ED",
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
                100}})));

    end Partial_EventDriver;

    expandable connector SignalSubBus_ActuatorInput

      extends NHES.Systems.Interfaces.SignalSubBus_ActuatorInput;

      annotation (defaultComponentName="actuatorBus",
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SignalSubBus_ActuatorInput;

    expandable connector SignalSubBus_SensorOutput

      extends NHES.Systems.Interfaces.SignalSubBus_SensorOutput;

      annotation (defaultComponentName="sensorBus",
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SignalSubBus_SensorOutput;
  end BaseClasses;

  model ParabolicTrough
     extends BaseClasses.Partial_SubSystem_A(
      redeclare replaceable CS_Dummy CS,
      redeclare replaceable ED_Dummy ED,
      redeclare Data.Data_Dummy data);
    input Real DNI_Input
    annotation(Dialog(tab="General"));

   ThermoCycle.Components.Units.Solar.SolarField_SchottSopo         solarCollectorIncSchott1(
      Nt=12,
      Mdotnom=30,
      redeclare model FluidHeatTransferModel =
          ThermoCycle.Components.HeatFlow.HeatTransfer.Ideal,
      redeclare
        ThermoCycle.Components.HeatFlow.Walls.SolarAbsorber.Geometry.Schott_SopoNova.Schott_2008_PTR70_Vacuum
        CollectorGeometry(L=16),
      redeclare package Medium1 = Modelica.Media.Water.StandardWater,
      Ns=60,
      Tstart_inlet=298.15,
      Tstart_outlet=373.15,
      pstart=1000000)
      annotation (Placement(transformation(extent={{4,-32},{34,16}})));
    Modelica.Blocks.Sources.Constant const5(k=0)
      annotation (Placement(transformation(extent={{-58,32},{-38,52}})));
    Modelica.Blocks.Sources.Constant const4(k=0)
      annotation (Placement(transformation(extent={{-60,2},{-40,22}})));
    Modelica.Blocks.Sources.Constant const2(k=25 + 273.15)
      annotation (Placement(transformation(extent={{-74,-34},{-54,-14}})));
    TRANSFORM.Fluid.Interfaces.FluidPort_State Outlet(redeclare package Medium =
          Modelica.Media.Water.StandardWater) annotation (Placement(
          transformation(extent={{148,32},{168,52}}), iconTransformation(extent={{
              88,34},{108,54}})));
    TRANSFORM.Fluid.Interfaces.FluidPort_Flow Inlet(redeclare package Medium =
          Modelica.Media.Water.StandardWater) annotation (Placement(
          transformation(extent={{148,-64},{168,-44}}), iconTransformation(extent=
             {{88,-62},{108,-42}})));
    Modelica.Blocks.Sources.RealExpression
                                     realExpression(y=DNI_Input)
      annotation (Placement(transformation(extent={{-86,-98},{-24,-68}})));
  equation

    connect(const5.y, solarCollectorIncSchott1.v_wind) annotation (Line(points={{-37,
            42},{-2,42},{-2,11.2},{6.33333,11.2}}, color={0,0,127}));
    connect(const4.y, solarCollectorIncSchott1.Theta) annotation (Line(points={{-39,
            12},{-4,12},{-4,1.81818},{6.5,1.81818}}, color={0,0,127}));
    connect(const2.y, solarCollectorIncSchott1.Tamb) annotation (Line(points={{-53,-24},
            {-22,-24},{-22,-8.65455},{6.16667,-8.65455}},    color={0,0,127}));
    connect(solarCollectorIncSchott1.OutFlow, Outlet)
      annotation (Line(points={{24,15.5636},{24,42},{158,42}}, color={0,0,255}));
    connect(solarCollectorIncSchott1.InFlow, Inlet) annotation (Line(points={{24,
            -32.4364},{24,-54},{158,-54}},
                                 color={0,0,255}));
    connect(realExpression.y, solarCollectorIncSchott1.DNI) annotation (Line(
          points={{-20.9,-83},{-20.9,-21.3091},{6.5,-21.3091}}, color={0,0,127}));
    annotation (experiment(
        StopTime=864000,
        __Dymola_NumberOfIntervals=1957,
        __Dymola_Algorithm="Esdirk45a"),
      Diagram(coordinateSystem(extent={{-120,-100},{160,100}})),
      Icon(coordinateSystem(extent={{-120,-100},{160,100}}), graphics={
                               Bitmap(extent={{-90,-72},{94,76}},   fileName="modelica://NHES/Icons/SecondaryEnergySupplyPackage/ParabolicTrough.png")}),
      Documentation(info="<html>
<p>This particular controlled CTES model is for use with the Nuscale stage-by-stage turbine model. The DCV is within the model itself, allowing the CTES to control its own pressure rise (surrogate for a pump) and flow characteristic. </p>
<p>That does mean that the demand and power levels need to be piped into the model, and a control system for the DCV needs to be put in place. </p>
</html>"),      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end ParabolicTrough;

  model CS_Dummy

    extends BaseClasses.Partial_ControlSystem;

  equation

  annotation(defaultComponentName="changeMe_CS", Icon(graphics={
          Text(
            extent={{-94,82},{94,74}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={255,255,237},
            fillPattern=FillPattern.Solid,
            textString="Change Me")}));
  end CS_Dummy;

  model ED_Dummy

    extends BaseClasses.Partial_EventDriver;

  equation

  annotation(defaultComponentName="changeMe_CS", Icon(graphics={
          Text(
            extent={{-94,82},{94,74}},
            lineColor={0,0,0},
            lineThickness=1,
            fillColor={255,255,237},
            fillPattern=FillPattern.Solid,
            textString="Change Me")}));
  end ED_Dummy;
end ConcentratedSolar1;
