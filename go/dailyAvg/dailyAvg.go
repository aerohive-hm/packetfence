//dailyAvg.go
package main

import ("fmt"
"io/ioutil"
"log"
"strconv"
"strings"
"os"
"sort")

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

/*
 * This function takes a int array and interval to finds the max segment with interval length
 */
func findMaxInterval(nums []int, interval int) ([]int) {
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

	return maxInterval
}

/*
 * calculate the avg of the array
 */
func avgOfList(nums []int) (avg int) {
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
	nums, err := readFile("data.txt")

	if err != nil {
		log.Fatal(err)
	}

	maxInterval := findMaxInterval(nums, businessHour)

	avg := avgOfList(maxInterval)

	/*TODO change txt file to read from db*/
	f, err := os.OpenFile("dayAvg.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0600)
	if err != nil {
		panic(err)
	}

	defer f.Close()
	dayString := strconv.Itoa(avg) + "\n"
	if _, err = f.WriteString(dayString); err != nil {
		panic(err)
	}

	dailyAvgArray, err := readFile("dayAvg.txt")

	if err != nil {
		log.Fatal(err)
	}

	movingAvg := findMovingAvg(dailyAvgArray)

	/*TODO output to the database*/
	fmt.Println("moving avg:", movingAvg)
}
