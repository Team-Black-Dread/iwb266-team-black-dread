import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // Bundles the driver to the project.
import ballerina/sql;



configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database="queue_management"
);


isolated function addService(Service queue_service) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Services (service_name, time_slot, capacity, occupied_positions)
        VALUES (${queue_service.service_name}, ${queue_service.time_slot}, 
                ${queue_service.capacity}, 0)
    `);
    
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function getService(int id) returns Service|error {
    Service queue_service = check dbClient->queryRow(
        `SELECT * FROM QueueDetails WHERE service_id = ${id}`
    );
    return queue_service;
}

isolated function getAllServices() returns Service[]|error {
    Service[] queue_services = [];
    stream<Service, error?> resultStream = dbClient->query(
        `SELECT * FROM QueueDetails`
    );
    check from Service queue_service in resultStream
        do {
            queue_services.push(queue_service);
        };
    check resultStream.close();
    return queue_services;
}

isolated function updateService(Service queue_service) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE QueueDetails SET
            service_name = ${queue_service.service_name},
            time_slot = ${queue_service.time_slot},
            capacity = ${queue_service.capacity}
        WHERE service_id = ${queue_service.service_id}
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function removeService(int id) returns int|error {
    // Retrieve the service_name before deleting the service
    record {| string service_name; |} serviceRecord = check dbClient->queryRow(
        `SELECT service_name FROM Services WHERE service_id = ${id}`
    );
    
    string serviceName = serviceRecord.service_name;

    // Remove the service
    sql:ExecutionResult serviceDeleteResult = check dbClient->execute(`
        DELETE FROM Services WHERE service_id = ${id}
    `);

    int? affectedRowCount = serviceDeleteResult.affectedRowCount;
    if affectedRowCount is int && affectedRowCount > 0 {
        // After successfully removing the service, remove all related queues
        sql:ExecutionResult queueDeleteResult = check dbClient->execute(`
            DELETE FROM Queues WHERE service_name = ${serviceName}
        `);

        int? queueAffectedRows = queueDeleteResult.affectedRowCount;
        if queueAffectedRows is int {
            return affectedRowCount; // Return the number of affected rows from the service delete operation
        } else {
            return error("Unable to delete related queues for the service");
        }
    } else {
        return error("Unable to remove the service");
    }
}


isolated function addQueue(Queue queue) returns int|error {
    time:Utc parsedQueueTime = check time:utcFromString(queue.queue_time); // Convert string to time:Utc.

    // Fetch the current number of occupied positions for the relevant service
    int occupiedPositions = check dbClient->queryRow(
        `SELECT occupied_positions FROM Services WHERE service_name = ${queue.service_name}`
    );

    // The queue position is one more than the current occupied positions
    int newPosition = occupiedPositions + 1;

    // Insert the new queue into the Queues table with the updated position
    sql:ExecutionResult insertResult = check dbClient->execute(`
        INSERT INTO Queues (service_name, customer_name, queue_time, position, status)
        VALUES (${queue.service_name}, ${queue.customer_name}, ${parsedQueueTime}, 
                ${newPosition}, ${queue.status})
    `);
    
    // Get the last inserted queue ID
    int|string? lastInsertId = insertResult.lastInsertId;

    // If insertion was successful, increment the occupied positions for the relevant service
    if lastInsertId is int {
        // Update occupied positions in the Services table
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE Services 
            SET occupied_positions = occupied_positions + 1 
            WHERE service_name = ${queue.service_name}
        `);

        // Check if the update was successful by inspecting affectedRowCount
        int? affectedRowCount = updateResult.affectedRowCount;

        if affectedRowCount is int && affectedRowCount > 0 {
            return lastInsertId; // Return the ID of the newly added queue
        } else {
            return error("Unable to update the occupied positions");
        }
    } else {
        return error("Unable to obtain last insert ID");
    }
}




isolated function getQueue(int id) returns Queue|error {
    Queue queue = check dbClient->queryRow(
        `SELECT * FROM Queues WHERE queue_id = ${id}`
    );
    return queue;
}

isolated function getAllQueues() returns Queue[]|error {
    Queue[] queues = [];
    stream<Queue, error?> resultStream = dbClient->query(
        `SELECT * FROM Queues`
    );
    check from Queue queue in resultStream
        do {
            queues.push(queue);
        };
    check resultStream.close();
    return queues;
}

isolated function updateQueue(Queue queue) returns int|error {
    time:Utc parsedQueueTime = check time:utcFromString(queue.queue_time); // Convert string to time:Utc.
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE Queues SET
            service_name = ${queue.service_name},
            customer_name = ${queue.customer_name},
            queue_time = ${parsedQueueTime},
            position = ${queue.position},
            status = ${queue.status}
        WHERE queue_id = ${queue.queue_id}
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function removeQueue(int queueId) returns int|error {
    // Retrieve the queue information before deleting it to get its position and service name
    record {| string service_name; int position; |} queueRecord = check dbClient->queryRow(
        `SELECT service_name, position FROM Queues WHERE queue_id = ${queueId}`
    );
    
    string serviceName = queueRecord.service_name;
    int removedQueuePosition = queueRecord.position;

    // Remove the queue
    sql:ExecutionResult deleteResult = check dbClient->execute(`
        DELETE FROM Queues WHERE queue_id = ${queueId}
    `);

    int? affectedRowCount = deleteResult.affectedRowCount;
    if affectedRowCount is int && affectedRowCount > 0 {
        // After successfully removing the queue, decrement the positions of the relevant queues
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE Queues
            SET position = position - 1
            WHERE service_name = ${serviceName} AND position > ${removedQueuePosition}
        `);

        int? updateAffectedRows = updateResult.affectedRowCount;
        if updateAffectedRows is int {
            // Decrement the occupied positions in the Services table
            sql:ExecutionResult serviceUpdateResult = check dbClient->execute(`
                UPDATE Services
                SET occupied_positions = occupied_positions - 1
                WHERE service_name = ${serviceName}
            `);

            int? serviceAffectedRowCount = serviceUpdateResult.affectedRowCount;
            if serviceAffectedRowCount is int && serviceAffectedRowCount > 0 {
                return affectedRowCount; // Return the number of affected rows from the delete operation
            } else {
                return error("Unable to update the occupied positions of the service");
            }
        } else {
            return error("Unable to update the positions of other queues");
        }
    } else {
        return error("Unable to remove the queue");
    }
}
