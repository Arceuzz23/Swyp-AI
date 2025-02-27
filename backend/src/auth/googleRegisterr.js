const APIError = require("../apiError");
const APIResponse = require("../apiResponse");
const User = require("../models/usermodel");
const { generateAccessAndRefreshTokens } = require("./LoginUser");

const googleRegister = async (req, res) => {
    const googleId = req.body.googleId;
    const username = req.body.username;
    const password = req.body.password;
    
    if (!googleId || !username) {
        return res.status(400).json(new APIError(400, null, "Google ID and email are required"));
    }

    const existedUser = await User.findOne({ username });
    // If the user already exists, just generate tokens and respond
    if (existedUser) {
        return res.status(400).json(new APIError(400, null, "User already exists"));
    }

    try {
        const registeredUser = await new User({
            username: username,
            password: password,
            googleId: googleId
        }).save();

        // Generate and respond
        const { accessToken, refreshToken } = await generateAccessAndRefreshTokens(registeredUser._id);
        
        return res
            .status(200)
            .json(new APIResponse(200, {
                user: registeredUser,
                accessToken,
                refreshToken
            }, "User created and logged in successfully"));

    } catch (error) {
        return res.status(500).json(new APIError(500, null, "Error: " + error.message));
    }
};

module.exports = googleRegister;