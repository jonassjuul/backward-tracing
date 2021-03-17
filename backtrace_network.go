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

func make_infectiousness(infectiousness_shape string,days_infect int,p_infect float64) []float64 {
	infectiousness := make([]float64,days_infect)
	for day := 0 ; day < days_infect ; day ++ {

		
		if ( infectiousness_shape == "Flat" ) {
			infectiousness[day] += p_infect

		} else if (infectiousness_shape == "Skewed") {
			infectiousness = get_skewed_function(days_infect,"poisson",[1]float64{3})//{3})
			for i := 0 ; i<len(infectiousness) ; i ++ {
				infectiousness[i] *= float64(days_infect)*p_infect
			}
		} else if (infectiousness_shape == "Singular") {
			infectiousness[0] += p_infect*float64(days_infect)
		}
	}
	fmt.Println(infectiousness)

	return infectiousness
}

func make_States(N_nodes int, Seed_arr [][]int ,exp int ) ([]int,[]int){
	States := make([]int,N_nodes)
	Parents := make([]int,N_nodes)

	N_seeds := len(Seed_arr[0])

	for node := 0 ; node < N_nodes ; node ++ {
		States[node]-=1
		Parents[node]-=9

	}
	for seed := 0 ; seed < N_seeds ; seed ++ {
		new_seed := Seed_arr[exp][seed]//draw_random_integer(N_nodes)
		
		States[new_seed] = 0 +0
		Parents[new_seed] = -1 +0

	}

	return States,Parents
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

func update_states(network_arr [][]int, contact_list map[int]int,States []int,Parents []int,days_presymp int, days_asymp int, days_tot int, num_infected int, num_found int, nodes_distinguishable int,ps float64,pt float64, ignore_parents int) ([]int, int, int) {
	// Nodes infected.. Should only be infectious!
	
	var remove_nodes []int
	var infectious_nodes []int
	var new_State []int

	var old_nodes []int

	for node := 0 ; node < len(States) ; node ++ {
		if (States[node]>=0) {

			States[node] += 1
			
			if (States[node]>=days_presymp){
				infectious_nodes = append(infectious_nodes,node)
				if (States[node]==days_presymp) {
					num_infected += 1
				} else if (days_asymp > 0 && States[node] == days_presymp + days_asymp) {

					rand_float_isolate := draw_random_float()
					if (rand_float_isolate < ps && days_asymp > 0) {
						States[node] = -9 +0
						contact_list = add_contacts(network_arr,node,contact_list, Parents,pt,ignore_parents)
						num_infected -= 1
						num_found +=1

					}
				}
			}

			if (States[node]==days_tot) {
				if ( nodes_distinguishable == 1 ){
					States[node] = -9
					num_infected -=1
				} else {

					old_nodes = append(old_nodes,node)

				}
			}

		}
	}
	if (nodes_distinguishable == 0) {

		for node := 0 ; node < len(old_nodes) ; node ++ {
			found := 0
			for (found == 0) {
				remove_this_node := draw_random_integer(len(infectious_nodes))
				if (is_int_in_array(remove_nodes,remove_this_node) == 0) {
					remove_nodes = append(remove_nodes,remove_this_node+0)
					if (States[infectious_nodes[remove_this_node]] < days_tot){
						new_State = append(new_State,States[infectious_nodes[remove_this_node]])

					}

					found = 1
					//break
				}
				
			}
		}


		for node := 0 ; node < len(remove_nodes) ; node ++{
			remove_this := infectious_nodes[remove_nodes[node]]
			States[remove_this] = -9
			num_infected -= 1
		}

		replace_state := 0
		for node:= 0 ; node < len(infectious_nodes) ; node ++ {
			if (States[infectious_nodes[node]]==days_tot) {
				States[infectious_nodes[node]] = new_State[replace_state] +0
				replace_state += 1
			}

		}

	}


	return States, num_infected,num_found
}

func new_infections(network_arr [][]int, contact_list map[int]int,results_newexposed []string, States []int, Parents []int,days_presymp int, days_asymp int,infectiousness []float64, ps float64, pt float64,num_infected int,num_found int, ignore_parents int) (map[int]int,[]string,[]int,[]int,int){

	var newexposed int
	for node := 0 ; node < len(States) ; node ++ {
		if (States[node] >= days_presymp) {

			var p_infect float64 = infectiousness[States[node]-days_presymp]

			for nb := 0 ; nb < len(network_arr[node]) ; nb ++ {

				if (States[network_arr[node][nb]]==-1) {
					rand_float := draw_random_float()
					if ( rand_float < p_infect){

						Parents[network_arr[node][nb]] = node

						rand_float_isolate := draw_random_float()
						if (rand_float_isolate < ps && days_asymp == 0) {
							States[network_arr[node][nb]] = -9 +0
							contact_list = add_contacts(network_arr,network_arr[node][nb],contact_list, Parents,pt,ignore_parents)
							num_found += 1
						} else {

						// Infect..
						States[network_arr[node][nb]] = 0 +0
						newexposed +=1
						//num_infected += 1
						// also keep track of parents....
						}
					}


				}
			}
		}
	}
	results_newexposed = append(results_newexposed,strconv.Itoa(newexposed))
	return contact_list,results_newexposed,States,Parents,num_found//,num_infected

}

func trace_and_isolate(network_arr [][]int, contact_list map[int]int, States []int,days_presymp int,n int, num_infected int, num_isolated int) ([]int,int,int){


	// Can this be done better?
	//v := make([]int, len(m), len(m))
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
			//fmt.Println(contact_list[key],breaking_point)
			if (contact_list[key]>breaking_point) {

				if (States[key]>=days_presymp) {
					num_infected -=1

				}

				// Isolate
				States[key] = -9
				num_isolated += 1
				//fmt.Println("Yes")
			}
			if (contact_list[key]==breaking_point) {
				on_breaking_point = append(on_breaking_point,key)

			}
		}
		num_isolated_start := num_isolated +0
		for  entry := 0 ; entry < int(math.Min(float64(n-num_isolated_start),float64(len(on_breaking_point)))) ; entry ++ {
			States[on_breaking_point[entry]] = -9
			num_isolated += 1
		}

	}
	//fmt.Println("num isol",num_isolated)
	return States, num_infected,num_isolated
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
	network_filename := "inputs/BA_network.csv"
	network_arr := make_network_from_csv(network_filename)
	fmt.Println(network_arr[0])

	// Make network definitions
	var N_nodes int = len(network_arr)
	var mean_degree float64 = mean_degree(network_arr)
	fmt.Println(mean_degree,N_nodes)

	// Make disease constant definitions
	const days_presymp int = 3
	const days_asymp int = 0
	const days_infect int = 8
	const days_tot int = days_presymp + days_infect
	var p_infect float64 = 1.5/((mean_degree-1)*float64(days_infect)) // Expected 1.5 cases per case.

	var infectiousness_shape string = [3]string{"Skewed","Flat","Singular"}[1]
	var infectiousness []float64 = make_infectiousness(infectiousness_shape,days_infect,p_infect)
	fmt.Println(infectiousness)

	const N_seeds int = 250 // 1/1000 is a seed...
	var nodes_distinguishable int = 0

	// Make disease mitigation definitions....

	var ps float64 = 0.05 // Prob detect upon infection
	var pt float64 = 0.50 // prob trace

	var n_trace int = 30

	const ignore_parents int = 22


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
		States,Parents := make_States(N_nodes,Seed_arr,exp)
		

		// Make simulation definitions
		var num_infected int = 0//N_seeds +0
		time := -1

		// make results definitions
		var results_infected []string
		var results_newexposed []string
		var results_isolated []string
		var results_found []string

		var filename_results = "outputs/I_curves/I_curves"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+".txt"
		var filename_resultsnewexposed = "outputs/Exposednew/Exposednew"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+".txt"
		var filename_resultsisolated = "outputs/Isolated/Isolated"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+".txt"
		var filename_resultsfound = "outputs/Found/Found"+"_NodesDistinguishable"+strconv.Itoa(nodes_distinguishable)+"_Dayspresymp"+strconv.Itoa(days_presymp)+"_Daysasymp"+strconv.Itoa(days_asymp)+"_ps"+fmt.Sprintf("%4.3f", ps)+"_pt"+fmt.Sprintf("%4.3f", pt)+"_Shape"+infectiousness_shape+"_Ignoreparents"+strconv.Itoa(ignore_parents)+"_Ntrace"+strconv.Itoa(n_trace)+".txt"
		
		var num_isolated int = 0
		var num_found int = 0
		
		
		results_infected = append(results_infected,strconv.Itoa(num_infected))
		results_isolated = append(results_isolated,strconv.Itoa(num_isolated))
		results_found = append(results_found,strconv.Itoa(num_found))
		for (num_infected > 0 || time < days_presymp) {

			var contact_list = make(map[int]int) // map of int

			time+=1
			fmt.Println("Exp",exp,"Doing time", time, "Number infected:",num_infected,"Number isolated:",num_isolated,"Number found",num_found)


			num_isolated = 0
			num_found = 0
			//var num_isolated int = 0
			//var num_found int = 0


			// First thing: Update all States
			States,num_infected,num_found = update_states(network_arr,contact_list,States,Parents,days_presymp,days_asymp,days_tot,num_infected,num_found,nodes_distinguishable,ps,pt,ignore_parents)

			// Then: Infect neighbours
			contact_list,results_newexposed, States,Parents,num_found = new_infections(network_arr,contact_list,results_newexposed, States, Parents,days_presymp,days_asymp,infectiousness,ps,pt,num_infected,num_found,ignore_parents)

			// Lastly : Trace and isolate.
			States,num_infected,num_isolated = trace_and_isolate(network_arr,contact_list,States,days_presymp,n_trace,num_infected,num_isolated)
			
			
			results_infected = append(results_infected,strconv.Itoa(num_infected))
			results_isolated = append(results_isolated,strconv.Itoa(num_isolated))
			results_found = append(results_found,strconv.Itoa(num_found))
			if (time > 140) {
				break

			}
		}
		append_to_file(filename_results,results_infected)
		append_to_file(filename_resultsnewexposed,results_newexposed)
		append_to_file(filename_resultsisolated,results_isolated)
		append_to_file(filename_resultsfound,results_found)

	}



}