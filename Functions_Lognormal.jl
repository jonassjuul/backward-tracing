using DataFrames
function AdvanceInfectedOneTimestep(StateOfNodes,Network,ParentDictionary,CountUpToStateChange,GoalOfCountDown,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodeCanTestPositive,TraceNodesChildren,WaitBeforeTestResult,NumberOfInfected,NumberOfRecovered,SymptomOnsetTime,ProbabilityDetectionWhenSymptoms,ProbabilityNeighborsAreTraced,ParentFactor,ChildFactor,NumberOfTestIsolations,NumberOfNodesToTrace,Asymptomatic,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential)
    # This function advances all infectious nodes 1 step in their course of disease.

    # Inputs:
    # ---------
    #   StateOfNodes:                   Vector. Entry i shows state of node. 0 if Susceptible, 1 if Exposed, 2 if Infectious, 3 if Removed.
    #   Network:                        Dictionary. Key i (an integer) points to a vector of integer NodeIds. These are i's neighbors.
    #   ParentDictionary:               Dictionary. Key i (an integer) points to an integer NodeId -- i's parent.
    #   CountUpToStateChange:           Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:                Vector. Entry i determines when state of node i changes. Type: Vector.
    #   TestArrivalTimeOfNodes:         Vector. Each entry is a countdown (integer value) to when a node will get tested. 0 at day when test will be taken.
    #   ResultArrivalTimeOfNodes:       Vector. Each entry is a countdown (integer value) to arrival of test result. 0 at day of result arrival.
    #   NodeCanTestPositive:            Vector. Entry i is 1 if node i was infectious when it was tested. Otherwise 0.
    #   TraceNodesChildren              Vector. Entry i is 1 if node i's children should be traced.
    #   WaitBeforeTestResult:           Integer. Number of days before a test result arrives after test is taken.
    #   NumberOfInfected:               Integer. Number of nodes that have been in infected with the disease since start of simulation.
    #   NumberOfRecovered:              Integer. Number of nodes that have recovered from disease since start of simulation.
    #   SymptomOnsetTime:               String. Specifies when an in the course of disease an infectious node gets symptoms. Can be "immediately" or "halfway".
    #   ProbabilityDetectionWhenSymptoms:Float. ps in Kojaku et al. Probability that a node is identified at symptom onset.
    #   ProbabilityNeighborsAreTraced:  Float. pt in Kojaku et al. Probability that each neighbor of an infected node is traced.
    #   ParentFactor:                   Float. Weight of parents in tracing list.
    #   ChildFactor:                    Float. Weight of children in tracing list.
    #   NumberOfTestIsolations:         Integer. How many nodes have been isolated following positive tests?
    #   NumberOfNodesToTrace:           Integer. How many nodes from the contact tracing list will be isolated in the end? n in Kojaku et al.
    #   Asymptomatic:                   Vector. Entry i is either 0 or 1. 0 If node i is not permanently asymptomatic. 1 if it is. 
    #   InfectiousWaitingTimeExponential: Bool. true if waiting time in infectious state is exponentially distributed. false if lognormally distributed.    
    #   MeanOfInfectiousExponential:    Float. Mean of the exponential distributed waiting time for leaving the infectious compartment.

    # Outputs:
    # ---------

    #   StateOfNodes:                   Vector. Entry i shows state of node. 0 if Susceptible, 1 if Exposed, 2 if Infectious, 3 if Removed.
    #   CountUpToStateChange:           Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:                Vector. Entry i determines when state of node i changes. Type: Vector.
    #   TestArrivalTimeOfNodes:         Vector. Each entry is a countdown (integer value) to when a node will get tested. 0 at day when test will be taken.
    #   ResultArrivalTimeOfNodes        Vector. Each entry is a countdown (integer value) to arrival of test result. 0 at day of result arrival.
    #   NodeCanTestPositive:            Vector. Entry i is 1 if node i was infectious when it was tested. Otherwise 0.
    #   TraceNodesChildren:             Vector. Entry i is 1 if node i's children should be traced.
    #   NumberOfInfected:              Integer. Number of nodes that have recovered from disease since start of simulation.
    #   NumberOfRecovered:              Integer. Number of nodes that have recovered from disease since start of simulation.
    #   FoundNoInfectiousOrExposedNode: Bool. true if there are no more exposed or infectious nodes (ends simulation). False otherwise.
    #   NodesToTrace:                   Vector/List. Contains the n nodes that will be contact traced. These are the most-frequently appearing nodes in the contact tracing list.
    #   NumberOfTestIsolations:         Integer.


    # Variable to check if all nodes are susceptible or removed.
    FoundNoInfectiousOrExposedNode = true;

    TraceList=Dict();

    # Loop over nodes that might be infectious.
    for InfectedNode=1:length(StateOfNodes)

        # Check if node is infectious or exposed.
        if StateOfNodes[InfectedNode] == 1 || StateOfNodes[InfectedNode] == 2
            # If it is, remember.
            FoundNoInfectiousOrExposedNode = false;

            # Advance counter to state change 1 step
            CountUpToStateChange[InfectedNode] += 1;




            SymptomOnset=false;

            # Check if infectious node gets symptoms this time step.
            if (SymptomOnsetTime == "halfway") && (CountUpToStateChange[InfectedNode] == floor(GoalOfCountDown[InfectedNode]/2+0.5)) && (StateOfNodes[InfectedNode] == 2)
                SymptomOnset = true;
            elseif (SymptomOnsetTime == "immediately") && (CountUpToStateChange[InfectedNode]==0) && (StateOfNodes[InfectedNode] == 2)
                SymptomOnset = true;
            end

            if StateOfNodes[InfectedNode] == 2 && CountUpToStateChange[InfectedNode]>=0 && SymptomOnset==true && TestArrivalTimeOfNodes[InfectedNode]<0 && ResultArrivalTimeOfNodes[InfectedNode]<0 && Asymptomatic[InfectedNode]==0
                
                # Toss a coin and see if the node is detected
                RandomNumber=rand()+0;
                if (RandomNumber<ProbabilityDetectionWhenSymptoms) 

                    # If it is and is not waiting for test or result, order test.
                    TestArrivalTimeOfNodes[InfectedNode]=WaitBeforeTestTaken+0;
                    NumberOfTestIsolations+=1;

                    # OBSERVE: We don't really wait for the test to be taken...... 

                    #StateOfNodes[InfectedNode] =3; # Remove node (it is in isolation)

                    # Add neighbors to TraceList
                    for NeighborNumber= 1 : length(Network[InfectedNode])
                        if rand()<ProbabilityNeighborsAreTraced
                            if (Network[InfectedNode][NeighborNumber] in keys(TraceList))==false 
                                TraceList[Network[InfectedNode][NeighborNumber]]=0;
                            end
                            # Check if traced neighbor is the node's parent. If yes, make sure it is weighted as parent in the trace list.
                            if ParentDictionary[InfectedNode]==Network[InfectedNode][NeighborNumber]
                                TraceMultiplicationFactor=ParentFactor +0;
                            else 
                                TraceMultiplicationFactor = ChildFactor +0;
                            end
                            TraceList[Network[InfectedNode][NeighborNumber]] += TraceMultiplicationFactor+0;
                        end
                    end
                end
            end            
            #println("Problem: Sometimes nodes are exposed for 0 days. In the present code, they will not have a chance to change state on the 0th day.")
            # Check if node changes state.
            if CountUpToStateChange[InfectedNode] >= GoalOfCountDown[InfectedNode]
                # Change state of node.

                
                if StateOfNodes[InfectedNode]==1
                    # If node is Exposed.

                    # Make node Infectious
                    StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode],GoalOfCountDown[InfectedNode] = makeNodeInfectious(StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode],GoalOfCountDown[InfectedNode],InfectiousWaitingTimeExponential,MeanOfInfectiousExponential);
                    NumberOfInfected+=1;
                elseif StateOfNodes[InfectedNode]==2
                    # If node is Infectious
                    
                    # Make node Removed
                    StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode] = makeNodeRemoved(StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode]);

                    # Remember that 1 node recovered.
                    NumberOfRecovered +=1;

                end


            end
        end
        #println("Need to handle test wait/result.")

        # Check if node is waiting for a test .
        StateOfNodes[InfectedNode],TestArrivalTimeOfNodes[InfectedNode],ResultArrivalTimeOfNodes[InfectedNode],NodeCanTestPositive[InfectedNode] = AdvanceTestWaitOneStep(StateOfNodes[InfectedNode],TestArrivalTimeOfNodes[InfectedNode],ResultArrivalTimeOfNodes[InfectedNode],NodeCanTestPositive[InfectedNode],WaitBeforeTestResult)

        # Check if node is waiting for a test result.
        StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode],GoalOfCountDown[InfectedNode],TestArrivalTimeOfNodes[InfectedNode],ResultArrivalTimeOfNodes[InfectedNode],NodeCanTestPositive[InfectedNode],TraceNodesChildren[InfectedNode],NumberOfRecovered = AdvanceResultWaitOneStep(StateOfNodes[InfectedNode],CountUpToStateChange[InfectedNode],GoalOfCountDown[InfectedNode],TestArrivalTimeOfNodes[InfectedNode],ResultArrivalTimeOfNodes[InfectedNode],NodeCanTestPositive[InfectedNode],TraceNodesChildren[InfectedNode],NumberOfRecovered)     
    end

    # Now get Nodes to be traced.
    NodesToTrace = [];  # This list will contain all nodes that were traced more than the n'th most found node.
    NodesToTrace_OnCutoff=[]; # This list will contain all nodes that are tied to be the n'th most found node.
    OccurencesInTraceList = collect(values(TraceList));

    if (length(OccurencesInTraceList)>0)
        sort!(OccurencesInTraceList,rev=true) # Sort occurences from highest to lowest.
        CutoffTracedOrNot = OccurencesInTraceList[min(length(OccurencesInTraceList),NumberOfNodesToTrace)]; # How many times were the n'th most found node found?

        for NodeId in keys(TraceList)
            if (TraceList[NodeId]>CutoffTracedOrNot || length(OccurencesInTraceList) <= NumberOfNodesToTrace)
                push!(NodesToTrace,NodeId);
            elseif (TraceList[NodeId]==CutoffTracedOrNot)
                push!(NodesToTrace_OnCutoff,NodeId);
            end
        end

        shuffle!(NodesToTrace_OnCutoff); # Randomize order of nodes at cutoff.
        append!(NodesToTrace,NodesToTrace_OnCutoff[1:min(length(NodesToTrace_OnCutoff),NumberOfNodesToTrace-length(NodesToTrace))]); # Choose cutoff nodes such that we isolate n in total.
    end



    return StateOfNodes,CountUpToStateChange,GoalOfCountDown,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodeCanTestPositive,TraceNodesChildren,NumberOfInfected,NumberOfRecovered,FoundNoInfectiousOrExposedNode,NodesToTrace,NumberOfTestIsolations
end

function AdvanceResultWaitOneStep(StateOfNodes_specific,CountUpToStateChange_specific,GoalOfCountDown_specific,TestArrivalTimeOfNodes_specific,ResultArrivalTimeOfNodes_specific,NodeCanTestPositive_specific,TraceNodesChildren_specific,NumberOfRecovered)
                                #TraceNodesChildren[InfectedNode],NumberOfRecovered
    
    
   # This function checks if a node is waiting for a test result. If result is due, it [Insert].

    # Inputs
    # --------
    # StateOfNodes_specific:                State of the node in question. 0 If susceptible, 1 if exposed, 2 if infectious, 3 if recovered.
    # CountUpToStateChange_specific:        Integer. Number of days node has been in its current state.
    # GoalOfCountDown_specific:             Integer. Number of days node wil be in its current state before switching state.
    # TestArrivalTimeOfNodes_specific:      Countdown to when a node will get tested. 0 at day when test will be taken.
    # ResultArrivalTimeOfNodes_specific:    Countdown to arrival of test result. 0 at day of result arrival.
    # NodeCanTestPositive_specific:         Integer. 1 if node was infectious when it was tested. Otherwise 0.
    # TraceNodesChildren_specific:          Integer. 1 if node's children should be traced.  
    # NumberOfRecovered:                    Integer. Number of nodes that have recovered so far in this simulation.
    
    # Outputs
    # --------    
    # StateOfNodes_specific:                State of the node in question. 0 If susceptible, 1 if exposed, 2 if infectious, 3 if recovered.
    # CountUpToStateChange_specific:        Integer. Number of days node has been in its current state.
    # GoalOfCountDown_specific:             Integer. Number of days node wil be in its current state before switching state.
    # TestArrivalTimeOfNodes_specific:      Countdown to when a node will get tested. 0 at day when test will be taken.
    # ResultArrivalTimeOfNodes_specific:    Countdown to arrival of test result. 0 at day of result arrival.
    # NodeCanTestPositive_specific:         Integer. 1 if node was infectious when it was tested. Otherwise 0.
    # TraceNodesChildren_specific:          Integer. 1 if node's children should be traced.  
    # NumberOfRecovered:                    Integer. Number of nodes that have recovered so far in this simulation.
    
    
    # Check if node is waiting for a test result
    if ResultArrivalTimeOfNodes_specific >=0
        # If node is waiting for a test result, check if result arrives today.
        if ResultArrivalTimeOfNodes_specific == 0 


            # If result arrives today, check whether node can even test positive [if test could be false negative, this is where one would check if test is false negative]
            if NodeCanTestPositive_specific==1

                # If node has not already recovered, add one node to recovered population
                if StateOfNodes_specific != 3
                    NumberOfRecovered +=1;
                end
                # Node tested positive. Trace its children.
                TraceNodesChildren_specific =1+0;

                # Node gets isolated (in model this is done by letting node recover).
                StateOfNodes_specific = 3+0;
                #println("I just removed a node.")
                # Ignore any counting down to state change, tests or test results.
                CountUpToStateChange_specific = -1 +0;
                GoalOfCountDown_specific = -9 +0;
                TestArrivalTimeOfNodes_specific = -9+0;
                ResultArrivalTimeOfNodes_specific = -9+0;


            else 
                # Node did not test positive. Register that result has arrived.
                ResultArrivalTimeOfNodes_specific = -9+0;

            end
            # Result was delivered. Reset whether node can test positive.
            NodeCanTestPositive_specific = 0;

        else 
            # If Result was not delivered this time step, advance time 1 step.
            ResultArrivalTimeOfNodes_specific -=1;
        end


    end

    return StateOfNodes_specific,CountUpToStateChange_specific,GoalOfCountDown_specific,TestArrivalTimeOfNodes_specific,ResultArrivalTimeOfNodes_specific,NodeCanTestPositive_specific,TraceNodesChildren_specific,NumberOfRecovered
end

function AdvanceTestWaitOneStep(StateOfNodes_specific,TestArrivalTimeOfNodes_specific,ResultArrivalTimeOfNodes_specific,NodeCanTestPositive_specific,WaitBeforeTestResult)
    # This function checks if a node is waiting for having a test taken. If test is due, it starts the node's wait for a test result.

    # Inputs
    # --------
    # StateOfNodes_specific:                State of the node in question. 0 If susceptible, 1 if exposed, 2 if infectious, 3 if recovered.
    # TestArrivalTimeOfNodes_specific:      Countdown to when a node will get tested. 0 at day when test will be taken.
    # ResultArrivalTimeOfNodes_specific:    Countdown to arrival of test result. 0 at day of result arrival.
    # NodeCanTestPositive_specific:         Integer. 1 if node was infectious when it was tested. Otherwise 0.
    # WaitBeforeTestResult:                 Integer. Number of days before a test result arrives after test is taken.

    # Outputs
    # --------
    # StateOfNodes_specific:                Integer. State of the node in question. 0 If susceptible, 1 if exposed, 2 if infectious, 3 if recovered.
    # TestArrivalTimeOfNodes_specific:      Integer. Countdown to when a node will get tested. 0 at day when test will be taken.
    # ResultArrivalTimeOfNodes_specific:    Integer. Countdown to arrival of test result. 0 at day of result arrival.
    # NodeCanTestPositive_specific:         Integer. 1 if node was infectious when it was tested. Otherwise 0.


    # Check if node is waiting for a test
    if TestArrivalTimeOfNodes_specific >= 0

        # If waiting, check if test is taken today.
        if TestArrivalTimeOfNodes_specific == 0
            # If test is taken today, start node's wait for a test result.
            ResultArrivalTimeOfNodes_specific = WaitBeforeTestResult+0;

            # Check whether this test can be positive. Only can if node is infectious at time of test.
            if StateOfNodes_specific == 2
                NodeCanTestPositive_specific = 1 +0;
            end
        end
        # Advance node's test count down one.
        TestArrivalTimeOfNodes_specific -=1;
    end

    return StateOfNodes_specific,TestArrivalTimeOfNodes_specific,ResultArrivalTimeOfNodes_specific,NodeCanTestPositive_specific
    
end

function AppendLineToFile(FileDestination,StringToSave)
    # This function saves a string as a new line in a file.
    # Inputs:
    # - FileDestination:    String. Path to where line should be saved.
    # - StringToSave:       String. The string that should be saved to the file.
    open(FileDestination,"a") do File
    
        write(File,string("\n",StringToSave))
    end

end

function drawExponentiallyDistributedInteger(MeanOfExponential)
    # Return an integer drawn from a Geometric distribution with mean R0OfNode
    # Inputs 
    # --------
    # MeanOfExponential:     Float. Mean of exponential distribution.

    # Outputs
    # --------
    # DrawnInteger  Integer. Drawn from exponential distribution

    # 

    # Get the exponential distribution
    ExponentialDistribution=getExponentialDistribution(MeanOfExponential);


    RandomFloat = rand()+0;
    DrawnInteger = -1;

    CumulativeExponentialDistribution =0 ;
    DrawnIntegerFound = false;
    while DrawnIntegerFound==false
        DrawnInteger += 1;

        CumulativeExponentialDistribution += ExponentialDistribution[DrawnInteger+1];

        if CumulativeExponentialDistribution >= RandomFloat
            DrawnIntegerFound = true;
            break
        end
    end
    
    
    return DrawnInteger
end

function drawGeometricInteger(R0OfNode)
    # Return an integer drawn from a Geometric distribution with mean R0OfNode
    # Inputs 
    # --------
    # R0OfNode:     Float. Mean of Geometric distribution

    # Outputs
    # --------
    # DrawnInteger  Integer. Drawn from Geometric distribution

    RandomFloat = rand()+0;
    DrawnInteger = -1;

    CumulativeGeometricDistribution =0 ;
    DrawnIntegerFound = false;
    while DrawnIntegerFound==false
        DrawnInteger += 1;

        CumulativeGeometricDistribution += evaluateGeometricDistribution(R0OfNode,DrawnInteger)

        if CumulativeGeometricDistribution >= RandomFloat
            DrawnIntegerFound = true
            break
        end
    end
    return DrawnInteger
end



function drawLognormallyDistributedInteger()
    # Output:
    # An integer drawn from a lognormal distribution.


    # Retrieve lognormal distribution
	LognormalDistribution = getLognormalDistribution();
	RandomFloat = rand()+0;

	SumOfLognormallyDistributedValues =0;

	Result = length(LognormalDistribution) + 0;
	for Day = 1:length(LognormalDistribution)

		SumOfLognormallyDistributedValues += LognormalDistribution[Day];
		if SumOfLognormallyDistributedValues >= RandomFloat || Day==length(LognormalDistribution)
			Result = Day;
			break

                end

	end

	return Result


end


function drawNumberOfChildren(R0OfNode,OffspringDistribution)

    if (OffspringDistribution=="poisson")

        NumberOfChildren = drawPoissonInteger(R0OfNode)

    elseif (OffspringDistribution=="geometric")
        NumberOfChildren = drawGeometricInteger(R0OfNode)

    end
    return NumberOfChildren
end

function drawPoissonInteger(R0OfNode)
    # Return an integer drawn from a Poisson distribution with mean R0OfNode
    # Inputs 
    # --------
    # R0OfNode:     Float. Mean of Poisson distribution

    # Outputs
    # --------
    # DrawnInteger  Integer. Drawn from Poisson distribution

    RandomFloat = rand()+0;
    DrawnInteger = -1;

    CumulativePoissonDistribution =0 ;
    DrawnIntegerFound = false;
    while DrawnIntegerFound==false
        DrawnInteger += 1;

        CumulativePoissonDistribution += evaluatePoissonDistribution(R0OfNode,DrawnInteger)

        if CumulativePoissonDistribution >= RandomFloat
            DrawnIntegerFound = true
            break
        end
    end
    return DrawnInteger
end

function drawTimesWhenInfectedWillInfectOthers(NumberOfChildrenToDraw,CounterGoalOfNode,InfectiousProfile)
    # Creates an array containing at what times an infectious node will infect others.
    # Inputs:
    # ---------
    # - NumberOfChildrenToDraw:     Integer. The number of people the node will infect.
    # - CounterGoalOfNode:          Integer. The number of days the node will be infectious.
    # - InfectiousProfile:          String. Name of the profile of infectiousness.

    # Outputs:
    # ---------
    # TimesOfInfection              Array of integers. Contains times at which the node infects other people.

    # Make array to contain infection times.
    TimesOfInfection = [];

    # Get infectiousness profile of the period that node is infectious.
    InfectiousnessDistribution = getInfectiousnessDistribution(CounterGoalOfNode,InfectiousProfile);

    for ChildNumber =1:NumberOfChildrenToDraw
        if InfectiousProfile=="empirical" || InfectiousProfile=="FlatSkewed"
            RandomFloat = rand()+0;
            Day =0;

            FoundDayOfInfection = false;
            SumInfectiousProfile = 0;
            while FoundDayOfInfection == false
                Day +=1;
                SumInfectiousProfile += InfectiousnessDistribution[Int(Day)];

                if SumInfectiousProfile>= RandomFloat
                    FoundDayOfInfection = true
                    break
                end

            end
            TimesOfInfection = push!(TimesOfInfection,Day);

        else
            print("USING INFECTIOUS PROFILE THAT WAS NOT IMPLEMENTED")
        end
    end
    return TimesOfInfection
end

function evaluateGeometricDistribution(R0OfNode,DrawnInteger)
    return (R0OfNode/(1+R0OfNode))^DrawnInteger / (R0OfNode + 1)
end

function evaluatePoissonDistribution(R0OfNode,DrawnInteger)
    if DrawnInteger > 20
        factorial_computed = factorial(big(DrawnInteger));
    else
        factorial_computed = factorial(DrawnInteger);
    end
    return R0OfNode^DrawnInteger/factorial_computed*exp(-R0OfNode)
end
function getCorrectedEmpiricalInfectiousness() 

	CorrectedEmpiricalInfectiousness = [0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000006, 0.000000000400, 0.000000014828, 0.000000327126, 0.000004598193, 0.000043551427, 0.000291074036, 0.001426631003, 0.005296911006, 0.015315428062, 0.035311746313, 0.066265116634, 0.103030125971, 0.134813059932, 0.150505975534, 0.145114140518, 0.122150668664, 0.090637282629, 0.059800573129, 0.035357288295, 0.018866386876, 0.009143443810, 0.004048236058, 0.001646108958, 0.000617722128, 0.000214881890, 0.000069574929, 0.000021046826, 0.000005969123, 0.000001592286, 0.000000400693, 0.000000095386, 0.000000021536, 0.000000004623, 0.000000000945, 0.000000000185, 0.000000000034, 0.000000000006, 0.000000000001, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000, 0.000000000000];
	return CorrectedEmpiricalInfectiousness # entry 29 is symptom onset.
end

function getExponentialDistribution(MeanOfExponential)
    
    
    # Inputs 
    # --------
    # MeanOfExponential:        Float. Mean of exponential distribution.

    # Outputs
    # --------
    # ExponentialDistribution:  Vector. Normalized Exponential probability distribution with length equal to the lognormal distribution defined elsewhere. 

    # 

    l=1/MeanOfExponential;
    NumberOfDays=length(getLognormalDistribution()); # Number of days the distribution should be defined on. [0,NumberOfDays-1].

    ExponentialDistribution=[];
    SumDistribution=0;
    for DayNumber =0:NumberOfDays-1
        push!(ExponentialDistribution,l*exp(-l*DayNumber));
        SumDistribution+=l*exp(-l*DayNumber);
    end

    # Normalize
    ExponentialDistribution =ExponentialDistribution./SumDistribution;

    return ExponentialDistribution
end

function getFlatSkewedInfectiousness()
    FlatSkewedInfectiousness = [0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.011204481792717087,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435,0.0056022408963585435];
    return FlatSkewedInfectiousness
end
function getInfectiousnessDistribution(CounterGoalOfNode,InfectiousProfile)

	InfectiousnessDistribution = zeros(Int(CounterGoalOfNode))#fill(Int[], Int(CounterGoalOfNode),1);

    if (InfectiousProfile=="empirical")
	EmpiricalInfectiousness = getCorrectedEmpiricalInfectiousness();
    elseif (InfectiousProfile=="FlatSkewed")
        EmpiricalInfectiousness = getFlatSkewedInfectiousness();

    elseif (InfectiousProfile=="Flat")
        EmpiricalInfectiousnessLength=length(getCorrectedEmpiricalInfectiousness());
        EmpiricalInfectiousness=ones(EmpiricalInfectiousnessLength);

    else
        print("USING INFECTIOUS PROFILE THAT WAS NOT IMPLEMENTED")
    end

    DenominatorSum = 0;
    #OffsetDays = Int(max(floor((length(EmpiricalInfectiousness)-1)/2)-floor(CounterGoalOfNode/2), 0));
    OffsetDays = Int(max(ceil(length(EmpiricalInfectiousness)/2)-floor(CounterGoalOfNode/2), 1));

    for Day = 1:Int(CounterGoalOfNode)



        InfectiousnessDistribution[Day] += EmpiricalInfectiousness[min(OffsetDays+Day-1,length(EmpiricalInfectiousness))];
        DenominatorSum += EmpiricalInfectiousness[min(OffsetDays+Day-1,length(EmpiricalInfectiousness))];

    end

    for Day = 1:Int(CounterGoalOfNode)
        InfectiousnessDistribution[Day] /= DenominatorSum;
    end        

    if (rand()<0.001)
        PrintSum=0
        for Day = 1:Int(CounterGoalOfNode)
            PrintSum+=InfectiousnessDistribution[Day];
        end  
        #println("Sum of Infectiousness Dist:\t",PrintSum)
    end

    return InfectiousnessDistribution
end


function getInitialConditionsOfSimulation(StateOfNodes,ParentDictionary,SeedsThisExperiment,CountUpToStateChange,GoalOfCountDown,IncludeExposedCompartment,MeanOfExposedExponential,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential)
    # Initialized 4 of state vectors.
    # Inputs:
    # ----------
    #   StateOfNodes:                   Vector with state of node i on entry i; type: Vector
    #   ParentDictionary:               
    #   SeedsThisExperiment:            Vector with entry i being seeds i; Type: Vector
    #   CountUpToStateChange:           Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:                Vector. Entry i determines when state of node i changes. Type: Vector.
    #   WhenInfectedWillInfectOthers:   Vector of lists. List on entry i contains times after infection when node i will infect others.
    #   IncludeExposedCompartment:      Bool. true if model is SEIR. Otherwise model is SIR.
    #   MeanOfExposedExponential:       Float. Mean of the exponential distributed waiting time for leaving the exposed compartment.i
    #   InfectiousWaitingTimeExponential: Bool. true if waiting time in infectious state is exponentially distributed. false if lognormally distributed.    
    #   MeanOfInfectiousExponential:    Float. Mean of the exponential distributed waiting time for leaving the infectious compartment.

    # Outputs:
    # ----------
    #   StateOfNodes:           Vector with state of node i on entry i; type: Vector
    #   CountUpToStateChange:   Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:        Vector. Entry i determines when state of node i changes. Type: Vector.



    # Seeds start out Infectious.
    for Seed in SeedsThisExperiment
        if (IncludeExposedCompartment == true) 
            StateOfNodes[Seed] += 1;
            # Draw goal for count of all seeds    
            GoalOfCountDown[Seed] += drawExponentiallyDistributedInteger(MeanOfExposedExponential);   
            
            if (GoalOfCountDown[Seed]==0) # instead go directly to infectious compartment..
                
                StateOfNodes[Seed] += 1;
                # Draw goal for count of all seeds    
               
                if (InfectiousWaitingTimeExponential==false)
                    GoalOfCountDown[Seed] += 2*drawLognormallyDistributedInteger();
                else
                    GoalOfCountDown[Seed] += 2*drawExponentiallyDistributedInteger(MeanOfInfectiousExponential);
                end


            end

            #println(" I drew\t",GoalOfCountDown[Seed])        
        else
            StateOfNodes[Seed] += 2;
            # Draw goal for count of all seeds    
            #GoalOfCountDown[Seed] += 2*drawLognormallyDistributedInteger();
            if (InfectiousWaitingTimeExponential==false)
                GoalOfCountDown[Seed] += 2*drawLognormallyDistributedInteger();
            else
                GoalOfCountDown[Seed] += 2*drawExponentiallyDistributedInteger(MeanOfInfectiousExponential);
            end

        end
        # -1 because these nodes get their count advanced once before having a chance to infect.
        CountUpToStateChange[Seed] =-1+0;
        


        # We expect people with longer infectious periods to infect more...
        ParentDictionary[Seed] =-1;

    end

    return StateOfNodes,CountUpToStateChange,GoalOfCountDown
end

function getLognormalDistribution()
	# Incubation time lognormal distribution
	LognormalDistribution = [0.003928899789, 0.068966842356, 0.151229922834, 0.177164768798, 0.159473206432, 0.126225212682, 0.093377539613, 0.066601193262, 0.046592864872, 0.032292432894, 0.022307832766, 0.015417789810, 0.010686160309, 0.007438793831, 0.005205546862, 0.003663990068, 0.002594779101, 0.001849127194, 0.001326071478, 0.000956932785, 0.000694814444, 0.000507543367, 0.000372931527, 0.000275591462, 0.000204790215, 0.000152997488, 0.000114898935, 0.000086722192, 0.000065774043, 0.000050120846, 0.000038366621, 0.000029498110, 0.000022775974, 0.000017657978, 0.000013744467, 0.000010739444, 0.000008422656, 0.000006629465, 0.000005236258, 0.000004149825, 0.000003299588, 0.000002631891, 0.000002105782, 0.000001689883, 0.000001360066, 0.000001097709, 0.000000888391, 0.000000720903, 0.000000586509, 0.000000478372, 0.000000391131, 0.000000320564, 0.000000263340, 0.000000216822, 0.000000178915, 0.000000147954, 0.000000122607, 0.000000101811, 0.000000084712];

	return LognormalDistribution
end

function getMeanDegree(Network)
    NumberOfEdges =0;
    NumberOfNodes =0;
    for Node in keys(Network)
        NumberOfNodes+=1;
        NumberOfEdges+=length(Network[Node]);

    end

    return NumberOfEdges/(NumberOfNodes)
end

function getMeanOfLognormalDistribution()
	MeanOfLognormalDistribution =0;
	LognormalDistribution = getLognormalDistribution();
	for Day = 1:length(LognormalDistribution)
		MeanOfLognormalDistribution += (Day) * LognormalDistribution[Day];
    end
	return MeanOfLognormalDistribution
end

function getNetwork(NetworkFileLocation)
    # Inputs:
    # -----------
    # - NetworkFileLocation:     string. location of .csv file containing edge list.

    # Read csv
    df_EdgeList=CSV.read(NetworkFileLocation,DataFrame);

    # Make Network 
    Network=Dict();
    for NodeIndex=1:length(df_EdgeList.Node1)
        Node1=df_EdgeList.Node1[NodeIndex]+1;
        Node2=df_EdgeList.Node2[NodeIndex]+1;

        # Check if both nodes are already in network. If not, add them.
        if (Node1 in keys(Network))==false
            Network[Node1]=[]
        end
        if (Node2 in keys(Network))==false
            Network[Node2]=[]
        end
        # Add node to lists of neighbors
        push!(Network[Node1],Node2);
        push!(Network[Node2],Node1);

    end


    return Network
end

function getSeeds(SeedFileLocation)
    # Inputs:
    # -----------
    # - SeedFileLocation:     string. location of .csv file containing seed list.

    # Read csv
    SeedList=readlines(SeedFileLocation);

    Seeds=[];
    for Seed in SeedList
        push!(Seeds,Seed);
    end

    return Seeds

end

function InfectNodesOnThisTimestep(StateOfNodes,ParentDictionary,CountUpToStateChange,GoalOfCountDown,ListOfChildren,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NumberOfInfected,R0,InfectiousProfile,IncludeExposedCompartment,MeanOfExposedExponential,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential)
    # Inputs
    # --------
    #   StateOfNodes:                   Vector. Entry i shows state of node. 0 if Susceptible, 1 if Exposed, 2 if Infectious, 3 if Removed.
    #   ParentDictionary:               Dictionary. Key i (an integer) points to an integer NodeId -- i's parent.
    #   CountUpToStateChange:           Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:                Vector. Entry i determines when state of node i changes. Type: Vector.
    #   ListOfChildren:                 Dictionary. Entry i (an integer) points to a vector containing NodeIds (integers) of the children of i.
    #   TestArrivalTimeOfNodes:         Vector. Each entry is a countdown to when a node will get tested. 0 at day when test will be taken.
    #   ResultArrivalTimeOfNodes:       Vector. Each entry is a countdown to arrival of test result. 0 at day of result arrival.
    #   NumberOfInfected:               Integer. The number of infected nodes so far.
    #   R0:                             Float. Basic reproduction number (mean).
    #   InfectiousProfile:              String. Specifies twhen infectious nodes are most and least infectious.
    #   IncludeExposedCompartment:      Bool. true if model is SEIR. false if not.
    #   MeanOfExposedExponential:       Float. Mean of exponential waiting time distribution for the Exposed compartment.
    #   InfectiousWaitingTimeExponential: Bool. true if waiting time in infectious state is exponentially distributed. false if lognormally distributed.    
    #   MeanOfInfectiousExponential:    Float. Mean of the exponential distributed waiting time for leaving the infectious compartment.


    # Outputs
    # --------
    #   StateOfNodes:                   Vector. Entry i shows state of node. 0 if Susceptible, 1 if Exposed, 2 if Infectious, 3 if Removed.
    #   CountUpToStateChange:           Vector. Entry i counts up towhen state of node i changes; Type: Vector
    #   GoalOfCountDown:                Vector. Entry i determines when state of node i changes. Type: Vector.
    #   ListOfChildren:                 Dictionary. Entry i (an integer) points to a vector containing NodeIds (integers) of the children of i.
    #   NumberOfInfected:               Integer. The number of infected nodes so far.
    #   ParentDictionary:               Dictionary. Key i (an integer) points to an integer NodeId -- i's parent.


    InfectionsThisTimestep = [];

    # Loop over nodes that might be infected. Get list of all infections that will happen this time step.
    for InfectedNode=1:length(StateOfNodes)
        # Get time-dependent q -- the relative infectiousness of an infected node on day x of disease.
        if StateOfNodes[InfectedNode]==2
            NodesRelativeInfectiousness=getInfectiousnessDistribution(GoalOfCountDown[InfectedNode],InfectiousProfile)[Int(min(Int(CountUpToStateChange[InfectedNode]+1),GoalOfCountDown[InfectedNode]))]+0;
            ProbabilityOfInfectingNeighbor = R0*NodesRelativeInfectiousness+0;
            #if (InfectedNode in keys(CheckInfectioussness))==false 
            #    CheckInfectioussness[InfectedNode]=0+0;
            #end
            #CheckInfectioussness[InfectedNode] +=ProbabilityOfInfectingNeighbor;
            #if (rand()<0.001)
            #    println("Prob\t",ProbabilityOfInfectingNeighbor)
            #end
            # Check if node is 1) Infectious, 2) Waiting for a test, 3) Waiting for a test result
            if StateOfNodes[InfectedNode]==2 && TestArrivalTimeOfNodes[InfectedNode]<0 && ResultArrivalTimeOfNodes[InfectedNode]<0
                # Loop of neighbors
                for NeighborNumber=1:length(Network[InfectedNode])
                    Neighbor=Network[InfectedNode][NeighborNumber]+0;
                    # If node is Susceptible and not in isolation, check if it gets infected
                    if StateOfNodes[Neighbor]==0 && TestArrivalTimeOfNodes[Neighbor]<0 && ResultArrivalTimeOfNodes[Neighbor]<0
                        RandomNumber =rand()+0;
                        if RandomNumber<ProbabilityOfInfectingNeighbor
                            push!(InfectionsThisTimestep,(InfectedNode+0,Neighbor+0));

                        end
                    end
                end
            end
        end
    end

    # Shuffle order of infections.
    shuffle!(InfectionsThisTimestep);
    
    NewlyInfectedArray=[];

    for InfectionNumber=1:length(InfectionsThisTimestep)
        NodeToBeInfected = InfectionsThisTimestep[InfectionNumber][2]+0;
        ParentNode = InfectionsThisTimestep[InfectionNumber][1]+0;


        # Node can only get infected if it is susceptible...
        if StateOfNodes[NodeToBeInfected]==0
            push!(NewlyInfectedArray,(ParentNode+0,NodeToBeInfected+0))

            # Could make node Exposed instead...
            if (IncludeExposedCompartment==true)
                StateOfNodes[NodeToBeInfected],CountUpToStateChange[NodeToBeInfected],GoalOfCountDown[NodeToBeInfected],NumberOfInfected = makeNodeExposed(StateOfNodes[NodeToBeInfected],CountUpToStateChange[NodeToBeInfected],GoalOfCountDown[NodeToBeInfected],MeanOfExposedExponential,NumberOfInfected,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential);
                if (StateOfNodes[NodeToBeInfected]==2)
                    CountUpToStateChange[NodeToBeInfected]=-1; # -1 because state will be advanced once before it gets to infect others.
                end
            else
                StateOfNodes[NodeToBeInfected],CountUpToStateChange[NodeToBeInfected],GoalOfCountDown[NodeToBeInfected] = makeNodeInfectious(StateOfNodes[NodeToBeInfected],CountUpToStateChange[NodeToBeInfected],GoalOfCountDown[NodeToBeInfected],InfectiousWaitingTimeExponential,MeanOfInfectiousExponential);
                NumberOfInfected +=1;
                CountUpToStateChange[NodeToBeInfected]=-1; # -1 because state will be advanced once before it gets to infect others.
            end

            ListOfChildren_specific = copy(ListOfChildren[ParentNode]);
            ListOfChildren_specific = push!(ListOfChildren_specific,NodeToBeInfected+0);
            ListOfChildren[ParentNode] = copy(ListOfChildren_specific);

            # Save who the parent is.
            ParentDictionary[NodeToBeInfected]=ParentNode+0;

        #else
        #    println("Trying to infect non-susc node.")
        end

    end




    return StateOfNodes,CountUpToStateChange,GoalOfCountDown,ListOfChildren,NumberOfInfected,ParentDictionary,NewlyInfectedArray
end

function makeNodeExposed(StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual,MeanOfExposedExponential,NumberOfInfected,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential)
    # This function changes the state of a node from Exposed to Infectious.

    # Inputs
    # --------
    # StateOfNodes_individual:                  Integer. State of node in question. Is node's entry in StateOfNodes vector.
    # CountUpToStateChange_individual:          Integer. Counter up to next time the node changes state. Is node's entry in CountUpToStateChange vector.
    # GoalOfCountDown_individual:               Integer. When the node will change state next time.
    # MeanOfExposedExponential:                 Float. Mean of the exponential waiting time probability distribution.
    # NumberOfInfected:                         Integer. Number of nodes that have become infected this simulation.
    # InfectiousWaitingTimeExponential:         Bool. true if waiting time in infectious state is exponentially distributed. false if lognormally distributed.    
    # MeanOfInfectiousExponential:              Float. Mean of the exponential distributed waiting time for leaving the infectious compartment.

    # Outputs
    # ---------
    # StateOfNodes_individual:                   Integer. State of node in question. Is node's entry in StateOfNodes vector.
    # CountUpToStateChange_individual:          Integer. Counter up to next time the node changes state. Is node's entry in CountUpToStateChange vector.
    # GoalOfCountDown_individual:               Integer. When the node will change state next time.
    # NumberOfInfected:                         Integer. Number of nodes that have become infected this simulation.


    # First, make state to 1:
    StateOfNodes_individual =1+0;

    # Reset count down to next change of node state.
    CountUpToStateChange_individual =0;

    # Draw time for node's next state change.
    GoalOfCountDown_individual = drawExponentiallyDistributedInteger(MeanOfExposedExponential)+0;

    if (GoalOfCountDown_individual==0)
        StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual=makeNodeInfectious(StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential);
        NumberOfInfected+=1;
    end

    return StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual,NumberOfInfected

end

function makeNodeInfectious(StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual,InfectiousWaitingTimeExponential,MeanOfInfectiousExponential)
    # This function changes the state of a node from Exposed to Infectious.

    # Inputs
    # --------
    # StateOfNodes_individual:                   Integer. State of node in question. Is node's entry in StateOfNodes vector.
    # CountUpToStateChange_individual:          Integer. Counter up to next time the node changes state. Is node's entry in CountUpToStateChange vector.
    # GoalOfCountDown_individual:               Integer. When the node will change state next time.
    # InfectiousWaitingTimeExponential:         Bool. true if waiting time in infectious state is exponentially distributed. false if lognormally distributed.    
    # MeanOfInfectiousExponential:              Float. Mean of the exponential distributed waiting time for leaving the infectious compartment.

    
    # Outputs
    # ---------
    # StateOfNodes_individual:                   Integer. State of node in question. Is node's entry in StateOfNodes vector.
    # CountUpToStateChange_individual:          Integer. Counter up to next time the node changes state. Is node's entry in CountUpToStateChange vector.
    # GoalOfCountDown_individual:               Integer. When the node will change state next time.


    # First, make state to 2:
    StateOfNodes_individual =2+0;

    # Reset count down to next change of node state.
    CountUpToStateChange_individual =0;

    # Draw time for node's next state change.
    #GoalOfCountDown_individual = 2*drawLognormallyDistributedInteger()+0;
    if (InfectiousWaitingTimeExponential==false)
        GoalOfCountDown_individual += 2*drawLognormallyDistributedInteger();
    else
        GoalOfCountDown_individual += 2*drawExponentiallyDistributedInteger(MeanOfInfectiousExponential);
    end      
    #println("drew:\t",GoalOfCountDown_individual)

    return StateOfNodes_individual,CountUpToStateChange_individual,GoalOfCountDown_individual

end


function makeNodeRemoved(StateOfNodes_individual,CountUpToStateChange_individual)
    # This function changes the state of a node from Infectious to Removed.

    # Inputs
    # --------
    # StateOfNodes_individual:          Integer. State of node in question. Is node's entry in StateOfNodes vector.
    # CountUpToStateChange_individual:  Integer. Counter up to next time the node changes state. Is node's entry in CountUpToStateChange vector.

    # Outputs
    # ---------

    # Advance state 1:
    StateOfNodes_individual +=1;

    # Stop counter to count up to another change of states.
    CountUpToStateChange_individual = -1;

    return StateOfNodes_individual,CountUpToStateChange_individual

end


function TraceNode(WaitBeforeTracedAreReleased,TestArrivalTimeOfNodes,ResultArrivalTimeOfNodes,NodesToTrace,NumberOfTraceIsolations)
    # This function traces children of nodes that tested positive this time step. Also orders test for nodes that got symptomatic this time step.

    # Inputs
    # --------

    #   WaitBeforeTestTaken:            Integer. Number of days between a test is ordered and it is taken.
    #   TestArrivalTimeOfNodes:         Vector. Entry i is an integer. The integer is the number of days left before the node gets its test taken. (<0 meaning no test ordered or already taken)
    #   ResultArrivalTimeOfNodes:       Vector. Entry i is an integer. The integer is the number of days left before the node gets its test result. (<0 meaning no test ordered or already delivered)
    #   NodesToTrace:                   Vector. Contains the n nodes that are traced this time step.
    #   NumberOfTraceIsolations:        Integer. Number of nodes that have been traced then isolated so far.

    # Outputs
    # ---------
    #   TestArrivalTimeOfNodes:           Vector. Each entry is a countdown to when a node will get tested. 0 at day when test will be taken.
    #   NumberOfTraceIsolations:          Integer. Number of nodes that have been traced then isolated so far.

    
    for TracedNodeNumber =1:length(NodesToTrace)
        TracedNode=NodesToTrace[TracedNodeNumber];
        
        # Order test for the node.
        if TestArrivalTimeOfNodes[TracedNode]<0 && ResultArrivalTimeOfNodes[TracedNode]<0
            #if (WaitBeforeTracedAreReleased == Wait) :
            TestArrivalTimeOfNodes[TracedNode] = WaitBeforeTracedAreReleased +0 ;#WaitBeforeTestTaken + 0;
            NumberOfTraceIsolations +=1;
            
        end        
    end


    return TestArrivalTimeOfNodes, NumberOfTraceIsolations
end
