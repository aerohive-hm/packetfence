//ahusavg.go
package main

import ("fmt"
"io/ioutil"
"log"
"strconv"
"strings"
"sort"
_ "github.com/go-sql-driver/mysql"
"regexp"
	"errors"
	"os"
)

const businessHour = 8 //8 business hours per day
const pastSixDays = 6 //num of days in a week
/*
 * read in the file of containing only integers and return them in an array
 */
func readFile(fname string) (nums []int, err error) {
	b, err := ioutil.ReadFile(fname)

	if err != nil {
		return nil, err
	}

	lines := strings.Split(string(b), "\n")
	// Assign cap to avoid resize on every append.
	nums = make([]int, 0, len(lines))

	for _, l := range lines {

		if len(l) == 0 {
			continue
		}

		n, err := strconv.Atoi(l)

		if err != nil {
			return nil, err
		}
		nums = append(nums, n)
	}

	return nums, nil
}
func readPW (fname string) (pw string, err error) {
	b, err := ioutil.ReadFile(fname)

	if err != nil {
		return "", err
	}

	delimiter := regexp.MustCompile(`pass=`)

	/* extract out the comments*/
	lines := strings.Split(string(b), "\n")
	/* split only the last line without the space*/
	result := delimiter.Split(lines[len(lines)-2], -1)

	return result[1], nil
}
/*
 * This function takes a int array and interval to finds the max segment with interval length
 */
func findMaxInterval(nums []int, interval int) ([]int, error) {

	if len(nums) < interval {
		return nums, errors.New("data not more than 8 hours")
	}
	var sum, maxIndex = 0, 0

	maxInterval := make([]int, 0, interval)
	/*start from 0 index to first interval */
	for i := 0; i < interval; i++ {
		sum += nums[i];
	}
	maxSum := sum
	/* one pass iterate through each element of the array, find the max sum of the interval and start index*/
	for i := 0; i < len(nums) - interval; i++ {

		sum += nums[i + interval] - nums[i];

		if (sum > maxSum) {
			maxSum = sum;
			maxIndex = i + 1;
		}
	}

	for i := maxIndex; i < maxIndex + interval; i++ {

		maxInterval = append(maxInterval, nums[i])

	}

	return maxInterval, nil
}

/*
 * calculate the avg of the array
 */
func avgOfList(nums []int) (avg int) {
	sum := 0
	if len(nums) == 0 {
		return sum
	}
	for _, value := range nums {
		sum += value;
	}
	return sum/len(nums)
}
/*
 * calculate the moving avg of the last 7 daily avg
 */
func findMovingAvg (dailyAvgArray []int, todayAvg int) (movingAvg int) {

	sum := 0
	dailyAvgArray = append(dailyAvgArray, todayAvg)
	if len(dailyAvgArray) == 0 {
		return todayAvg
	} else if len(dailyAvgArray) < pastSixDays {
		return avgOfList(dailyAvgArray)
	} else {
		/* store the last 6 days of data*/

		sort.Ints(dailyAvgArray)
		dropLowHigh := dailyAvgArray[1:pastSixDays]
		for _, value := range dropLowHigh{
			sum += value
		}
		return sum / len(dropLowHigh)
	}

}

func main() {

	var dailySampleFile string
	var previousSixDaySampleFile string

	if len(os.Args) > 2 {
		/*using command line inputs to find the templ files*/
		dailySampleFile = os.Args[1] //first arg is where today's usage sample file is
		previousSixDaySampleFile = os.Args[2] //second arg stores the past 6 days of data

	} else {
		fmt.Fprintf(os.Stderr, "error: not enough input data from a3ma\n")
		os.Exit(1)
	}

	/*read in 24hr data*/
	nums, err := readFile(dailySampleFile)

	if err != nil {
		log.Fatal(err)
	}
	/*find max interval from previous 24 hours*/
	maxInterval, err := findMaxInterval(nums, businessHour)

	if err != nil {
		log.Fatal(err)
	}

	/*today's avg usage*/
	todayAvg := avgOfList(maxInterval)
	fmt.Println(todayAvg)

	dailyAvgArray, err := readFile(previousSixDaySampleFile)

	if err != nil {
		log.Fatal(err)
	}

	movingAvg := findMovingAvg(dailyAvgArray, todayAvg)

	fmt.Println(movingAvg)
}
