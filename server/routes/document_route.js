const express = require('express');
const Document = require('../models/document_model');
const documentRouter = express.Router();
const auth = require('../middlewares/auth_middleware');

documentRouter.post('/doc/create', auth, async (req, res) => {
    try {
        const {createdAt} = req.body;
        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
            createdAt,
        });
        
        document = await document.save();
        res.json(document);
    } catch (err) {
        res.status(500).json({"error": err.message});
        console.log(err);
    }
});


documentRouter.get('/docs/me', auth, async (req, res) => {
    try {
        let docs = await Document.find({uid: req.user});
        res.json(docs);
        
    } catch (err) {
        res.status(500).json({"error": err.message});
        console.log(err);
    }
});
module.exports = documentRouter;