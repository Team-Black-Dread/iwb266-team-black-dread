import ballerina/http;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}

service /queues on new http:Listener(8080) {

    isolated resource function post entries(int customer_id, int service_id) returns string|error? {
        return addQueueEntry(service_id, customer_id);
    }

    isolated resource function get entries(int id) returns QueueEntries|error? {
        return getQueueEntry(id);
    }

    isolated resource function get entries/all() returns QueueEntries[]|error? {
        return getAllQueueEntries();
    }

    isolated resource function get entries/similar(int service_id) returns QueueEntries[]|error? {
        return getServiceQueueEntries(service_id);
    }

    isolated resource function put entries(@http:Payload QueueEntries queueEntry) returns int|error? {
        return updateQueueEntry(queueEntry);
    }

    isolated resource function delete entries(int id) returns int|error? {
        return removeQueueEntry(id);
    }

    isolated resource function post services(@http:Payload Service queue_service) returns int|error? {
        return addService(queue_service);
    }

    isolated resource function get services(int id) returns Service|error? {
        return getService(id);
    }

    isolated resource function get services/all() returns Service[]|error? {
        return getAllServices();
    }

    isolated resource function put services(@http:Payload Service queue_service) returns int|error? {
        return updateService(queue_service);
    }

    isolated resource function delete services(int id) returns int|error? {
        return removeService(id);
    }

}
