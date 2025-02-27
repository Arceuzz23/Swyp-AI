const APIError = require("../apiError");
const APIResponse = require("../apiResponse");
const User = require("../models/usermodel");
const jwt = require('jsonwebtoken');
const { generateAccessAndRefreshTokens } = require("../auth/LoginUser");


const deleteQuotes = async (req, res) => {
    const accessToken = req.body.accessToken;
    const refreshToken = req.body.refreshToken;
    const quote = req.body.quote;
    if(!accessToken || !refreshToken){
        return res.status(400).json(new APIError(400, null, "Access token and refresh token are required"));
    }
    const verifyRefeshToken = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    const verifyAccessToken = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET);
    if(!verifyRefeshToken){
        return res.status(403).json(new APIError(403, null, "Session expired!! Please login again"));
    }
    if(!verifyAccessToken){
        const user = await User.findById(verifyRefeshToken._id);
        if(!user){
            return res.status(404).json(new APIError(404, null, "User not found"));
        }
        const {accessToken, refreshToken} = await generateAccessAndRefreshTokens(user._id);
        const updatedUser = await User
        .findByIdAndUpdate(user._id, {
            $pull: {
                savedQuotes: quote
            }
        }, {new: true}).select("-password -refreshToken");
        if(!updatedUser){
            return res.status(500).json(new APIError(500, null, "Error deleting quote"));
        }
        return res.status(200).json(new APIResponse(200, {
            user : updatedUser,
            accessToken : accessToken,
            refreshToken : refreshToken
        }, "Quote deleted successfully"));
        
        
    }
    const user = await User.findById(verifyAccessToken._id);
    if(!user){
        return res.status(404).json(new APIError(404, null, "User not found"));
    }
    const updatedUser = await User
    .findByIdAndUpdate(user._id, {
        $pull: {
            savedQuotes: quote
        }
    }, {new: true}).select("-password -refreshToken");
    if(!updatedUser){
        return res.status(500).json(new APIError(500, null, "Error deleting quote"));
    }
    return res.status(200).json(new APIResponse(200, {
        user : updatedUser,
        accessToken : accessToken,
        refreshToken : refreshToken
    }, "Quote deleted successfully"));
    


}


module.exports = deleteQuotes;