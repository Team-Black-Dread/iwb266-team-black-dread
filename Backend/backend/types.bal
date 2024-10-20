public type QueueEntries record {| 
    int queue_entry_id?;
    int  service_id;
    int customer_id;
    string estimated_time; // Store time as a string temporarily.
    int position;
|};
public type Service record {| 
    int service_id?;
    string service_name;
    int time_period;
    string start_time;
    string working_days ;
    string working_slots;
    int capacity;
    int occupied_positions; // New field for tracking occupied positions
|};

public type Admin record {| 
    int admin_id?;
    string admin_username;
    string admin_password;
|};

public type Customer record {| 
    int customer_id?;
    string customer_name;
    string customer_NIC;
    string customer_address;
    string customer_email;
    string customer_phone;
    string password;
|};