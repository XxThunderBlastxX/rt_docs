const express = require('express');
const User = require("../models/user_models");

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
        
        res.json(user);
    } catch (err) {
        console.log(err);
    }
});

module.exports = authRouter;