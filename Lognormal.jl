
using DelimitedFiles
using CSV
using Random
using DataFrames

# Include my functions.....
include("Functions_Lognormal.jl")

DataPath=string("../../../../../../data/jlj/outputs/BackwardTracing/");


# Definitions
# -----------

#TimeMax = 40;     # Maximum days run.
#InitialNumberOfInfected  = 100;      # Infectious at start
#MaximumAllowedInfected = 100000; # How many people will we maximally get?

NumberOfExperiments  = 1000; # Number of experiments
NumberOfSeeds=250; # Number of patient zeros in each simulation.
NumberOfNodesToTrace=30;

# Epidemiological details
AsymptomaticFractionOfInfected = 0.; # Fraction of infected that never get symptoms.

Average_R0 = 1.; #3//2.5 # Mean number of children in full period of infection.
OffspringDistribution = "poisson";
#OffspringDistribution = "geometric";

InfectiousProfile = "empirical";
#InfectiousProfile = "FlatSkewed";
#InfectiousProfile = "Flat";

SymptomOnsetTime = "halfway";
#SymptomOnsetTime = "immediately";

IncludeExposedCompartment = false; # true if SEIR model. false if not.
InfectiousWaitingTimeExponential=false; #If false, time spent in Infectious state is lognormally distributed.
ExposedExponentialMean = 4; # Exponential PDF is l*exp(-l*t), where 1/l is the parameter being defined here.
InfectiousExponentialMean = ExposedExponentialMean+0; # Exponential PDF is l*exp(-l*t), where 1/l is the parameter being defined here.



MeanOfLognormal = getMeanOfLognormalDistribution();

# Societal details
global WaitBeforeTestTaken = 0;  # Number of days before test is taken
global WaitBeforeTestResult = 0; # Number of days before test result arrives after test is taken

WaitBeforeTracedAreReleased=10000; # How long does it take before a traced person is set free again?

# Test-and-trace details
#ProbabilityChildIsTraced  = -0.02; #+34*0.02 // Fraction of children that are found through contact tracing
#ProbabilityFalseNegativeTest = -0.02;
ProbabilityDetectionWhenSymptoms=0.05;#0.05; #ps of Kojaku et al.
ProbabilityNeighborsAreTraced=0.5;#0.5; #pt of Kojaku et al.

ParentFactor=1.0; #Weight of parents in tracelist. If >ChildrenFactor, Parents are more important to trace.


ChildFactor=1-ParentFactor; #Weight of children in tracelist. If >ParentFactor, Children are more important to trace.

# Get network
NetworkTypeName="BA_Kojaku";
NetworkFileName="BA_network.csv";

#NetworkTypeName="ER";
#NetworkFileName="ER_network.csv";

NetworkFileLocation=string("inputs/",NetworkFileName);
Network = getNetwork(NetworkFileLocation);

NumberOfNodes=maximum(keys(Network));

MeanDegree=getMeanDegree(Network);

# Adjust R0 to network structure.
R0 = Average_R0/(MeanDegree-1);
println("R0:\t",R0)
# Get seeds
# -------------
# Generate seeds for simulation after patient zeros have been chosen.
RandomSeedsForRandomNumberGenerator=rand(1:500000,1,NumberOfExperiments);

# Set fixed Seed for random generation of patient zeros [(also known as "seeds") -- 2 different meanings of "seeds".. sorry!]
Random.seed!(1234)
Seeds=rand(1:NumberOfNodes,1,NumberOfExperiments*NumberOfSeeds);

#--------------------

# Do NumberOfExperiments runs for each parameter combination. 
for ExperimentNumber =1:NumberOfExperiments
    println("Currently doing experiment number: ",ExperimentNumber)
    # Reset seed of random-number generator
    Random.seed!(RandomSeedsForRandomNumberGenerator[ExperimentNumber]);
    SeedsThisExperiment=Seeds[1+(ExperimentNumber-1)*NumberOfSeeds:ExperimentNumber*NumberOfSeeds];

    ParentDictionary = Dict(); # Dictionary to keep track of who are parents for whom. 


    # Define variables and vectors for each run.
    # -------

    # Integers
    NumberOfInfected = NumberOfSeeds*(IncludeExposedCompartment==false) +0; # Number of infected at the beginning of simulation.
    NumberOfRecovered = 0; # Number of people that recovered from disease.
    NumberOfPeopleDoneInfecting = 0; # Number of people that infected all that they will infect.
    # TO DO: CHeck difference between NumberOfRecovered and NumberOfPeopleDoneInfecting. Document this.

    NumberOfTestIsolations=0; # Number of nodes that were quarantined after testing positive at symptom onset.
    NumberOfTraceIsolations=0; # Number of nodes that were quanrantined after being traced when a neighbor tested positive.


    # State arrays
    # TO DO: DEFINE THESE.
    StateOfNodes = zeros(NumberOfNodes); # Array with 0, 1, 2, 3 on entry, corresponding to S, E, I, R.

    CountUpToStateChange = ones(NumberOfNodes)*(-1) ;     # Array with Day on entry. Counts from 0. Node i changes state when Counter_goal[i] is reached.
    GoalOfCountDown = zeros(NumberOfNodes) ;# Array with Day on entry. Negative if not infected,

    TestArrivalTimeOfNodes = ones(NumberOfNodes)*(-9) ;     # Array with Day on entry. Negative if not waiting,
    ResultArrivalTimeOfNodes = ones(NumberOfNodes)*(-9) ;   # Array with Day on entry. Negative if not waiting,
    TraceNodesChildren = zeros(NumberOfNodes) ;             # Array with 0 or 1 on entry. 0 if not waiting to be traced,
    NodeCanTestPositive = zeros(NumberOfNodes); # Array with 0 on entry if node cannot test positive. 1 if node can.

    Asymptomatic = floor.(Int,rand(NumberOfNodes,1).+(AsymptomaticFractionOfInfected)); # Array with 0 or 1 on entry. 0 if normal, 1 if always asymptomatic.

    ListOfChildren = fill(Int[], NumberOfNodes,1); # List at entry i contains nodes that node i infected. Used for contact tracing in Kojaku's model.

    # Infect a number of people at start of simulation
    StateOfNodes,CountUpToStateChange,GoalOfCountDown = getInitialConditionsOfSimulation(StateOfNodes,ParentDictionary,SeedsThisExperiment,CountUpToStateChange,GoalOfCountDown,IncludeExposedCompartment,ExposedExponentialMean,InfectiousWaitingTimeExponential,InfectiousExponentialMean);

    # I_curve
    SumInfected=0;
    for NodeId =1:length(StateOfNodes)
        if (StateOfNodes[NodeId]==1 || StateOfNodes[NodeId]==2)
            SumInfected+=1;
        end
    end    
    Icurve=[SumInfected+0];

    # Run model until noone is active anymore
    NodesStillActive=true;
    TimeStep = 0;
    CheckInfectiousness=Dict();
    CheckMinDay=Dict();
    CheckMaxDay=Dict();


    TreeString=string();


    while NodesStillActive==true

        # Advance Time 1 step
        TimeStep +=1;
        #println("TimeStep:\t",TimeStep,"\t\tNumberOfInfected:\t",NumberOfInfected)
        # Advance all infected and all waiting 1 time step.
        StateOfNodes,CountUpToStateChange,GoalOfCountDown,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodeCanTestPositive,TraceNodesChildren,NumberOfInfected,NumberOfRecovered,FoundNoInfectiousOrExposedNode,NodesToTrace,NumberOfTestIsolations = AdvanceInfectedOneTimestep(StateOfNodes,Network,ParentDictionary,CountUpToStateChange,GoalOfCountDown,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodeCanTestPositive,TraceNodesChildren,WaitBeforeTestResult,NumberOfInfected,NumberOfRecovered,SymptomOnsetTime,ProbabilityDetectionWhenSymptoms,ProbabilityNeighborsAreTraced,ParentFactor,ChildFactor,NumberOfTestIsolations,NumberOfNodesToTrace,Asymptomatic,InfectiousWaitingTimeExponential,InfectiousExponentialMean);

        # If no nodes are infectiuos or exposed, stop simulation.
        if FoundNoInfectiousOrExposedNode == true
            NodesStillActive = false;
            break
        end

        # Infect all children that are due to get infected this time step.
        StateOfNodes,CountUpToStateChange,GoalOfCountDown,ListOfChildren,NumberOfInfected,ParentDictionary,NewlyInfectedArray=InfectNodesOnThisTimestep(StateOfNodes,ParentDictionary,CountUpToStateChange,GoalOfCountDown,ListOfChildren,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NumberOfInfected,R0,InfectiousProfile,IncludeExposedCompartment,ExposedExponentialMean,InfectiousWaitingTimeExponential,InfectiousExponentialMean);


        # Trace nodes that should get traced this time step and test nodes that get symptoms.
        TestArrivalTimeOfNodes,NumberOfTraceIsolations = TraceNode(WaitBeforeTracedAreReleased,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodesToTrace,NumberOfTraceIsolations);

        SumInfected=0
        for NodeId =1:length(StateOfNodes)
            if (StateOfNodes[NodeId]==1 || StateOfNodes[NodeId]==2)
                SumInfected+=1;
            end
        end
        push!(Icurve,SumInfected);#-Icurve[end]);

        # Keep track of Epidemic Tree..
        if (ProbabilityDetectionWhenSymptoms==0 && ProbabilityNeighborsAreTraced==0)
        for NewlyInfectedIndex = 1:length(NewlyInfectedArray)

            NewlyInfected = NewlyInfectedArray[NewlyInfectedIndex][2]+0;
            NewParent = NewlyInfectedArray[NewlyInfectedIndex][1]+0;

            if (length(TreeString)!=0)
                TreeString=string(TreeString,",",TimeStep,":",NewParent,":",NewlyInfected)

            else 
                TreeString=string(TreeString,TimeStep,":",NewParent,":",NewlyInfected)

            end
        end
        end

    end

    NumberOfRecovered=0;
    for NodeId =1:length(StateOfNodes)
        if (StateOfNodes[NodeId]==3)
            NumberOfRecovered+=1;
        end
    end

    # Now save results
    FilenameEnd=string("Network:",NetworkTypeName,"_InfectiousProfile:",InfectiousProfile,"_IncudeExposedCompartment",IncludeExposedCompartment,"_InfectiousWaitExponential:",InfectiousWaitingTimeExponential,"_AverageR0:",Average_R0,"_SymptomOnsetTime:",SymptomOnsetTime,"_TraceReleaseTime:",WaitBeforeTracedAreReleased,"_SeedNumber:",NumberOfSeeds,"_Ps:",ProbabilityDetectionWhenSymptoms,"_Pt:",ProbabilityNeighborsAreTraced,"_ParentFactor:",ParentFactor,"_ChildFactor:",ChildFactor,".txt");
    AppendLineToFile(string(DataPath,"Infected/",FilenameEnd),string(NumberOfRecovered)); # Number of Infected
    AppendLineToFile(string(DataPath,"TraceIsolated/",FilenameEnd),string(NumberOfTraceIsolations)); # Number of Infected
    AppendLineToFile(string(DataPath,"TestIsolated/",FilenameEnd),string(NumberOfTestIsolations)); # Number of Infected

    # Epidemic trees
    if (ProbabilityDetectionWhenSymptoms==0 && ProbabilityNeighborsAreTraced==0)
        #for Node in keys(ParentDictionary)
        AppendLineToFile(string(DataPath,"EpidemicTree/",FilenameEnd[1:end-4],"_Experiment:",ExperimentNumber,".txt"),TreeString); # Number of Infected
        #end
    end

    IcurveString=string(Icurve[1])
    for IcurveEntry=2:length(Icurve)
        IcurveString=string(IcurveString,",",Icurve[IcurveEntry])
    end
    AppendLineToFile(string(DataPath,"I_curves/",FilenameEnd),IcurveString); # Number of Infected


    println("Number Of Recovered:\t",NumberOfRecovered)
    println("Number Of Isolated (total):\t",NumberOfTestIsolations+NumberOfTraceIsolations)
    println("Number Of TraceIsolations:\t",NumberOfTraceIsolations)

end
