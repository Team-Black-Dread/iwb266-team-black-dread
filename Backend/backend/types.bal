public type Queue record {| 
    int queue_id?;
    string service_name;
    string customer_name;
    string queue_time; // Store time as a string temporarily.
    int? position;
    string status;
|};
public type Service record {| 
    int service_id?;
    string service_name;
    string time_slot;
    int capacity;
    int occupied_positions; // New field for tracking occupied positions
|};

public type Admin record {| 
    int admin_id?;
    string username;
    string password;
|};

public type User record {| 
    int user_id?;
    string username;
    string password;
|};