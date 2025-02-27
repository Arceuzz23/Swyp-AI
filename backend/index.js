
const app = require('./src/app');
const connectDB = require('./src/db');
const cors = require('cors');
const express = require('express');
const cookieParser = require('cookie-parser');
require('dotenv').config();
const registerUser = require('./src/auth/RegisterUser');
const APIResponse = require('./src/apiResponse');
const APIError = require('./src/apiError');
const { loginUser } = require('./src/auth/LoginUser');
const addQuote = require('./src/manageQuotes/addQuote');
const deleteQuotes = require('./src/manageQuotes/deleteQuotes');
const User = require('./src/models/usermodel');
const addGenere = require('./src/manageGenere');
const logoutUser = require('./src/auth/logout');
const googleLogin = require('./src/auth/googleLogin');
const googleRegister = require('./src/auth/googleRegisterr');






app.use(cors());
app.use(express.json({limit: '16kb'}));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());



const PORT = process.env.PORT || 3001;

//Routes

app.get('/', (req, res) => {
    res.send('Hello World');
});
app.get('/test', (req, res) => {
    return res.json(new APIResponse(200, null, 'Test successful'));
});
app.post('/register',registerUser);
app.post('/login', loginUser);
app.post('/addQuote', addQuote);
app.post('/deleteQuote', deleteQuotes);
app.post('/addGenre', addGenere);
app.post('/logout', logoutUser);
app.post('/googlelogin', googleLogin)
app.post('/googleRegister', googleRegister);






//DB connection

connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
        console.log(`Server runnin on url: http://localhost:${PORT}`);
    });
}).catch((error) => {
    console.error('Error connecting to MongoDB:', error.message);
});