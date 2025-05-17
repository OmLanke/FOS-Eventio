const express = require("express");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const router = express.Router();

router.get("/councils", async (req, res) => {
  console.log("COUNCILS");
  const councils = await prisma.council.findMany({
    include: { events: true },
  });
  res.json(councils);
});

router.get("/event/", async (req, res) => {
  const userId = parseInt(req.query.userId);
  console.log("ALL /event/ userId-", userId);

  const events = await prisma.event.findMany({
    include: { council: true },
  });

  const tickets = await prisma.ticket.findMany({
    where: {
      userId: userId,
    },
  });
  events.forEach((event) => {
    event.ticket_collected = tickets.some(
      (ticket) => ticket.eventId === event.id,
    );
  });

  res.json(events);
});

router.get("/tickets/", async (req, res) => {
  const userId = parseInt(req.query.userId);
  console.log("ALL /tickets/ userId-", userId);

  const events = await prisma.event.findMany({
    include: { council: true },
  });

  const tickets = await prisma.ticket.findMany({
    where: {
      userId: userId,
    },
  });

  let eventsTickets = events.filter((event) =>
    tickets.some((ticket) => ticket.eventId === event.id),
  );

  eventsTickets.forEach((event) => {
    event.ticket_collected = tickets.some(
      (ticket) => ticket.eventId === event.id,
    );
  });

  res.json(eventsTickets);
});

router.post("/register", async (req, res) => {
  const { userId, eventId } = req.body;
  console.log("REGISTER - ", userId, eventId);
  try {
    const u = parseInt(userId);
    const e = parseInt(eventId);
    const ticket = await prisma.ticket.create({
      data: { userId: u, eventId: e },
    });
    res.status(201).json({ message: "Registered", ticketId: ticket.id });
    console.log("SUCCESSFULLY REGISTERED");
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ message: "Already registered" });
    }
    console.log(err);
    res.status(500).json({ message: "Internal error", error: err });
  }
});

module.exports = router;
