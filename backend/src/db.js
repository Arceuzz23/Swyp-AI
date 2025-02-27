const mongoose = require('mongoose');


const connectDB = async () => {
    try {
        console.log(process.env.MONGODB_URI);
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Successfully connected to MongoDB ✅✅✅');
    } catch (error) {
        console.error('MongoDB connection FAIL');
        console.error(error);
        process.exit(1);
    }
};

module.exports = connectDB;


