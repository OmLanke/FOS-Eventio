require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use("/auth", require("./routes/auth"));
app.use("/events", require("./routes/events"));

app.get("/", (req, res) => {
  res.send("Server is running!");
});

app.listen(PORT, () =>
  console.log(`Server running at http://localhost:${PORT}`),
);
