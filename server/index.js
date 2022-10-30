const express = require('express');
const mongoose = require('mongoose')
const authRouter = require("./routes/auth_routes");
const cors = require('cors')
require('dotenv').config();

const PORT = process.env.PORT | 3000;
const MONGO_URI = process.env.MONGO_URI;

// Connect to MongoDB
mongoose.connect(MONGO_URI).then(() => {
    console.log("Connected to MongoDB!! ");
}).catch((err) => {
    console.log(err)
});

// Express instance
const app = express();

app.use(cors());
app.use(express.json());
app.use(authRouter);

app.listen(PORT, "0.0.0.0", () => console.log(`Server Connected at port ${PORT}`));