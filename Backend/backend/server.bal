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
