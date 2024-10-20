import ballerina/io;
import ballerina/regex;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // Bundles the driver to the project.

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new (
    host = HOST, user = USER, password = PASSWORD, port = PORT, database = "queue"
);

///////////////////////// Service Operations/////////////////////////

//Add a new service to the database

isolated function addService(Service queue_service) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Services (service_name, time_period,start_time,working_days, working_slots, capacity)
        VALUES (${queue_service.service_name}, ${queue_service.time_period}, ${queue_service.start_time}, ${queue_service.working_days}, ${queue_service.working_slots},
                ${queue_service.capacity})
    `);

    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

//Retrieve a service from the database
isolated function getService(int id) returns Service|error {
    Service queue_service = check dbClient->queryRow(
        `SELECT * FROM Services WHERE service_id = ${id}`
    );
    return queue_service;
}

//Retrieve all services from the database
isolated function getAllServices() returns Service[]|error {
    Service[] queue_services = [];
    stream<Service, error?> resultStream = dbClient->query(
        `SELECT * FROM Services`
    );
    check from Service queue_service in resultStream
        do {
            queue_services.push(queue_service);
        };
    check resultStream.close();
    return queue_services;
}

//Update a service in the database
isolated function updateService(Service queue_service) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE Services SET
            service_name = ${queue_service.service_name},
            time_slot = ${queue_service.time_period},
            start_time = ${queue_service.start_time},
            working_days = ${queue_service.working_days},
            working_slots = ${queue_service.working_slots},
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

//Remove a service from the database
isolated function removeService(int id) returns int|error {
    // Retrieve the service_name before deleting the service
    record {|int service_id;|} serviceRecord = check dbClient->queryRow(
        `SELECT service_id FROM Services WHERE service_id = ${id}`
    );

    int service_id = serviceRecord.service_id;

    // Remove the service
    sql:ExecutionResult serviceDeleteResult = check dbClient->execute(`
        DELETE FROM Services WHERE service_id = ${id}
    `);

    int? affectedRowCount = serviceDeleteResult.affectedRowCount;
    if affectedRowCount is int && affectedRowCount > 0 {
        // After successfully removing the service, remove all related queue entries
        sql:ExecutionResult queueDeleteResult = check dbClient->execute(`
            DELETE FROM QueueEntries WHERE service_id = ${service_id}
        `);

        int? queueAffectedRows = queueDeleteResult.affectedRowCount;
        if queueAffectedRows is int {
            return affectedRowCount; // Return the number of affected rows from the service delete operation
        } else {
            return error("Unable to delete related queue entries for the service");
        }
    } else {
        return error("Unable to remove the service");
    }
}

///////////////////////// Queue Entries Operations/////////////////////////

//Add a new queue entry to the database
isolated function addQueueEntry(int service_id, int customer_id) returns string|error {

    // Fetch the current number of occupied positions for the relevant service
    int occupiedPositions = check dbClient->queryRow(
        `SELECT occupied_positions FROM Services WHERE service_id = ${service_id}`
    );

    // The queue position is one more than the current occupied positions
    int newPosition = occupiedPositions + 1;

    string start_time = check dbClient->queryRow(
        `SELECT start_time FROM Services WHERE service_id = ${service_id}`
    );

    int timePeriod = check dbClient->queryRow(
        `SELECT time_period FROM Services WHERE service_id = ${service_id}`
    );

    string workingDaysString = check dbClient->queryRow(
        `SELECT working_days FROM Services WHERE service_id = ${service_id}`
    );
    string[] workingDays = regex:split(workingDaysString, " ");

    string slot = check dbClient->queryRow(
        `SELECT working_slots FROM Services WHERE service_id = ${service_id}`
    );

    // Calculate the estimated time for the new queue entry
    string estimatedTime = check calculateEstimatedTime(newPosition, start_time, timePeriod, workingDays, slot);

    // Insert the new queue entry into the QueueEntries table with the updated position
    sql:ExecutionResult insertResult = check dbClient->execute(`
        INSERT INTO QueueEntries (service_id, customer_id, estimated_time, position)
        VALUES (${service_id}, ${customer_id}, ${estimatedTime}, 
                ${newPosition})
    `);

    // Get the last inserted queue entry ID
    int|string? lastInsertId = insertResult.lastInsertId;

    // If insertion was successful, increment the occupied positions for the relevant service
    if lastInsertId is int {
        // Update occupied positions in the Services table
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE Services 
            SET occupied_positions = occupied_positions + 1 
            WHERE service_id = ${service_id}
        `);

        // Check if the update was successful by inspecting affectedRowCount
        int? affectedRowCount = updateResult.affectedRowCount;

        if affectedRowCount is int && affectedRowCount > 0 {
            return "Position: " + newPosition.toString() + "\n" + "Estimated Time: " + estimatedTime; // Return the position of the queue
        } else {
            return error("Unable to update the occupied positions");
        }
    } else {
        return error("Unable to obtain last insert ID");
    }
}

//Retrieve a queue entry from the database
isolated function getQueueEntry(int id) returns QueueEntries|error {
    QueueEntries queue = check dbClient->queryRow(
        `SELECT * FROM QueueEntries WHERE queue_entry_id = ${id}`
    );
    return queue;
}

//Retrieve all queue entries from the database
isolated function getAllQueueEntries() returns QueueEntries[]|error {
    QueueEntries[] queues = [];
    stream<QueueEntries, error?> resultStream = dbClient->query(
        `SELECT * FROM QueueEntries`
    );
    check from QueueEntries queue in resultStream
        do {
            queues.push(queue);
        };
    check resultStream.close();
    return queues;
}

//Retrieve  queue entries that are related to a paticular service

isolated function getServiceQueueEntries(int service_id) returns QueueEntries[]|error {
    QueueEntries[] queues = [];
    stream<QueueEntries, error?> resultStream = dbClient->query(
        `SELECT * FROM QueueEntries WHERE service_id = ${service_id}`
    );
    check from QueueEntries queue in resultStream
        do {
            queues.push(queue);
        };
    check resultStream.close();
    return queues;
}

//Update a queue entry in the database
isolated function updateQueueEntry(QueueEntries queue) returns int|error {
    time:Utc parsedQueueTime = check time:utcFromString(queue.estimated_time); // Convert string to time:Utc.
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE QueueEntries SET
            service_id = ${queue.service_id},
            customer_id = ${queue.customer_id},
            estimated_time = ${parsedQueueTime},
            position = ${queue.position},
        WHERE queue_entry_id = ${queue.queue_entry_id}
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

//Remove a queue entry from the database
isolated function removeQueueEntry(int queueId) returns int|error {
    // Retrieve the queue information before deleting it to get its position and service name
    record {|int service_id; int position;|} queueRecord = check dbClient->queryRow(
        `SELECT service_id, position FROM QueueEntries WHERE queue_entry_id = ${queueId}`
    );

    int service_id = queueRecord.service_id;
    int removedQueuePosition = queueRecord.position;

    // Remove the queue entry
    sql:ExecutionResult deleteResult = check dbClient->execute(`
        DELETE FROM QueueEntries WHERE queue_entry_id = ${queueId}
    `);

    int? affectedRowCount = deleteResult.affectedRowCount;
    if affectedRowCount is int && affectedRowCount > 0 {
        // After successfully removing the queue entry, decrement the positions of the relevant queue entries
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE QueueEntries
            SET position = position - 1
            WHERE service_id = ${service_id} AND position > ${removedQueuePosition}
        `);

        int? updateAffectedRows = updateResult.affectedRowCount;
        if updateAffectedRows is int {
            // Fetch updated queue entries that have been affected (i.e., their positions were decremented)
            QueueEntries[] updatedEntries = check getServiceQueueEntries(service_id);

            // Recalculate estimated time for each queue entry
            foreach QueueEntries queueEntry in updatedEntries {
                if queueEntry.position >= removedQueuePosition {
                    string start_time = check dbClient->queryRow(`
                        SELECT start_time FROM Services WHERE service_id = ${service_id}
                    `);

                    int timePeriod = check dbClient->queryRow(`
                        SELECT time_period FROM Services WHERE service_id = ${service_id}
                    `);

                    string workingDaysString = check dbClient->queryRow(`
                        SELECT working_days FROM Services WHERE service_id = ${service_id}
                    `);
                    string[] workingDays = regex:split(workingDaysString, " ");

                    string slot = check dbClient->queryRow(`
                        SELECT working_slots FROM Services WHERE service_id = ${service_id}
                    `);

                    // Calculate new estimated time
                    string newEstimatedTime = check calculateEstimatedTime(queueEntry.position, start_time, timePeriod, workingDays, slot);

                    // Update the estimated time in the database
                    sql:ExecutionResult estimateUpdateResult = check dbClient->execute(`
                        UPDATE QueueEntries
                        SET estimated_time = ${newEstimatedTime}
                        WHERE queue_entry_id = ${queueEntry.queue_entry_id}
                    `);

                    io:println(estimateUpdateResult);
                }

            }

            // Decrement the occupied positions in the Services table
            sql:ExecutionResult serviceUpdateResult = check dbClient->execute(`
                UPDATE Services
                SET occupied_positions = occupied_positions - 1
                WHERE service_id = ${service_id}
            `);

            int? serviceAffectedRowCount = serviceUpdateResult.affectedRowCount;
            if serviceAffectedRowCount is int && serviceAffectedRowCount > 0 {
                return affectedRowCount; // Return the number of affected rows from the delete operation
            } else {
                return error("Unable to update the occupied positions of the service");
            }
        } else {
            return error("Unable to update the positions of other queue entries");
        }
    } else {
        return error("Unable to remove the queue entry");
    }
}
