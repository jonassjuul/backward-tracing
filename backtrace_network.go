package main

import (
	"fmt"
	"strconv"
	"math/rand"
    "math"
	"sort"
	"time"	
	"os"
	"log"
	"encoding/csv"
	"io"
)
func make_network_from_csv(filename string) [][]int{
	var node_number int 
	var file_content [2][]int 
	csvfile, err := os.Open(filename)
	if err != nil {
		log.Fatalln("Couldn't open the csv file", err)
	}

	// Parse the file
	r := csv.NewReader(csvfile)
	//r := csv.NewReader(bufio.NewReader(csvfile))

	// Iterate through the records
	for {
		// Read each record from csv
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		record2,err := strconv.Atoi(record[0])
		record3,err := strconv.Atoi(record[1])

		file_content[0] = append(file_content[0],record2)
		file_content[1] = append(file_content[1],record3)


		record0,err:=strconv.ParseFloat(record[0],64)
		record1,err:=strconv.ParseFloat(record[1],64)

		if (math.Max(record0,record1)>float64(node_number)) {
			node_number = int(math.Max(record0,record1))

		}
	}
	
	// Now open again and make the array
	var network_arr = make([][]int,node_number+1)
	for i:=0; i<len(file_content[0]);i++ {
		if (file_content[0][i]!=file_content[1][i]) {
			network_arr[file_content[0][i]] = append(network_arr[file_content[0][i]],file_content[1][i])
			network_arr[file_content[1][i]] = append(network_arr[file_content[1][i]],file_content[0][i])
		}
	}
	return network_arr

}

func mean_degree(network_arr [][]int) float64 {
	var degree float64 
	var nodes float64
	for node := 0; node < len(network_arr); node++ {
		degree += float64(len(network_arr[node]))
		nodes += float64(1)

	}
	return degree/nodes
}


func say_something() {
	fmt.Println("Hello!")
}

func get_lognormal() [59]float64{
	// Lognormal dist:
	logn := [59]float64{ 0.003928899789,0.068966842356,0.151229922834,0.177164768798,0.159473206432,0.126225212682,0.093377539613,0.066601193262,0.046592864872,0.032292432894,0.022307832766,0.015417789810,0.010686160309,0.007438793831,0.005205546862,0.003663990068,0.002594779101,0.001849127194,0.001326071478,0.000956932785,0.000694814444,0.000507543367,0.000372931527,0.000275591462,0.000204790215,0.000152997488,0.000114898935,0.000086722192,0.000065774043,0.000050120846,0.000038366621,0.000029498110,0.000022775974,0.000017657978,0.000013744467,0.000010739444,0.000008422656,0.000006629465,0.000005236258,0.000004149825,0.000003299588,0.000002631891,0.000002105782,0.000001689883,0.000001360066,0.000001097709,0.000000888391,0.000000720903,0.000000586509,0.000000478372,0.000000391131,0.000000320564,0.000000263340,0.000000216822,0.000000178915,0.000000147954,0.000000122607,0.000000101811,0.000000084712 }
	return logn
}

func get_skewed_function(infectious_ends int,child_location string,child_location_parameters [1]float64) []float64 {
	child_location_array := make([]float64,infectious_ends)
	if (child_location == "poisson") {
		mean := child_location_parameters[0]
		var denominator float64
		for day:= 0 ; day < infectious_ends ; day ++ {
			child_location_array[day] += math.Pow(math.Pow(mean,float64(day))/factorial(float64(day))*math.Exp(-mean),1)
			denominator += math.Pow(math.Pow(mean,float64(day))/factorial(float64(day))*math.Exp(-mean),1)
		}

		for day:= 0 ; day < infectious_ends ; day ++ {
			child_location_array[day] /= denominator
		}

	}
	return child_location_array
}

func get_Corrected_empirical_func() [59]float64{

	inf_v := [59]float64{ 0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000006,0.000000000400,0.000000014828,0.000000327126,0.000004598193,0.000043551427,0.000291074036,0.001426631003,0.005296911006,0.015315428062,0.035311746313,0.066265116634,0.103030125971,0.134813059932,0.150505975534,0.145114140518,0.122150668664,0.090637282629,0.059800573129,0.035357288295,0.018866386876,0.009143443810,0.004048236058,0.001646108958,0.000617722128,0.000214881890,0.000069574929,0.000021046826,0.000005969123,0.000001592286,0.000000400693,0.000000095386,0.000000021536,0.000000004623,0.000000000945,0.000000000185,0.000000000034,0.000000000006,0.000000000001,0.000000000000,0.000000000000,0.000000000000,0.000000000000,0.000000000000 }	

	return inf_v // entry 29 is symptom onset.
}



func make_infectiousness(infectiousness_shape string,days_infect int,p_infect float64) ([]float64,[]float64) {
	infectiousness := make([]float64,59)
	infectiousness_offset := make([]float64,59)




		
	if ( infectiousness_shape == "Flat" ) {
		for day := 0 ; day < 59; day ++{
			infectiousness[day] += p_infect
		}
		for infect_length := 1 ; infect_length < 59 ; infect_length ++ {
			//sumvar := 0
			infectiousness_offset[infect_length-1] += float64(infect_length)//infectiousness[29-int(math.Floor((infect_length/2))+day]
			
		}		


	} else if (infectiousness_shape == "Skewed") {
		inf_temp := get_Corrected_empirical_func()
		for i := 0; i< 59; i++ {
			infectiousness[i] = inf_temp[i]+0 //get_skewed_function(days_infect,"poisson",[1]float64{3})//{3})

		}

		for infect_length := 1 ; infect_length < 59 ; infect_length ++ {
			//sumvar := 0
			for day := 0; day < infect_length ; day ++ {
				infectiousness_offset[infect_length-1] += infectiousness[29-int(math.Floor(float64(infect_length/2)))+day] +0
			}
		}		


		for i := 0 ; i<len(infectiousness) ; i ++ {
			infectiousness[i] *= float64(days_infect)*p_infect
		}
	} else if (infectiousness_shape == "Singular") {
		infectiousness[0] += p_infect*float64(days_infect)
	}

	return infectiousness,infectiousness_offset
}



func make_States(N_nodes int, Seed_arr [][]int ,exp int ) ([]int,[]int,[]int,[]int){
	States := make([]int,N_nodes)
	Parents := make([]int,N_nodes)
	Counter := make([]int,N_nodes)
	Count_goal := make([]int,N_nodes)


	N_seeds := len(Seed_arr[0])

	for node := 0 ; node < N_nodes ; node ++ {
		Counter[node]-=1
		Parents[node]-=9

	}
	for seed := 0 ; seed < N_seeds ; seed ++ {
		new_seed := Seed_arr[exp][seed]//draw_random_integer(N_nodes)
		
		States[new_seed] = 1 +0
		Parents[new_seed] = -1 +0

		Counter[new_seed] = 0 +0
		Count_goal[new_seed] = draw_lognormal_int() +0

	}

	return States,Parents,Counter,Count_goal
}

func draw_lognormal_int() int{

	logn := get_lognormal()
	rand_float := draw_random_float()

	var sum_var float64

	result := len(logn) +0
	for entry := 0 ; entry < len(logn) ; entry ++ {

		sum_var += logn[entry]
		if (sum_var >= rand_float) {
			result = entry+1

			break

		}

	}

	return result
}

func draw_random_integer(maximum int) int {
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1)
	return r1.Intn(maximum)
}
func draw_random_float() float64 {
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1)
	return r1.Float64()
}

func update_states(network_arr [][]int, contact_list map[int]int,States []int,Counter []int,Count_goal []int,Isolation []int,Parents []int,days_presymp int, days_asymp int, days_tot int, num_infected int, num_found int, nodes_distinguishable int,ps float64,pt float64, ignore_parents int, isolate_right_away bool) (map[int]int, []int, []int, int, int) {
	// Nodes infected.. Should only be infectious!
	var infectious_nodes []int


	for node := 0 ; node < len(Counter) ; node ++ {
		if (Isolation[node]>0) {
			Isolation[node]-=1
			if (isolate_right_away == false && Isolation[node] == 0 && (States[node]==2 || (States[node]==1 && Counter[node]==Count_goal[node])  )) {
				if (States[node] == 2) {
					num_infected -=1
				}
				// Node was tested and found positive.				
				States[node] = 3
				Counter[node] = -1

				// We then add its contacts to a contact list.
				contact_list = add_contacts(network_arr,node,contact_list, Parents,pt,ignore_parents)


			}

		}


		if (Counter[node]>=0) {

			Counter[node] += 1
			
			if (Counter[node]==Count_goal[node]){
				States[node] +=1

				if (States[node] <3) {
					Counter[node] = 0
					Count_goal[node] = draw_lognormal_int() +0 // Start new count.

				} else {
					Counter[node] = -1
					num_infected -=1
				}


			}
			if (States[node] == 2 && Isolation[node]!=0) { // If infectious and not in isolation..
				infectious_nodes = append(infectious_nodes,node)
			}


			if (States[node]==2 && Counter[node]==0) {
				num_infected += 1
			} else if (days_asymp > 0 && States[node] == 2 && (Counter[node]>Count_goal[node]/2 && Counter[node]-1<=Count_goal[node]/2)) {
				// Node got symptoms.

				rand_float_isolate := draw_random_float()
				if (rand_float_isolate < ps && days_asymp > 0) {
					// Node got tested positive. Then quarantined.
					States[node] = 3 +0
					contact_list = add_contacts(network_arr,node,contact_list, Parents,pt,ignore_parents)
					num_infected -= 1
					num_found +=1

				}
			}
		

		}
	}


	return contact_list, States, Counter, num_infected,num_found
}

func new_infections(network_arr [][]int, contact_list map[int]int,results_newexposed []string,epidemic_tree []string, States []int,Counter []int, Count_goal []int,Isolation []int, Parents []int,days_presymp int, days_asymp int,infectiousness []float64,infectiousness_offset []float64, ps float64, pt float64,num_infected int,num_found int, ignore_parents int,time int,Isolate_steps int,isolate_right_away bool) (map[int]int,[]string,[]string,[]int,[]int,[]int,int){

	var newexposed int
	for node := 0 ; node < len(States) ; node ++ {
		if (States[node] == 2 && Isolation[node]==0) {

			var p_infect float64 = infectiousness[29-int(math.Floor(float64(Count_goal[node]/2)))+Counter[node]]/infectiousness_offset[Count_goal[node]-1]//[States[node]-days_presymp]

			for nb := 0 ; nb < len(network_arr[node]) ; nb ++ {

				if (States[network_arr[node][nb]]==0) {
					rand_float := draw_random_float()
					if ( rand_float < p_infect){
						//fmt.Println("Infected!!")
						epidemic_tree = append(epidemic_tree,strconv.Itoa(time)+":"+strconv.Itoa(node)+":"+strconv.Itoa(network_arr[node][nb]))
						Parents[network_arr[node][nb]] = node

						rand_float_isolate := draw_random_float()
						if (rand_float_isolate < ps && days_asymp == 0) {
							// Node was found . Case isolation takes place.

							Isolation[network_arr[node][nb]] = 0//Isolate_steps +0
							States[network_arr[node][nb]] = 3
							contact_list = add_contacts(network_arr,network_arr[node][nb],contact_list, Parents,pt,ignore_parents)
							num_found += 1
						} else {

						// Infect..
						States[network_arr[node][nb]] = 1 +0
						Counter[network_arr[node][nb]] = 0
						Count_goal[network_arr[node][nb]] = draw_lognormal_int() +0 // Start new count.						
						newexposed +=1
						}
					}


				}
			}
		}
	}
	results_newexposed = append(results_newexposed,strconv.Itoa(newexposed))
	return contact_list,results_newexposed,epidemic_tree,States,Isolation,Parents,num_found//,num_infected

}

func trace_and_isolate(network_arr [][]int, contact_list map[int]int, States []int, Isolation []int,days_presymp int,n int, num_infected int, num_isolated int, Isolate_steps int, isolate_right_away bool) ([]int,[]int,int,int){


	// Can this be done better?
	var v []int
	for  key := range contact_list {
		v = append(v,contact_list[key])
	}

	// Sort from lowest to highest
	sort.Ints(v)
	if (len(v)>0) {
		var breaking_point int = v[len(v)-int(math.Min(float64(n),float64(len(v))))]
		var on_breaking_point []int
		for  key := range contact_list {
			if (contact_list[key]>breaking_point) {

				if (States[key]==2) {
					num_infected -=1

				}

				// Isolate
				if (isolate_right_away == true) {
					States[key] = 3
				} else {
					Isolation[key] = Isolate_steps
				}
				num_isolated += 1
				//fmt.Println("Yes")
			}
			if (contact_list[key]==breaking_point) {
				on_breaking_point = append(on_breaking_point,key)

			}
		}
		num_isolated_start := num_isolated +0
		for  entry := 0 ; entry < int(math.Min(float64(n-num_isolated_start),float64(len(on_breaking_point)))) ; entry ++ {
			if (isolate_right_away == true) {
				States[on_breaking_point[entry]] = 3
			} else {
				Isolation[on_breaking_point[entry]] = Isolate_steps
			}			
			num_isolated += 1
		}

	}
	return States, Isolation, num_infected,num_isolated
}

func add_contacts(network_arr [][]int, node int, contact_list map[int]int,Parents []int,pt float64,ignore_parents int) (map[int]int){
	for nb := 0 ; nb < len(network_arr[node]) ; nb ++ {
		random_float := draw_random_float()
		if (random_float < pt && ( ( ignore_parents == 0 && Parents[node] == network_arr[node][nb]) || ( ignore_parents == 1 && Parents[node] != network_arr[node][nb]) || ignore_parents == 22)) {

			contact_list[network_arr[node][nb]] += 1

		}
	}

	return contact_list
}

func is_int_in_array(arr []int, number int) int {
	is_there := 0
	for i := 0 ; i< len(arr) ; i++ {
		if (arr[i] == number) {
			is_there = 1
			break
		}
	}
	return is_there
}
func factorial(k float64) float64{
	Res := 1
	if ( k>1) {
		for num := 2 ; num < int(k+1) ; num ++ {
			Res *= num
		}
	}
	return float64(Res)
}
func append_to_file (filename string, text []string) {
    // If the file doesn't exist, create it, or append to the file
    f, err := os.OpenFile(filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Fatal(err)
	}
	sep := " "
	for _, line := range text {	
		if _, err := f.WriteString(line+sep); err != nil {
			log.Fatal(err)
		}

	}
	if _, err := f.WriteString("\n"); err != nil {
		log.Fatal(err)
	}	
	if err := f.Close(); err != nil {
		log.Fatal(err)
	}	
}

func main() {

	// Make network 
	network_filename := "../inputs/BA_network.csv"
	network_arr := make_network_from_csv(network_filename)
	fmt.Println(network_arr[0])

	// Make network definitions
	var N_nodes int = len(network_arr)
	var mean_degree float64 = mean_degree(network_arr)
	fmt.Println(mean_degree,N_nodes)

	// Make disease constant definitions
	const days_presymp int = 3
	const days_asymp int = 4
	const days_infect int = 1//8
	const days_tot int = days_presymp + days_infect
	var p_infect float64 = 1.5/((mean_degree-1)*float64(days_infect)) // Expected 1.5 cases per case.

	isolate_right_away := false
	var Isolate_steps int = 5

	var infectiousness_shape string = [3]string{"Skewed","Flat","Singular"}[1]
	infectiousness,infectiousness_offset  := make_infectiousness(infectiousness_shape,days_infect,p_infect)
	//fmt.Println(infectiousness)

	const N_seeds int = 250 // 1/1000 is a seed...
	var nodes_distinguishable int = 1

	


	// Make disease mitigation definitions....

	var ps float64 = 0.00 // Prob detect upon infection
	var pt float64 = 0.00 // prob trace

	var n_trace int = 30

	const ignore_parents int = 0


	// Make run definitions
	const Nexp int = 100
	Seed_arr := make([][]int,Nexp)
	
	// Ensure same seeds when changing parameters.
	rand.Seed(2) // 
	for exp := 0 ; exp < Nexp ; exp ++ {
		for seednum:=0;seednum < N_seeds;seednum ++ {
			Seed_arr[exp] = append(Seed_arr[exp],rand.Intn(N_nodes))
		}
	}
	rand.Seed(time.Now().UTC().UnixNano()) // 

	for exp := 0 ; exp < Nexp ; exp ++{
		// Make disease arrays
		States,Parents,Counter,Count_goal := make_States(N_nodes,Seed_arr,exp)
		
		// Arrays to keep track of disease
		Isolation := make([]int,N_nodes)
		


		// Make simulation definitions
		var num_infected int = 0 // Seeds start Exposed
		time := -1

		// make results definitions
		var results_infected []string
		var results_newexposed []string
		var results_isolated []string
		var results_found []string
		var epidemic_tree []string
		
		var filename_results = "outputs/I_curves/I_curves"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+"_IsolateRightAway"+strconv.FormatBool(isolate_right_away)+".txt"
		var filename_resultsnewexposed = "outputs/Exposednew/Exposednew"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+"_IsolateRightAway"+strconv.FormatBool(isolate_right_away)+".txt"
		var filename_resultsisolated = "outputs/Isolated/Isolated"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+"_IsolateRightAway"+strconv.FormatBool(isolate_right_away)+".txt"
		var filename_resultsfound = "outputs/Found/Found"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+"_IsolateRightAway"+strconv.FormatBool(isolate_right_away)+".txt"
		//var filename_epidemictree = "outputs/EpidemicTrees/EpidemicTrees"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+"_IsolateRightAway"+strconv.FormatBool(isolate_right_away)+".txt"
		
		var num_isolated int = 0 // Number of nodes isolated due to contact tracing.
		var num_found int = 0 // Number of nodes isolated due to case isolation.
		
		
		results_infected = append(results_infected,strconv.Itoa(num_infected))
		results_isolated = append(results_isolated,strconv.Itoa(num_isolated))
		results_found = append(results_found,strconv.Itoa(num_found))
		for ((num_infected > 0) || time < 20) {

			var contact_list = make(map[int]int) // map of int

			time+=1
			fmt.Println("Exp",exp,"Doing time", time, "Number infected:",num_infected,"Number isolated:",num_isolated,"Number found",num_found)


			num_isolated = 0
			num_found = 0
			//var num_isolated int = 0
			//var num_found int = 0


			// First thing: Update all States
			contact_list, States,Counter,num_infected,num_found = update_states(network_arr,contact_list,States,Counter,Count_goal,Isolation,Parents,days_presymp,days_asymp,days_tot,num_infected,num_found,nodes_distinguishable,ps,pt,ignore_parents,isolate_right_away)

			// Then: Infect neighbours
			contact_list,results_newexposed,epidemic_tree, States, Isolation,Parents,num_found = new_infections(network_arr,contact_list,results_newexposed, epidemic_tree, States, Counter,Count_goal,Isolation,Parents,days_presymp,days_asymp,infectiousness,infectiousness_offset,ps,pt,num_infected,num_found,ignore_parents,time,Isolate_steps,isolate_right_away)

			// Lastly : Trace and isolate.
			States, Isolation,num_infected,num_isolated = trace_and_isolate(network_arr,contact_list,States,Isolation,days_presymp,n_trace,num_infected,num_isolated,Isolate_steps, isolate_right_away)
			
			
			results_infected = append(results_infected,strconv.Itoa(num_infected))
			results_isolated = append(results_isolated,strconv.Itoa(num_isolated))
			results_found = append(results_found,strconv.Itoa(num_found))
			if (time > 200) {
				break

			}
		}
		append_to_file(filename_results,results_infected)
		append_to_file(filename_resultsnewexposed,results_newexposed)
		append_to_file(filename_resultsisolated,results_isolated)
		append_to_file(filename_resultsfound,results_found)
		//append_to_file(filename_epidemictree,epidemic_tree)

	}



}