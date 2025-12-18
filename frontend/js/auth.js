const API = 'http://176.84.214.29:3000/api/auth';

async function handleLogin() {
  const res = await fetch(`${API}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: email.value,
      password: password.value
    })
  });

  const data = await res.json();

  if (data.token) {
    localStorage.setItem('token', data.token);
    msg.innerText = 'Login correcto';
  } else {
    msg.innerText = data.error;
  }
}

async function handleRegister() {
  const res = await fetch(`${API}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: username.value,
      email: email.value,
      password: password.value
    })
  });

  const data = await res.json();
  msg.innerText = data.message || data.error;
}
