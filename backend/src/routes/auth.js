const express = require("express");
const bcrypt = require("bcrypt");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const router = express.Router();

// Signup
router.post("/signup", async (req, res) => {
  const { email, password, name } = req.body;
  console.log("SIGNUP - ", email, password, name);
  if (!email || !password || !name)
    return res.status(400).json({ message: "Missing fields" });

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) return res.status(409).json({ message: "User already exists" });

  const hashed = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: { email, password: hashed, name },
  });

  res
    .status(200)
    .json({
      message: "User created",
      id: `${user.id}`,
      name: user.name,
      email: user.email,
    });
});

// Login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  console.log("LOGIN - ", email, password);
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return res.status(401).json({ message: "Invalid credentials" });

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(401).json({ message: "Invalid credentials" });

  res
    .status(200)
    .json({
      message: "Login successful",
      id: `${user.id}`,
      name: user.name,
      email: user.email,
    });
});

module.exports = router;
