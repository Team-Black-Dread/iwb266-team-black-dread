import { useEffect, useState } from "react";
import Header from "./Header";
import Footer from "./Footer";

const API_URL = "http://localhost:4000/customers";

function QueueDetails() {
  //   const [customers, setCustomers] = useState([]);

  return (
    <div style={{ padding: "20px" }}>
      <Header />

      <div>
        <div
          style={{
            width: "25%",
          }}
        >
          <button
            onClick={() => (window.location.href = "/managequeues")}
            style={{
              backgroundColor: "green",
              color: "white",
              border: "none",
              borderRadius: "5px",
              padding: "5px 10px",
              cursor: "pointer",
              marginBottom: "8px",
            }}
          >
            Back to Manage Queues
          </button>
        </div>

        <div
          style={{
            width: "75%",
            marginBottom: "10px",
          }}
        >
          <h2>Customer List for OPD 1 Queue</h2>
        </div>
      </div>

      <div style={{ width: "100%", maxWidth: "1200px", margin: "0 auto" }}>
        {/* {customers.map(customer => ( */}
        <div
          key={"customer.id"}
          style={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr auto", // Wider first column
            alignItems: "center",
            width: "100%",
            border: "1px solid #ddd",
            borderRadius: "5px",
            padding: "15px",
            marginBottom: "10px",
            boxSizing: "border-box",
            backgroundColor: "#fff", // Optional: cleaner look
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          }}
        >
          <div style={{ paddingRight: "10px" }}>{"customer.name"}</div>
          <div style={{ paddingRight: "10px", textAlign: "right" }}>
            {"customer.estimatedTime"}
          </div>
          <button
            onClick={() => handleDelete("customer.id")}
            style={{
              backgroundColor: "red",
              color: "white",
              border: "none",
              borderRadius: "5px",
              padding: "5px 10px",
              cursor: "pointer",
              marginBottom: "8px",
            }}
          >
            Delete Customer
          </button>
        </div>
        {/* ))} */}
      </div>

      <div style={{ width: "100%", maxWidth: "1200px", margin: "0 auto" }}>
        {/* {customers.map(customer => ( */}
        <div
          key={"customer.id"}
          style={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr auto", // Wider first column
            alignItems: "center",
            width: "100%",
            border: "1px solid #ddd",
            borderRadius: "5px",
            padding: "15px",
            marginBottom: "10px",
            boxSizing: "border-box",
            backgroundColor: "#fff", // Optional: cleaner look
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          }}
        >
          <div style={{ paddingRight: "10px" }}>{"customer.name"}</div>
          <div style={{ paddingRight: "10px", textAlign: "right" }}>
            {"customer.estimatedTime"}
          </div>
          <button
            onClick={() => handleDelete("customer.id")}
            style={{
              backgroundColor: "red",
              color: "white",
              border: "none",
              borderRadius: "5px",
              padding: "5px 10px",
              cursor: "pointer",
              marginBottom: "8px",
            }}
          >
            Delete Customer
          </button>
        </div>
        {/* ))} */}
      </div>

      <div style={{ width: "100%", maxWidth: "1200px", margin: "0 auto" }}>
        {/* {customers.map(customer => ( */}
        <div
          key={"customer.id"}
          style={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr auto", // Wider first column
            alignItems: "center",
            width: "100%",
            border: "1px solid #ddd",
            borderRadius: "5px",
            padding: "15px",
            marginBottom: "10px",
            boxSizing: "border-box",
            backgroundColor: "#fff", // Optional: cleaner look
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
          }}
        >
          <div style={{ paddingRight: "10px" }}>{"customer.name"}</div>
          <div style={{ paddingRight: "10px", textAlign: "right" }}>
            {"customer.estimatedTime"}
          </div>
          <button
            onClick={() => handleDelete("customer.id")}
            style={{
              backgroundColor: "red",
              color: "white",
              border: "none",
              borderRadius: "5px",
              padding: "5px 10px",
              cursor: "pointer",
              marginBottom: "8px",
            }}
          >
            Delete Customer
          </button>
        </div>
        {/* ))} */}
      </div>

      <Footer />
    </div>
  );
}

export default QueueDetails;
