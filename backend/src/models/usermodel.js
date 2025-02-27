

const mongoose = require('mongoose');
const { Schema } = mongoose;
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongooseAggregatePaginate = require('mongoose-aggregate-paginate-v2');

const userSchema = new Schema(
    {
    
        username : {
            type: String,
            required: true,
            unique: true,
            trim: true,
            minlength: 2,
            maxlength: 50
        }, 
        password: {
            type: String,
            required: true,
            trim: true,
            minlength: 6,
            maxlength: 1024
        },
        generes : {
            type: Array,
            default: [],
        },
        savedQuotes : {
            type: Array,
            default: [],
        },
        refreshToken: {
            type: String,
            default: null
        },
        gender : {
            type: String,
            default: null,
            required: true
        },
        age : {
            type: Number,
            default: null,
            required: true
        },
        googleId : {
            type: String,
            default: null,

        },
        
    },
    {
        timestamps: true
    },
    

);

userSchema.plugin(mongooseAggregatePaginate);
userSchema.pre("save", async function (next) {
    const user = this;
    if(user.isModified("password")){
        user.password = await bcrypt.hash(user.password, 10);
    }
    next();
});

userSchema.methods.isPasswordCorrect = async function (password) {
    const user = this;
    return await bcrypt.compare(password, user.password);
}


userSchema.methods.generateAccessToken = function () {
    const user = this;
    return jwt.sign({
        _id : user._id,
        username: user.username

    },
    process.env.ACCESS_TOKEN_SECRET,
    {
        expiresIn: process.env.ACCESS_TOKEN_EXPIRY
    }

    )
    
}


userSchema.methods.generateRefreshToken = function () {
    const user = this;
    return jwt.sign({
        _id : user._id,
        username: user.username

    },
    process.env.REFRESH_TOKEN_SECRET,
    {
        expiresIn: process.env.REFRESH_TOKEN_EXPIRY
    }

    )
    
}


const User = mongoose.model('User', userSchema);

module.exports = User;