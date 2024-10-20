// src/components/Home.jsx
import React from "react";
import { Link } from "react-router-dom";
import "./AdminHome.css";
import Header from "./Header";
import Footer from "./Footer";

// Open the modal
function openModal() {
  document.getElementById("joinQueueModal").style.display = "block";
}

// Close the modal
function closeModal() {
  document.getElementById("joinQueueModal").style.display = "none";
}

// Close the modal if the user clicks outside of it
window.onclick = function (event) {
  const modal = document.getElementById("joinQueueModal");
  if (event.target === modal) {
    modal.style.display = "none";
  }
};

const AdminHome = () => {
  return (
    <div className="home">
      <Header />

      <div className="empty"></div>

      <span class="spacer"></span>

      <h2>Welcome to the Queue Management System</h2>
      <p>Manage your queues efficiently and effectively.</p>

      <main class="content">
        <section class="hero">
          <h2>Simplify Queues, Save Time</h2>
          <p>
            Manage crowds effectively and improve service delivery. Make your
            service delivery more efficient and effective.
          </p>
          <div class="button-group">
            <button onClick={openModal}>Create Queue</button>
            <button onClick={goToManageQueues}>Manage Queues</button>
            {/* <button >Join Queue</button> */}
            {/* <button onClick="alert('Check Queue Status')">
              Check Queue Status
            </button> */}
          </div>
        </section>

        <hr />

        <h2>Platform Features</h2>
        <section class="features">
          <div class="feature-card">
            <h3>Create and Track Queues</h3>
            <p>Easily create and monitor queues for different services.</p>
          </div>
          <div class="feature-card">
            <h3>Real-Time Notifications</h3>
            <p>Receive updates about queue progress instantly.</p>
          </div>
          <div class="feature-card">
            <h3>Email & SMS Notifications</h3>
            <p>Stay notified with integration through SMS or email alerts.</p>
          </div>
        </section>
      </main>

      <span class="spacer"></span>

      <Footer />

      {/* <!-- Modal Window --> */}
      <div id="joinQueueModal" class="modal">
        <div class="modal-content">
          <span class="close" onClick={closeModal}>
            &times;
          </span>
          <h2>Add New Queue</h2>
          <form>
            {/* <label for="name">Service Name:</label> */}
            <input
              type="text"
              id="name"
              name="name"
              required
              className="model-input"
              placeholder="Service Name"
            />

            <div>
              <div>
                <label for="starttime">Start Time: </label>
                <input
                  type="time"
                  id="starttime"
                  name="starttime"
                  required
                  className="model-input"
                  placeholder="Start Time"
                />
              </div>

              <div>
                <label for="endtime">End Time: </label>
                <input
                  type="time"
                  id="endtime"
                  name="endtime"
                  required
                  className="model-input"
                  placeholder="End Time"
                />
              </div>
            </div>

            {/* time_period = endtime - starttime */}

            {/* <label for="workingdays">Select Working Days:</label> */}
            <select
              id="workingdays"
              name="workingdays"
              required
              className="service"
            >
              <option value="0">Select Working Days</option>
              <option value="weekdays">Weekdays</option>
              <option value="weekend">Weekend</option>
            </select>
            <br />
            <br />

            {/* <label for="capacity">Capacity: </label> */}
            <input
              type="number"
              id="capacity"
              name="capacity"
              required
              className="model-input"
              placeholder="Give Capacity"
            />

            <button type="submit">Add Queue</button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default AdminHome;


function goToManageQueues() {
    window.location.href = "/managequeues"; // Navigate to the home page
  }
