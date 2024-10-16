import ballerina/time;
import ballerina/regex;

// Function to calculate the estimated time for a service.
isolated function calculateEstimatedTime(int positions, string start_time, int timePeriod, string[] workingDays, string workingSlot) returns string|error {

    // Calculate the total working hours per day based on the working slot.
    int[] workingSlotDetails = check WorkingSlot(workingSlot);

    // Get the current local time.
    string current_time = check getLocalTime();
        
    // Convert current and start time to UTC.
    time:Utc utcTime = check time:utcFromString(current_time);
    time:Utc startTime = check time:utcFromString(start_time);
    time:Seconds seconds = time:utcDiffSeconds(startTime, utcTime);

    // Check if the service has not started yet.
    if <int>seconds > 0 {
        // Calculate total remaining time if service hasn't started yet.
        int totalRemainingMinutes = check calculateRemainingTime(positions, start_time, timePeriod, workingDays, workingSlotDetails);
        int totalMinutes = <int>seconds/60 + totalRemainingMinutes;
        
        // Add total remaining minutes to the current UTC time.
        time:Utc estimatedEndTimeUtc = time:utcAddSeconds(utcTime, totalMinutes*60 + 5*3600 + 30*60); // Subtract 5 hours 30 minutes for UTC+5:30.
        
        // Return the estimated end time in UTC format.
        return time:utcToEmailString(estimatedEndTimeUtc);

    } else {
        // Calculate remaining time for already started service.
        int totalMinutes = check calculateRemainingTime(positions, current_time, timePeriod, workingDays, workingSlotDetails);
        
        // Add total remaining seconds to the current UTC time.
        time:Utc estimatedEndTimeUtc = time:utcAddSeconds(utcTime, totalMinutes*60 + 5*3600 + 30*60); // Subtract 5 hours 30 minutes for UTC+5:30.
        
        // Return the estimated end time in UTC format.
        return time:utcToEmailString(estimatedEndTimeUtc);

    }
}

// Function to parse and calculate the total working slot duration.
isolated function WorkingSlot(string slot) returns int[]|error  {
    // Split the working slot string (e.g., "08:30-17:30") into start and end times.
    string[] time = regex:split(slot, "-");
    string[] start_time = regex:split(time[0], ":");
    string[] end_time = regex:split(time[1], ":");
    
    // Convert start and end times to minutes.
    int startHour = check int:fromString(start_time[0]);
    int endHour = check int:fromString(end_time[0]);
    int startMinute = check int:fromString(start_time[1]);
    int endMinute = check int:fromString(end_time[1]);

    // Calculate total working minutes and return details.
    int endingMinute = (endHour * 60  + endMinute);
    int startingMinute = (startHour * 60 + startMinute);
    int totalMinutes = endingMinute - startingMinute;

    int[] result  = [totalMinutes, startingMinute, endingMinute];
    return result;
}

// Function to get the current local time in the specified timezone (Asia/Colombo).
isolated function getLocalTime() returns string|time:Error {
    // Convert UTC time to civil time in the Asia/Colombo timezone.
    time:Civil civil = check time:civilFromString(time:utcToString(time:utcNow()) + "[Asia/Colombo]");

    // Convert the civil time to string format and return.
    string localTime = check time:civilToString(civil);
    return localTime;
} 

// Function to calculate the remaining service time based on the current position, time, and working slots.
isolated function calculateRemainingTime(int position, string start_time, int timePeriod, string[] workingDays, int[] workingSlotDetails) returns int|error {
    int startingMinute = workingSlotDetails[1];
    int endingMinute = workingSlotDetails[2];
    int totalRemainingMinutes = (position - 1) * timePeriod;

    // Extract the current minute and day of the week from the start time.
    int|error currentMinute = extractTime(start_time);
    string|error currentDay = extractDayOfWeek(start_time);

    int time = 0;
    int totalMinutes = 0;

    if (currentMinute is int && currentDay is string) {
        int currentMinuteRounded = currentMinute;
        string today = currentDay;

        // Loop to calculate the remaining time across days and working hours.
        while (time < totalRemainingMinutes) {
            if (workingDays.indexOf(today) != ()) {
                if (currentMinuteRounded >= startingMinute && currentMinuteRounded < endingMinute) {
                    time += timePeriod;
                    currentMinuteRounded += timePeriod;
                    totalMinutes += timePeriod;
                } else if (currentMinuteRounded >= endingMinute) {
                    totalMinutes += (24 * 60 - currentMinuteRounded); // Add the remaining day time.
                    today = getNextDay(today); // Move to the next day.
                    currentMinuteRounded = 0; // Reset to midnight.
                } else {
                    totalMinutes += (startingMinute - currentMinuteRounded); // Time before working hours.
                    currentMinuteRounded = startingMinute;
                }
            } else {
                totalMinutes += (24 * 60 - currentMinuteRounded); // Skip non-working days.
                today = getNextDay(today);
                currentMinuteRounded = 0;
            }
        } 
    } else {
        return error("Error occurred");
    }

    return totalMinutes;
}

// Function to extract the total minutes from a time string
isolated function extractTime(string input) returns int|error {
    // Parse the input string to a Civil record and extract time components.
    time:Civil|time:Error civil = time:civilFromString(input);
    if civil is time:Error {
        return civil;
    }
    int hour = civil.hour;
    int minute = civil.minute;

    // Convert the extracted time to total minutes.
    int totalMinutes = hour * 60 + minute;
    return totalMinutes;
}

// Function to extract the day of the week (e.g., "Mon", "Tue") from a time string.
isolated function extractDayOfWeek(string input) returns string|error {
    // Parse the input string to a Civil record.
    time:Civil|time:Error civil = time:civilFromString(input);
    if civil is time:Error {
        return civil;
    }

    // Extract the day of the week from the date.
    time:Date date = {year: civil.year, month: civil.month, day: civil.day};
    time:DayOfWeek dayOfWeek = time:dayOfWeek(date);

    // Convert DayOfWeek enum to short-form string.
    match dayOfWeek {
        time:MONDAY => { return "Mon"; }
        time:TUESDAY => { return "Tue"; }
        time:WEDNESDAY => { return "Wed"; }
        time:THURSDAY => { return "Thu"; }
        time:FRIDAY => { return "Fri"; }
        time:SATURDAY => { return "Sat"; }
        time:SUNDAY => { return "Sun"; }
        _ => { return "Unknown"; }
    }
}


// Function to get the next day based on the current day (e.g., "Mon" -> "Tue").
isolated  function getNextDay(string currentDay) returns string {
    // Map of days to their next day.
    map<string> daysMap = {
        "Mon": "Tue",
        "Tue": "Wed",
        "Wed": "Thu",
        "Thu": "Fri",
        "Fri": "Sat",
        "Sat": "Sun",
        "Sun": "Mon"
    };

    string? nextDay = daysMap[currentDay];
    return nextDay ?: "Invalid day";
}



