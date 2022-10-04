within NHES.Systems.BalanceOfPlant.Turbine.Data;
model TES_Setpoints
  parameter Modelica.Units.SI.Pressure p_steam = 35e5 "Reference steam pressure";
  parameter Modelica.Units.SI.Temperature T_Steam_Ref = 306.6+273.15 "Reference steam temperature";
  parameter Modelica.Units.SI.Power Q_Nom = 60e6 "Reference electrical power";
  parameter Modelica.Units.SI.Temperature T_Feedwater = 148+273.15 "Reference feedwater temperature";
  parameter Modelica.Units.SI.Pressure p_steam_vent = 150e5 "Overpressurization relief valve setpoint"; //error associated with too high Temperature calling using the steam generator pipe surface temperature and the water fluid pressure is your indicator that the system is overpressurized and leaving the steam tables
  parameter Modelica.Units.SI.Temperature T_SHS_Return = 218+273.15 "Reference SHS Return temperature";
  parameter Modelica.Units.SI.MassFlowRate m_flow_reactor = 67 "Reference mass flow rate";

  extends Systems.BalanceOfPlant.Turbine.BaseClasses.Record_Data;

  annotation (
    defaultComponentName="data",
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
          lineColor={0,0,0},
          extent={{-100,-90},{100,-70}},
          textString="Rankine")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)));
end TES_Setpoints;
