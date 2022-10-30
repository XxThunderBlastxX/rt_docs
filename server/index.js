const express = require('express');
const mongoose = require('mongoose')
const authRouter = require("./routes/auth_routes");

const PORT = process.env.PORT | 3000;
const MONGO_URI = "mongodb+srv://koustav:DRhk36qY4Xgn@microservicesfcc.i93ca.mongodb.net/rt-docs?authSource=admin&replicaSet=atlas-aeenjt-shard-0&w=majority&readPreference=primary&appname=MongoDB%20Compass&retryWrites=true&ssl=true";

mongoose.connect(MONGO_URI).then(() => {
    console.log("Connected to MongoDB!! ");
}).catch((err) => {
    console.log(err)
});

const app = express();

app.use(express.json());
app.use(authRouter);

app.listen(PORT, "0.0.0.0", () => console.log(`Server Connected at port ${PORT}`));