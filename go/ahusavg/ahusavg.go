//dailyAvg.go
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
)

const businessHour = 8 //8 business hours per day
const daysInWeek = 7 //num of days in a week
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
	if len(nums) == 0 {
		return 0
	}
	sum := 0
	for _, value := range nums {
		sum += value;
	}
	return sum/len(nums)
}
/*
 * calculate the moving avg of the last 7 daily avg
 */
func findMovingAvg (dailyAvgArray []int) (movingAvg int) {

	sum := 0
	if len(dailyAvgArray) < daysInWeek {
		return avgOfList(dailyAvgArray)
	} else if len(dailyAvgArray) == 0 {
		return sum
	} else {
		/* store the last 7 days of data*/
		sevenDay := dailyAvgArray[len(dailyAvgArray) - daysInWeek : len(dailyAvgArray)]

		sort.Ints(sevenDay)
		dropLowHigh := sevenDay[1:daysInWeek - 1]
		for _, value := range dropLowHigh{
			sum += value
		}
		return sum / len(dropLowHigh)
	}

}

func main() {


	/*read in 24hr data*/
	nums, err := readFile("/tmp/temp_daily_us.txt")

	if err != nil {
		log.Fatal(err)
	}

	maxInterval, err := findMaxInterval(nums, businessHour)

	if err != nil {
		log.Fatal(err)
	}

	todayAvg := avgOfList(maxInterval)
	fmt.Println(todayAvg)

	dailyAvgArray, err := readFile("/tmp/moving_avg.txt")

	if err != nil {
		log.Fatal(err)
	}

	movingAvg := findMovingAvg(dailyAvgArray)

	fmt.Println(movingAvg)
}
