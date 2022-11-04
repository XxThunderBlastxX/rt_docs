const express = require('express');
const mongoose = require('mongoose')
const authRouter = require("./routes/auth_route");
const cors = require('cors')
const documentRouter = require("./routes/document_route");
const http = require("http");
require('dotenv').config();
const Document = require("./models/document_model");

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
const server = http.createServer(app);
const io = require('socket.io')(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

io.on('connection', (socket) => {
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log('Socket joined: ' + documentId);
    });
    
    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    });
    
    socket.on('save', (data) => {
        saveData(data);
    });
});

const saveData = async (data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = document.save();
}
server.listen(PORT, "0.0.0.0", () => console.log(`Server Connected at port ${PORT}`));