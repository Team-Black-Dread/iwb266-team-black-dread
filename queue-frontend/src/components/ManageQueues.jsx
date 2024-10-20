// src/components/Home.jsx
import React from "react";
import { Link } from "react-router-dom";
import "./ManageQueues.css";
import Header from "./Header";
import Footer from "./Footer";

const ManageQueues = () => {
  return (
    <div className="home">
      <Header />

      <div className="empty"></div>

      <span class="spacer"></span>

      <h2>Welcome to the Queue Management System</h2>
      <p>Manage your queues efficiently and effectively.</p>

      <main class="content">
        <section class="hero">
          <div class="button-group">
            {/* iterate over the queues using a for loop with db */}
            <button onClick={goToQueueDetails}>OPD 1 Queue</button>
            <button onClick="">OPD 2 Queue</button>
            <button onClick="">OPD 3 Queue</button>
            <button onClick="">OPD 4 Queue</button>
            <button onClick="">OPD 5 Queue</button>
            <button onClick="">OPD 6 Queue</button>
            {/* <button >Join Queue</button> */}
            {/* <button onClick="alert('Check Queue Status')">
              Check Queue Status
            </button> */}
          </div>
        </section>
      </main>

      <span class="spacer"></span>

      <Footer />
    </div>
  );
};

export default ManageQueues;


function goToQueueDetails() {
    window.location.href = "/queuedetails"; // Navigate to the the queue details with the id of the queue
  }
