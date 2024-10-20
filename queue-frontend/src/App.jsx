import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Login from "./components/Login";
import Register from "./components/Register";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Home from "./components/Home";
import AdminHome from "./components/AdminHome";
import ManageQueues from "./components/ManageQueues";
import QueueDetails from "./components/QueueDetails";

const App = () => {
  return (
    <Router>
      <div>
        <Routes>
          <Route path="/home" element={<Home />} /> 
          <Route path="/adminhome" element={<AdminHome />} /> 
          <Route path="/header" element={<Header />} /> 
          <Route path="/footer" element={<Footer />} /> 
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/managequeues" element={<ManageQueues />} /> 
          <Route path="/queuedetails" element={<QueueDetails />} />
        </Routes>
      </div>
    </Router>
  );
};

export default App;
