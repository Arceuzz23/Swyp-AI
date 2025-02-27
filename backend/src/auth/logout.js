const APIError = require('../apiError');
const APIResponse = require('../apiResponse');
const User = require('../models/usermodel');

const logoutUser = async (req, res) => {
    const userID = req.body.userID;
    const user = await User.findById(userID);
    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }
    try {
        user.refreshToken = null;
        const updatedUser = await user.save();
        return res.status(200).json(new APIResponse(200, {
            user: updatedUser,
            
        }, "User logged out successfully"));
    } catch (error) {
        return res.status(500).json(new APIError(500, null, "Error logging out"));
    }
};

module.exports = logoutUser;