import ballerina/http;

service /queues on new http:Listener(8080) {

    isolated resource function post .(@http:Payload QueueEntries queueEntry) returns string|error? {
        return addQueueEntry(queueEntry);
    }

    isolated resource function get [int id]() returns QueueEntries|error? {
        return getQueueEntry(id);
    }

    isolated resource function get .() returns QueueEntries[]|error? {
        return getAllQueueEntries();
    }

    isolated resource function put .(@http:Payload QueueEntries queueEntry) returns int|error? {
        return updateQueueEntry(queueEntry);
    }

    isolated resource function delete [int id]() returns int|error? {
        return removeQueueEntry(id);
    }

    
}

service /services on new http:Listener(8081) {

    isolated resource function post .(@http:Payload Service queue_service) returns int|error? {
        return addService(queue_service);
    }
    
    isolated resource function get [int id]() returns Service|error? {
        return getService(id);
    }

    isolated resource function get .() returns Service[]|error? {
        return getAllServices();
    }

    isolated resource function put .(@http:Payload Service queue_service) returns int|error? {
        return updateService(queue_service);
    }

    isolated resource function delete [int id]() returns int|error? {
        return removeService(id);
    }

}
