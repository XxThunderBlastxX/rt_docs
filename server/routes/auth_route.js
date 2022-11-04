const express = require('express');
const User = require("../models/user_model");
const jwt = require('jsonwebtoken');
const auth = require("../middlewares/auth_middleware");

const authRouter = express.Router();

authRouter.post('/api/signup', async (req, res) => {
    try {
        const {name, email, profile_pic} = req.body;
        
        let user = await User.findOne({email: email})
        
        if (!user) {
            user = new User({
                name: name,
                email: email,
                profile_pic: profile_pic
            });
            
            user = await user.save();
        }
        
        const token = jwt.sign({id: user._id}, "passwordKey")
        res.status(200).json({user, token});
    } catch (err) {
        res.status(500).json({"error": err.message});
        console.log(err);
    }
});

authRouter.get("/", auth, async (req, res) => {
    const user = await User.findById(req.user);
    res.json({user, token: req.token});
});

module.exports = authRouter;
