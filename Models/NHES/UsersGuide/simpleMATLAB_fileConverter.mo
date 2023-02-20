within NHES.UsersGuide;
function simpleMATLAB_fileConverter
 "Function to import trajectory result files and write them as MatLab compatible .mat files"
 input String filename="LWR_L2_Turbine_AdditionalFeedheater_NewControl2.mat" "File to be converted" annotation (Dialog(__Dymola_loadSelector(filter="Matlab files (*.mat)",
 caption="Select the results trajectory file")));
 input String varOrigNames[:]={"Time","Effficiency","BOP.LPT_Bypass.m_flow","BOP.sensor_T2.T", "BOP.sensor_T1.T", "SMR_Taveprogram.Q_total.y", "BOP.generator1.Q_elec", "dual_Pipe_CTES_Controlled_Feedwater.CTES.T_Ave_Conc","BOP.sensor_p.p","sum2.y","parabolicTrough.solarCollectorIncSchott1.Summary.Q_htf","BOP.MainFeedwaterHeater1.Q","dual_Pipe_CTES_Controlled_Feedwater.temperature3.T","BOP.MainFeedwaterHeater.Q","BOP.sensor_T4.T", "BOP.sensor_T6.T", "BOP.port_a.m_flow"} "Variable names/headers in the file in modelica syntax";
 input String varReNames[:]={"Time2","Eff2","BMF2","FWIT2","FWOT2","TP2","EP2","T_Ave_Conc2","SteamP2","Demand2","TPPT2","SFWHQ2","COT2","PFWHQ2","CondOT2","IntTemp2", "SGMF"}
 "Variable names which will appear in the MATLAB results file";
 input String outputFilename="outputFile2.mat";

protected
   Integer noRows "Number of rows in the trajectory being converted";
   Integer noColumn=12 "Number of columns in the trajectory being converted";
   Real data[:,:] "Data read in from trajectory file";
   Real dataDump[:,:] "Sacrificial dump variable for writeMatrix command";
   Integer i=2 "Loop counter";

algorithm

   noRows := DymolaCommands.Trajectories.readTrajectorySize(filename);
   data := DymolaCommands.Trajectories.readTrajectory(
     filename,
     varOrigNames,
     noRows);
 data := transpose(data);
 noColumn := size(data, 2);
 while i <= noColumn loop
   dataDump := [data[:, 1],data[:, i]];
   if i == 2 then
     DymolaCommands.MatrixIO.writeMatrix(
       outputFilename,
       varReNames[i],
       dataDump);
   else
      DymolaCommands.MatrixIO.writeMatrix(
       outputFilename,
       varReNames[i],
       dataDump,
       true);
   end if;
 i := i + 1;
 end while;
 annotation (Documentation(info="<html>
<p></p>
</html>"), uses(DymolaCommands(version="1.4")));
end simpleMATLAB_fileConverter;
