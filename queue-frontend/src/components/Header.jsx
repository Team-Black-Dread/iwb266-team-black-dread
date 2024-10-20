// src/components/Header.jsx
import React from 'react';
import './Header.css';

const Header = () => {
    return (
        <header className="header">
            <h1>Digital Queue Management System</h1>
            <nav>
                <ul>
                    <li><a href="/home">Home</a></li>
                    <li><a href="/home">About</a></li>
                    <li><a href="/home">Contact</a></li>
                </ul>
            </nav>
        </header>
    );
};

export default Header;
