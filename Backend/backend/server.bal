import ballerina/http;

service /queues on new http:Listener(8080) {

    isolated resource function post .(@http:Payload Queue queue) returns int|error? {
        return addQueue(queue);
    }

    isolated resource function get [int id]() returns Queue|error? {
        return getQueue(id);
    }

    isolated resource function get .() returns Queue[]|error? {
        return getAllQueues();
    }

    isolated resource function put .(@http:Payload Queue queue) returns int|error? {
        return updateQueue(queue);
    }

    isolated resource function delete [int id]() returns int|error? {
        return removeQueue(id);
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
