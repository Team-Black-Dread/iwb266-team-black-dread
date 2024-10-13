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

isolated function addQueue(Queue queue) returns int|error {
    time:Utc parsedQueueTime = check time:utcFromString(queue.queue_time); // Convert string to time:Utc.
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Queues (service_name, customer_name, queue_time, position, status)
        VALUES (${queue.service_name}, ${queue.customer_name}, ${parsedQueueTime}, 
                ${queue.position}, ${queue.status})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
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

isolated function removeQueue(int id) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`
        DELETE FROM Queues WHERE queue_id = ${id}
    `);
    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Unable to obtain the affected row count");
    }
}

