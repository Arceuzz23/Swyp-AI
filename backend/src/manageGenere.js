const APIError = require("./apiError");
const APIResponse = require("./apiResponse");
const User = require("./models/usermodel");


const addGenere = async (req, res) => {
    const genere = req.body.genere;
    const userID = req.body.userID;
    const user = await User.findById(userID);
    console.log(user);

    if (!user) {
        return res.status(404).json(new APIError(404, null, "User not found"));
    }
    if(genere.length === 0){
        return res.status(400).json(new APIError(400, null, "Genere is required"));
    }
    try {
        user.genere = genere;
        await user.save();
        return res.status(200).json(new APIResponse(200, user, "Genere added successfully"));
    } catch (error) {
        return res.status(500).json(new APIError(500, null, "Error adding genere"));
        
    }

}

module.exports = addGenere;