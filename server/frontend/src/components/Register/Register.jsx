import React, { useState } from 'react';
import Header from '../Header/Header';
import '../Login/Login.css';

const Register = () => {
  const [form, setForm] = useState({
    userName: '', firstName: '', lastName: '', email: '', password: ''
  });
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const update = (key) => (event) => {
    setForm(previous => ({ ...previous, [key]: event.target.value }));
  };

  const register = async (event) => {
    event.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      const response = await fetch('/djangoapp/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const result = await response.json();
      if (!response.ok || result.status !== 'Registered') {
        setError(result.message || 'Registration was unsuccessful.');
      } else {
        window.location.href = '/login';
      }
    } catch (exception) {
      setError('Could not reach the registration server. Try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div>
      <Header />
      <main className="container" style={{ maxWidth: 600, paddingTop: 36 }}>
        <h1>Sign-up</h1>
        <p>Create your Best Cars account to review dealerships.</p>
        <form onSubmit={register} className="card p-4">
          <label htmlFor="username">Username</label>
          <input id="username" name="username" type="text" className="form-control mb-3"
            value={form.userName} onChange={update('userName')} required />
          <label htmlFor="firstName">First Name</label>
          <input id="firstName" name="firstName" type="text" className="form-control mb-3"
            value={form.firstName} onChange={update('firstName')} required />
          <label htmlFor="lastName">Last Name</label>
          <input id="lastName" name="lastName" type="text" className="form-control mb-3"
            value={form.lastName} onChange={update('lastName')} required />
          <label htmlFor="email">Email</label>
          <input id="email" name="email" type="email" className="form-control mb-3"
            value={form.email} onChange={update('email')} required />
          <label htmlFor="password">Password</label>
          <input id="password" name="password" type="password" className="form-control mb-3"
            value={form.password} onChange={update('password')} minLength={8} required />
          {error && <p role="alert" className="text-danger">{error}</p>}
          <button type="submit" className="btn btn-primary" disabled={submitting}>
            {submitting ? 'Creating account...' : 'Register'}
          </button>
        </form>
      </main>
    </div>
  );
};

export default Register;
