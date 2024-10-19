import React, { useState } from "react";
import { Link } from "react-router-dom";

const Register = () => {
  const [customer, setCustomer] = useState({
    customer_name: "",
    customer_NIC: "",
    customer_address: "",
    customer_email: "",
    customer_phone: "",
    password: "",
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setCustomer((prevCustomer) => ({
      ...prevCustomer,
      [name]: value,
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Add registration logic here (e.g., send data to backend)
    console.log("Registering:", customer);
  };

  return (
    <div className="form-container">
      <h2>Register as Customer</h2>
      <form onSubmit={handleSubmit}>

        <div className="form-grid">
        <div className="form-group">
            {/* <label>First Name:</label> */}
            <input
              type="text"
              placeholder="First Name"
              name="customer_name"
              value={customer.customer_name}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            {/* <label>Last Name:</label> */}
            <input
              type="text"
              placeholder="Last Name"
              name="customer_name"
              value={customer.customer_name}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="form-group">
            {/* <label>Email:</label> */}
            <input
              type="email"
              placeholder="Email"
              name="customer_email"
              value={customer.customer_email}
              onChange={handleChange}
              required
            />
          </div>

        <div className="form-grid">
          <div className="form-group">
            {/* <label>Password:</label> */}
            <input
              type="password"
              placeholder="Password"
              name="password"
              value={customer.password}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            {/* <label>Confirm Password:</label> */}
            <input
              type="password"
              placeholder="Confirm Password"
              name="password"
              value={customer.password}
              onChange={handleChange}
              required
            />
          </div>
        </div>


        <div className="form-grid">
          <div className="form-group">
            {/* <label>NIC:</label> */}
            <input
              type="text"
              placeholder="NIC"
              name="customer_NIC"
              value={customer.customer_NIC}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            {/* <label>Phone:</label> */}
            <input
              type="text"
              placeholder="Phone"
              name="customer_phone"
              value={customer.customer_phone}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        
        <div className="form-single">
          <div className="form-group">
            {/* <label>Address:</label> */}
            <input
              placeholder="Address"
              type="text"
              name="customer_address"
              value={customer.customer_address}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <button type="submit">Register</button>
      </form>
      <p>
        Already have an account? <Link to="/login">Login</Link>
      </p>
    </div>
  );
};

export default Register;
