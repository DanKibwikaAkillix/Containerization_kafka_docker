import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

mysql:Client dbClient = check new (
    host = "localhost",
    port = 3306,
    user = "root",
    password = "",
    database = "mentorlink"
);

// DeliveryRequest record
type DeliveryRequest record {|
    readonly string customerName;
    string pickupLocation;
    string deliveryLocation;
    string preferredTimeSlot;
    string shipmentType;
|};

service /standard on new http:Listener(8081) {
    // In-memory storage for delivery requests
    private final table<DeliveryRequest> key(customerName) requestsTable = table [];

    // Create a new delivery request
    resource function post request(@http:Payload DeliveryRequest payload) returns http:Created|http:BadRequest {
        payload.shipmentType = "standard";

        // Store the request in the in-memory table
        error? result = self.requestsTable.add(payload);
        if result is error {
            return <http:BadRequest>{body: "Failed to add request"};
        }

        return <http:Created>{body: "Standard delivery request received."};
    }

    // Get all delivery requests
    resource function get requests() returns DeliveryRequest[] {
        return self.requestsTable.toArray();
    }
}
