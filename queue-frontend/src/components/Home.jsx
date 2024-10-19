// src/components/Home.jsx
import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";
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

const Home = () => {
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
            Join virtual queues and get notified when it’s your turn. Manage
            crowds effectively and improve service delivery.
          </p>
          <div class="button-group">
            <button onClick="alert('Queue Created')">Create Queue</button>
            <button onClick={openModal}>Join Queue</button>
            <button onClick="alert('Check Queue Status')">
              Check Queue Status
            </button>
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
          <h2>Join Queue</h2>
          <form>
            <label for="name">Your Name:</label>
            <br />
            <input type="text" id="name" name="name" required className="model-input"/>
            <br />
            <br />

            <label for="service">Select Service:</label>
            <br />
            <select id="service" name="service" required className="service">
                <option value="0">Select</option>
              <option value="bank">Bank</option>
              <option value="hospital">Hospital</option>
              <option value="government">Government Office</option>
            </select>
            <br />
            <br />

            <button type="submit">Join Queue</button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Home;


