public type Queue record {| 
    int queue_id?;
    string service_name;
    string customer_name;
    string queue_time; // Store time as a string temporarily.
    int? position;
    string status;
|};